#!/bin/bash

if [ "$(id -u)" -eq 0 ]; then
  echo "Please run this script from your user account"
  exit 1
fi

set -x

# create all necessary files/folders
mkdir -p ~/.ssh
chmod 700 ~/.ssh
sudo chown $USER:$USER /home/abogutskiy/.ssh
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
echo "Don't forget add public/private keys pairs if needed"
echo "Don't forget to add your personal public key to authorized_keys if needed"


# install basic needed software and libs
sudo apt update \
    && sudo apt upgrade -y \
    && sudo apt install -y \
        zsh \
        git \
        vim \
        neovim \
        vim \
        curl \
        wget \
        python3 \
        python3-pip \
        python3-venv \
        telnet \
        tmux \
        htop \
        apt-transport-https \
        ca-certificates \
        software-properties-common

sudo chsh -s $(which zsh)

# install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update \
    && sudo apt-get install docker-ce docker-ce-cli containerd.io

sudo usermod -aG docker $USER
sudo systemctl enable docker





