#!/usr/bin/env bash

target_space=$1

# current_display=$(yabai -m query --displays --display | jq '.index')
# target_display=$(yabai -m query --displays --space ${tgt_space} | jq '.index')

# keycode=(0 18 19 20 21 23 22 26 28 25 29)
keystroke=("u" "i" "o" "p")

# if [[ ${cur_display} != ${tgt_display} ]]; then
#   yabai -m display --focus ${tgt_display}
# fi

osascript -e "tell application \"System Events\" to keystroke \"${keystroke[${target_space} - 1]}\" using {command down, option down, control down}"
