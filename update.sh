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

if [ -f "$HOME/.ssh/id_rsa" ]; then
  cout "SSH keys already configured"
else
  cout "Creating SSH configuration"
  mkdir -p "$HOME/.ssh"
  cp ./sshconfig/config "$HOME/.ssh/config"
  openssl bf -d -a -in ./sshconfig/id_rsa.encrypt -out "$HOME/.ssh/id_rsa"
  openssl bf -d -a -in ./sshconfig/id_rsa.pub.encrypt -out "$HOME/.ssh/id_rsa.pub"
  chmod 600 "$HOME/.ssh/id_rsa"
fi

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
  curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
  eval "$($(which brew) shellenv)"
fi

confirm "Should install HomeBrew Packages (postgresql pyenv pyenv-virtualenv tree nvm)?"

if [ "${answer}" == "yes" ]; then
  cout "Installing HomeBrew packages"
  brew install direnv postgresql pyenv pyenv-virtualenv tree nvm
  {
    echo "source $HOME/.zsh/homebrew.zshrc";
    echo "source $HOME/.zsh/nvm.zshrc";
    echo "source $HOME/.zsh/pyenv.zshrc";
  } >> "$HOME/.zshrc"
  zsh -c 'source "$HOME/.zshrc"'
fi

confirm "Should install python?"

if [ "${answer}" == "yes" ]; then
  cout "Installing Python"
  ask "Python version (3.9.0): "
  pyenv install 3.9.0
  pyenv global 3.9.0
fi

confirm "Should install Node?"

if [ "${answer}" == "yes" ]; then
  cout "Installing Node"
  ask "Node version (16.13.1): "
  nvm install ${answer}
  nvm use ${answer}

fi

confirm "Should install HomeBrew Programs (notion jetbrains-toolbox google-chrome 1password figma iterm2)?"

if [ "${answer}" == "yes" ]; then
  cout "Installing HomeBrew Cask Programs"
  brew install --cask notion jetbrains-toolbox google-chrome 1password figma iterm2

  cout "Opening Google Chrome"
  open -a "Google Chrome" --args --make-default-browser
fi

confirm "Should configure iterm?"

if [ "${answer}" == "yes" ]; then
  cout "Copying iTerm2 configuration files"
  cp ./itermconfig/iterm2.preferences "$HOME/Documents/com.googlecode.iterm2.plist"
  cp ./itermconfig/ItermProfile.json "$HOME/Desktop/ItermProfile.json"
fi

confirm "Setup MO configuration?"

if [ "${answer}" == "yes" ]; then
  ./mo/update.sh
fi

confirm "Setup LeanTech configuration?"

if [ "${answer}" == "yes" ]; then
  ./leantech/update.sh
fi

confirm "Setup Everyset configuration?"

if [ "${answer}" == "yes" ]; then
  ./everyset/update.sh
fi
