#!/usr/bin/env bash

questions=0

cout() {
  echo "-----------------------------------------------------------"
  echo "|--- $*"
  echo ""
}

confirm() {
  questions=$((questions + 1))
  echo "-----------------------------------------------------------"
  read -rp "|--- (${questions}) $* " answer
  if [ "${answer}" != "yes" ]; then
    echo "|--- No"
  else
    echo "|--- Yes"
  fi
  echo ""
}

ask() {
  questions=$((questions + 1))
  echo ""
  read -rp "|--- (${questions}) $* " answer
  echo ""
}

cout "Creating vimrc"
echo "syntax on" > "$HOME/.vimrc"

cout "Creating git configuration"
cp ./gitconfig/config "$HOME/.gitconfig"

if [[ "$(uname -p)" == "arm" ]]; then
  if [ $(/usr/bin/pgrep oahd >/dev/null 2>&1;echo $?) -ne 0 ]; then
    cout "Installing Rosetta in M1"
    softwareupdate --install-rosetta --agree-to-license
  else
    cout "Rosetta already installed"
  fi
fi

confirm "Should install ZSH?"

if [ "${answer}" == "yes" ]; then
  cout "Installing ZSH"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [ "${answer}" != "yes" ]; then
  confirm "Should update zsh config?"
fi

if [ "${answer}" == "yes" ]; then
  cout "Updating zsh configuration"
  mkdir -p "$HOME/.zsh"
  cp ./zshconfig/zsh-scripts/* "$HOME/.zsh/"
  cp ./zshconfig/zshrc "$HOME/.zshrc"
  zsh -c 'source "$HOME/.zshrc"'
fi

confirm "Should install HomeBrew?"

if [ "${answer}" == "yes" ]; then
  cout "Installing HomeBrew"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$($(which brew) shellenv)"
fi

confirm "Should install HomeBrew Packages (tree nvm pnpm)?"

if [ "${answer}" == "yes" ]; then
  cout "Installing HomeBrew packages"
  brew install tree nvm pnpm
  {
    echo "source $ZSH_CONFIG_FOLDER/homebrew.sh";
    echo "source $ZSH_CONFIG_FOLDER/node.sh";
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

