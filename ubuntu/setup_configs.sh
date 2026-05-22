#!/usr/bin/env bash

set -euo pipefail

# Optional first arg: target username for `usermod` (requires sudo, works for any user).
# When omitted, fall back to `chsh` for the current user (prompts for password, no sudo).
TARGET_USER="${1:-}"

if [ ! -d ~/environment ]; then
    echo "Please pre-clone environment repo with configs before running the script:"
    echo "git clone https://github.com/abogutskiy/environment.git ~/environment"
    exit 1
fi

if ! command -v zsh >/dev/null 2>&1; then
    echo "zsh is not installed — run setup_base.sh first (or: sudo apt install -y zsh)"
    exit 1
fi

set -x

# vim
rm -rf ~/.config/nvim
mkdir -p ~/.config/nvim
rm -rf ~/.vim
ln -s ~/.config/nvim ~/.vim
cp ~/environment/configs/init.vim ~/.config/nvim/init.vim
rm -f ~/.vimrc
ln -s ~/.config/nvim/init.vim ~/.vimrc
git clone https://github.com/VundleVim/Vundle.vim.git ~/.config/nvim/bundle/Vundle.vim
echo "Run PluginInstall in vim or neovim"

# git
cp ~/environment/configs/.gitconfig ~/
cp ~/environment/configs/.gitignore ~/


# switch default shell to zsh and install oh-my-zsh (skip if zsh is already default)
ZSH_PATH=$(command -v zsh)
if [ -n "$TARGET_USER" ]; then
    sudo usermod -s "$ZSH_PATH" "$TARGET_USER"
else
    chsh -s "$ZSH_PATH"
fi


# Oh my zsh
rm -rf ~/.oh-my-zsh
set +x
echo "sh -c curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
set -x

mkdir -p ~/.oh-my-zsh/themes
cp ~/environment/configs/debug22.zsh-theme ~/.oh-my-zsh/themes/debug22.zsh-theme

set -x
# bashrc/zshrc
cp ~/environment/configs/.zprofile ~/
cp ~/environment/configs/.zshrc ~/
cp ~/environment/configs/.bashrc ~/
cp ~/environment/configs/.profile ~/

cp ~/environment/configs/.bash_aliases ~/

# modify rc
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

# python
cp ~/environment/configs/.pythonrc ~/

# claude
mkdir -p ~/.claude
cp -r ~/environment/configs/claude/. ~/.claude/


