#!/bin/bash
# Switch to MangoHud gaming theme and restart the system monitor (user service)
cd "$(dirname "$0")"

# Save current theme (only if not already MangoHudTheme)
STATE_DIR="$HOME/.config/mangohud-turing-theme"
mkdir -p "$STATE_DIR"
CURRENT=$(grep 'THEME:' config.yaml | sed 's/.*THEME: *//')
if [ -n "$CURRENT" ] && [ "$CURRENT" != "MangoHudTheme" ]; then
    echo "$CURRENT" > "$STATE_DIR/previous-theme.txt"
fi

sed -i 's/THEME: .*/THEME: MangoHudTheme/' config.yaml
echo "Tema alterado para MangoHudTheme"
systemctl --user restart mangohud-turing-theme.service