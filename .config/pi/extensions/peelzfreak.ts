/**
 * Peelzfreak gateway provider for Pi.
 *
 * Models are discovered from the gateway itself:
 *   GET {PEELZFREAK_BASE_URL}/models        OpenAI-standard model listing
 *   GET {PEELZFREAK_BASE_URL}/model/info    LiteLLM deployment metadata
 *
 * No model list is stored in this file or in models.json. The gateway stays
 * the source of truth, and models added or removed there show up on the next
 * Pi model refresh.
 *
 * Defaults target the Peelzfreak LiteLLM gateway:
 *   provider id:   peelzfreak
 *   display name:  peelzfreak
 *   base URL:      https://litellm.crank.peelzfreak.com/v1
 *
 * Environment overrides:
 *   PEELZFREAK_BASE_URL       gateway API root (default above)
 *   PEELZFREAK_PROVIDER_ID    provider id (default "peelzfreak")
 *   PEELZFREAK_PROVIDER_NAME  display name (default "peelzfreak")
 *   PEELZFREAK_API_KEY        API key
 *
 * Without a key in the environment, the provider is still registered so
 * `/login peelzfreak` works and the key is stored in auth.json.
 *
 * `/peelzfreak-refresh` forces a fresh discovery.
 */
import { readFileSync } from "node:fs";
import { join } from "node:path";
import {
  getAgentDir,
  type ExtensionAPI,
} from "@earendil-works/pi-coding-agent";

type Json = Record<string, any>;

const DEFAULT_BASE_URL = "https://litellm.crank.peelzfreak.com/v1";
const DEFAULT_PROVIDER_ID = "peelzfreak";
const DEFAULT_PROVIDER_NAME = "peelzfreak";
const KEY_ENV = "PEELZFREAK_API_KEY";

const REQUEST_TIMEOUT_MS = 15_000;
const CHAT_MODES = new Set(["chat", "responses"]);
// LiteLLM returns these virtual ids when a key/team grant means "everything".
// They are not callable models; /model/info lists the actual deployments.
const SPECIAL_MODEL_IDS = new Set([
  "all-proxy-models",
  "all-team-models",
  "no-default-models",
]);

function configuredBaseUrl(): string {
  const raw = (process.env.PEELZFREAK_BASE_URL ?? DEFAULT_BASE_URL).trim();
  return (raw || DEFAULT_BASE_URL).replace(/\/+$/, "");
}

function providerId(): string {
  return process.env.PEELZFREAK_PROVIDER_ID?.trim() || DEFAULT_PROVIDER_ID;
}

function providerName(): string {
  return process.env.PEELZFREAK_PROVIDER_NAME?.trim() || DEFAULT_PROVIDER_NAME;
}

function envApiKey(): string | undefined {
  const value = process.env[KEY_ENV];
  return typeof value === "string" && value.trim() ? value : undefined;
}

function apiKeyEnvName(): string | undefined {
  return envApiKey() ? KEY_ENV : undefined;
}

/** Read the key saved by /login so --list-models works without env vars. */
function storedApiKey(providerId: string): string | undefined {
  try {
    const data = JSON.parse(
      readFileSync(join(getAgentDir(), "auth.json"), "utf8"),
    ) as Json;
    const entry = data?.[providerId];
    return entry &&
      typeof entry === "object" &&
      entry.type === "api_key" &&
      typeof entry.key === "string"
      ? entry.key
      : undefined;
  } catch {
    return undefined;
  }
}

function modelsUrl(baseUrl: string): string {
  const root = baseUrl.replace(/\/+$/, "");
  return root.endsWith("/v1") ? `${root}/models` : `${root}/v1/models`;
}

function modelInfoUrl(baseUrl: string): string {
  const root = baseUrl.replace(/\/+$/, "");
  return root.endsWith("/v1") ? `${root}/model/info` : `${root}/v1/model/info`;
}

