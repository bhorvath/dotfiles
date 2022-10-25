#!/bin/sh

function _usage()
{
  echo "Usage: $0 POSITION"
  echo "Divides the screen into $columns columns. The window will be positioned within the specified column, starting at 0."
}

function _check_parameters {
  if [[ $1 -ge 0 && $1 -lt $columns ]]; then
    :
  else
    _usage
    exit 1
  fi
}

function _setup {
  columns=3
  padding=6
}

function _position {
  left_offset=0
  right_offset=0
  screen_width=`yabai -m query --displays | jq ".[0].frame.w"`
  screen_height=`yabai -m query --displays | jq ".[0].frame.h"`
  column_width=$(($screen_width/$columns))

  # Work out offsets based on position and padding
  if [ $1 -eq 0 ]; then
    # Left
    right_offset=$((padding/2))
  elif [ $1 -eq $(($columns - 1)) ]; then
    # Right
    left_offset=$((padding/2))
  else
    # Centre
    left_offset=$((padding/2))
    right_offset=$((padding/2))
  fi

  position=$(($column_width*$1+$left_offset))
  width=$(($column_width-$left_offset-$right_offset))

  yabai -m window --move abs:$position:0
  yabai -m window --resize abs:$width:$screen_height
}

# Not currently used
function _persist_window_properties {
  local window_id=`yabai -m query --windows | jq "nth(index(map(select(.\"has-focus\" == true)))).id"`
  local properties=`yabai -m query --windows | jq -r "[nth(index(map(select(.\"has-focus\" == true)))) | .frame.x, .frame.y, .frame.w, .frame.h] | join(\" \")"`
  echo $properties > /tmp/yabai/$window_id
}

_setup
_check_parameters $1
_position $1
#_persist_window_properties
