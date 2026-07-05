#!/usr/bin/env fish
cd (dirname (status --current-filename))

set -l state_dir "$HOME/.config/mangohud-turing-theme"
mkdir -p "$state_dir"
set -l current (grep '^THEME:' config.yaml | sed 's/^THEME: *//')
echo "$current" > "$state_dir/previous-theme.txt"

sed -i 's/THEME: .*/THEME: MangoHudTheme/' config.yaml
echo "Tema alterado para MangoHudTheme"
source lcd/bin/activate.fish
echo "Iniciando system monitor..."
python3 main.py
