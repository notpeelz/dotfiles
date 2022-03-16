#!/usr/bin/env zsh

# don't change terminal title if we're not in a TTY
[[ "$2" -ne 1 && ! -t 0 ]] && exit 0

# don't change terminal title over ssh
[[ -n "$SSH_CLIENT" || -n "$SSH_TTY" || -n "$SSH_CONNECTION" ]] && exit 0

name="$1"

[[ -z "$name" ]] && exit 0

case "$TERM" in
  cygwin|xterm*|putty*|rxvt*|konsole*|ansi|mlterm*|alacritty|st*|foot)
    print -Pn "\e]2;${name:q}\a" # set window name
    print -Pn "\e]1;${name:q}\a" # set tab name
    ;;
  screen*|tmux*)
    print -Pn "\ek${name:q}\e\\" # set screen hardstatus
    ;;
esac
