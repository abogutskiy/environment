#!/usr/bin/env bash

if [ "$(id -u)" -eq 0 ]; then
  echo "Please run this script from your sudoer user account"
  exit 1
fi

set -euxo pipefail

# Avoid interactive prompts from apt/needrestart that can stall the script
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# create all necessary files/folders
mkdir -p ~/.ssh
chmod 700 ~/.ssh
sudo chown $USER:$USER ~/.ssh
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
echo "Don't forget add public/private keys pairs if needed"
echo "Don't forget to add your personal public key to authorized_keys if needed"


# install basic needed software and libs
# install before upgrade so a stalled/failed upgrade doesn't skip the install
sudo -E apt update
sudo -E apt install -y \
    zsh \
    git \
    git-crypt \
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
    software-properties-common \
    postgresql \
    postgresql-contrib
sudo -E apt upgrade -y

sudo usermod -s $(which zsh) $USER

# install neovim from snap (newer than apt — apt ships an old 0.7.x while snap is on 0.12.x)
sudo snap install --classic nvim

# install claude cli (skip if already installed)
if command -v claude >/dev/null 2>&1 || [ -x "$HOME/.local/bin/claude" ]; then
    echo "claude already installed, skipping"
else
    curl -fsSL https://claude.ai/install.sh | bash
fi

# install docker (skip if already installed)
if command -v docker >/dev/null 2>&1; then
    echo "docker already installed, skipping"
else
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo -E apt-get update
    sudo -E apt-get -y install docker-ce docker-ce-cli containerd.io
fi

sudo usermod -aG docker $USER
sudo systemctl enable docker

if [ ! -d ~/environment ]; then
    git clone https://github.com/abogutskiy/environment.git ~/environment
fi
