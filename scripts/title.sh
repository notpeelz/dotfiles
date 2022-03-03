#!/usr/bin/env zsh

[[ -v GIT_EXEC_PATH ]] && exit 0
[[ -z "$1" ]] && exit 0

# Don't set the title if inside emacs, unless using vterm
[[ -n "${INSIDE_EMACS:-}" && "$INSIDE_EMACS" != vterm ]] && return

# if $2 is unset use $1 as default
# if it is set and empty, leave it as is
: ${2=$1}

param1="$1"
param2="$1"
[[ ! -z "$2" ]] && param2="$2"

case "$TERM" in
  cygwin|xterm*|putty*|rxvt*|konsole*|ansi|mlterm*|alacritty|st*|foot)
    print -Pn "\e]2;${param2:q}\a" # set window name
    print -Pn "\e]1;${param1:q}\a" # set tab name
    ;;
  screen*|tmux*)
    print -Pn "\ek${param1:q}\e\\" # set screen hardstatus
    ;;
  *)
    if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
      print -Pn "\e]2;${param2:q}\a" # set window name
      print -Pn "\e]1;${param1:q}\a" # set tab name
    else
      # Try to use terminfo to set the title if the feature is available
      if (( ${+terminfo[fsl]} && ${+terminfo[tsl]} )); then
        print -Pn "${terminfo[tsl]}$1${terminfo[fsl]}"
      fi
    fi
    ;;
esac
