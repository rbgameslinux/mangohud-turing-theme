#!/usr/bin/env fish
cd (dirname (status --current-filename))

# Kill any existing main.py process to prevent display conflicts
pkill -f "python3 main.py" 2>/dev/null
sleep 1

set -l state_dir "$HOME/.config/mangohud-turing-theme"
mkdir -p "$state_dir"
set -l current (grep 'THEME:' config.yaml | sed 's/.*THEME: *//')
if test -n "$current" -a "$current" != "MangoHudTheme"
    echo "$current" > "$state_dir/previous-theme.txt"
end

sed -i 's/THEME: .*/THEME: MangoHudTheme/' config.yaml
echo "Tema alterado para MangoHudTheme"
source lcd/bin/activate.fish
echo "Iniciando system monitor..."
python3 main.py
