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
echo -e "${YELLOW}[1/6]${NC} Instalando tema MangoHudTheme..."
mkdir -p "$PROJECT_DIR/res/themes/MangoHudTheme"
cp theme/MangoHudTheme/theme.yaml "$PROJECT_DIR/res/themes/MangoHudTheme/"
cp theme/MangoHudTheme/background.png "$PROJECT_DIR/res/themes/MangoHudTheme/"
echo -e "${GREEN}✓ Tema instalado${NC}"

# 2. Add sensor classes
echo -e "${YELLOW}[2/6]${NC} Adicionando sensores MangoHud..."
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
echo -e "${YELLOW}[3/6]${NC} Configurando MangoHud..."
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
echo -e "${YELLOW}[4/6]${NC} Instalando scripts de atalho..."
cp scripts/* "$PROJECT_DIR/"
chmod +x "$PROJECT_DIR"/theme-mangohud.sh "$PROJECT_DIR"/theme-desktop.sh "$PROJECT_DIR"/theme-mangohud.fish "$PROJECT_DIR"/theme-desktop.fish 2>/dev/null || true
echo -e "${GREEN}✓ Scripts instalados${NC}"

# 5. Detect and handle the SYSTEM service from the official turing-smart-screen-python install
echo -e "${YELLOW}[5/6]${NC} Verificando servico de SISTEMA legado do turing-smart-screen..."
SYSTEM_SERVICE_FILE="/etc/systemd/system/turing-smart-screen-python.service"
if [ -f "$SYSTEM_SERVICE_FILE" ] || systemctl is-enabled turing-smart-screen-python.service >/dev/null 2>&1; then
    echo -e "${RED}  ATENCAO: detectado servico de SISTEMA antigo (Restart=always).${NC}"
    echo "  Ele roda o main.py junto com o servico de usuario, gerando 2 processos"
    echo "  disputando o display -> o tema so muda na segunda tecla."
    read -p "  Desativa-lo agora? [S/n] " R
    if [ -z "$R" ] || [ "$R" = "s" ] || [ "$R" = "S" ]; then
        sudo systemctl disable --now turing-smart-screen-python.service && \
            echo -e "${GREEN}  ✓ Servico de sistema desativado${NC}" || \
            echo -e "${RED}  ✗ Falha ao desativar (senha sudo?)${NC}"
    else
        echo -e "${YELLOW}  OK. Sem desativar, a troca de tema nao vai funcionar.${NC}"
        echo -e "${YELLOW}  Depois rode: sudo systemctl disable --now turing-smart-screen-python${NC}"
    fi
else
    echo "  Nenhum servico de sistema encontrado, ok."
fi

# Kill any leftover main.py process from old services (avoid 2 instances)
MAIN_COUNT=$(pgrep -fc "[m]ain.py" 2>/dev/null || echo 0)
if [ "$MAIN_COUNT" -gt 1 ]; then
    echo -e "${YELLOW}  Matando $MAIN_COUNT processo(s) main.py (para ficar 1 unico)...${NC}"
    pkill -f "[m]ain.py" 2>/dev/null || true
    sleep 1
fi

# 6. Install systemd user service (scripts restart via systemctl --user)
echo -e "${YELLOW}[6/6]${NC} Instalando servico de usuario (systemd --user)..."
mkdir -p "$HOME/.config/systemd/user"
# Remove any old user service from previous versions of this installer (same role, old name)
if [ -f "$HOME/.config/systemd/user/turing-smart-screen-python.service" ] || \
   systemctl --user list-unit-files turing-smart-screen-python.service >/dev/null 2>&1; then
    echo "  Removendo servico de usuario antigo (turing-smart-screen-python.service)..."
    systemctl --user disable --now turing-smart-screen-python.service >/dev/null 2>&1 || \
        systemctl --user stop turing-smart-screen-python.service >/dev/null 2>&1 || true
    rm -f "$HOME/.config/systemd/user/turing-smart-screen-python.service"
    systemctl --user daemon-reload
fi
cat > "$HOME/.config/systemd/user/mangohud-turing-theme.service" <<EOF
[Unit]
Description=MangoHud Turing Theme (Turing Smart Screen)

[Service]
Type=simple
WorkingDirectory=$PROJECT_DIR/
ExecStart=$PROJECT_DIR/lcd/bin/python3 main.py $PROJECT_DIR/main.py
Restart=on-failure
RestartSec=2

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload
systemctl --user enable mangohud-turing-theme.service >/dev/null 2>&1 || true
loginctl enable-linger "$USER" 2>/dev/null || true
systemctl --user restart mangohud-turing-theme.service
echo -e "${GREEN}✓ Servico de usuario mangohud-turing-theme.service instalado${NC}"

echo ""
echo "========================================"
echo -e "${GREEN}Instalacao concluida!${NC}"
echo "========================================"
echo ""
echo "Para usar:"
echo "  ./theme-mangohud.sh   (tema gaming)"
echo "  ./theme-desktop.sh    (tema desktop)"
echo ""
echo "Os scripts reiniciam o monitor via systemd --user"
echo "  (servico mangohud-turing-theme.service, ja habilitado)."
echo ""
echo "Dica: se a troca de tema estiver lenta (~6-8s), aplique no $PROJECT_DIR/config.yaml:"
echo "  COM_PORT: \"/dev/ttyACM0\"   (em vez de AUTO)"
echo "  RESET_ON_STARTUP: false     (evita reset USB + espera de 5s)"
echo ""
echo "Para Niri, adicione no config.kdl:"
echo '  Mod+Z { spawn "'"$PROJECT_DIR"'/theme-mangohud.fish"; }'
echo '  Mod+X { spawn "'"$PROJECT_DIR"'/theme-desktop.fish"; }'
echo ""
echo "Configure o MangoHud (seu ~/.config/MangoHud/MangoHud.conf)"
echo "ja deve ter sido atualizado com:"
echo "  output_folder=$HOME/.config/MangoHud/mangologs"
echo "  autostart_log=5"
