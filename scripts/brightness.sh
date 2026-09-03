#!/bin/bash

CACHE="/tmp/asus-brightness"
REQUEST="/tmp/asus-brightness-request"
LOCK="/tmp/asus-brightness-input.lock"

exec 9>"$LOCK"
flock 9

case "$1" in
    up)
        current=$(cat "$REQUEST" 2>/dev/null || cat "$CACHE" 2>/dev/null)

        [[ "$current" =~ ^[0-9]+$ ]] || exit 0

        new=$((current + 5))
        ((new > 100)) && new=100

        printf '%s\n' "$new" > "$REQUEST"

        # INSTANTLY tell Waybar the pending value
        printf '%s\n' "$new"
        ;;

    down)
        current=$(cat "$REQUEST" 2>/dev/null || cat "$CACHE" 2>/dev/null)

        [[ "$current" =~ ^[0-9]+$ ]] || exit 0

        new=$((current - 5))
        ((new < 0)) && new=0

        printf '%s\n' "$new" > "$REQUEST"

        # INSTANTLY tell Waybar the pending value
        printf '%s\n' "$new"
        ;;

    *)
        # Display pending value while scrolling,
        # otherwise display verified ASUS value.
        if [[ -f "$REQUEST" ]]; then
            cat "$REQUEST"
        else
            cat "$CACHE"
        fi
        ;;
esac