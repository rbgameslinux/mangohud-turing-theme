#!/bin/bash
# Switch to desktop theme and start the system monitor
cd "$(dirname "$0")"
sed -i 's/THEME: .*/THEME: 3.5inchTheme2/' config.yaml
echo "Tema alterado para 3.5inchTheme2"
source lcd/bin/activate
echo "Iniciando system monitor..."
python3 main.py
