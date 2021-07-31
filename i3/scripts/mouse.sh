#!/bin/sh
case "$1" in
  "left")
    button_order="3 2 1"
    ;;
  "right")
    button_order="1 2 3"
    ;;
  *)
    echo "Invalid argument: $1\nMust be one of 'left' or 'right'"
    exit 1
esac

xmodmap -e "pointer = $button_order"
