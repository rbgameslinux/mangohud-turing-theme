#!/usr/bin/env fish
cd (dirname (status --current-filename))
sed -i 's/THEME: .*/THEME: 3.5inchTheme2/' config.yaml
echo "Tema alterado para 3.5inchTheme2"
source lcd/bin/activate.fish
echo "Iniciando system monitor..."
python3 main.py
