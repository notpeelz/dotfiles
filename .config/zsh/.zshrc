# vim:ft=zsh foldmethod=marker

(( ${+commands[direnv]} )) && emulate zsh -c "$(direnv export zsh)"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

(( ${+commands[direnv]} )) && emulate zsh -c "$(direnv hook zsh)"

source "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme"

() {

autoload -Uz add-zle-hook-widget

# Make $terminfo available
zmodload -i zsh/terminfo

# The default zsh keymap is $EDITOR dependent. This forces it to emacs.
# NOTE: this has to be done as early as possible because `bindkey` defaults
# to the current keymap.
bindkey -e

# GNU colors {{{
alias ls="ls --color=auto"
alias grep="grep --color=auto"

local _LS_COLORS=(
  # reset to normal
  "rs=0"
  # normal text
  "no=0"
  # file
  "fi=0"
  # directory
  "di=0;38;2;97;175;239"
  # executable
  "ex=0;38;2;166;226;46"
  # other-writable
  "ow=44;30"
  # block device
  "bd=0;38;2;189;147;249"
  # character device
  "cd=0;38;2;189;147;249"
  # fifo
  "pi=0;38;2;189;147;249"
  # socket
  "so=0;38;2;189;147;249"
  # door (a Solaris thing)
  "do=0;38;2;189;147;249"
  # symlink
  "ln=0;38;2;255;184;108"
  # hard link?
  "mh=0"
  # setuid/setgid
  "su=0;38;2;241;250;140;48;2;255;121;198"
  "sg=0;38;2;241;250;140;48;2;255;121;198"
  # sticky
  "st=0;38;2;241;250;140;48;2;139;233;253"
  # sticky (other writable)
  "tw=0;38;2;241;250;140;48;2;80;250;123"
  # missing symlink target
  "mi=0;38;2;255;85;85;48;2;40;42;54"
  # broken symlink
  "or=1;38;2;236;239;244;48;2;191;97;106"
  # file with capabilities
  "ca=1;38;2;189;147;249"
)
export LS_COLORS="${(j.:.)_LS_COLORS}"

alias grep="grep --color=auto"
alias diff="diff --color=auto"

# XXX: completion breaks if this is set as an alias
ip() { command ip --color=auto "$@"; }

export LESS_TERMCAP_mb=$'\033[1;31m'     # begin blink
export LESS_TERMCAP_md=$'\033[1;36m'     # begin bold
export LESS_TERMCAP_me=$'\033[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\033[01;33m'    # begin reverse video
export LESS_TERMCAP_se=$'\033[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\033[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\033[0m'        # reset underline

# Files and process completion colors
zstyle ":completion:*" list-colors "$LS_COLORS"
zstyle ":completion:*:*:kill:*:processes" list-colors "=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01"
# }}}

# Manpage colors {{{
if command -v bat &>/dev/null; then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export MANROFFOPT="-c"
elif command -v batcat &>/dev/null; then
  export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
  export MANROFFOPT="-c"
elif command -v less &>/dev/null; then
  export MANPAGER="less -R --use-color -Dd+r -Du+b"
  export MANROFFOPT="-P -c"
fi
# }}}

# Aliases {{{
alias vim="nvim"
alias vi="nvim"

if command -v eza &>/dev/null; then
  alias ls="eza --group --git"
fi

# "sudo vim" -> "sudoedit"
if command -v sudoedit &>/dev/null; then
  sudo() {
    setopt local_options extended_glob unset
    local -i i=$argv[(i)^-*]
    # $argv[i] is the first non-option argument (or empty if there is none)
    case "${argv[i]}" in
      vim|nvim)
        argv[$i]=()
        command sudoedit "${argv[@]}"
        return "$?"
        ;;
    esac
    command sudo "$@"
  }
fi

# Using default settings, running `paru` will update all repo and AUR packages.
# When using RepoOnly, `paru` only checks for repo updates.
# This workaround restores the default behavior.
if command -v paru &>/dev/null; then
  paru() {
    if [[ "$#" -eq 0 ]]; then
      command paru -Syu --mode all
    else
      command paru "$@"
    fi
  }
fi
# }}}

# History settings {{{
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=100000
SAVEHIST=100000
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
zstyle ":completion:*" menu select

# Enable completion for commands prefixed with `sudo`
zstyle ":completion:*:sudo:*" command-path "${(s|:|)PATH}"

# Enable automatic discovery of new programs in $PATH
# NOTE: can degrade performance of the shell
zstyle ":completion:*" rehash true

# Don't autoselect the first completion entry
unsetopt menu_complete

# Show completion menu on succesive tab presses
setopt auto_menu

