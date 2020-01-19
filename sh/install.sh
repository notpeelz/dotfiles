#!/usr/bin/env bash

set -Eeu

current_shell="$(getent passwd | grep "^${USER}:" | cut -d: -f7)"

[[ "${current_shell}" == *"/zsh" && "$(type -t zsh)" == "file" ]] || {
  new_shell="$(command -v zsh)"

  # Make sure we don't set the shell to something invalid
  [[ "${new_shell}" != "" ]] && {
    while true; do
      read -p "Do you want to make zsh your default shell? [Yn] " yn
      case "$yn" in
        [Yy]*|"") chsh -s "${new_shell}"; break ;;
        [Nn]*) break ;;
      esac
    done
  }
}

ZSH="${ZSH:-${HOME}/.oh-my-zsh}"
ZSH_CUSTOM="${ZSH_CUSTOM:-${ZSH}/custom}"

[[ -d "${ZSH}" ]] && {
  echo "Updating oh-my-zsh"
  cd "${ZSH}"
  git pull origin
} || {
  echo "Installing oh-my-zsh"
  git clone 'https://github.com/ohmyzsh/ohmyzsh.git' "${ZSH}"
}

zsh_syntaxhl_path="${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
[[ -d "${zsh_syntaxhl_path}" ]] && {
  echo "Updating zsh-syntax-highlighting"
  cd "${zsh_syntaxhl_path}"
  git pull origin
} || {
  echo "Installing zsh-syntax-highlight"
  git clone 'https://github.com/zsh-users/zsh-syntax-highlighting.git' "${zsh_syntaxhl_path}"
}

pl10k_path="${ZSH_CUSTOM}/themes/powerlevel10k"
[[ -d "${pl10k_path}" ]] && {
  echo "Updating powerlevel10k"
  cd "${pl10k_path}"
  git pull origin
} || {
  echo "Installing pl10k-prompt"
  git clone --depth=1 'https://github.com/romkatv/powerlevel10k.git' "${pl10k_path}"
}
