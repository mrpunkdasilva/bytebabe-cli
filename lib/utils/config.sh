#!/bin/bash

# Configurações globais
CONFIG_DIR="$HOME/.config/bytebabe"
CONFIG_FILE="$CONFIG_DIR/settings.conf"

# Garante que o diretório existe com permissões corretas
ensure_config_dir() {
    mkdir -p "$CONFIG_DIR"
    chmod 700 "$CONFIG_DIR"
}

# Carrega ou cria configuração
load_config() {
    ensure_config_dir
    [[ ! -f "$CONFIG_FILE" ]] && touch "$CONFIG_FILE"
    chmod 600 "$CONFIG_FILE"
    
    # Carrega variáveis de forma segura
    source <(grep -E '^(GIT_NAME|GIT_EMAIL|NVM_INSTALLED)=' "$CONFIG_FILE" 2>/dev/null)
}

# Salva configuração de forma robusta
save_config() {
    local key="$1"
    local value="$2"
    
    ensure_config_dir
    
    # Cria arquivo se não existir
    [[ ! -f "$CONFIG_FILE" ]] && touch "$CONFIG_FILE"
    
    # Verifica se o arquivo está acessível
    if [[ ! -w "$CONFIG_FILE" ]]; then
        echo -e "${CYBER_ORANGE}⚠ Erro: Sem permissão para escrever em $CONFIG_FILE${RESET}"
        return 1
    fi

    # Processamento atômico com arquivo temporário
    local temp_file
    temp_file=$(mktemp "/tmp/bytebabe_config.XXXXXX")
    
    # Remove entrada existente e adiciona nova
    grep -v "^$key=" "$CONFIG_FILE" > "$temp_file"
    echo "$key=\"${value//\"/\\\"}\"" >> "$temp_file"
    
    # Substitui arquivo original preservando metadados
    if ! mv -f "$temp_file" "$CONFIG_FILE"; then
        echo -e "${CYBER_ORANGE}⚠ Falha ao salvar configurações!${RESET}"
        rm -f "$temp_file"
        return 1
    fi

    # Mensagem de sucesso detalhada
    echo -e "${CYBER_GREEN}✔ Configuração salva com sucesso em:"
    echo -e "   Arquivo: ${CYBER_BLUE}$CONFIG_FILE${CYBER_GREEN}"
    echo -e "   Chave:   ${CYBER_BLUE}$key${CYBER_GREEN}"
    echo -e "   Valor:   ${CYBER_BLUE}$value${RESET}"
}