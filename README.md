# dotfiles

Dotfiles for setting up a new install.

## Usage

```
git clone git@github.com:bhorvath/dotfiles.git ~/.dotfiles
~/.dotfiles/setup.sh
source ~/.bashrc
```

## Arguments

You can pass arguments to `setup.sh` to modify what is installed.

Argument        | Description
--------        | -----------
`--zsh`         | if using zsh as your preferred shell
`--bash`        | if using bash as your preferred shell
`--development` | install dependencies for development (RVM, etc)
`--gui`         | sets up configuration for X
`--help`        | displays help
