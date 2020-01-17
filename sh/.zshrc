ZSH_THEME="dieter"
plugins=(git sudo)

export ZSH="$HOME/.oh-my-zsh"
[[ -s "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

[[ -s "$HOME/.shrc" ]] && source "$HOME/.shrc"
