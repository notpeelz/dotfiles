#!/usr/bin/env bash

set -Eeuo pipefail

DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" >/dev/null 2>&1 && pwd)"
cd "$DIR/.."

. "$DIR/bash-getopt/getopt.sh"

GO_add_opt handle_opt_dry_run "dry-run" "" "Do not modify the filesystem; only show what would happen"

handle_opt_dry_run() {
  opt_dry_run=1
  return 0
}

required_commands=(stow git)

for cmd in "${required_commands[@]}"; do
  if ! type "$cmd" &>/dev/null; then
    echo "Missing command: $cmd"
    exit 1
  fi
done

git submodule init
git submodule update

stowit() {
  local target="$1"
  local app="$2"
  # XXX: the no-folding option prevents stow from symlinking directories.
  # This is desirable in case the system already has, e.g. a `.ssh` folder.
  # If the `.ssh` folder gets symlinked, all new files created inside would
  # show up as "untracked" in git.
  stow -v ${opt_dry_run:+--no} --no-folding -t "$target" "$app"
  if [[ -x "$app/install.sh" ]]; then
    "$app/install.sh"
  fi
}

GO_parse "$@"

apps=(systemd ssh zsh git vim tmux)

for app in "${apps[@]}"; do
  stowit "$HOME" "$app"
done
