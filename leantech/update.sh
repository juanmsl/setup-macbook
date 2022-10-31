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

if [ -f "$HOME/.ssh/id_rsa_leantech" ]; then
  cout "LeanTech SSH keys already configured"
else
  cout "Setting up LeanTech ssh configuration"
  cat ./leantech/sshconfig/config >> "$HOME/.ssh/config"
  openssl bf -d -a -in ./leantech/sshconfig/id_rsa.encrypt -out "$HOME/.ssh/id_rsa_leantech"
  openssl bf -d -a -in ./leantech/sshconfig/id_rsa.pub.encrypt -out "$HOME/.ssh/id_rsa_leantech.pub"
  chmod 600 "$HOME/.ssh/id_rsa_leantech"
fi

cout "Setting up LeanTech git configuration"
mkdir -p "$HOME/Code/leantech"
{
  echo '[includeIf "gitdir:~/Code/leantech/**/"]';
  echo '  path = ~/Code/leantech/.gitconfig';
  echo ''
} >> "$HOME/.gitconfig"
cp ./leantech/gitconfig/config "$HOME/Code/leantech/.gitconfig"

confirm "Should install HomeBrew Programs (discord)?"

if [ "${answer}" == "yes" ]; then
  cout "Installing HomeBrew Cask Programs"
  brew install --cask discord
fi
