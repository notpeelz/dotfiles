# vim:ft=zsh foldmethod=marker

mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/zsh"
mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/zsh"
mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zfunc"

# EDITOR {{{
if (( ${+commands[nvim]} )); then
  export EDITOR=nvim
elif (( ${+commands[vim]} )); then
  export EDITOR=vim
elif (( ${+commands[nano]} )); then
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
