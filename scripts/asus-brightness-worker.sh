#!/bin/bash

CACHE="/tmp/asus-brightness"
REQUEST="/tmp/asus-brightness-request"

BUS=9
DELAY=0.5

# Get the REAL brightness from the ASUS
read_asus() {
    ddcutil getvcp 10 \
        --bus "$BUS" \
        --terse 2>/dev/null |
        awk '{print $4}'
}

# Initialize cache from the actual ASUS brightness
actual=$(read_asus)

if [[ "$actual" =~ ^[0-9]+$ ]]; then
    echo "$actual" > "$CACHE"
fi

while true; do

    # Nothing waiting to be applied
    if [[ ! -f "$REQUEST" ]]; then
        sleep 0.05
        continue
    fi

    # Get current requested value
    target=$(cat "$REQUEST")

    # Wait until the requested value stops changing
    sleep "$DELAY"

    # Check again
    current_request=$(cat "$REQUEST" 2>/dev/null)

    # User is still scrolling
    if [[ "$target" != "$current_request" ]]; then
        continue
    fi

    # Apply ONLY the finalized value
    ddcutil setvcp 10 "$target" \
        --bus "$BUS" \
        --noverify \
        >/dev/null 2>&1

    # Read the brightness BACK from the ASUS
    actual=$(read_asus)

    if [[ "$actual" =~ ^[0-9]+$ ]]; then

        # Only update Waybar if the request wasn't changed
        # while ddcutil was talking to the monitor.
        latest=$(cat "$REQUEST" 2>/dev/null)

        if [[ "$latest" == "$target" ]]; then
            echo "$actual" > "$CACHE"
            rm -f "$REQUEST"
        fi
    fi

done