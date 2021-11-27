# vim:foldmethod=marker

_SCRIPT_PATH="${$(print -P %N):A:h}"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source "$HOME/.powerlevel10k/powerlevel10k.zsh-theme"

# GNU colors {{{
alias ls="ls --color=auto"
alias grep="grep --color=auto"

if [[ -x /usr/bin/dircolors ]]; then
  test -r ~/.dircolors \
    && eval "$(dircolors -b ~/.dircolors)" \
    || eval "$(dircolors -b)"
fi
# }}}

# History settings {{{
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
# Allow multiple sessions to append to one history
setopt append_history
# Disable history bangs
unsetopt bang_hist
# Write history in :start:elasped;command format
setopt extended_history
# Eliminate duplicates first when trimming history
setopt hist_expire_dups_first
# When searching history, don't repeat duplicates
setopt hist_find_no_dups
# Ignore duplicate entries
setopt hist_ignore_dups
# Prefix command with a space to prevent it from being recorded
setopt hist_ignore_space
# Remove extra blanks from each command added to history
setopt hist_reduce_blanks
# Don't execute immediately upon history expansion
setopt hist_verify
# Write to history file immediately, not when shell quits
setopt inc_append_history
# Share history with other sessions
setopt share_history
# }}}

# Completion {{{
# Menu selection
zmodload -i zsh/complist
zstyle ':completion:*' menu select

# Don't autoselect the first completion entry
unsetopt menu_complete

# cd /u/lo/l<TAB> expands to /usr/local/lib
setopt complete_in_word

# Show completion menu on succesive tab presses
setopt auto_menu

# Forces the cursor to the end of the word after it is completed,
# even if completion took place in the middle.
setopt always_to_end

# Completion always takes place at the cursor position in the word
setopt complete_in_word

# Case/hyphen insensitive
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'
# zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

# Complete . and .. special directories
zstyle ':completion:*' special-dirs true

# Colors
zstyle ':completion:*' list-colors "$LS_COLORS"

# Process completion
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm -w -w"

# Disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path $ZSH_CACHE_DIR

# Don't complete uninteresting users
zstyle ':completion:*:*:*:users' ignored-patterns \
  adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
  clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
  gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
  ldap lp mail mailman mailnull man messagebus  mldonkey mysql nagios \
  named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
  operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
  rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
  usbmux uucp vcsa wwwrun xfs backup gnats irc list proxy sys \
  www-data '_*' 'systemd-*'
# ... unless we really want to.
zstyle '*' single-ignored show

# These "eat" the auto prior space after a tab complete
ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;&'

bindkey -M menuselect "${terminfo[kcbt]}" reverse-menu-complete

# Add ~/.zfunc to the fpath {{{
[[ ! -d "$HOME/.zfunc" ]] && mkdir -p "$HOME/.zfunc"
fpath+="$HOME/.zfunc"
# }}}

# dotnet {{{
_dotnet_zsh_complete() {
  local completions=("$(dotnet complete "$words")")
  reply=( "${(ps:\n:)completions}" )
}
compctl -K _dotnet_zsh_complete dotnet
# }}}

# rustup {{{
if [[ ! -e "$HOME/.zfunc/_rustup" ]] && type rustup &>/dev/null; then
  rustup completions zsh > "$HOME/.zfunc/_rustup"
fi
# }}}

# cargo {{{
if type rustc &>/dev/null; then
  fpath+="$(rustc --print sysroot)/share/zsh/site-functions"
fi
# }}}

# nvm (Node Version Manager) {{{
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
# }}}

# npm {{{
# FIXME: this completion is not ideal (no `npm install` completion)
if type npm &>/dev/null; then
  source <(npm completion)
fi
# }}}

autoload -Uz compinit && compinit
autoload -U bashcompinit && bashcompinit
# }}}

# Fuzzy up/down completion {{{
autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
bindkey "${terminfo[kcud1]}" down-line-or-beginning-search
# }}}

# Directory history {{{
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus
# }}}

# Miscellaneous {{{
# Frees up ^Q and ^S
unsetopt flowcontrol

# Remove the default word separators
# This lets {backward,forward}-word skip over, e.g. path segments
WORDCHARS=''

