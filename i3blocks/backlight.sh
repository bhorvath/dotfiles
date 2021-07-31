#!/usr/bin/env bash

# Show the screen brightness value given by `xbacklight`.
# Right clicking turns off the backlight and scrolling increases or decreases
# the brightness.

case $BLOCK_BUTTON in
  3) xbacklight -set 0 ;; # right click
  4) ~/.dotfiles/i3/scripts/backlight.sh up ;; # scroll up
  5) ~/.dotfiles/i3/scripts/backlight.sh down ;; # scroll down, decrease
esac

BRIGHTNESS=$(xbacklight -get | cut -f1 -d'.')
echo "${BRIGHTNESS}%"
