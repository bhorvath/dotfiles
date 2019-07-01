#!/bin/bash

dotfiles_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dotfiles="bashrc bash_profile vimrc tmux.conf dir_colors gitconfig"
backup_dir=$dotfiles_dir/dotfiles_bak
dependencies='tmux vim curl'
install_rvm=true

function _usage()
{
  echo "Usage: setup.sh [OPTION]..."
  echo "Options:"
  echo "    -r, --no-rvm     Skip installing RVM"
  echo "    -h, --help       Show this message"
}

function _unrecognised_option()
{
  echo "setup.sh: unrecognised option '$1'"
  echo "Try 'setup.sh --help' for more information."
}

function _parse_options()
{
  # Convert long options to short options
  for arg in "$@"; do
    shift
    case "$arg" in
      "--no-rvm") set -- "$@" "-r" ;;
      "--help") set -- "$@" "-h" ;;
      "--"*) _unrecognised_option {$arg}; exit 2;;
      *) set -- "$@" "$arg" ;;
    esac
  done

  # Parse short options
  OPTIND=1
  while getopts "rh" opt
  do
    case "$opt" in
      "r") install_rvm=false ;;
      "h") _usage; exit 0 ;;
    esac
  done
  shift $(expr $OPTIND - 1)
}

_parse_options $@

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
  for file in $dotfiles; do
    if [ -f $file ]; then
      mv -v ~/.$file $backup_dir
    fi
  done
else
  echo -n "A backup of existing config files already exists at $backup_dir."
  echo " If you wish to create a new backup then first delete this directory."
fi

for file in $dotfiles; do
  ln -sfv $dotfiles_dir/$file ~/.$file
done

mkdir -pv ~/.vim/undo ~/.vim/swp

# RVM
if [ "$install_rvm" = true ]; then
  \curl -L https://get.rvm.io | bash -s stable
fi
