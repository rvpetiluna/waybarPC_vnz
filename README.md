# 🔴 Minimalist Red & Black Waybar

A sleek, modern, floating-pill Waybar setup for Arch Linux running Hyprland. Designed with high-contrast crimson accents, custom audio switching via Wofi, and an optimized, async `ddcutil` hardware brightness controller.

![Waybar Preview](preview.png)

## 🎨 Features

* **Pill-Style Layout:** Floating segmented modules (`#000000`) with red accent elements.
* **Dual-Monitor Ready:** Configured with workspace setups (`HDMI-A-1` & `DP-3`).
* **Interactive Audio Menu:** PulseAudio module integrated with a custom Wofi menu script for instant output device switching and stream routing.
* **Non-Blocking DDC/CI Brightness Control:** Custom background worker script preventing Waybar lag when scrolling monitor hardware brightness.
* **Styled Calendar Tooltip:** Native calendar widget formatted in JetBrains Mono with custom colors.

## 📁 Repository Structure

```text
.
├── config                 # Waybar JSON layout configuration
├── style.css              # Custom styling with red/black theme
└── scripts/
    ├── audio-menu.sh      # Wofi PulseAudio output switcher
    ├── audio-menu.css     # Styling for audio selector window
    ├── brightness.sh      # Fast scroll interface for brightness
    └── asus-brightness-worker.sh  # Non-blocking DDC/CI background daemon