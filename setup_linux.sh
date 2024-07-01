#!/bin/bash

function _usage()
{
  echo "Usage: setup_linux.sh [OPTION]..."
  echo "Options:"
  echo "    -b, --bash            Use bash"
  echo "    -d, --development     Setup for development"
  echo "    -g, --gui             Setup for GUI"
  echo "    -l, --laptop          Setup for laptop"
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
      "--bash") set -- "$@" "-b" ;;
      "--development") set -- "$@" "-d" ;;
      "--gui") set -- "$@" "-g" ;;
      "--laptop") set -- "$@" "-l" ;;
      "--help") set -- "$@" "-h" ;;
      "--"*) _unrecognised_option {$arg}; exit 2;;
      *) set -- "$@" "$arg" ;;
    esac
  done

  # Parse short options
  OPTIND=1
  while getopts "bdglh" opt
  do
    case "$opt" in
      "b") bash=true ;;
      "d") development=true ;;
      "g") gui=true ;;
      "l") laptop=true ;;
      "h") _usage; exit 0 ;;
    esac
  done
  shift $(expr $OPTIND - 1)
}

function _setup()
{
  if [ "$bash" = true ]; then
    linux_dotfiles+=" $bash_dotfiles"
  fi

  if [ "$development" = true ]; then
    dependencies+=" curl"
  fi

  if [ "$gui" = true ]; then
    linux_dotfiles+=" $gui_dotfiles"
    dependencies+=" i3 i3blocks rofi rxvt-unicode xsel solaar mousepad pcmanfm ddcutil autorandr xclip"
  fi

  if [ "$laptop" = true ]; then
    dependencies+=" xbacklight"
  fi
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

function _backup()
{
  echo -e "${bold}Backing up existing config files...${normal}"
  now=`date +%y%m%d_%H%M%S`
  mkdir -p $backup_dir/$now
  dotfiles="$shared_dotfiles $linux_dotfiles"
  for file in $dotfiles; do
    if [ -f ~/.$file ]; then
      mv -v ~/.$file $backup_dir/$now
    fi
  done
  for dir in $config_dirs; do
    if [ -d ~/.config/$dir ]; then
      mv -v ~/.config/$dir $backup_dir/$now
    fi
  done
  for dir in $gui_config_dirs; do
    if [ -d $dir ]; then
      mv -v ~/.config/$dir $backup_dir/$now
    fi
  done
}

function _symlinks()
{
  echo -e "${bold}Adding symlinks...${normal}"
  for file in $shared_dotfiles; do
    ln -sfv $dotfiles_dir/shared/$file ~/.$file
  done
  echo "linux dotfiles $linux_dotfiles"

  for file in $linux_dotfiles; do
    ln -sfv $dotfiles_dir/linux/$file ~/.$file
  done

  if [ "$gui" = true ]; then
    for dir in $gui_config_dirs; do
      ln -sfv $dotfiles_dir/$dir ~/.config
    done
  fi
}

function _packages()
{
  echo -e "${bold}Installing dependencies...${normal}"
  sudo $package_manager_command $dependencies
}

function _zsh()
{
  echo -e "${bold}Installing zsh plugins...${normal}"

  if [ ! -d  ~/.zsh/zsh-autosuggestions ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
  else
    echo "zsh-autosuggestions already installed"
  fi

  if [ ! -d  ~/.zsh/zsh-history-substring-search ]; then
    git clone https://github.com/zsh-users/zsh-history-substring-search ~/.zsh/zsh-history-substring-search
  else
    echo "zsh-history-substring-search already installed"
  fi
}

function _vim()
{
  mkdir -p ~/.vim/undo ~/.vim/swp

  echo -e "${bold}Installing Vundle...${normal}"
  vundle_dir=~/.vim/bundle/Vundle.vim
  if [ ! -d $vundle_dir ]; then install_vundle=true; else install_vundle=false; fi
  if [ "$install_vundle" = true ]; then
    git clone https://github.com/gmarik/vundle.git $vundle_dir
  else
    echo "Vundle already installed"
  fi
}

function _nvm()
{
  if [ "$development" = true ]; then
    echo -e "${bold}Installing nvm...${normal}"
    [ -s "$NVM_DIR/nvm.sh"  ] && \. "$NVM_DIR/nvm.sh"
    nvm -v > /dev/null
    if [ $? != 0 ]; then
      curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    else
      echo "nvm already installed"
    fi
  fi
}

function _x()
{
  if [ "$gui" = true ]; then
    xrdb ~/.Xresources
  fi

}

function _cleanup()
{
  echo -e "${bold}Backups of config files have been created in $backup_dir/$now${normal}"

  if [ "$install_vundle" = true ]; then
    echo -e "${bold}To finish setting up Vundle, open vim and run :PluginInstall${normal}"
  fi
}

bash=false
development=false
gui=false
laptop=false

shared_dotfiles="aliases docker_aliases git_aliases gitconfig tmux.conf vimrc zshrc"
linux_dotfiles="dir_colors"
bash_dotfiles="bashrc bash_profile"
gui_config_dirs="i3 i3blocks rofi"
gui_dotfiles="Xresources"
dotfiles_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dependencies="tmux vim git fzf awk"
backup_dir=$dotfiles_dir/backup
vundle_dir=~/.vim/bundle/Vundle.vim

bold=`tput setaf 7`
normal=`tput sgr0`

_parse_options $@
_setup
_find_package_manager
_backup
_symlinks
_packages
_zsh
_vim
_nvm
_x
_cleanup

