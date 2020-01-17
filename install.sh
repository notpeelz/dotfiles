#!/usr/bin/env bash

set -Eeu

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd "$DIR"

git submodule init
git submodule update

base_apps=(sh term vim)
user_apps=(git)

function stowit() {
  local target="$1"
  local app="$2"
  stow -v ${opt_force:+--adopt} -t "${target}" "${app}"
  if [[ -x "${app}/install.sh" ]]; then
    "${app}/install.sh"
  fi
}

scriptfile="$(basename ${BASH_SOURCE[0]})"

function exit_with_help() {
  echo "Syntax: ${scriptfile} [-u|--user] [-f|--force]"
  exit 1
}

options="$(getopt -o u,f --long=user,force -- "$@")" || exit_with_help

eval set -- "$options"
while true; do
  # Check if "$1" is set 
  [[ ! "${1:+1}" -eq 1 ]] && break

  # Parameter list ends with "--"
  [[ "$1" == "--" ]] && { shift; break; }

  case "$1" in
    -u|--user) opt_user=1 ;;
    -f|--force) opt_force=1 ;;
  esac
  shift
done

for app in "${base_apps[@]}"; do
  stowit "${HOME}" "${app}"
done

if [[ "${opt_user:-}" -eq 1 ]]; then
  for app in ${user_apps[@]}; do
    stowit "${HOME}" "${app}"
  done
fi
