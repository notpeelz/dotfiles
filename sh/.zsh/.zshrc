# Let home-manager handle session vars
if [[ -r "${HOME}/.nix-profile/etc/profile.d/hm-session-vars.sh" ]]; then
  source "${HOME}/.nix-profile/etc/profile.d/hm-session-vars.sh"
fi

function __is_tty() { [[ "${0}" =~ ^-.* || "${TERM}" == "linux" ]]; }

__is_tty || {
  # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
  # Initialization code that may require console input (password prompts, [y/n]
  # confirmations, etc.) must go above this block, everything else may go below.
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi
}

# oh-my-zsh settings
export ZSH_CUSTOM="${HOME}/.oh-my-zsh/custom"

__is_tty \
  && ZSH_THEME="imajes" \
  || ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  sudo
  zsh-completions
)

# Load zsh-syntax-highlighting if installed
zsh_syntaxhl_path="${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
[[ -d "${zsh_syntaxhl_path}" ]] && {
  plugins+=(zsh-syntax-highlighting)
}

# Load zsh-nix-shell if installed
zsh_nixshell_path="${ZSH_CUSTOM}/plugins/nix-shell"
[[ -d "${zsh_nixshell_path}" ]] && {
  plugins+=(nix-shell)
}

# This speeds up pasting w/ autosuggest
# https://github.com/zsh-users/zsh-autosuggestions/issues/238
function pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
}
function pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

# Initialize oh-my-zsh
export ZSH="${HOME}/.oh-my-zsh"
source "${ZSH}/oh-my-zsh.sh"

[[ "${+ZSH_HIGHLIGHT_STYLES}" -eq 1 ]] && {
  # Prevent comments from disappearing (dark fg on dark bg)
  # https://github.com/zsh-users/zsh-syntax-highlighting/issues/510#issuecomment-376400492
  ZSH_HIGHLIGHT_STYLES[comment]='fg=11'
}

# Initialize p10k
__is_tty \
 || [[ -f "${HOME}/.p10k.zsh" ]] && source "${HOME}/.p10k.zsh"

# Load direnv
eval "$(direnv hook zsh)"

# Add hotkey for ranger: ctrl+f
function run_ranger() {
  lastdir_file="$(mktemp)"
  function TRAPEXIT() { rm "${lastdir_file}"; }
  ranger --choosedir="${lastdir_file}" < "${TTY}"
  lastdir="$(cat "${lastdir_file}")"
  cd "${lastdir}"
  # FIXME: https://github.com/romkatv/powerlevel10k/issues/72
  BUFFER=
  zle accept-line
  #zle reset-prompt
}
zle -N run_ranger
bindkey '^f' run_ranger

# Add hotkey to list files: ctrl+space
function list_files() {
  zle .push-input
  BUFFER="ls -lh"
  zle .accept-line
}
zle -N list_files
bindkey '^@' list_files

# Add hotkey to list all files: ctrl+shift+space
function list_all_files() {
  zle .push-input
  BUFFER="ls -alh"
  zle .accept-line
}
zle -N list_all_files
bindkey '^[[21;2~' list_all_files

# Add hotkey to open $EDITOR
function run_editor() { "$EDITOR" < ${TTY}; }
zle -N run_editor
bindkey '^v' run_editor

# Load .shrc
[[ -s "${HOME}/.shrc" ]] && source "${HOME}/.shrc"

# Initialize zsh completion
autoload -U compinit && compinit
if [[ "$TERM" == "xterm-kitty" ]]; then
  kitty + complete setup zsh | source /dev/stdin
fi
