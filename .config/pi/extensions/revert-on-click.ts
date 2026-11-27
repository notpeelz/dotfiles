/**
 * Click a user message in the transcript to open a message menu.
 *
 * "Revert" stays in the current session and moves the branch back to before
 * that message. "Fork and revert" creates a new session instead. Neither
 * touches file state. Both restore the prompt into the editor.
 *
 * Pi has no extension hook for clicks on built-in user messages, so this
 * wraps the UserMessageComponent's child in a MouseRegion. That is an
 * internal detail of the interactive UI and may break on Pi upgrades.
 * Clicks only reach components in fullscreen TUI mode; `/revert` works in
 * any mode.
 */
import { MouseRegion, type Component } from "@earendil-works/pi-tui";
import {
	UserMessageComponent,
	type ExtensionAPI,
	type ExtensionCommandContext,
	type ExtensionContext,
} from "@earendil-works/pi-coding-agent";

const COMMAND = "revert";
const ACTION_REVERT = "Revert";
const ACTION_FORK = "Fork and revert";
const ACTIONS = [ACTION_REVERT, ACTION_FORK];
const GLOBAL_KEY = Symbol.for("pi.revert-on-click");
const MAX_PICKER_ENTRIES = 20;
const PREVIEW_WIDTH = 72;

interface BranchMessageEntry {
	id: string;
	type: string;
	message?: { role?: string; content?: unknown };
}

interface ClickRecord {
	entryId?: string;
	message?: unknown;
}

interface SharedState {
	api?: ExtensionAPI;
	ctx?: ExtensionContext;
	patched: boolean;
	pendingMessages: unknown[];
	records: WeakMap<object, ClickRecord>;
	byMessage: WeakMap<object, ClickRecord>;
	wrapped: WeakSet<object>;
}

const shared: SharedState = ((globalThis as unknown as Record<symbol, unknown>)[GLOBAL_KEY] ??= {
	patched: false,
	pendingMessages: [],
	records: new WeakMap(),
	byMessage: new WeakMap(),
	wrapped: new WeakSet(),
}) as unknown as SharedState;

function contentText(content: unknown): string {
	if (typeof content === "string") return content;
	if (!Array.isArray(content)) return "";
	return content
		.filter(
			(part): part is { type: "text"; text: string } =>
				!!part &&
				typeof part === "object" &&
				(part as { type?: unknown }).type === "text" &&
				typeof (part as { text?: unknown }).text === "string",
		)
		.map((part) => part.text)
		.join(" ");
}

function branchUserEntries(ctx: ExtensionContext): BranchMessageEntry[] {
	return (ctx.sessionManager.getBranch() as unknown as BranchMessageEntry[]).filter(
		(entry) => entry.type === "message" && entry.message?.role === "user",
	);
}

function findEntryForMessage(
	sessionManager: { getBranch(): readonly unknown[] },
	message: unknown,
): BranchMessageEntry | undefined {
	const branch = sessionManager.getBranch() as readonly BranchMessageEntry[];
	for (let index = branch.length - 1; index >= 0; index -= 1) {
		const entry = branch[index];
		if (entry?.type === "message" && entry.message === message) return entry;
	}
	return undefined;
}

function handleClick(component: { messageId?: string }, record: ClickRecord): void {
	const api = shared.api;
	const ctx = shared.ctx;
	if (!api || !ctx) return;

	if (!record.entryId && record.message) {
		const entry = findEntryForMessage(ctx.sessionManager, record.message);
		if (entry) record.entryId = entry.id;
	}

	const entryId = record.entryId ?? component.messageId;
	if (!entryId) {
		ctx.ui.notify("Revert: could not resolve this message", "warning");
		return;
	}

	api.sendUserMessage(`/${COMMAND} ${entryId}`, { expandPromptTemplates: true });
}

function installClickHandler(): void {
	if (shared.patched) return;

	const proto = UserMessageComponent.prototype as unknown as {
		render: (width: number) => readonly string[];
	} & Record<string, unknown>;
	const render = proto.render;
	if (typeof render !== "function") return;
	shared.patched = true;

	proto.render = function (
		this: { children?: Component[]; messageId?: string },
		width: number,
	) {
		const child = this.children?.[0];
		if (child && !shared.wrapped.has(child as object)) {
			let record = shared.records.get(this as object);
			if (!record) {
				record = { entryId: this.messageId };
				if (!this.messageId) {
					record.message = shared.pendingMessages.shift();
					if (record.message) shared.byMessage.set(record.message as object, record);
				}
				shared.records.set(this as object, record);
			}

			const resolved = record;
			const region = new MouseRegion(child, (event) => {
				if (event.type !== "click" || event.button !== "left") return undefined;
				handleClick(this as { messageId?: string }, resolved);
				return { handled: true };
			});
			shared.wrapped.add(region as object);
			this.children![0] = region;
		}

		return render.call(this, width);
	};
}

