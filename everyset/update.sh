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

if [ -f "$HOME/.ssh/id_rsa_everyset" ]; then
  cout "Everyset SSH keys already configured"
else
  cout "Setting up Everyset ssh configuration"
  cat ./everyset/sshconfig/config >> "$HOME/.ssh/config"
  openssl bf -d -a -in ./everyset/sshconfig/id_rsa.encrypt -out "$HOME/.ssh/id_rsa_everyset"
  openssl bf -d -a -in ./everyset/sshconfig/id_rsa.pub.encrypt -out "$HOME/.ssh/id_rsa_everyset.pub"
  chmod 600 "$HOME/.ssh/id_rsa_everyset"
fi

cout "Setting up Everyset git configuration"
mkdir -p "$HOME/Code/everyset"
{
  echo '[includeIf "gitdir:~/Code/everyset/**/"]';
  echo '  path = ~/Code/everyset/.gitconfig';
  echo ''
} >> "$HOME/.gitconfig"
cp ./everyset/gitconfig/config "$HOME/Code/everyset/.gitconfig"
