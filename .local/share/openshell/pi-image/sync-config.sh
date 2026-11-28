#!/usr/bin/env bash
# Copy the host pi config into the image build context, minus secrets and state.
#
# -L dereferences symlinks (AGENTS.md -> ../ai/AGENTS.md) so the target content
# lands in the image; the symlink on the host is left untouched.
#
# models-store.json is the catalog the peelzfreak extension restores from
# before any network refresh, so it is copied and its base URLs are rewritten
# to the loopback proxy. Without the rewrite the stored models point at the
# public LiteLLM host, which the sandbox policy does not allow.
set -euo pipefail

ctx=$(cd -- "$(dirname -- "$0")" && pwd)
pi_home=${PI_HOME:-$HOME/.config/pi}
proxy_base=${PEELZFREAK_PROXY_BASE:-http://host.openshell.internal:8787/v1}

mkdir -p "$ctx/user-config"

rsync -aL --delete --delete-excluded \
  --include='/AGENTS.md' \
  --include='/config.yml' \
  --include='/settings.json' \
  --include='/keybindings.json' \
  --include='/keybindings.yml' \
  --include='/mcp.json' \
  --include='/pi-caffeinate.json' \
  --include='/sticky-message.json' \
  --include='/models-store.json' \
  --include='/extensions/***' \
  --include='/npm/***' \
  --include='/git/***' \
  --exclude='*' \
  "$pi_home/" "$ctx/user-config/"

python3 - "$ctx/user-config/models-store.json" "$proxy_base" <<'PY'
import json
import sys

path, proxy_base = sys.argv[1], sys.argv[2]
try:
    with open(path) as handle:
        store = json.load(handle)
except FileNotFoundError:
    sys.exit(0)

for provider_id, provider in store.items():
    if provider_id != "peelzfreak":
        continue
    for model in provider.get("models", []):
        if isinstance(model, dict):
            model["baseUrl"] = proxy_base

with open(path, "w") as handle:
    json.dump(store, handle, indent=2)
    handle.write("\n")
PY
