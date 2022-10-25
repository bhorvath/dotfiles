#!/bin/bash

function _usage()
{
  echo "Usage: setup_mac.sh [OPTION]..."
  echo "Options:"
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
      "--help") set -- "$@" "-h" ;;
      "--"*) _unrecognised_option {$arg}; exit 2;;
      *) set -- "$@" "$arg" ;;
    esac
  done

  # Parse short options
  OPTIND=1
  while getopts "h" opt
  do
    case "$opt" in
      "h") _usage; exit 0 ;;
    esac
  done
  shift $(expr $OPTIND - 1)
}

function _backup()
{
  echo -e "${bold}Backing up existing config files...${normal}"
  now=`date +%y%m%d_%H%M%S`
  mkdir -p $backup_dir/$now
  dotfiles="$shared_dotfiles $mac_dotfiles"
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

}

function _symlinks()
{
  echo -e "${bold}Adding symlinks...${normal}"
  for file in $shared_dotfiles; do
    ln -sfv $dotfiles_dir/shared/$file ~/.$file
  done
  for file in $mac_dotfiles; do
    ln -sfv $dotfiles_dir/mac/$file ~/.$file
  done
  for dir in $config_dirs; do
    ln -sfv $dotfiles_dir/mac/$dir ~/.config
  done
}

function _brew()
{
  brew -v > /dev/null
  if [ $? != 0 ]; then
    echo -e "${bold}Installing Homebrew...${normal}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    brew analytics off
  else
    echo -e "${bold}Updating Homebrew...${normal}"
    brew update
  fi

  echo -e "${bold}Installing packages via Homebrew...${normal}"
  brew install "${packages[@]}"
  brew install --cask "${cask_packages[@]}"
}

function _yabai()
{
  echo -e "${bold}Setting up yabai...${normal}"
  brew install koekeishiya/formulae/yabai
  brew services start yabai
}

function _skhd()
{
  echo -e "${bold}Setting up skhd...${normal}"
  brew install koekeishiya/formulae/skhd
  brew services start skhd
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
  echo -e "${bold}Installing nvm...${normal}"
  [ -s "$NVM_DIR/nvm.sh"  ] && \. "$NVM_DIR/nvm.sh"
  nvm -v > /dev/null
  if [ $? != 0 ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
  else
    echo "nvm already installed"
  fi
}

function _cleanup()
{
  echo -e "${bold}Backups of config files have been created in $backup_dir/$now${normal}"

  if [ "$install_vundle" = true ]; then
    echo -e "${bold}To finish setting up Vundle, open vim and run :PluginInstall${normal}"
  fi
}

shared_dotfiles="aliases docker_aliases git_aliases gitconfig tmux.conf vimrc zshrc"
mac_dotfiles="zprofile"
dotfiles_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
config_dirs="yabai skhd"
backup_dir=$dotfiles_dir/backups

packages=(
  fzf
  jq
  tmux
)

cask_packages=(
  authy
  docker
  iterm2
  slack
  thunderbird
  visual-studio-code
)

bold=`tput setaf 7`
normal=`tput sgr0`

_parse_options $@
_backup
_symlinks
_brew
_yabai
_skhd
_zsh
_vim
_nvm
_cleanup
