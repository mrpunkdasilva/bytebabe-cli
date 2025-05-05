#!/bin/bash

# Cores e estilos
source "$(dirname "$0")/../core/styles.sh"

# Configurações
FLUX_CONFIG_DIR="$HOME/.bytebabe/flux"
HISTORY_FILE="$FLUX_CONFIG_DIR/request_history.json"

# Inicializa estrutura de histórico
init_history() {
    mkdir -p "$FLUX_CONFIG_DIR"
    if [ ! -f "$HISTORY_FILE" ]; then
        echo '{"requests":[]}' > "$HISTORY_FILE"
        echo -e "${CYBER_GREEN}✓ Histórico de requisições inicializado${RESET}"
    fi
}

# Salva uma requisição no histórico
save_request_history() {
    local method="$1"
    local url="$2"
    local headers="$3"
    local body="$4"
    local response="$5"
    local status_code="$6"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    # Escapa caracteres especiais para JSON
    headers=$(echo "$headers" | sed 's/"/\\"/g')
    body=$(echo "$body" | sed 's/"/\\"/g')
    response=$(echo "$response" | sed 's/"/\\"/g')
    
    local new_entry="{\"method\":\"$method\",\"url\":\"$url\",\"headers\":\"$headers\",\"body\":\"$body\",\"response\":\"$response\",\"status_code\":\"$status_code\",\"timestamp\":\"$timestamp\"}"
    local temp_file=$(mktemp)
    
    jq ".requests += [$new_entry]" "$HISTORY_FILE" > "$temp_file"
    mv "$temp_file" "$HISTORY_FILE"
    
    echo -e "${CYBER_GREEN}✓ Requisição salva no histórico${RESET}"
}

# Lista histórico de requisições
list_request_history() {
    local limit=${1:-10}  # Limite padrão de 10 entradas
    
    echo -e "${HEADER_STYLE}╔════════════════════════════════════════════════╗${RESET}"
    echo -e "${HEADER_STYLE}║           HISTÓRICO DE REQUISIÇÕES             ║${RESET}"
    echo -e "${HEADER_STYLE}╚════════════════════════════════════════════════╝${RESET}"
    echo
    
    # Obtém as últimas N requisições
    local entries=$(jq -r ".requests | sort_by(.timestamp) | reverse | .[0:$limit] | .[]" "$HISTORY_FILE")
    
    if [ -z "$entries" ]; then
        echo -e "${CYBER_YELLOW}⚠ Nenhuma requisição no histórico${RESET}"
        return
    fi
    
    local count=1
    while IFS= read -r entry; do
        local method=$(echo "$entry" | jq -r '.method')
        local url=$(echo "$entry" | jq -r '.url')
        local status=$(echo "$entry" | jq -r '.status_code')
        local timestamp=$(echo "$entry" | jq -r '.timestamp')
        
        # Formata o status com cor
        if [[ $status -ge 200 && $status -lt 300 ]]; then
            status_colored="${CYBER_GREEN}$status${RESET}"
        elif [[ $status -ge 300 && $status -lt 400 ]]; then
            status_colored="${CYBER_BLUE}$status${RESET}"
        elif [[ $status -ge 400 && $status -lt 500 ]]; then
            status_colored="${CYBER_YELLOW}$status${RESET}"
        else
            status_colored="${CYBER_RED}$status${RESET}"
        fi
        
        echo -e "${CYBER_PURPLE}[$count]${RESET} ${CYBER_CYAN}$method${RESET} $url"
        echo -e "    Status: $status_colored | Data: ${CYBER_YELLOW}$timestamp${RESET}"
        echo
        
        ((count++))
    done <<< "$entries"
}

# Visualiza detalhes de uma requisição específica
view_request_details() {
    local index=$1
    
    # Obtém a requisição pelo índice (invertido para mostrar mais recentes primeiro)
    local total=$(jq '.requests | length' "$HISTORY_FILE")
    local entry=$(jq -r ".requests | sort_by(.timestamp) | reverse | .[$index-1]" "$HISTORY_FILE")
    
    if [ "$entry" == "null" ]; then
        echo -e "${CYBER_RED}✗ Requisição não encontrada${RESET}"
        return 1
    fi
    
    local method=$(echo "$entry" | jq -r '.method')
    local url=$(echo "$entry" | jq -r '.url')
    local headers=$(echo "$entry" | jq -r '.headers')
    local body=$(echo "$entry" | jq -r '.body')
    local response=$(echo "$entry" | jq -r '.response')
    local status=$(echo "$entry" | jq -r '.status_code')
    local timestamp=$(echo "$entry" | jq -r '.timestamp')
    
    echo -e "${HEADER_STYLE}╔════════════════════════════════════════════════╗${RESET}"
    echo -e "${HEADER_STYLE}║           DETALHES DA REQUISIÇÃO               ║${RESET}"
    echo -e "${HEADER_STYLE}╚════════════════════════════════════════════════╝${RESET}"
    echo
    echo -e "${CYBER_CYAN}Método:${RESET} $method"
    echo -e "${CYBER_CYAN}URL:${RESET} $url"
    echo -e "${CYBER_CYAN}Status:${RESET} $status"
    echo -e "${CYBER_CYAN}Data:${RESET} $timestamp"
    echo
    echo -e "${CYBER_CYAN}Headers:${RESET}"
    echo "$headers" | sed 's/\\"/"/g'
    echo
    
    if [ ! -z "$body" ]; then
        echo -e "${CYBER_CYAN}Body:${RESET}"
        echo "$body" | sed 's/\\"/"/g'
        echo
    fi
    
    echo -e "${CYBER_CYAN}Resposta:${RESET}"
    echo "$response" | sed 's/\\"/"/g'
}

# Limpa o histórico de requisições
clear_request_history() {
    echo -e "${CYBER_YELLOW}⚠ Esta ação irá apagar todo o histórico de requisições.${RESET}"
    read -p "Deseja continuar? (s/N): " confirm
    
    if [[ "$confirm" =~ ^[Ss]$ ]]; then
        echo '{"requests":[]}' > "$HISTORY_FILE"
        echo -e "${CYBER_GREEN}✓ Histórico de requisições limpo${RESET}"
    else
        echo -e "${CYBER_YELLOW}⚠ Operação cancelada${RESET}"
    fi
}

# Exporta histórico para arquivo
export_request_history() {
    local export_file=${1:-"flux_history_$(date +%Y%m%d_%H%M%S).json"}
    
    cp "$HISTORY_FILE" "$export_file"
    echo -e "${CYBER_GREEN}✓ Histórico exportado para ${CYBER_CYAN}$export_file${RESET}"
}

# Inicializa o histórico ao carregar o script
init_history