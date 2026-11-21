/**
 * Make the next-message action fall through to the live feed.
 *
 * Pi's tui.altScreen.nextPrompt stops at the last message and does nothing
 * after it. This wraps the fullscreen alt-screen's scrollToPrompt so that a
 * forward step with no next message scrolls to the end and re-enables follow.
 */
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const WIDGET_KEY = "next-prompt-fallback";
// Mark the real renderer, not the stable `this.ui` proxy: pi swaps the proxy's
// target when the TUI mode changes, and a new AltScreen must be re-patched.
const PATCHED = "__nextPromptFallbackPatched" as const;

type ScrollViewLike = { scrollTop: number };
type AltScreenLike = {
  scrollToPrompt?: (direction: number) => void;
  scrollToBottom?: () => void;
  getPrimaryScrollView?: () => ScrollViewLike | undefined;
  __nextPromptFallbackPatched?: boolean;
};

export default function (pi: ExtensionAPI) {
  const install = (ctx: ExtensionContext) => {
    if (ctx.mode !== "tui") return;
    try {
      ctx.ui.setWidget(WIDGET_KEY, (tui) => {
        const alt = tui as unknown as AltScreenLike;
        if (typeof alt.scrollToPrompt === "function" && !alt[PATCHED]) {
          alt[PATCHED] = true;
          const original = alt.scrollToPrompt.bind(alt);
          alt.scrollToPrompt = (direction: number) => {
            const before = alt.getPrimaryScrollView?.()?.scrollTop;
            original(direction);
            const after = alt.getPrimaryScrollView?.()?.scrollTop;
            if (direction > 0 && before !== undefined && after === before) {
              alt.scrollToBottom?.();
            }
          };
        }
        return {
          render: () => [],
          invalidate() {},
        };
      });
    } catch {}
  };

  pi.on("session_start", async (_event, ctx) => install(ctx));
  pi.on("agent_start", async (_event, ctx) => install(ctx));
  pi.on("turn_start", async (_event, ctx) => install(ctx));
}
