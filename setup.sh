#!/bin/bash

echo "Installing dependencies..."
sudo apt-get install tmux vim curl

# Vundle
git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
files="bashrc bash_profile vimrc tmux.conf dir_colors"
olddir=dotfiles_old

mkdir -v $dir/$olddir
for file in $files; do
    mv -v ~/.$file $dir/$olddir
    ln -sv $dir/$file ~/.$file
done

mkdir -pv ~/.vim/undo ~/.vim/swp

# RVM
\curl -L https://get.rvm.io | bash -s stable
