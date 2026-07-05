#!/bin/bash
# Switch back to previous theme and start the system monitor
cd "$(dirname "$0")"

STATE_DIR="$HOME/.config/mangohud-turing-theme"
SAVED_THEME="3.5inchTheme2"
if [ -f "$STATE_DIR/previous-theme.txt" ] && [ -s "$STATE_DIR/previous-theme.txt" ]; then
    SAVED_THEME=$(cat "$STATE_DIR/previous-theme.txt")
fi

sed -i "s/THEME: .*/THEME: $SAVED_THEME/" config.yaml
echo "Tema alterado para $SAVED_THEME"
source lcd/bin/activate
echo "Iniciando system monitor..."
python3 main.py
