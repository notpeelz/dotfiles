#!/usr/bin/env bash

set -Eeu

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd "$DIR"

required_commands=(stow git)

for cmd in "${required_commands[@]}"; do
  if ! type "$cmd" &>/dev/null; then
    echo "Missing command: $cmd"
    exit 1
  fi
done

git submodule init
git submodule update

apps=(systemd ssh zsh git vim tmux)

function stowit() {
  local target="$1"
  local app="$2"
  stow -v ${opt_adopt:+--adopt} -t "$target" "$app"
  if [[ -x "$app/install.sh" ]]; then
    "$app/install.sh"
  fi
}

scriptfile="$(basename ${BASH_SOURCE[0]})"

function exit_with_help() {
  echo "Syntax: $scriptfile [--adopt]"
  exit 1
}

options="$(getopt -n "$scriptfile" -o='' --long=adopt -- "$@")" || exit_with_help

eval set -- "$options"
while true; do
  # Check if "$1" is set
  [[ "${1:+1}" -ne 1 ]] && break

  # Parameter list ends with "--"
  [[ "$1" == "--" ]] && { shift; break; }

  case "$1" in
    --adopt) opt_adopt=1 ;;
  esac
  shift
done

for app in "${apps[@]}"; do
  stowit "$HOME" "$app"
done