# Allow comments in shell
setopt interactive_comments

# Disable zsh suggestions
unsetopt correct_all

# Add commas to file sizes
export BLOCK_SIZE="'1"

# Bat theme
export BAT_THEME="Monokai Extended Bright"

# Set by the ssh-agent user service
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
# }}}

# Mappings {{{
# Make $terminfo available
zmodload -i zsh/terminfo
# Make sure that the terminal is in application mode when zle is active, since
# only then values from $terminfo are valid
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
  function zle-line-init() {
    echoti smkx
  }
  function zle-line-finish() {
    echoti rmkx
  }
  zle -N zle-line-init
  zle -N zle-line-finish
fi

# Use emacs key bindings
bindkey -e
# Skips over words using ctrl-left/right
bindkey '[1;5D' backward-word
bindkey '[1;5C' forward-word
# History search
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
# }}}

# Clipboard {{{
function detect-clipboard() {
  emulate -L zsh

  if [[ "${OSTYPE}" == darwin* ]] && (( ${+commands[pbcopy]} )) && (( ${+commands[pbpaste]} )); then
    function clipcopy() { pbcopy < "${1:-/dev/stdin}"; }
    function clippaste() { pbpaste; }
  elif [[ "${OSTYPE}" == (cygwin|msys)* ]]; then
    function clipcopy() { cat "${1:-/dev/stdin}" > /dev/clipboard; }
    function clippaste() { cat /dev/clipboard; }
  elif [ -n "${WAYLAND_DISPLAY:-}" ] && (( ${+commands[wl-copy]} )) && (( ${+commands[wl-paste]} )); then
    function clipcopy() { wl-copy < "${1:-/dev/stdin}"; }
    function clippaste() { wl-paste; }
  elif [ -n "${DISPLAY:-}" ] && (( ${+commands[xclip]} )); then
    function clipcopy() { xclip -in -selection clipboard < "${1:-/dev/stdin}"; }
    function clippaste() { xclip -out -selection clipboard; }
  elif [ -n "${DISPLAY:-}" ] && (( ${+commands[xsel]} )); then
    function clipcopy() { xsel --clipboard --input < "${1:-/dev/stdin}"; }
    function clippaste() { xsel --clipboard --output; }
  elif (( ${+commands[lemonade]} )); then
    function clipcopy() { lemonade copy < "${1:-/dev/stdin}"; }
    function clippaste() { lemonade paste; }
  elif (( ${+commands[doitclient]} )); then
    function clipcopy() { doitclient wclip < "${1:-/dev/stdin}"; }
    function clippaste() { doitclient wclip -r; }
  elif (( ${+commands[win32yank]} )); then
    function clipcopy() { win32yank -i < "${1:-/dev/stdin}"; }
    function clippaste() { win32yank -o; }
  elif [[ "$OSTYPE" == linux-android* ]] && (( $+commands[termux-clipboard-set] )); then
    function clipcopy() { termux-clipboard-set "${1:-/dev/stdin}"; }
    function clippaste() { termux-clipboard-get; }
  elif [ -n "${TMUX:-}" ] && (( ${+commands[tmux]} )); then
    function clipcopy() { tmux load-buffer "${1:--}"; }
    function clippaste() { tmux save-buffer -; }
  elif [[ "$(uname -r)" = *icrosoft* ]]; then
    function clipcopy() { clip.exe < "${1:-/dev/stdin}"; }
    function clippaste() { powershell.exe -noprofile -command Get-Clipboard; }
  else
    function _retry_clipboard_detection_or_fail() {
      local clipcmd="${1}"; shift
      if detect-clipboard; then
        "${clipcmd}" "$@"
      else
        print "${clipcmd}: Platform $OSTYPE not supported or xclip/xsel not installed" >&2
        return 1
      fi
    }
    function clipcopy() { _retry_clipboard_detection_or_fail clipcopy "$@"; }
    function clippaste() { _retry_clipboard_detection_or_fail clippaste "$@"; }
    return 1
  fi
}

detect-clipboard || true
# }}}

# Plugins {{{
# FIXME: `yarn add` completion is slow
source "$_SCRIPT_PATH/plugins/zsh-yarn-completions/zsh-yarn-completions.plugin.zsh"
# }}}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
