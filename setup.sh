#!/bin/bash

dotfiles_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
files="bashrc bash_profile vimrc tmux.conf dir_colors"
backup_dir=$dotfiles_dir/dotfiles_bak
dependencies='tmux vim curl'

echo "Installing dependencies..."
sudo apt-get install $dependencies

# Vundle
vundle_dir=~/.vim/bundle/Vundle.vim
if [ ! -d $vundle_dir ]; then
  echo "Installing Vundle..."
  git clone https://github.com/gmarik/vundle.git $vundle_dir
fi


# Only create a backup copy of existing config files once
if [ ! -d $backup_dir ]; then
  echo "Backing up existing config files..."
  mkdir -v $backup_dir
  for file in $files; do
    if [ -f $file ]; then
      mv -v ~/.$file $backup_dir
    fi
  done
else
  echo -n "A backup of existing config files already exists at $backup_dir."
  echo " If you wish to create a new backup then first delete this directory."
fi

for file in $files; do
  ln -sfv $dotfiles_dir/$file ~/.$file
done

mkdir -pv ~/.vim/undo ~/.vim/swp

# RVM
\curl -L https://get.rvm.io | bash -s stable
