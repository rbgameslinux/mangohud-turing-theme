#!/usr/bin/env fish
cd (dirname (status --current-filename))

set -l state_dir "$HOME/.config/mangohud-turing-theme"
set -l saved_theme "3.5inchTheme2"
if test -f "$state_dir/previous-theme.txt" -a -s "$state_dir/previous-theme.txt"
    set -l content (cat "$state_dir/previous-theme.txt")
    if test "$content" != "MangoHudTheme"
        set saved_theme "$content"
    end
end

sed -i "s/THEME: .*/THEME: $saved_theme/" config.yaml
echo "Tema alterado para $saved_theme"
source lcd/bin/activate.fish
echo "Iniciando system monitor..."
python3 main.py
