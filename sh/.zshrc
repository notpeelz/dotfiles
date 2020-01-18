export ZSH_CUSTOM="${HOME}/.oh-my-zsh/custom"

ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
  git
  sudo
)

# Load zsh-syntax-highlighting if installed
zsh_syntaxhl_path="${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
[[ -d "${zsh_syntaxhl_path}" ]] && {
  plugins+=(zsh-syntax-highlighting)
}

# This speeds up pasting w/ autosuggest
# https://github.com/zsh-users/zsh-autosuggestions/issues/238
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
}
pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

# Initialize oh-my-zsh
export ZSH="${HOME}/.oh-my-zsh"
source "${ZSH}/oh-my-zsh.sh"

# Load .shrc
[[ -s "${HOME}/.shrc" ]] && source "${HOME}/.shrc"
