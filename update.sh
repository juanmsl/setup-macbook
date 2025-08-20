#!/usr/bin/env bash

questions=0

# Define color codes
RED='\033[1;31m'
GRN='\033[1;32m'
BLU='\033[1;34m'
YEL='\033[1;33m'
PUR='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m'

copyFile() {
  local file="${1}"
  local dest="${2}"

  curl -fsSL https://raw.githubusercontent.com/juanmsl/setup-macbook/refs/heads/master/${file} -o ${dest}
}

cout() {
  echo -e "${BLU}-----------------------------------------------------------"
  echo -e "|---${NC} $*"
  echo ""
}

confirm() {
  questions=$((questions + 1))
  echo -e "${PUR}-----------------------------------------------------------${CN}"
  read -rp "|--- (${questions}) $* " answer
  if [ "${answer}" != "yes" ]; then
    echo -e "${RED}|--- No"
  else
    echo -e "${GRN}|--- Yes"
  fi
  echo -e "${CN}"
}

ask() {
  questions=$((questions + 1))
  echo ""
  read -rp "|--- (${questions}) $* " answer
  echo ""
}

if [ -f "$HOME/.vimrc" ]; then
    cout "✅ vimrc already configured"
else
    cout "🔄 Creating vimrc"
    echo "syntax on" > "$HOME/.vimrc"
fi

if xcode-select -p >/dev/null 2>&1; then
    cout "✅ Xcode Command Line Tools are installed"
else
    cout "🔄 Installing xcode dev tools"
    xcode-select --install
fi

if [ -f "$HOME/.gitconfig" ]; then
    cout "✅ Git config already configured"
else
    cout "🔄 Creating git configuration"
    copyFile gitconfig/config "$HOME/.gitconfig"
fi

if [[ "$(uname -p)" == "arm" ]]; then
  if /usr/bin/pgrep oahd >/dev/null 2>&1; then
    cout "✅ Rosetta already installed"
  else
    cout "🔄 Installing Rosetta in M1"
    softwareupdate --install-rosetta --agree-to-license
  fi
fi

if command -v zsh >/dev/null 2>&1; then
  cout "✅ zsh already installed"
else
  cout "🔄 Installing ZSH"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [ "${answer}" != "yes" ]; then
  confirm "Should update zsh config?"
fi

if [ "${answer}" == "yes" ]; then
  cout "Updating zsh configuration"
  mkdir -p "$HOME/.zsh"
  for script in aws epic git homebrew node pyenv terraform utility; do
    copyFile "zshconfig/zsh-scripts/$script.sh" "$HOME/.zsh/$script.sh"
  done
  copyFile zshconfig/zshrc "$HOME/.zshrc"
  zsh -c 'source "$HOME/.zshrc"'
fi

confirm "Should install HomeBrew?"

if [ "${answer}" == "yes" ]; then
  cout "Installing HomeBrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$($(which brew) shellenv)"
fi

confirm "Should install HomeBrew Packages (tree nvm pnpm)?"

if [ "${answer}" == "yes" ]; then
  cout "Installing HomeBrew packages"
  brew install tree nvm pnpm
  {
    echo "source \$ZSH_CONFIG_FOLDER/homebrew.sh";
    echo "source \$ZSH_CONFIG_FOLDER/node.sh";
  } >> "$HOME/.zshrc"
  zsh -c 'source "$HOME/.zshrc"'

  confirm "Should install Node?"

  if [ "${answer}" == "yes" ]; then
    cout "Installing Node"
    ask "Node version: "
    nvm install ${answer}
    nvm use ${answer}
    nvm alias default ${answer}
  fi
fi

confirm "Should install HomeBrew Programs (notion jetbrains-toolbox google-chrome 1password figma iterm2 logi-options-plus macs-fan-control)?"

if [ "${answer}" == "yes" ]; then
  cout "Installing HomeBrew Cask Programs"
  brew install --cask notion jetbrains-toolbox google-chrome 1password figma iterm2 logi-options-plus macs-fan-control

  cout "Opening Google Chrome"
  open -a "Google Chrome" --args --make-default-browser
fi

confirm "Should configure iterm?"

if [ "${answer}" == "yes" ]; then
  mkdir -p "$HOME/.iTerm"
  cout "Copying iTerm2 configuration files"
  cp ./itermconfig/* "$HOME/.iTerm/"
fi

confirm "Setup Epam configuration?"

if [ "${answer}" == "yes" ]; then
  cout "Setting up Epam git configuration"
  mkdir -p "$HOME/Code/epam"
  {
    echo '[includeIf "gitdir:~/Code/epam/**/"]';
    echo '  path = ~/Code/epam/.gitconfig';
    echo ''
  } >> "$HOME/.gitconfig"
  cp ./gitconfig/epam.config "$HOME/Code/epam/.gitconfig"
fi

