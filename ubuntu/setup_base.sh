#!/bin/bash

set -x

deploy() {
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
            git-crypt \
            vim \
            neovim \
            vim \
            curl \
            wget \
            gnupg \
            openssl \
            pass \
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
        && sudo apt-get -y install docker-ce docker-ce-cli containerd.io

    sudo usermod -aG docker $USER
    sudo systemctl enable docker
}

if [ $# -eq 1 ]; then
    sudo groupadd "$1"
    sudo useradd -m -g "$1" "$1"
    sudo usermod -aG sudo "$1"
    sudo su - $1 -c "$(declare -f deploy); deploy"
elif [ $# -eq 2 ]; then
    sudo groupadd "$2"
    sudo useradd -m -g "$2" "$1"
    sudo usermod -aG sudo "$1"
    sudo su - $1 -c "$(declare -f deploy); deploy"
else
    if [ "$(id -u)" -eq 0 ]; then
      echo "Please run this script from your user account or with username param:"
      echo "setup_base.sh username"
      echo "or"
      echo "setup_base.sh username groupname"
      exit 1
    fi
    deploy
fi

