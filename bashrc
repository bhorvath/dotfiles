# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

function __prompt_command()
{
  exit_status="$?"
  PS1=""

  # Show history line number and set colour based on exit code of last command
   if [ $exit_status -eq 0 ]; then PS1+="$green"; else PS1+="$red"; fi
   PS1+="\!$nc "

  # Show chroot name if in a chroot
  PS1+="${debian_chroot:+($debian_chroot)}"

  PS1+="$yellow\u$nc@$yellow\h$nc$remote_term:$purple\w$nc$green$(__git_ps1 " (%s)")$nc "

  # Show $ or # for root
  PS1+="\$ "
}

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=100000
HISTFILESIZE=100000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

nc="\[\033[0m\]" # No colour
red="\[\033[0;31m\]"
green="\[\033[0;32m\]"
orange="\[\033[1;31m\]"
yellow="\[\033[0;33m\]"
purple="\[\033[1;35m\]"
if [ "$SSH_CONNECTION" != "" ]; then remote_term="$orange[R]$nc"; else remote_term=""; fi

# Show a marker if the git repo is dirty
GIT_PS1_SHOWDIRTYSTATE=1

PROMPT_COMMAND=__prompt_command

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Bash aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Docker aliases
if [ -f ~/.docker_aliases ]; then
  . ~/.docker_aliases
fi

# Git alias
alias g='git'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

# Only start tmux if not an ssh connection
if [[ -z "$TMUX" ]] && [ "$SSH_CONNECTION" == "" ]; then
  exec tmux
fi
