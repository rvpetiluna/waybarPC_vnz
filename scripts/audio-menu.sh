#!/usr/bin/env bash

# Fetch all available audio output sinks using native pactl
mapfile -t raw_sinks < <(pactl list short sinks)

labels=()
names=()

# Get the current system default sink name
default_sink=$(pactl get-default-sink)

for row in "${raw_sinks[@]}"; do
    # Extract internal system name (Column 2) and description/clean string
    sink_name=$(echo "$row" | awk '{print $2}')
    
    # Get a human-readable description for the menu
    label=$(pactl list sinks | grep -A 50 "$sink_name" | grep "Description:" | head -n 1 | cut -d: -f2- | sed 's/^[[:space:]]*//')
    
    if [ -z "$label" ]; then
        label="$sink_name"
    fi

    # Highlight currently active default output
    if [ "$sink_name" = "$default_sink" ]; then
        labels+=("  $label")
    else
        labels+=("  $label")
    fi
    names+=("$sink_name")
done

# Format items for Wofi selection panel
menu_input=$(printf "%s\n" "${labels[@]}")

# FIXED: Added 0 to --xoffset so backslash escapes properly
# ADDED: --hide-scroll to keep it ultra minimal
# Execute Wofi with precise single-click parameters
chosen=$(echo "$menu_input" | wofi --dmenu \
    --style "$HOME/.config/waybar/scripts/audio-menu.css" \
    --prompt "Select Output Target" \
    --width 300 \
    --height 200 \
    --cache-file /dev/null \
    --location top_right \
    --xoffset -20 \
    --yoffset 0 \
    --hide-scroll \
    --insensitive \
    --allow-images)

# If nothing was selected (user pressed Escape or clicked away), exit cleanly
if [ -z "$chosen" ]; then
    exit 0
fi

# If selected, forcefully move the system default and all active streams
for i in "${!labels[@]}"; do
    if [[ "${labels[$i]}" == "$chosen" ]]; then
        target_sink="${names[$i]}"
        
        # 1. Force the new system global default sink choice
        pactl set-default-sink "$target_sink"
        
        # 2. Force move every single currently playing audio stream to the new target
        pactl list short sink-inputs | awk '{print $1}' | while read -r stream_id; do
            pactl move-sink-input "$stream_id" "$target_sink" 2>/dev/null
        done
        break
    fi
done

# Kill any stray wofi instances just to be absolutely sure it closes
killall wofi 2>/dev/null