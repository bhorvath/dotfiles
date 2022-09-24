# dotfiles

Dotfiles for setting up a new install.

## Usage

Clone the repo.

```
git clone git@github.com:bhorvath/dotfiles.git ~/.dotfiles
```

For macOS:
```
~/.dotfiles/setup_mac.sh
```

For Linux (not currently maintained):
```
~/.dotfiles/setup_linux.sh
```

## Arguments

You can pass arguments to `setup_linux.sh` to modify what is installed.

Argument        | Description
--------        | -----------
`--zsh`         | if using zsh as your preferred shell
`--bash`        | if using bash as your preferred shell
`--development` | install dependencies for development (nvm, etc)
`--gui`         | sets up configuration for X
`--laptop`      | sets up laptop specific configurations
`--help`        | displays help
