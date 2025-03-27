#!/bin/bash

# Configurações globais
CONFIG_DIR="$HOME/.config/bytebabe"
CONFIG_FILE="$CONFIG_DIR/settings.conf"

# Garante que o diretório existe com permissões corretas
ensure_config_dir() {
    mkdir -p "$CONFIG_DIR"
    chmod 700 "$CONFIG_DIR"  # Permissões restritas
}

# Carrega ou cria configuração
load_config() {
    ensure_config_dir
    [ ! -f "$CONFIG_FILE" ] && touch "$CONFIG_FILE"
    chmod 600 "$CONFIG_FILE"  # Permissões restritas
    
    # Carrega apenas variáveis específicas para segurança
    source "$CONFIG_FILE" 2>/dev/null | grep -E '^(GIT_NAME|GIT_EMAIL|NVM_INSTALLED)=' || true
}

# Salva configuração de forma segura
save_config() {
    local key=$1
    local value=$2
    
    ensure_config_dir
    
    # Usa temp file para evitar corrupção
    local temp_file=$(mktemp)
    
    # Remove linhas existentes e adiciona nova
    grep -v "^$key=" "$CONFIG_FILE" > "$temp_file"
    echo "$key=\"$value\"" >> "$temp_file"
    
    # Substitui arquivo original atomicamente
    mv "$temp_file" "$CONFIG_FILE"
    
    echo -e "${CYBER_GREEN}✔ Configuração atualizada em: $CONFIG_FILE${RESET}"
    echo -e "Conteúdo atual:\n$(cat $CONFIG_FILE)"
}