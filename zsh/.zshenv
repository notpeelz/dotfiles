if command -v nvim &>/dev/null; then
  export EDITOR=nvim
elif command -v vim &>/dev/null; then
  export EDITOR=vim
elif command -v nano &>/dev/null; then
  export EDITOR=nano
fi

[[ -s "$HOME/.cargo/env" ]] && \. "$HOME/.cargo/env"

if [[ -d "$HOME/.nvm" ]]; then
  export NVM_DIR="$HOME/.nvm"
  [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
fi

if [[ -d "$HOME/.dotnet" ]]; then
  export DOTNET_ROOT="$(dirname "$(readlink -f $(which dotnet))")"
  export PATH="$PATH:$HOME/.dotnet/tools"
fi

if [[ -d "$HOME/.local/bin" ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi
