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

# Initialize p10k
__is_tty \
 || [[ -f "${HOME}/.p10k.zsh" ]] && source "${HOME}/.p10k.zsh"

# Load direnv
eval "$(direnv hook zsh)"

# Add hotkey for ranger
function run_ranger() {
  lastdir_file="$(mktemp)"
  function TRAPEXIT() { rm "${lastdir_file}"; }
  ranger --choosedir="${lastdir_file}" < "${TTY}"
  lastdir="$(cat "${lastdir_file}")"
  cd "${lastdir}"
  zle reset-prompt
}
zle -N run_ranger
bindkey '^f' run_ranger

# Load .shrc
[[ -s "${HOME}/.shrc" ]] && source "${HOME}/.shrc"
