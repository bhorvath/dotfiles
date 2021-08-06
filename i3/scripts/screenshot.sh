#!/bin/bash

screenshot_dir=$HOME/screenshots
if ! [ -d $screenshot_dir ]; then
  mkdir -p $screenshot_dir
fi
cd $screenshot_dir

# Sleep to make sure pointer is available
sleep 0.2

filename="screenshot_%Y%m%d-%H%M%S.png"

case "$1" in
  --all|-a|$NULL)
    file=`scrot $filename -e 'echo $f'` &&
    notify-send "Screenshot saved as $file"
    ;;
  --window|-w)
    file=`scrot $filename -u -e 'echo $f'` &&
    notify-send "Screenshot saved as $file"
    ;;
  --selection|-s)
    file=`scrot $filename -s -e 'echo $f'` &&
    notify-send "Screenshot saved as $file"
    ;;
  --clipboard|-c)
    scrot $filename -s -e 'xclip -selection clipboard -t image/png -i $f && rm $f' &&
    notify-send "Screenshot copied to clipboard"
    ;;
  *)
  echo "Usage: screenshot.sh [OPTION]...
Options:
    -a, --all             Capture all displays (default)
    -w, --window          Capture focused window
    -s, --selection       Capture selected area
    -c, --clipboard       Copy selected area to clipboard"
esac
