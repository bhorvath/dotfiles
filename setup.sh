#!/bin/bash

function _usage()
{
  echo "Usage: setup.sh [OPTION]..."
  echo "Options:"
  echo "    -z, --zsh             Use zsh"
  echo "    -b, --bash            Use bash"
  echo "    -d, --development     Setup for development"
  echo "    -g, --gui             Setup for GUI"
  echo "    -h, --help            Show this message"
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
      "--zsh") set -- "$@" "-z" ;;
      "--bash") set -- "$@" "-b" ;;
      "--development") set -- "$@" "-d" ;;
      "--gui") set -- "$@" "-g" ;;
      "--help") set -- "$@" "-h" ;;
      "--"*) _unrecognised_option {$arg}; exit 2;;
      *) set -- "$@" "$arg" ;;
    esac
  done

  # Parse short options
  OPTIND=1
  while getopts "zbdgh" opt
  do
    case "$opt" in
      "z") zsh=true ;;
      "b") bash=true ;;
      "d") development=true ;;
      "g") gui=true ;;
      "h") _usage; exit 0 ;;
    esac
  done
  shift $(expr $OPTIND - 1)
}

function _find_package_manager()
{
  pacman=`command -v pacman`
  if [ -n "$pacman" ]; then
    package_manager_command="$pacman -Syu --noconfirm "
    return
  fi

  apt=`command -v apt`
  if [ -n "$apt" ]; then
    package_manager_command="$apt -y install "
    return
  fi

  echo "Package manager not found"
  exit 1
}

zsh=false
bash=false
zsh_dotfiles="zshrc"
bash_dotfiles="bashrc bash_profile"
gui_config_dirs="i3 i3blocks rofi"
gui_dotfiles="Xresources"
dotfiles="vimrc tmux.conf dir_colors gitconfig aliases docker_aliases"
dotfiles_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dependencies="tmux vim"
backup_dir=$dotfiles_dir/backup
vundle_dir=~/.vim/bundle/Vundle.vim
development=false

_find_package_manager

# Only install vundle once
if [ ! -d $vundle_dir ]; then install_vundle=true; else install_vundle=false; fi
# Only create a backup once
if [ ! -d $backup_dir ]; then create_backup=true; else create_backup=false; fi

_parse_options $@

if [ "$zsh" = true ]; then
  dotfiles+=" $zsh_dotfiles"
  dependencies+=" zsh"
fi

if [ "$bash" = true ]; then
  dotfiles+=" $bash_dotfiles"
fi

if [ "$development" = true ]; then
  dependencies+=" curl"
fi

if [ "$gui" = true ]; then
  dependencies+=" i3-gaps i3blocks rofi"
fi

bold=`tput setaf 7`
normal=`tput sgr0`

echo -e "${bold}Installing dependencies...${normal}"
sudo $package_manager_command $dependencies

if [ "$zsh" = true ]; then
  echo -e "${bold}Installing zsh plugins...${normal}"
  git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-history-substring-search ~/.zsh/zsh-history-substring-search
fi

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
  for file in $gui_dotfiles; do
    if [ -f $file ]; then
      mv -v ~/.$file $backup_dir
    fi
  done
  for dir in $gui_config_dirs; do
    if [ -d $dir ]; then
      mv -v ~/.config/$dir $backup_dir
    fi
  done
fi

echo -e "${bold}Adding symlinks...${normal}"
for file in $dotfiles; do
  ln -sfv $dotfiles_dir/$file ~/.$file
done

if [ "$gui" = true ]; then
  for dir in $gui_config_dirs; do
    ln -sfv $dotfiles_dir/$dir ~/.config/$dir
  done
  for file in $gui_dotfiles; do
    ln -sfv $dotfiles_dir/$file ~/.$file
  done
  xrdb ~/.Xresources
fi

mkdir -pv ~/.vim/undo ~/.vim/swp

if [ "$development" = true ]; then
  # Install RVM
  echo -e "${bold}Installing RVM...${normal}"
  gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
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
