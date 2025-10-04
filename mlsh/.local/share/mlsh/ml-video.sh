#!/usr/bin/env bash
# File: ~/.local/bin/dm-video
# Log : ~/.local/share/dm-video.log
# Purpose: Video output diagnosis & quick fixes with dmenu
# @about: Diagnose and manage video outputs (extend, mirror, turn off/on)

set -euo pipefail
LOG="${HOME}/.local/share/dm-video.log"
mkdir -p "$(dirname "$LOG")"

# Detect outputs
OUTPUTS=$(xrandr | awk '/ connected/ {print $1 " (connected)"} / disconnected/ {print $1 " (disconnected)"}')
CHOICE="$(printf "%s\nBack" "$OUTPUTS" | dmenu -b -i -l 10 -p "Select output:")"

[ -z "${CHOICE:-}" ] && exit 0
[ "$CHOICE" = "Back" ] && exit 0

OUT="$(echo "$CHOICE" | awk '{print $1}')"

echo "$(date -Is) INFO: Selected $OUT" | tee -a "$LOG"

# Sub-menu for actions
ACTION="$(printf "Status\nAuto-detect (xrandr --auto)\nSet 1920x1080@60\nMirror primary\nExtend right\nExtend left\nTurn off\nBack" | \
  dmenu -b -i -l 10 -p "Action for $OUT:")"

case "${ACTION:-}" in
  "Status")
    MSG="$(xrandr | grep -A1 "^$OUT ")"
    notify-send "[$OUT] Status" "$MSG"
    echo "$(date -Is) INFO: Status -> $MSG" | tee -a "$LOG"
    ;;
  "Auto-detect (xrandr --auto)")
    xrandr --output "$OUT" --auto
    notify-send "[$OUT]" "Auto detect applied"
    echo "$(date -Is) INFO: Auto detect run" | tee -a "$LOG"
    ;;
  "Set 1920x1080@60")
    xrandr --output "$OUT" --mode 1920x1080 --rate 60
    notify-send "[$OUT]" "Mode set to 1920x1080@60"
    echo "$(date -Is) INFO: Set 1920x1080@60" | tee -a "$LOG"
    ;;
  "Mirror primary")
    PRIMARY=$(xrandr | awk '/ primary/ {print $1; exit}')
    if [ -n "${PRIMARY:-}" ]; then
      xrandr --output "$OUT" --same-as "$PRIMARY" --auto
      notify-send "[$OUT]" "Mirroring $PRIMARY"
      echo "$(date -Is) INFO: Mirroring $PRIMARY" | tee -a "$LOG"
    else
      notify-send "[$OUT]" "No primary display found!"
    fi
    ;;
  "Turn off")
    xrandr --output "$OUT" --off
    notify-send "[$OUT]" "Turned off"
    echo "$(date -Is) INFO: Turned off" | tee -a "$LOG"
    ;;
  "Extend right")
    PRIMARY=$(xrandr | awk '/ primary/ {print $1; exit}')
    if [ -n "${PRIMARY:-}" ]; then
      xrandr --output "$OUT" --auto --right-of "$PRIMARY"
      notify-send "[$OUT]" "Extended to the right of $PRIMARY"
      echo "$(date -Is) INFO: Extended $OUT right of $PRIMARY" | tee -a "$LOG"
    else
      notify-send "[$OUT]" "No primary display found!"
    fi
    ;;
  "Extend left")
    PRIMARY=$(xrandr | awk '/ primary/ {print $1; exit}')
    if [ -n "${PRIMARY:-}" ]; then
      xrandr --output "$OUT" --auto --left-of "$PRIMARY"
      notify-send "[$OUT]" "Extended to the left of $PRIMARY"
      echo "$(date -Is) INFO: Extended $OUT left of $PRIMARY" | tee -a "$LOG"
    else
      notify-send "[$OUT]" "No primary display found!"
    fi
    ;;
  *) exit 0 ;;
esac