# Completion always takes place at the cursor position in the word
setopt complete_in_word

# Case/hyphen insensitive
zstyle ":completion:*" matcher-list "" "m:{a-zA-Z-_}={A-Za-z_-}" "r:|=*" "l:|=* r:|=*"

# Complete . and .. special directories
zstyle ":completion:*" special-dirs true

# Process completion
zstyle ":completion:*:*:*:*:processes" command "ps -u $USERNAME -o pid,user,comm -w -w"

# Disable named-directories autocompletion
zstyle ":completion:*:cd:*" tag-order local-directories directory-stack path-directories

# Use caching so that commands like apt and dpkg complete are useable
zstyle ":completion:*" use-cache yes
zstyle ":completion:*" cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"

# Don't complete uninteresting users
zstyle ":completion:*:*:*:users" ignored-patterns \
  adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
  clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
  gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
  ldap lp mail mailman mailnull man messagebus  mldonkey mysql nagios \
  named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
  operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
  rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
  usbmux uucp vcsa wwwrun xfs backup gnats irc list proxy sys \
  cups colord geoclue http nm-openvpn qemu tss uuidd libvirt-qemu \
  www-data "_*" "systemd-*"
# ... unless we really want to.
zstyle "*" single-ignored show

# Replace the completion suffix (final slash of a dir) with a space
ZLE_SPACE_SUFFIX_CHARS=$'&|'

# Completion binds
bindkey "${terminfo[ht]}" complete-word
bindkey -M menuselect "${terminfo[kcbt]}" reverse-menu-complete

# Load compinit {{{
fpath=(
  "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/functions"
  "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/functions"
  "${fpath[@]}"
)

# XXX: any modification to fpath must be done before loading compinit
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"
# }}}
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
WORDCHARS=""

# Allow comments in shell
setopt interactive_comments

# Disable zsh suggestions
unsetopt correct_all

# Add commas to file sizes
export BLOCK_SIZE="'1"

# Bat theme
export BAT_THEME="Monokai Extended Bright"
# }}}

_zshrc-set-cursor() {
  echoti Ss 6
}

add-zle-hook-widget zle-line-init _zshrc-set-cursor
add-zle-hook-widget zle-line-finish _zshrc-set-cursor

# Mappings {{{
# Make sure that the terminal is in application mode when zle is active, since
# only then values from $terminfo are valid
_zshrc-set-appmode() {
  if (( ${+terminfo[smkx]} )); then
    echoti smkx
  fi
}
_zshrc-unset-appmode() {
  if (( ${+terminfo[rmkx]} )); then
    echoti rmkx
  fi
}
add-zle-hook-widget zle-line-init _zshrc-set-appmode
add-zle-hook-widget zle-line-finish _zshrc-unset-appmode

# Skips over words using ctrl-left/right
bindkey "${terminfo[kLFT5]}" backward-word
bindkey "${terminfo[kRIT5]}" forward-word
# History search
bindkey "^p" history-search-backward
bindkey "^n" history-search-forward
# }}}

# Clipboard {{{
_zshrc-detect-clipboard() {
  emulate -L zsh

  if [[ "${OSTYPE}" == darwin* ]] && (( ${+commands[pbcopy]} )) && (( ${+commands[pbpaste]} )); then
    clipcopy() { pbcopy < "${1:-/dev/stdin}"; }
    clippaste() { pbpaste; }
  elif [[ "${OSTYPE}" == (cygwin|msys)* ]]; then
    clipcopy() { cat "${1:-/dev/stdin}" > /dev/clipboard; }
    clippaste() { cat /dev/clipboard; }
  elif [ -n "${WAYLAND_DISPLAY:-}" ] && (( ${+commands[wl-copy]} )) && (( ${+commands[wl-paste]} )); then
    clipcopy() { wl-copy < "${1:-/dev/stdin}"; }
    clippaste() { wl-paste; }
  elif [ -n "${DISPLAY:-}" ] && (( ${+commands[xclip]} )); then
    clipcopy() { xclip -in -selection clipboard < "${1:-/dev/stdin}"; }
    clippaste() { xclip -out -selection clipboard; }
  elif [ -n "${DISPLAY:-}" ] && (( ${+commands[xsel]} )); then
    clipcopy() { xsel --clipboard --input < "${1:-/dev/stdin}"; }
    clippaste() { xsel --clipboard --output; }
  elif (( ${+commands[lemonade]} )); then
    clipcopy() { lemonade copy < "${1:-/dev/stdin}"; }
    clippaste() { lemonade paste; }
  elif (( ${+commands[doitclient]} )); then
    clipcopy() { doitclient wclip < "${1:-/dev/stdin}"; }
    clippaste() { doitclient wclip -r; }
  elif (( ${+commands[win32yank]} )); then
    clipcopy() { win32yank -i < "${1:-/dev/stdin}"; }
    clippaste() { win32yank -o; }
  elif [[ "$OSTYPE" == linux-android* ]] && (( $+commands[termux-clipboard-set] )); then
    clipcopy() { termux-clipboard-set "${1:-/dev/stdin}"; }
    clippaste() { termux-clipboard-get; }
  elif [ -n "${TMUX:-}" ] && (( ${+commands[tmux]} )); then
    clipcopy() { tmux load-buffer "${1:--}"; }
    clippaste() { tmux save-buffer -; }
  elif [[ "$(uname -r)" = *icrosoft* ]]; then
    clipcopy() { clip.exe < "${1:-/dev/stdin}"; }
    clippaste() { powershell.exe -noprofile -command Get-Clipboard; }
  else
    _retry_clipboard_detection_or_fail() {
      local clipcmd="${1}"; shift
      if _zshrc-detect-clipboard; then
        "${clipcmd}" "$@"
      else
        print "${clipcmd}: Platform $OSTYPE not supported or xclip/xsel not installed" >&2
        return 1
      fi
    }
    clipcopy() { _retry_clipboard_detection_or_fail clipcopy "$@"; }
    clippaste() { _retry_clipboard_detection_or_fail clippaste "$@"; }
    return 1
  fi
}

