#!/usr/bin/env bash

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

[[ -d "${HOME}/.oh-my-zsh" ]] || {
  echo "Installing oh-my-zsh"
  git clone 'https://github.com/ohmyzsh/ohmyzsh.git' "${HOME}/.oh-my-zsh"
}

ZSH_CUSTOM="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"

zsh_syntaxhl_path="${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
[[ -d "${zsh_syntaxhl_path}" ]] || {
  echo "Installing zsh-syntax-highlight"
  git clone 'https://github.com/zsh-users/zsh-syntax-highlighting.git' "${zsh_syntaxhl_path}"
}
