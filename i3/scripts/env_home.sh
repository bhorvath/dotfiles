#!/bin/sh
# Home - 2 monitors + laptop
#xrandr --output DP1 --mode 1920x1080 --pos 0x0 --output DP3 --mode 1920x1080 --pos 1920x0 --output eDP1 --mode 1920x1080 --pos 3400x1080
# Home - right monitor + laptop
xrandr --output DP3 --mode 1920x1080 --pos 0x0 --output eDP1 --mode 1920x1080 --pos 1400x1080
# Home - left monitor + laptop
# xrandr --output DP1 --mode 1920x1080 --pos 0x0 --output eDP1 --mode 1920x1080 --pos 1000x1080

# Work
#xrandr --output DP1-3 --mode 1920x1080 --pos 0x0 --output DP2 --mode 2560x1440 --pos 1920x0 --output eDP1 --mode 1920x1080 --pos 2240x1440

# Portable
#xrandr --output eDP1 --mode 1920x1080 --pos 0x0
echo Home environment
