#!/usr/bin/env fish
# Switch to MangoHud gaming theme and restart the system monitor (user service)
cd (dirname (status --current-filename))

set -l state_dir "$HOME/.config/mangohud-turing-theme"
mkdir -p "$state_dir"
set -l current (grep 'THEME:' config.yaml | sed 's/.*THEME: *//')
if test -n "$current" -a "$current" != "MangoHudTheme"
    echo "$current" > "$state_dir/previous-theme.txt"
end

sed -i 's/THEME: .*/THEME: MangoHudTheme/' config.yaml
echo "Tema alterado para MangoHudTheme"
systemctl --user restart mangohud-turing-theme.service