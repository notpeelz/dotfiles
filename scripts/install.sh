#!/usr/bin/env zsh

apps=(zsh git vim tmux)

######

set -Eeuo pipefail
setopt ksh_arrays # for bash compatibility
zmodload zsh/mapfile

DIR="${0:A:h}"
DOTFILES_DIR="${DIR:h}"

. "$DIR/bash-getopt/getopt.sh"

GO_add_opt handle_opt_dry_run "dry-run" "" "Do not modify the filesystem; only show what would happen"

handle_opt_dry_run() {
  opt_dry_run=1
  return 0
}

required_commands=(git dirname basename realpath)

for cmd in "${required_commands[@]}"; do
  if ! type "$cmd" &>/dev/null; then
    echo "Missing command: $cmd"
    exit 1
  fi
done

git submodule init
git submodule update

STOW_LOCAL_IGNORE=".stow-local-ignore"
STOW_IGNORE_LIST=("$STOW_LOCAL_IGNORE" start.sh)

# XXX: unfortunately, the join expansion flag (j) doesn't work with ksh_arrays
join_by() {
  local d="${1-}" f="${2-}"
  if shift 2; then
    printf "%s" "$f" "${@/#/$d}"
  fi
}

link_exists() {
  local dst="$1"
  local src="$2"
  if [[ -f "$dst" || -h "$dst" ]] && [[ "$(readlink -f "$dst")" != "$src" ]]; then
    return 1
  fi
  return 0
}

declare -A dirs=()
declare -A links=()

add_package() {
  local target="$1"
  local app="$2"
  local app_dir="$DOTFILES_DIR/$app"

  if [[ ! -d "$app_dir" ]]; then
    echo "Package '$app' doesn't exist"
    return 1
  fi

  if [[ ! -d "$target" ]]; then
    echo "Target '$target' doesn't exist"
    return 1
  fi

  collect_files() {
    local dir="$(realpath --no-symlinks "$1")"
    local dir_rel="$(realpath --no-symlinks --relative-to="$DOTFILES_DIR" "$dir")"
    dirs+=("$dir" "$target/$dir_rel")

    local ignore_list=()
    local ignore_path="$dir/$STOW_LOCAL_IGNORE"
    if [[ -f "$ignore_path" ]]; then
      # echo "using local ignore from $dir"
      ignore_list+=("${(f)mapfile[$ignore_path]}")
    fi

    for file in "$dir"/*(D); do
      local file_rel="$(realpath --no-symlinks --relative-to="$DOTFILES_DIR" "$file")"
      local name="$(basename "$file")"

      if [[ "${#ignore_list[@]}" -gt 0 && "${ignore_list[(ie)$name]}" -eq 0 ]]; then
        # echo "ignoring file (ignore file): $file_rel"
        continue
      fi

      if [[ "${STOW_IGNORE_LIST[(ie)$name]}" -eq 0 ]]; then
        # echo "ignoring file (builtin): $file_rel"
        continue
      fi

      # XXX: we start a 1 because we want to skip the package folder,
      # NOT because of zsh arrays (1-indexed arrays)
      local parts=("${(s:/:)file_rel}")
      # echo "parts before: ${parts[@]}"
      for ((i = 1; i < ${#parts[@]}; i++)); do
        if [[ "${parts[$i]}" =~ "^dot-" ]]; then
          local name=".${parts[$i]#dot-}"
          # echo "renaming part: ${parts[$i]} -> $name"
          parts[$i]="$name"
        fi
      done
      # echo "parts after: ${parts[@]}"

      local dst="$target/$(join_by / "${parts[@]:1}")"

      if [[ -f "$file" ]]; then
        if link_exists "$dst" "$file"; then
          links+=("$dst" "")
        elif [[ -e "$dst" ]]; then
          echo "File already exists: $dst"
          echo "No files were changed"
          return 1
        else
          links+=("$file" "$dst")
        fi
      elif [[ -d "$file" ]]; then
        # echo "|-> $file"
        collect_files "$file"
      fi
    done
  }

  collect_files "$app_dir"
}

GO_parse "$@"

for app in "${apps[@]}"; do
  add_package "$HOME" "$app"
done

for k v in "${(kv)links[@]}"; do
  if [[ -z "$v" ]]; then
    echo "SKIPPING $k (already exists)"
  else
    echo "LINK $k => $v"

    if ! ((${opt_dry_run:-0})); then
      mkdir -p "$(dirname "$v")"
      ln -s "$k" "$v"
    fi
  fi
done

for dir dir_rel in "${(kv)dirs[@]}"; do
  if [[ -x "$dir/install.sh" ]]; then
    echo "EXEC $dir_rel/install.sh"
    "$dir/install.sh" "$dir"
  fi
done