_zshrc-detect-clipboard || true
# }}}

# Plugins {{{
source "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

ZSH_HIGHLIGHT_STYLES[comment]="fg=#8d94b0"
# }}}

}

# powerlevel10k config {{{
if [[ -f "${XDG_CONFIG_HOME:-${HOME}/.config}/p10k.zsh" ]]; then
  source "${XDG_CONFIG_HOME:-${HOME}/.config}/p10k.zsh"
fi

typeset -g POWERLEVEL9K_LOCK_ICON='∅'
typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VISUAL_IDENTIFIER_EXPANSION='≡'

# configure p10k to use mise instead of asdf
# https://github.com/romkatv/powerlevel10k/issues/2212#issuecomment-1685084366
() {
  function prompt_mise() {
    while IFS= read -r line; do
      eval "local parts=(${line})"
      local tool_name="${parts[1]}"
      local tool_version="${parts[2]}"
      local tool_path="${parts[3]}"
      case "${tool_path}" in
        "${HOME}/.tool-versions") ;&
        "${HOME}/.config/mise/config.toml")
          ;;
        *)
          p10k segment -r -i "${(U)tool_name}_ICON" -s "${tool_name}" -t "${tool_version}"
          ;;
      esac
    done < <(
      mise ls -Jc 2>/dev/null | jq -r '
        to_entries[]
        | {k: .key, v: .value[0]}
        | [.k, .v.version, .v.source.path]
        | @sh
      '
    )
  }

  typeset -g POWERLEVEL9K_MISE_FOREGROUND=6

  typeset -g POWERLEVEL9K_MISE_RUBY_FOREGROUND=1
  typeset -g POWERLEVEL9K_MISE_PYTHON_FOREGROUND=6
  typeset -g POWERLEVEL9K_MISE_GOLANG_FOREGROUND=6
  typeset -g POWERLEVEL9K_MISE_NODEJS_FOREGROUND=2
  typeset -g POWERLEVEL9K_MISE_RUST_FOREGROUND=4
  typeset -g POWERLEVEL9K_MISE_DOTNET_CORE_FOREGROUND=5
  typeset -g POWERLEVEL9K_MISE_FLUTTER_FOREGROUND=4
  typeset -g POWERLEVEL9K_MISE_LUA_FOREGROUND=4
  typeset -g POWERLEVEL9K_MISE_JAVA_FOREGROUND=4
  typeset -g POWERLEVEL9K_MISE_PERL_FOREGROUND=6
  typeset -g POWERLEVEL9K_MISE_ERLANG_FOREGROUND=1
  typeset -g POWERLEVEL9K_MISE_ELIXIR_FOREGROUND=5
  typeset -g POWERLEVEL9K_MISE_POSTGRES_FOREGROUND=6
  typeset -g POWERLEVEL9K_MISE_PHP_FOREGROUND=5
  typeset -g POWERLEVEL9K_MISE_HASKELL_FOREGROUND=3
  typeset -g POWERLEVEL9K_MISE_JULIA_FOREGROUND=2

  # Substitute the default asdf prompt element
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=("${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[@]/asdf/mise}")
}
# }}}
