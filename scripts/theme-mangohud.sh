#!/bin/bash
# Switch to MangoHud gaming theme and start the system monitor
cd "$(dirname "$0")"
sed -i 's/THEME: .*/THEME: MangoHudTheme/' config.yaml
echo "Tema alterado para MangoHudTheme"
source lcd/bin/activate
echo "Iniciando system monitor..."
python3 main.py