async function getJson(
  url: string,
  apiKey: string | undefined,
  signal?: AbortSignal,
): Promise<Json> {
  const timeout = AbortSignal.timeout(REQUEST_TIMEOUT_MS);
  const combined = signal ? AbortSignal.any([signal, timeout]) : timeout;
  const response = await fetch(url, {
    signal: combined,
    headers: {
      accept: "application/json",
      ...(apiKey ? { authorization: `Bearer ${apiKey}` } : {}),
      "user-agent": "pi-peelzfreak/1.0",
    },
  });
  if (!response.ok) throw new Error(`${url}: HTTP ${response.status}`);
  return (await response.json()) as Json;
}

function positiveNumber(value: unknown): number | undefined {
  return typeof value === "number" && Number.isFinite(value) && value > 0
    ? value
    : undefined;
}

function perMillion(value: unknown): number {
  if (typeof value !== "number" || !Number.isFinite(value)) return 0;
  return Number((value * 1_000_000).toFixed(6));
}

function modelInfoMap(entries: Json[]): Map<string, Json> {
  const map = new Map<string, Json>();
  for (const entry of entries) {
    if (!entry || typeof entry !== "object") continue;
    const id =
      typeof entry.model_name === "string"
        ? entry.model_name
        : typeof entry.model_info?.id === "string"
          ? entry.model_info.id
          : undefined;
    if (id) map.set(id, entry);
  }
  return map;
}

function thinkingLevelMap(modelInfo: Json): Json | undefined {
  const map: Json = {};
  let present = false;

  const levels = Array.isArray(modelInfo.reasoning_effort_levels)
    ? (modelInfo.reasoning_effort_levels as unknown[]).filter(
        (level): level is string => typeof level === "string",
      )
    : undefined;

  if (levels) {
    const allowed = new Set(levels);
    for (const level of ["minimal", "low", "medium", "high", "xhigh", "max"]) {
      map[level] = allowed.has(level) ? level : null;
    }
    map.off = allowed.has("none") ? "none" : allowed.has("off") ? "off" : null;
    return map;
  }

  const set = (
    piLevel: string,
    supported: unknown,
    providerValue: string,
  ): void => {
    if (supported === true) {
      map[piLevel] = providerValue;
      present = true;
    } else if (supported === false) {
      map[piLevel] = null;
      present = true;
    }
  };

  set("off", modelInfo.supports_none_reasoning_effort, "none");
  set("minimal", modelInfo.supports_minimal_reasoning_effort, "minimal");
  set("low", modelInfo.supports_low_reasoning_effort, "low");
  set("medium", modelInfo.supports_medium_reasoning_effort, "medium");
  set("high", modelInfo.supports_high_reasoning_effort, "high");
  set("xhigh", modelInfo.supports_xhigh_reasoning_effort, "xhigh");
  set("max", modelInfo.supports_max_reasoning_effort, "max");
  if (modelInfo.thinking_always_on === true) {
    map.off = null;
    present = true;
  }

  return present ? map : undefined;
}

function toPiModel(row: Json, info: Json | undefined): Json | undefined {
  const modelInfo = info?.model_info ?? {};
  const rawMode = row.mode ?? modelInfo.mode;
  // LiteLLM emits "mode": null for legacy rows that omit it. Treat null like
  // absent instead of skipping the model.
  const mode =
    typeof rawMode === "string" && rawMode.length > 0 ? rawMode : undefined;
  if (mode !== undefined && !CHAT_MODES.has(mode)) return undefined;

  const id = row.id ?? info?.model_name;
  if (typeof id !== "string" || !id) return undefined;

  const contextWindow =
    positiveNumber(row.max_input_tokens) ??
    positiveNumber(modelInfo.max_input_tokens) ??
    128000;
  const maxTokens =
    positiveNumber(row.max_output_tokens) ??
    positiveNumber(modelInfo.max_output_tokens) ??
    16384;
  const supportsVision =
    modelInfo.supports_vision === true || row.supports_vision === true;
  const levelMap = thinkingLevelMap(modelInfo);
  const supportsReasoning =
    modelInfo.supports_reasoning === true ||
    row.supports_reasoning === true ||
    (levelMap !== undefined &&
      Object.values(levelMap).some((value) => typeof value === "string"));

  return {
    id,
    name: typeof row.name === "string" ? row.name : id,
    reasoning: supportsReasoning,
    ...(levelMap ? { thinkingLevelMap: levelMap } : {}),
    input: supportsVision ? ["text", "image"] : ["text"],
    cost: {
      input: perMillion(modelInfo.input_cost_per_token),
      output: perMillion(modelInfo.output_cost_per_token),
      cacheRead: perMillion(modelInfo.cache_read_input_token_cost),
      cacheWrite: perMillion(modelInfo.cache_creation_input_token_cost),
    },
    contextWindow,
    maxTokens,
  };
}

