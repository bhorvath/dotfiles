#!/usr/bin/env sh
PID=$(pgrep -x "$1")

if [ ! -z "$PID" ]; then
  echo "$PID" | xargs kill
else
  "$1"
fi
