#!/usr/bin/env zsh

function _usage()
{
  echo "Usage: $0 [OPTION]..."
  echo "Options:"
  echo "    -u, --up            Move window focus up"
  echo "    -d, --down          Move window focus down"
  echo "    -l, --left          Move window focus left"
  echo "    -r, --right         Move window focus right"
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
      "--left") set -- "$@" "-l" ;;
      "--right") set -- "$@" "-r" ;;
      "--help") set -- "$@" "-h" ;;
      "--"*) _unrecognised_option {$arg}; exit 2;;
      *) set -- "$@" "$arg" ;;
    esac
  done

  # Parse short options
  OPTIND=1
  while getopts "udlrh" opt
  do
    case "$opt" in
      "u") _up ;;
      "d") _down ;;
      "l") _left ;;
      "r") _right ;;
      "h") _usage; exit 0 ;;
    esac
  done
  shift $(expr $OPTIND - 1)
}

function _setup_vertical {
  read -r window_left window_right < <(yabai -m query --windows |
    jq -re "[map(select(.\"has-focus\" == true)) |
    .[0].frame |
    .x, .x + .w] |
    join(\" \")")
}

function _up {
  _setup_vertical
  yabai -m window --focus "$(yabai -m query --windows |
    jq -e "map(select(.\"is-visible\" == true 
      and .frame.x <= $window_right 
      and .frame.x + .frame.w >= $window_left)) |
    sort_by(-.frame.y, .frame.x, .id) |
    nth(index(map(select(.\"has-focus\" == true))) + 1).id")"
}

function _down {
  _setup_vertical
  yabai -m window --focus "$(yabai -m query --windows |
    jq -e "map(select(.\"is-visible\" == true 
      and .frame.x <= $window_right 
      and .frame.x + .frame.w >= $window_left)) |
    sort_by(.frame.y, .frame.x, .id) |
    nth(index(map(select(.\"has-focus\" == true))) + 1).id")"
}

function _setup_horizontal {
  read -r window_top window_bottom < <(yabai -m query --windows |
    jq -re "[map(select(.\"has-focus\" == true)) |
    .[0].frame |
    .y, .y + .h] |
    join(\" \")")
}

function _left {
  _setup_horizontal
  yabai -m window --focus "$(yabai -m query --windows |
    jq -e "map(select(.\"is-visible\" == true 
      and .frame.y <= $window_bottom 
      and .frame.y + .frame.h >= $window_top)) |
    sort_by(-.frame.x, .frame.y, .id) |
    nth(index(map(select(.\"has-focus\" == true))) + 1).id")"
}

function _right {
  _setup_horizontal
  yabai -m window --focus "$(yabai -m query --windows |
    jq -e "map(select(.\"is-visible\" == true 
      and .frame.y <= $window_bottom 
      and .frame.y + .frame.h >= $window_top)) |
    sort_by(.frame.x, .frame.y, .id) |
    nth(index(map(select(.\"has-focus\" == true))) + 1).id")"
}

_parse_options $@