function buildPickerChoices(ctx: ExtensionContext): Array<{ entryId: string; label: string }> {
	return branchUserEntries(ctx)
		.slice(-MAX_PICKER_ENTRIES)
		.reverse()
		.map((entry, index) => {
			const text = contentText(entry.message?.content).replace(/\s+/g, " ").trim();
			const preview =
				text.length > PREVIEW_WIDTH ? `${text.slice(0, PREVIEW_WIDTH - 1)}…` : text;
			return {
				entryId: entry.id,
				label: `${index + 1}. ${preview || "(empty message)"}`,
			};
		});
}

async function runRevert(
	pi: ExtensionAPI,
	args: string,
	ctx: ExtensionCommandContext,
): Promise<void> {
	if (ctx.mode !== "tui") {
		ctx.ui.notify("Revert requires interactive mode", "error");
		return;
	}

	let entryId = args.trim();

	if (!entryId) {
		const choices = buildPickerChoices(ctx);
		if (choices.length === 0) {
			ctx.ui.notify("No user messages to revert to", "info");
			return;
		}
		const choice = await ctx.ui.select(
			"Revert to message",
			choices.map((item) => item.label),
		);
		if (choice === undefined) return;
		entryId = choices.find((item) => item.label === choice)?.entryId ?? "";
	}

	const entry = branchUserEntries(ctx).find((item) => item.id === entryId);
	if (!entry) {
		ctx.ui.notify("Revert: that is not a user message on the active branch", "error");
		return;
	}

	if (!ctx.isIdle()) {
		ctx.ui.notify("Revert: wait for the current response to finish", "warning");
		return;
	}

	const choice = await ctx.ui.select("Message actions", ACTIONS);
	if (choice !== ACTION_REVERT && choice !== ACTION_FORK) return;

	try {
		if (choice === ACTION_FORK) {
			// Keep pi-rewind-hook's restore menu out of this fork when it is loaded.
			pi.events.emit("rewind:fork-preference", {
				mode: "conversation-only",
				source: "fork-from-first",
			});
			const result = await ctx.fork(entryId, { position: "before" });
			if (result.cancelled) ctx.ui.notify("Revert cancelled", "info");
			return;
		}

		// navigateTree() treats a user message target as "go to its parent and
		// put the prompt in the editor", all within the current session.
		const result = await ctx.navigateTree(entryId, { summarize: false });
		if (result.cancelled) ctx.ui.notify("Revert cancelled", "info");
	} catch (error) {
		ctx.ui.notify(
			`Revert failed: ${error instanceof Error ? error.message : String(error)}`,
			"error",
		);
	}
}

export default function revertOnClick(pi: ExtensionAPI): void {
	shared.api = pi;
	installClickHandler();

	pi.registerCommand(COMMAND, {
		description: "Revert the conversation to a user message",
		handler: (args, ctx) => runRevert(pi, args, ctx),
	});

	pi.on("session_start", async (_event, ctx) => {
		shared.ctx = ctx;
		shared.pendingMessages.length = 0;
	});

	pi.on("session_tree", async (_event, ctx) => {
		shared.ctx = ctx;
		shared.pendingMessages.length = 0;
	});

	pi.on("session_compact", async (_event, ctx) => {
		shared.ctx = ctx;
		shared.pendingMessages.length = 0;
	});

	pi.on("message_start", async (event, ctx) => {
		shared.ctx = ctx;
		if (ctx.mode !== "tui") return;
		if (event.message.role === "user") shared.pendingMessages.push(event.message);
	});

	pi.on("message_end", (event, ctx) => {
		if (ctx.mode !== "tui") return;
		if (event.message.role !== "user") return;

		// The user entry is appended only after this event handler returns, so
		// resolve the id on a later tick instead of awaiting here.
		const message = event.message;
		const sessionManager = ctx.sessionManager;
		setTimeout(() => {
			const entry = findEntryForMessage(sessionManager, message);
			if (!entry) return;
			const record = shared.byMessage.get(message as object);
			if (record) record.entryId = entry.id;
		}, 0);
	});

	pi.on("session_shutdown", async () => {
		if (shared.api !== pi) return;
		shared.ctx = undefined;
		shared.pendingMessages.length = 0;
	});
}
