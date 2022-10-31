#!/usr/bin/env bash

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

if [ -f "$HOME/.ssh/id_rsa_mo" ]; then
  cout "MO SSH keys already configured"
else
  cout "Setting up MO ssh configuration"
  cat ./mo/sshconfig/config >> "$HOME/.ssh/config"
  openssl bf -d -a -in ./mo/sshconfig/id_rsa.encrypt -out "$HOME/.ssh/id_rsa_mo"
  openssl bf -d -a -in ./mo/sshconfig/id_rsa.pub.encrypt -out "$HOME/.ssh/id_rsa_mo.pub"
  chmod 600 "$HOME/.ssh/id_rsa_mo"
fi

cout "Setting up MO git configuration"
mkdir -p "$HOME/Code/mo"
{
  echo '[includeIf "gitdir:~/Code/mo/**/"]';
  echo '  path = ~/Code/mo/.gitconfig';
  echo ''
} >> "$HOME/.gitconfig"
cp ./mo/gitconfig/config "$HOME/Code/mo/.gitconfig"

if [ -f "$HOME/.pip/pip.conf" ]; then
  cout "MO pypi already configured"
else
  cout "Setting up MO pypi configuration"
  mkdir -p "$HOME/.pip"
  {
    echo "[global]";
    echo "extra-index-url = https://mo-releases:5a7395400c0424b05ee6a5f038692cce@pypi.moprestamo.com/simple";
    echo "timeout = 10";
  } >> "$HOME/.pip/pip.conf"

  cout "Installing mo-scripts"
  pip3 install moscripts
fi

confirm "Should install HomeBrew Packages (awscli cli53 tfenv)?"

if [ "${answer}" == "yes" ]; then
  cout "Installing HomeBrew packages"
  brew install awscli cli53 tfenv
  cp ./mo/zshconfig/* "$HOME/.zsh/"
  {
    echo "source $HOME/.zsh/aws.zshrc";
    echo "source $HOME/.zsh/django.zshrc";
    echo "source $HOME/.zsh/terraform.zshrc";
  } >> "$HOME/.zshrc"
  zsh -c 'source "$HOME/.zshrc"'
fi

if [ -f "$HOME/.aws/config" ]; then
  cout "MO AWS already configured"
else
  cout "Setting up MO aws configuration"
  mkdir -p "$HOME/.aws"
  cp ./mo/awsconfig/config "$HOME/.aws/config"
  npm install -g aws-azure-login
fi

confirm "Should install Terraform?"

if [ "${answer}" == "yes" ]; then
  cout "Installing Terraform"
  ask "Terraform version (1.0.11): "
  tfenv install ${answer}
  tfenv use ${answer}
fi

confirm "Should install HomeBrew Programs (docker keka keybase pritunl slack tableplus pgadmin4 microsoft-teams)?"

if [ "${answer}" == "yes" ]; then
  cout "Installing HomeBrew Cask Programs"
  brew install --cask docker keka keybase pritunl slack tableplus pgadmin4 microsoft-teams
fi
