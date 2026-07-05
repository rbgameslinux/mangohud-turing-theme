#!/bin/bash
set -e

PROJECT_DIR=""
MANGOHUD_CONF="$HOME/.config/MangoHud/MangoHud.conf"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================"
echo " MangoHud Turing Theme - Instalador"
echo "========================================"
echo ""

# Find turing-smart-screen-python
if [ -z "$PROJECT_DIR" ]; then
    for dir in "$HOME/turing-smart-screen-python" "$PWD" "$PWD/.."; do
        if [ -f "$dir/main.py" ] && [ -d "$dir/res/themes" ] && [ -d "$dir/library/sensors" ]; then
            PROJECT_DIR="$dir"
            break
        fi
    done
fi

if [ -z "$PROJECT_DIR" ]; then
    read -p "Caminho do turing-smart-screen-python: " PROJECT_DIR
fi

if [ ! -f "$PROJECT_DIR/main.py" ]; then
    echo -e "${RED}Erro: $PROJECT_DIR/main.py nao encontrado${NC}"
    echo "Certifique-se de que o turing-smart-screen-python esta instalado"
    exit 1
fi

echo -e "${GREEN}✓ Projeto encontrado em:${NC} $PROJECT_DIR"
echo ""

# 1. Copy theme
echo -e "${YELLOW}[1/4]${NC} Instalando tema MangoHudTheme..."
mkdir -p "$PROJECT_DIR/res/themes/MangoHudTheme"
cp theme/MangoHudTheme/theme.yaml "$PROJECT_DIR/res/themes/MangoHudTheme/"
cp theme/MangoHudTheme/background.png "$PROJECT_DIR/res/themes/MangoHudTheme/"
echo -e "${GREEN}✓ Tema instalado${NC}"

# 2. Add sensor classes
echo -e "${YELLOW}[2/4]${NC} Adicionando sensores MangoHud..."
SENSOR_FILE="$PROJECT_DIR/library/sensors/sensors_custom.py"
# Check if already installed
if grep -q "MangoHud CSV integration" "$SENSOR_FILE" 2>/dev/null; then
    echo -e "${YELLOW}  ↪ Sensores ja instalados, pulando...${NC}"
else
    # Add required imports if missing
    for imp in "import csv" "import os" "import time" "from pathlib import Path"; do
        if ! grep -q "$imp" "$SENSOR_FILE" 2>/dev/null; then
            sed -i "1s/^/$imp\n/" "$SENSOR_FILE"
        fi
    done
    cat config/mangohud-sensors.py >> "$SENSOR_FILE"
    echo -e "${GREEN}✓ Sensores adicionados${NC}"
fi

# 3. Configure MangoHud
echo -e "${YELLOW}[3/4]${NC} Configurando MangoHud..."
mkdir -p "$HOME/.config/MangoHud/mangologs"
if [ -f "$MANGOHUD_CONF" ]; then
    # Add settings if not present
    if grep -q "output_folder=" "$MANGOHUD_CONF" 2>/dev/null; then
        sed -i "s|#output_folder=.*|output_folder=$HOME/.config/MangoHud/mangologs|" "$MANGOHUD_CONF"
    else
        echo "" >> "$MANGOHUD_CONF"
        echo "# MangoHud Turing Theme" >> "$MANGOHUD_CONF"
        echo "output_folder=$HOME/.config/MangoHud/mangologs" >> "$MANGOHUD_CONF"
    fi
    if ! grep -q "autostart_log=" "$MANGOHUD_CONF" 2>/dev/null; then
        echo "autostart_log=5" >> "$MANGOHUD_CONF"
    fi
    echo -e "${GREEN}✓ MangoHud configurado${NC}"
else
    echo "output_folder=$HOME/.config/MangoHud/mangologs" > "$MANGOHUD_CONF"
    echo "autostart_log=5" >> "$MANGOHUD_CONF"
    echo -e "${GREEN}✓ MangoHud configurado (novo arquivo)${NC}"
fi

# 4. Copy scripts
echo -e "${YELLOW}[4/4]${NC} Instalando scripts de atalho..."
cp scripts/* "$PROJECT_DIR/"
chmod +x "$PROJECT_DIR"/theme-mangohud.sh "$PROJECT_DIR"/theme-desktop.sh "$PROJECT_DIR"/theme-mangohud.fish "$PROJECT_DIR"/theme-desktop.fish 2>/dev/null || true
echo -e "${GREEN}✓ Scripts instalados${NC}"

echo ""
echo "========================================"
echo -e "${GREEN}Instalacao concluida!${NC}"
echo "========================================"
echo ""
echo "Para usar:"
echo "  1. Ative o ambiente virtual:  source lcd/bin/activate"
echo "  2. Edite config.yaml:         THEME: MangoHudTheme"
echo "  3. Inicie o monitor:          python3 main.py"
echo ""
echo "Ou use os scripts:"
echo "  ./theme-mangohud.sh   (tema gaming)"
echo "  ./theme-desktop.sh    (tema desktop)"
echo ""
echo "Para Niri, adicione no config.kdl:"
echo '  Mod+Z { spawn "'"$PROJECT_DIR"'/theme-mangohud.fish"; }'
echo '  Mod+X { spawn "'"$PROJECT_DIR"'/theme-desktop.fish"; }'
echo ""
echo "Configure o MangoHud (seu ~/.config/MangoHud/MangoHud.conf)"
echo "ja deve ter sido atualizado com:"
echo "  output_folder=$HOME/.config/MangoHud/mangologs"
echo "  autostart_log=5"
