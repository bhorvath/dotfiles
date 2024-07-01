#!/bin/sh

function _usage()
{
  echo "Usage: $0 [OPTION]..."
  echo "Options:"
  echo "    -u, --up            Resize window upwards by growing from the top or shrinking from the bottom depending on window height"
  echo "    -d, --down          Resize window downwards by growing from the bottom or shrinking from the top depending on window height"
  echo "    -l, --left          Resize window to the left (requires --grow or --shrink)"
  echo "    -r, --right         Resize window to the right (requires --grow or --shrink)"
  echo "    -g, --grow          Grow window when resizing horizontally"
  echo "    -s, --shrink        Shrink window when resizing horizontally"
  echo "    -h, --help          Show this message"
}

function _unrecognised_option()
{
  echo "$0: unrecognised option '$1'"
  echo "Try '$0 --help' for more information."
}

function _parse_options()
{
  # Convert long options to short options
  for arg in "$@"; do
    shift
    case "$arg" in
      "--up") set -- "$@" "-u" ;;
      "--down") set -- "$@" "-d" ;;
      "--grow") set -- "$@" "-g" ;;
      "--shrink") set -- "$@" "-s" ;;
      "--left") set -- "$@" "-l" ;;
      "--right") set -- "$@" "-r" ;;
      "--help") set -- "$@" "-h" ;;
      "--"*) _unrecognised_option {$arg}; exit 2;;
      *) set -- "$@" "$arg" ;;
    esac
  done

  # Parse short options
  OPTIND=1
  while getopts "udlgsrh" opt
  do
    case "$opt" in
      "u") _up ;;
      "d") _down ;;
      "g") horizontal_resize_method="grow" ;;
      "s") horizontal_resize_method="shrink" ;;
      "l") _horizontal_resize "left" ;;
      "r") _horizontal_resize "right";;
      "h") _usage; exit 0 ;;
    esac
  done
  shift $(expr $OPTIND - 1)
}

function _setup_vertical {
  rows=2
  padding=6
  offset=$(($padding/2))
  # TODO: Work out programmatically
  #37: laptop screen
  #25: external monitor
  menu_bar_height=25

  screen_height=`yabai -m query --displays | jq ".[0].frame.h | floor"`
  row_height=$((($screen_height-$menu_bar_height)/$rows))
  window_y=`yabai -m query --windows | jq -r "nth(index(map(select(.\"has-focus\" == true)))) | .frame.y | floor"`
  window_height=`yabai -m query --windows | jq -r "nth(index(map(select(.\"has-focus\" == true)))) | .frame.h | floor"`
}

function _up {
  _setup_vertical  
  if [ $window_y -eq $menu_bar_height ]; then
    # Handle full height window
    if [ $(($window_height + $menu_bar_height)) -eq $screen_height ]; then
      local resize=$(($row_height+$offset))
      yabai -m window --resize bottom:0:-$resize
    fi
  elif [ $window_y -eq $(( $menu_bar_height + $row_height + $offset )) ] && [ $(($window_y + $window_height)) -eq $screen_height ]; then
    # Handle half height window
    local resize=$(($screen_height-$window_height-$menu_bar_height))
    yabai -m window --resize top:0:-$resize
  fi
}

function _down {
  _setup_vertical  
  if [ $window_y -eq $menu_bar_height ]; then
    # Handle full height window
    if [ $(($window_height + $menu_bar_height)) -eq $screen_height ]; then
      local resize=$(($row_height+$offset))
      yabai -m window --resize top:0:$resize
    # Handle half height window
    else
      local resize=$(($screen_height-$window_height-$menu_bar_height))
      yabai -m window --resize bottom:0:$resize
    fi
  fi
}

function _horizontal_resize {
  if [ -z $horizontal_resize_method ]; then
    _usage
    exit 1
  fi

  _setup_horizontal

  if [ $horizontal_resize_method = "grow" ]; then
    _grow $1
  elif [ $horizontal_resize_method = "shrink" ]; then
    _shrink $1
  fi
}

function _setup_horizontal {
  columns=3
  padding=6

  screen_width=`yabai -m query --displays | jq ".[0].frame.w | floor"`
  screen_height=`yabai -m query --displays | jq ".[0].frame.h | floor"`
  column_width=$(($screen_width/$columns))
  window_x=`yabai -m query --windows | jq -r "nth(index(map(select(.\"has-focus\" == true)))) | .frame.x | floor"`
  window_width=`yabai -m query --windows | jq -r "nth(index(map(select(.\"has-focus\" == true)))) | .frame.w | floor"`
}

function _grow {
  local offset=$(($padding/2))
  local grow=$column_width
  # If we are `offset` away from the max size then extend to the edge
  if [ $screen_width -eq $(($window_x + $window_width + $grow + $offset)) ]; then
    echo "edge"
    grow=$(($grow+$offset))
  fi

  if [ $1 = "left" ]; then
    local resize_amount=left:-$grow:0
  elif [ $1 = "right" ]; then
    local resize_amount=right:$grow:0
  fi
  yabai -m window --resize $resize_amount
}

function _shrink {
  local offset=$(($padding/2))
  local shrink=$column_width
  # If the window is currently at max width to the right then add additional `offset` amount when shrinking
  if [ $screen_width -eq $(($window_x + $window_width)) ]; then
    echo "edge"
    shrink=$(($shrink+$offset))
  fi

  if [ $1 = "left" ]; then
    local resize_amount=left:$shrink:0
  elif [ $1 = "right" ]; then
    local resize_amount=right:-$shrink:0
  fi
  yabai -m window --resize $resize_amount
}

_parse_options $@
