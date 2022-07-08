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

cout "Creating up vimrc"
echo "syntax on" > "$HOME/.vimrc"

cout "Creating ssh configuration"
mkdir -p "$HOME/.ssh"
cp ./sshconfig/config "$HOME/.ssh/config"
openssl bf -d -a -in ./sshconfig/id_rsa.encrypt -out "$HOME/.ssh/id_rsa"
openssl bf -d -a -in ./sshconfig/id_rsa.pub.encrypt -out "$HOME/.ssh/id_rsa.pub"
chmod 600 "$HOME/.ssh/id_rsa"

cout "Creating git configuration"
cp ./gitconfig/config "$HOME/.gitconfig"

if [[ "$(uname -p)" == "arm" ]]; then
  cout "Installing Rosetta in M1"
  softwareupdate --install-rosetta --agree-to-license
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

  cout "Installing HomeBrew packages"
  brew install direnv postgresql pyenv pyenv-virtualenv tree nvm
  {
    echo "source $HOME/.zsh/homebrew.zshrc";
    echo "source $HOME/.zsh/nvm.zshrc";
    echo "source $HOME/.zsh/pyenv.zshrc";
  } >> "$HOME/.zshrc"
  zsh -c 'source "$HOME/.zshrc"'

  cout "Installing Python"
  ask "Python version (3.9.0): "
  pyenv install 3.9.0
  pyenv global 3.9.0

  cout "Installing Node"
  ask "Node version (16.13.1): "
  nvm install ${answer}
  nvm use ${answer}

  cout "Installing HomeBrew Cask Programs"
  brew install --cask notion pycharm google-chrome 1password figma iterm2

  cout "Copying iTerm2 configuration files"
  cp ./itermconfig/iterm2.preferences "$HOME/Documents/com.googlecode.iterm2.plist"
  cp ./itermconfig/ItermProfile.json "$HOME/Desktop/ItermProfile.json"

  cout "Opening Google Chrome"
  open -a "Google Chrome" --args --make-default-browser
fi

confirm "Setup MO configuration?"

if [ "${answer}" == "yes" ]; then
  cout "Setting up MO ssh configuration"
  cat ./sshconfig/mo.config >> "$HOME/.ssh/config"
  openssl bf -d -a -in ./sshconfig/id_rsa_mo.encrypt -out "$HOME/.ssh/id_rsa_mo"
  openssl bf -d -a -in ./sshconfig/id_rsa_mo.pub.encrypt -out "$HOME/.ssh/id_rsa_mo.pub"
  chmod 600 "$HOME/.ssh/id_rsa_mo"

  cout "Setting up MO git configuration"
  mkdir -p "$HOME/Code/mo"
  {
    echo '[includeIf "gitdir:~/Code/mo/**/"]';
    echo '  path = ~/Code/mo/.gitconfig';
    echo ''
  } >> "$HOME/.gitconfig"
  cp ./gitconfig/mo.config "$HOME/Code/mo/.gitconfig"

  cout "Setting up MO pypi configuration"
  mkdir -p "$HOME/.pip"
  echo "[global]" > "$HOME/.pip/pip.conf"
  {
    echo "extra-index-url = https://mo-releases:5a7395400c0424b05ee6a5f038692cce@pypi.moprestamo.com/simple";
    echo "timeout = 10";
  } >> "$HOME/.pip/pip.conf"

  cout "Installing mo-scripts"
  pip install moscripts

  cout "Installing HomeBrew packages"
  brew install awscli cli53 tfenv
  {
    echo "source $HOME/.zsh/aws.zshrc";
    echo "source $HOME/.zsh/django.zshrc";
    echo "source $HOME/.zsh/terraform.zshrc";
  } >> "$HOME/.zshrc"
  zsh -c 'source "$HOME/.zshrc"'

  cout "Setting up MO aws configuration"
  mkdir -p "$HOME/.aws"
  cp ./awsconfig/config "$HOME/.aws/config"
  npm install -g aws-azure-login

  cout "Installing Terraform"
  ask "Node version (1.0.11): "
  tfenv install ${answer}
  tfenv use ${answer}

  cout "Installing HomeBrew Cask Programs"
  brew install --cask docker keka keybase pritunl slack tableplus pgadmin4 microsoft-teams
fi

confirm "Setup LeanTech configuration?"

if [ "${answer}" == "yes" ]; then
  cout "Setting up LeanTech ssh configuration"
  cat ./sshconfig/leantech.config >> "$HOME/.ssh/config"
  openssl bf -d -a -in ./sshconfig/id_rsa_leantech.encrypt -out "$HOME/.ssh/id_rsa_leantech"
  openssl bf -d -a -in ./sshconfig/id_rsa_leantech.pub.encrypt -out "$HOME/.ssh/id_rsa_leantech.pub"
  chmod 600 "$HOME/.ssh/id_rsa_leantech"

  cout "Setting up LeanTech git configuration"
  mkdir -p "$HOME/Code/leantech"
  {
    echo '[includeIf "gitdir:~/Code/leantech/**/"]';
    echo '  path = ~/Code/leantech/.gitconfig';
    echo ''
  } >> "$HOME/.gitconfig"
  cp ./gitconfig/leantech.config "$HOME/Code/leantech/.gitconfig"

  cout "Installing HomeBrew Cask Programs"
  brew install --cask discord
fi
