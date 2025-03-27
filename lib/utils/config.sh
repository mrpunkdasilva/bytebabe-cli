#!/bin/bash

source ../core/colors.sh

# Configurações globais
CONFIG_DIR="$HOME/.config/bytebabe"
CONFIG_FILE="$CONFIG_DIR/settings.conf"

# Carrega ou cria configuração
load_config() {
    [ ! -d "$CONFIG_DIR" ] && mkdir -p "$CONFIG_DIR"
    [ ! -f "$CONFIG_FILE" ] && touch "$CONFIG_FILE"

    source "$CONFIG_FILE" 2>/dev/null || {
        echo -e "${CYBER_BLUE}▶ Criando configuração inicial...${RESET}"
        cat > "$CONFIG_FILE" << EOL
# Configurações ByteBabe
THEME="cyberpunk"
DEFAULT_NODE_VERSION="18"
PREFERRED_PKG_MANAGER="pnpm"
EOL
    }
}

# Salva configuração
save_config() {
    local key=$1
    local value=$2
    sed -i "/^$key=/d" "$CONFIG_FILE"
    echo "$key=\"$value\"" >> "$CONFIG_FILE"
    echo -e "${CYBER_GREEN}✔ Configuração atualizada${RESET}"
}