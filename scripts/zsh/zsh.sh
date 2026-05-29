#!/bin/bash

K9S_VERSION=v0.32.5
sleep 1
printf "\n\n"
printf "_______________________________________________________________________________"
printf "\n\nYou are going to install zsh with some plugins.\n"
printf "_______________________________________________________________________________"
printf "\n\n"

read -p "Do you want to install additional recommended software?[Yy/Nn] " -n 1 -r
printf "\n"
if [[ $REPLY =~ ^[Yy]$ ]]
then
  printf "Update of apt\n"
  sudo apt update
  printf "ZSH and oh-my-zsh\n"
  sudo apt install -y curl zsh git ca-certificates apt-transport-https
  
  read -p "Do you want to install kubernetes tools?[Yy/Nn] " -n 1 -r
  printf "\n"
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
    wget https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz
    tar -xf k9s_Linux_amd64.tar.gz
    sudo mv k9s /usr/bin/
    rm -f k9s_Linux_amd64.tar.gz
  fi
fi

curl https://raw.githubusercontent.com/padawarmik/scripts/main/scripts/zsh/.p10k.zsh -o $HOME/.p10k.zsh -s

if [ -f $HOME/.zshrc ]
then
  read -p "Your .zshrc file will be replaced. Do you want to continue?[Yy/Nn] " -n 1 -r
  printf "\n"
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    printf "Deleting\n"
    rm $HOME/.zshrc -f
    curl https://raw.githubusercontent.com/padawarmik/scripts/main/scripts/zsh/.zshrc -o $HOME/.zshrc -s
  fi
else
  curl https://raw.githubusercontent.com/padawarmik/scripts/main/scripts/zsh/.zshrc -o $HOME/.zshrc -s
fi

mkdir -p $HOME/.aliases
touch $HOME/.aliases/custom_aliases
touch $HOME/.aliases/customs
printf "\n\n"
printf "The work has been done, restart your terminal now to feel the power of the ZSH command prompt\nNow you can run chsh -s '$(which zsh)' to set default shell.\n"
printf "You can now add custom aliases to the ~/.aliases/custom_aliases file.\n"
printf "To rerun this script run 'zsh-rerun'\n"
