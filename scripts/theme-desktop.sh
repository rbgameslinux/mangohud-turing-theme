#!/bin/bash
# Switch back to previous theme and start the system monitor
cd "$(dirname "$0")"

# Kill any existing main.py process to prevent display conflicts
pkill -f "python3 main.py" 2>/dev/null || true
sleep 1

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
source lcd/bin/activate
echo "Iniciando system monitor..."
python3 main.py
