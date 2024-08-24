#!/bin/bash

if [ ! -d ~/environment ]; then
    echo "Please pre-clone environment repo with configs before running the script:"
    echo "git clone https://github.com/abogutskiy/environment.git ~/environment"
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

# Oh my zhsh
rm -rf ~/.oh-my-zsh
set +x
echo "sh -c curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

set -x
cp ~/environment/configs/.zprofile ~/
cp ~/environment/configs/.zshrc ~/
cp ~/environment/configs/debug22.zsh-theme ~/.oh-my-zsh/themes/debug22.zsh-theme

# bashrc
cp ~/environment/configs/.bashrc ~/
cp ~/environment/configs/.profile ~/

cp ~/environment/configs/.bash_aliases ~/

# python
cp ~/environment/configs/.pythonrc ~/

