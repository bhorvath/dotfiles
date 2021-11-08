#!/bin/sh
xset r rate 200 25
touchpad_id=`xinput | grep Touchpad | sed -E 's/.*id=([[:digit:]]+).*/\1/'`
xinput set-prop $touchpad_id "libinput Tapping Enabled" 1
