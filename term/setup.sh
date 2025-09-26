#!/bin/bash

set -e 

echo
echo "Setting up .mybashrc"
mybashrc="$HOME/.mybashrc"
rm -f $mybashrc
ln -s $PWD/.mybashrc $mybashrc
echo ". ~/.mybashrc" >> ~/.bashrc

echo
echo "yo! Setting up term configs"

echo
echo "Creating dirs"
mkdir -p $HOME/.vim
mkdir -p $HOME/.config/nvim
mkdir -p $HOME/.config/nvim/lua
mkdir -p $HOME/.config/ghostty

vimrc="$HOME/.vimrc"
nvimrc="$HOME/.config/nvim/init.vim"
nvimlua="$HOME/.config/nvim/lua/init.lua"
tmuxconf="$HOME/.tmux.conf"
ghosttyconf="$HOME/.config/ghostty/config"

echo
read -p "Clean existing config files? [Yy]es|[Nn]no: " in
case "$in" in
    [Yy])
        echo "Deleting existing configs..."
            rm -f $vimrc
            rm -f $nvimrc
            rm -f $nvimlua
            rm -f $tmuxconf
            rm -f $ghosttyconf
        ;;
    [Nn])
        echo 
        ;;
    *)
        echo "Invalid input. Please enter 'yes' or 'no'."
        exit 1
        ;;
esac


echo
echo "Symlinking configs"
# Gotta use absolute paths for symlinks!
ln -s $PWD/vim/.vimrc $vimrc
ln -s $PWD/vim/.vimrc $nvimrc
ln -s $PWD/vim/init.lua $nvimlua
ln -s $PWD/.tmux.conf $tmuxconf
ln -s $PWD/ghostty.conf $ghosttyconf

echo Done!

