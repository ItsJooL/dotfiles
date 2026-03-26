#!/bin/bash

# Force C locale for numeric operations
export LC_NUMERIC=C

# Define the monitor
MONITOR="eDP-1"

# Get current monitor info
MONITOR_INFO=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$MONITOR\")")
WIDTH=$(echo "$MONITOR_INFO" | jq -r ".width")
HEIGHT=$(echo "$MONITOR_INFO" | jq -r ".height")
CURRENT_SCALE=$(echo "$MONITOR_INFO" | jq -r ".scale")
CURRENT_SCALE=$(printf "%.2f" "$CURRENT_SCALE")

# Define valid scales based on resolution
if [[ "$WIDTH" -eq 2560 && "$HEIGHT" -eq 1440 ]]; then
    # 1440p Scales (2560x1440)
    VALID_SCALES=(1.00 1.25 1.33 1.50 1.60 2.00)
elif [[ "$WIDTH" -eq 1920 && "$HEIGHT" -eq 1080 ]]; then
    # 1080p Scales (1920x1080)
    VALID_SCALES=(0.50 0.75 1.00 1.20 1.25 1.50 2.00)
else
    # Fallback/Generic steps if resolution isn't matched
    VALID_SCALES=(1.00 1.25 1.50 2.00)
fi

# Find current index
INDEX=-1
for i in "${!VALID_SCALES[@]}"; do
   if [ "${VALID_SCALES[$i]}" == "$CURRENT_SCALE" ]; then
       INDEX=$i
       break
   fi
done

# If current scale isn't in the list, find the closest one
if [ $INDEX -eq -1 ]; then
    INDEX=0
    for i in "${!VALID_SCALES[@]}"; do
        if (( $(echo "${VALID_SCALES[$i]} > $CURRENT_SCALE" | bc -l) )); then
            INDEX=$i
            if [ "$1" == "down" ]; then ((INDEX--)); fi
            break
        fi
    done
fi

# Handle increments
case $1 in
    up) NEW_INDEX=$((INDEX + 1)) ;;
    down) NEW_INDEX=$((INDEX - 1)) ;;
    *) exit 1 ;;
esac

# Bound checks
if [ $NEW_INDEX -lt 0 ]; then
    NEW_INDEX=0
elif [ $NEW_INDEX -ge ${#VALID_SCALES[@]} ]; then
    NEW_INDEX=$((${#VALID_SCALES[@]} - 1))
fi

NEW_SCALE=${VALID_SCALES[$NEW_INDEX]}

# Update the monitor scale
hyprctl keyword monitor "$MONITOR,preferred,auto,$NEW_SCALE"

# Send a notification
notify-send -u low -t 1500 -h string:x-canonical-private-synchronous:scale-notify "Monitor Scale" "Res: ${WIDTH}x${HEIGHT} | Scale: $NEW_SCALE"
