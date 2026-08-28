#!/bin/bash
# Switch back to previous theme and restart the system monitor (user service)
cd "$(dirname "$0")"

STATE_DIR="$HOME/.config/mangohud-turing-theme"
SAVED_THEME="3.5inchTheme2"
if [ -f "$STATE_DIR/previous-theme.txt" ] && [ -s "$STATE_DIR/previous-theme.txt" ]; then
    CONTENT=$(cat "$STATE_DIR/previous-theme.txt")
    if [ "$CONTENT" != "MangoHudTheme" ]; then
        SAVED_THEME="$CONTENT"
    fi
fi

sed -i "s/THEME: .*/THEME: $SAVED_THEME/" config.yaml
echo "Tema alterado para $SAVED_THEME"
systemctl --user restart mangohud-turing-theme.service