function infoRow(entry: Json): Json | undefined {
  const id = typeof entry.model_name === "string" ? entry.model_name : undefined;
  if (!id) return undefined;
  return {
    id,
    mode: entry.model_info?.mode,
    max_input_tokens: entry.model_info?.max_input_tokens,
    max_output_tokens: entry.model_info?.max_output_tokens,
  };
}

async function discoverModels(
  baseUrl: string,
  apiKey: string | undefined,
  signal?: AbortSignal,
): Promise<Json[]> {
  const [modelsResult, infoResult] = await Promise.allSettled([
    getJson(modelsUrl(baseUrl), apiKey, signal),
    getJson(modelInfoUrl(baseUrl), apiKey, signal),
  ]);

  const listing =
    modelsResult.status === "fulfilled" && Array.isArray(modelsResult.value.data)
      ? (modelsResult.value.data as Json[])
      : undefined;
  const info =
    infoResult.status === "fulfilled" && Array.isArray(infoResult.value.data)
      ? (infoResult.value.data as Json[])
      : undefined;

  const infoById = info ? modelInfoMap(info) : new Map<string, Json>();
  const listingRows = (listing ?? []).filter(
    (row): row is Json =>
      !!row &&
      typeof row === "object" &&
      typeof row.id === "string" &&
      !SPECIAL_MODEL_IDS.has(row.id),
  );
  const listingById = new Map(listingRows.map((row) => [row.id, row]));
  const infoEntries = (info ?? [])
    .map(infoRow)
    .filter(
      (row): row is Json =>
        !!row && typeof row.id === "string" && !SPECIAL_MODEL_IDS.has(row.id),
    );

  // /model/info lists real deployments even when /v1/models collapses a key's
  // grant to the all-proxy-models/all-team-models sentinel, so use the union.
  const ids = new Set<string>([
    ...infoEntries.map((row) => row.id),
    ...listingRows.map((row) => row.id),
  ]);

  if (ids.size === 0) {
    const sawSentinel = (listing ?? []).some(
      (row) => typeof row?.id === "string" && SPECIAL_MODEL_IDS.has(row.id),
    );
    const failure =
      modelsResult.status === "rejected"
        ? modelsResult.reason
        : infoResult.status === "rejected"
          ? infoResult.reason
          : undefined;
    throw new Error(
      sawSentinel
        ? "LiteLLM returned only sentinel model ids (all-proxy-models/all-team-models), and /model/info did not expose the deployments."
        : failure instanceof Error
          ? failure.message
          : "No chat models returned by /v1/models or /model/info",
    );
  }

  const models: Json[] = [];
  for (const id of ids) {
    const infoEntry = infoById.get(id);
    const listingRow = listingById.get(id) ?? {};
    const row: Json = {
      ...listingRow,
      id,
      mode: listingRow.mode ?? infoEntry?.model_info?.mode,
      max_input_tokens:
        listingRow.max_input_tokens ?? infoEntry?.model_info?.max_input_tokens,
      max_output_tokens:
        listingRow.max_output_tokens ?? infoEntry?.model_info?.max_output_tokens,
    };
    const model = toPiModel(row, infoEntry);
    if (model) models.push(model);
  }
  return models;
}

function asProviderModels(
  providerId: string,
  baseUrl: string,
  models: Json[],
): Json[] {
  return models.map((model) => ({
    ...model,
    provider: providerId,
    api: "openai-completions",
    baseUrl,
  }));
}

