#!/bin/sh

STEP_SIZE=10
BRIGHTNESS=$(xbacklight -get | cut -f1 -d'.')

case "$1" in
  "up")
    if [ "$BRIGHTNESS" -eq "0" ]
    then
      ARGS="-set 1"
    elif [ "$BRIGHTNESS" -lt "5" ]
    then
      ARGS="-set 5"
    elif [ "$BRIGHTNESS" -lt "10" ]
    then
      ARGS="-set 10"
    else
      ARGS="-inc $STEP_SIZE"
    fi
    ;;
  "down")
    if [ "$BRIGHTNESS" -eq "1" ]
    then
      ARGS="-set 0"
    elif [ "$BRIGHTNESS" -le "5" ]
    then
      ARGS="-set 1"
    elif [ "$BRIGHTNESS" -le "10" ]
    then
      ARGS="-set 5"
    else
      ARGS="-dec $STEP_SIZE"
    fi
    ;;
  *)
    echo "Invalid argument: $1\nMust be one of 'up' or 'down'"
    exit 1
esac

xbacklight $ARGS
