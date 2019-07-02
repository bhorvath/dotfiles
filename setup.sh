#!/bin/bash

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

dotfiles_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dotfiles="bashrc bash_profile vimrc tmux.conf dir_colors gitconfig"
dependencies='tmux vim curl autoconf pkg-config'
backup_dir=$dotfiles_dir/dotfiles_bak
vundle_dir=~/.vim/bundle/Vundle.vim
install_rvm=true
if [ ! -d $vundle_dir ]; then install_vundle=true; else install_vundle=false; fi
if [ ! -d $backup_dir ]; then create_backup=true; else create_backup=false; fi
bold=`tput setaf 7`
normal=`tput sgr0`

_parse_options $@

echo -e "${bold}Installing dependencies...${normal}"
sudo apt-get -y install $dependencies

# Vundle
if [ "$install_vundle" = true ]; then
  echo -e "${bold}Installing Vundle...${normal}"
  git clone https://github.com/gmarik/vundle.git $vundle_dir
fi

# Only create a backup copy of existing config files once
if [ "$create_backup" = true ]; then
  echo -e "${bold}Backing up existing config files...${normal}"
  mkdir -v $backup_dir
  for file in $dotfiles; do
    if [ -f $file ]; then
      mv -v ~/.$file $backup_dir
    fi
  done
fi

echo -e "${bold}Adding symlinks...${normal}"
for file in $dotfiles; do
  ln -sfv $dotfiles_dir/$file ~/.$file
done

mkdir -pv ~/.vim/undo ~/.vim/swp

# ctags
if [ ! -f "/usr/local/bin/ctags" ];then
  echo -e "${bold}Installing universal-ctags...${normal}"
  ctags_dir=$dotfiles_dir/ctags
  git clone https://github.com/universal-ctags/ctags.git $ctags_dir
  cd $ctags_dir
  pwd
  ./autogen.sh
  ./configure
  make
  sudo make install
  rm -Rf $ctags_dir
fi

# RVM
if [ "$install_rvm" = true ]; then
  echo -e "${bold}Installing RVM...${normal}"
  \curl -L https://get.rvm.io | bash -s stable
fi

# Post-setup messages
if [ "$create_backup" = true ]; then
  echo -e "${bold}Backups of config files have been created in $backup_dir${normal}"
else
  echo -e -n "${bold}A backup of existing config files already exists at $backup_dir."
  echo -e " If you wish to create a new backup then first delete this directory and re-run setup.${normal}"
fi
if [ "$install_vundle" = true ]; then
  echo -e "${bold}To finish setting up Vundle, open vim and run :PluginInstall${normal}"
fi