function apiKeyFromCredential(credential: unknown): string | undefined {
  if (
    credential &&
    typeof credential === "object" &&
    (credential as Json).type === "api_key" &&
    typeof (credential as Json).key === "string"
  ) {
    return (credential as Json).key;
  }
  return undefined;
}

export default async function (pi: ExtensionAPI) {
  const id = providerId();
  const name = providerName();
  const baseUrl = configuredBaseUrl();
  const keyEnv = apiKeyEnvName();

  let currentModels: Json[] = [];

  const providerConfig: Json = {
    name,
    baseUrl,
    api: "openai-completions",
    ...(keyEnv ? { apiKey: `$${keyEnv}` } : {}),
    models: currentModels,
    async refreshModels(context: Json) {
      const storedModels = Array.isArray(context.stored?.models)
        ? (context.stored.models as Json[]).filter(
            (model) =>
              !!model &&
              typeof model === "object" &&
              typeof model.id === "string" &&
              !SPECIAL_MODEL_IDS.has(model.id),
          )
        : [];

      // Restore Pi's persisted catalog when the process starts offline or in
      // print/RPC mode, before any network refresh runs.
      if (currentModels.length === 0 && storedModels.length > 0) {
        await context.publish({
          update: () => {
            currentModels = storedModels;
          },
        });
      }

      if (!context.allowNetwork) return currentModels;

      const apiKey =
        apiKeyFromCredential(context.credential) ??
        envApiKey() ??
        storedApiKey(id);
      if (!apiKey) return currentModels;

      const refreshed = asProviderModels(
        id,
        baseUrl,
        await discoverModels(
          typeof context.baseUrl === "string" ? context.baseUrl : baseUrl,
          apiKey,
          context.signal,
        ),
      );

      // Persist through Pi's ModelsStore so the built-in refresh/cache path
      // owns the catalog instead of this extension keeping a private cache.
      await context.publish({
        persist: { models: refreshed, checkedAt: Date.now() },
        update: () => {
          currentModels = refreshed;
        },
      });
      return currentModels;
    },
  };

  function register(models: Json[]): void {
    currentModels = models;
    pi.registerProvider(id, { ...providerConfig, models });
  }

  pi.registerCommand("peelzfreak-refresh", {
    description: "Refresh Peelzfreak models from the gateway",
    handler: async (_args, ctx) => {
      try {
        const auth = await ctx.modelRegistry.getProviderAuth(id);
        const apiKey =
          auth?.auth.apiKey ?? envApiKey() ?? storedApiKey(id);
        if (!apiKey) {
          ctx.ui.notify(
            `No API key for ${id}. Set PEELZFREAK_API_KEY or run /login ${id}.`,
            "error",
          );
          return;
        }
        // Use Pi's own refresh coordinator so this command exercises the same
        // refreshModels()/ModelsStore path as startup, /model and /login.
        const result = await ctx.modelRegistry.refresh({
          allowNetwork: true,
          providers: [id],
          force: true,
        });
        if (result.aborted) {
          ctx.ui.notify("Peelzfreak model refresh timed out.", "warning");
          return;
        }
        const refreshError = result.errors.get(id);
        if (refreshError) {
          ctx.ui.notify(
            `Peelzfreak model refresh failed: ${refreshError.message}`,
            "error",
          );
          return;
        }
        const count = ctx.modelRegistry.getModelsOfType("chat", id).length;
        ctx.ui.notify(
          `Refreshed ${count} model(s) from ${modelsUrl(baseUrl)}`,
          "info",
        );
      } catch (error) {
        ctx.ui.notify(
          `Peelzfreak model refresh failed: ${
            error instanceof Error ? error.message : String(error)
          }`,
          "error",
        );
      }
    },
  });

  const startupKey = envApiKey() ?? storedApiKey(id);
  if (!startupKey) {
    register([]);
    return;
  }

  try {
    register(
      asProviderModels(id, baseUrl, await discoverModels(baseUrl, startupKey)),
    );
  } catch (error) {
    console.error(
      `[peelzfreak] ${error instanceof Error ? error.message : String(error)}`,
    );
    register([]);
  }
}
