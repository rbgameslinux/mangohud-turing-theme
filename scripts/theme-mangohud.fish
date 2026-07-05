#!/usr/bin/env fish
cd (dirname (status --current-filename))
sed -i 's/THEME: .*/THEME: MangoHudTheme/' config.yaml
echo "Tema alterado para MangoHudTheme"
source lcd/bin/activate.fish
echo "Iniciando system monitor..."
python3 main.py
