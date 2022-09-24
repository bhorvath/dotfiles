#!/bin/sh
case "$1" in
  "day")
    brightness="80"
    ;;
  "night")
    brightness="20"
    ;;
  *)
    echo "Invalid argument: $1\nMust be one of 'day' or 'night'"
    exit 1
esac

ddcutil -d 1 setvcp 10 $brightness
ddcutil -d 2 setvcp 10 $brightness
