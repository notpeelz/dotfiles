# vim:ft=zsh foldmethod=marker

mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/zsh"
mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/zsh"
mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zfunc"

# Source environment.d {{{
if [[ -z "${ENVIRONMENTD_SOURCED:-}" ]]; then
  set -a
  for gen in /usr/lib/systemd/user-environment-generators/*; do
    if command -v "$gen" &>/dev/null; then
      source <("$gen")
    fi
  done
  set +a
  export ENVIRONMENTD_SOURCED=zsh
fi
# }}}

# EDITOR {{{
if command -v nvim &>/dev/null; then
  export EDITOR=nvim
elif command -v vim &>/dev/null; then
  export EDITOR=vim
elif command -v nano &>/dev/null; then
  export EDITOR=nano
fi
# }}}

# mise {{{
if type mise &>/dev/null; then
  if [[ ! -e "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/mise" ]]; then
    mise activate > "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/mise"
  fi
  source "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/mise"
fi
# }}}
