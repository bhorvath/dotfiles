#!/bin/bash

in=$(acpi battery)
status=$(echo "$in" | egrep -o 'Discharging|Charging|AC|Full|Unknown')
percentage=$(echo "$in" | grep -o '[0-9]\{1,3\}%')

case "$status" in
  "Discharging")
    out=" "
    ;;
   "Charging"|"AC"|"Full")
     out=" "
     ;;
   "Unknown")
     out=" "
     ;;
esac

out+=$percentage

echo $out

# Alert if the battery is low
if [[ $(echo $percentage | tr -d '%') -le 20  ]]; then
    exit 33
fi
