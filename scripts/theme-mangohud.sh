#!/bin/bash
# Switch to MangoHud gaming theme and start the system monitor
cd "$(dirname "$0")"

# Save current theme
STATE_DIR="$HOME/.config/mangohud-turing-theme"
mkdir -p "$STATE_DIR"
CURRENT=$(grep '^THEME:' config.yaml | sed 's/^THEME: *//')
echo "$CURRENT" > "$STATE_DIR/previous-theme.txt"

sed -i 's/THEME: .*/THEME: MangoHudTheme/' config.yaml
echo "Tema alterado para MangoHudTheme"
source lcd/bin/activate
echo "Iniciando system monitor..."
python3 main.py
