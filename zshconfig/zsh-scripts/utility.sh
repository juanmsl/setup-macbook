cout() {
  echo "-----------------------------------------------------------"
  echo "|--- $*"
  echo ""
}

ask() {
  echo "-----------------------------------------------------------"
  read -rp "|--- (?) $* " answer
  if [ "${answer}" != "yes" ]; then
    echo "|--- No"
  else
    echo "|--- Yes"
  fi
  echo ""
}

encrypt() {
  echo "${#}"
  if [ "${#}" != "2" ]; then
      echo "You must specify two params (input, output)"
      return 1
  fi
  openssl bf -a -salt -in $1 -out $2
}

decrypt() {
  if [ "${$#}" != "2" ]; then
    echo "You must specify two params (input, output)"
    return 1
  fi
  openssl bf -d -a -in $1 -out $2
}

alias szsh="source $HOME/.zshrc"
alias zshrc="vim $HOME/.zshrc"
