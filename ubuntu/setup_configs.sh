#!/bin/bash

if [ -d ~/environment ]; then
    echo "Please pre-clone environment repo with configs before running the script:"
    echo "git clone https://github.com/abogutskiy/environment.git ~/environment"
fi

# vim
mkdir -p ~/.config/nvim
ln -s ~/.config/nvim ~/.vim
cp environment/configs/init.vim ~/.config/nvim
ln -s ~/.config/nvim/init.vim ~/.vimrc
git clone https://github.com/VundleVim/Vundle.vim.git ~/config/nvim/bundle/Vundle.vim
vim -c PluginInstall -es

# git
cp ~/.environment/configs/.gitconfig ~/
cp ~/.environment/configs/.gitignore ~/

# Oh my zhsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
cp ~/.environment/configs/.zprofile ~/
cp ~/.environment/configs/.zshrc ~/
cp ~/.environment/configs/debug22.zsh-theme ~/.oh-my-zsh/themes/

# python
cp ~/.environment/configs/.pythonrc ~/


