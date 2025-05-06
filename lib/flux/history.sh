#!/bin/bash

# Cores e estilos
CYBER_PINK='\033[38;5;198m'
CYBER_BLUE='\033[38;5;45m'
CYBER_GREEN='\033[38;5;118m'
CYBER_YELLOW='\033[38;5;227m'
CYBER_RED='\033[38;5;196m'
CYBER_PURPLE='\033[38;5;93m'
CYBER_CYAN='\033[38;5;51m'
RESET='\033[0m'
BOLD='\033[1m'
HEADER_STYLE="${BOLD}${CYBER_PURPLE}"

# Configurações
FLUX_CONFIG_DIR="$HOME/bytebabe/flux"
HISTORY_FILE="$FLUX_CONFIG_DIR/request_history.json"

# ASCII art para o histórico
show_history_header() {
    clear
    echo -e "${CYBER_BLUE}"
    cat << "EOF"
 _    _ _____  _____ _______ ____  _______     __
| |  | |_   _|/ ____|__   __/ __ \|  __ \ \   / /
| |__| | | | | (___    | | | |  | | |__) \ \_/ / 
|  __  | | |  \___ \   | | | |  | |  _  / \   /  
| |  | |_| |_ ____) |  | | | |__| | | \ \  | |   
|_|  |_|_____|_____/   |_|  \____/|_|  \_\ |_|   
                                                 
EOF
    echo -e "${CYBER_PINK}"
    cat << "EOF"
 _____  ______  ____  _    _ ______  _____ _______ _____ 
|  __ \|  ____|/ __ \| |  | |  ____|/ ____|__   __/ ____|
| |__) | |__  | |  | | |  | | |__  | (___    | | | (___  
|  _  /|  __| | |  | | |  | |  __|  \___ \   | |  \___ \ 
| | \ \| |____| |__| | |__| | |____ ____) |  | |  ____) |
|_|  \_\______|\___\_\\____/|______|_____/   |_| |_____/ 
                                                         
EOF
    echo -e "${RESET}"
}

# Inicializa estrutura de histórico
init_history() {
    mkdir -p "$FLUX_CONFIG_DIR"
    if [ ! -f "$HISTORY_FILE" ] || ! jq empty "$HISTORY_FILE" 2>/dev/null; then
        echo -e "${CYBER_YELLOW}[!] Arquivo de histórico inválido ou não encontrado. Criando novo...${RESET}"
        echo '{"requests":[]}' > "$HISTORY_FILE"
        echo -e "${CYBER_GREEN}[✓] ${CYBER_CYAN}Histórico de requisições inicializado${RESET}"
    fi
}

# Função para reparar o histórico se estiver corrompido
repair_history() {
    echo -e "${CYBER_YELLOW}[!] Tentando reparar arquivo de histórico...${RESET}"
    
    # Verifica se o arquivo existe
    if [ ! -f "$HISTORY_FILE" ]; then
        echo '{"requests":[]}' > "$HISTORY_FILE"
        echo -e "${CYBER_GREEN}[✓] Novo arquivo de histórico criado${RESET}"
        return 0
    fi
    
    # Tenta validar o JSON
    if ! jq empty "$HISTORY_FILE" 2>/dev/null; then
        # Backup do arquivo corrompido
        cp "$HISTORY_FILE" "${HISTORY_FILE}.bak"
        echo -e "${CYBER_BLUE}[i] Backup do arquivo original salvo em ${HISTORY_FILE}.bak${RESET}"
        
        # Cria um novo arquivo vazio
        echo '{"requests":[]}' > "$HISTORY_FILE"
        echo -e "${CYBER_GREEN}[✓] Arquivo de histórico reparado${RESET}"
    else
        echo -e "${CYBER_GREEN}[✓] Arquivo de histórico está íntegro${RESET}"
    fi
}

# Verifica e limpa o histórico se contiver dados inválidos
check_and_clean_history() {
    # Verifica se o arquivo existe e é um JSON válido
    if [ ! -f "$HISTORY_FILE" ] || ! jq empty "$HISTORY_FILE" 2>/dev/null; then
        echo -e "${CYBER_YELLOW}[!] Arquivo de histórico inválido detectado.${RESET}"
        echo '{"requests":[]}' > "$HISTORY_FILE"
        echo -e "${CYBER_GREEN}[✓] Histórico reinicializado${RESET}"
        return
    fi
    
    # Verifica se há entradas inválidas
    local invalid_entries=$(jq '.requests[] | select(.method == null or .url == null)' "$HISTORY_FILE" 2>/dev/null)
    if [ -n "$invalid_entries" ]; then
        echo -e "${CYBER_YELLOW}[!] Entradas inválidas detectadas no histórico.${RESET}"
        
        # Remove entradas inválidas
        jq '.requests |= map(select(.method != null and .url != null))' "$HISTORY_FILE" > "${HISTORY_FILE}.tmp"
        mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"
        
        echo -e "${CYBER_GREEN}[✓] Entradas inválidas removidas${RESET}"
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
    
    # Verifica se o arquivo de histórico é válido
    if ! jq empty "$HISTORY_FILE" 2>/dev/null; then
        repair_history
    fi
    
    # Escapa caracteres especiais para JSON
    headers=$(echo "$headers" | sed 's/"/\\"/g')
    body=$(echo "$body" | sed 's/"/\\"/g')
    response=$(echo "$response" | sed 's/"/\\"/g')
    
    # Cria a entrada JSON
    local new_entry="{\"method\":\"$method\",\"url\":\"$url\",\"headers\":\"$headers\",\"body\":\"$body\",\"response\":\"$response\",\"status_code\":\"$status_code\",\"timestamp\":\"$timestamp\"}"
    
    # Verifica se a entrada é um JSON válido
    if ! echo "$new_entry" | jq empty 2>/dev/null; then
        echo -e "${CYBER_RED}[✗] Erro ao criar entrada de histórico: JSON inválido${RESET}" >&2
        return 1
    fi
    
    # Adiciona a entrada ao histórico
    local temp_file=$(mktemp)
    if jq ".requests += [$new_entry]" "$HISTORY_FILE" > "$temp_file" 2>/dev/null; then
        mv "$temp_file" "$HISTORY_FILE"
    else
        echo -e "${CYBER_RED}[✗] Erro ao atualizar histórico${RESET}" >&2
        rm -f "$temp_file"
        return 1
    fi
}

# Lista histórico de requisições
list_request_history() {
    local limit=${1:-10}  # Limite padrão de 10 entradas
    
    echo -e "${CYBER_PURPLE}╔═══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_PURPLE}║ ${CYBER_CYAN}${BOLD}HISTÓRICO DE REQUISIÇÕES FLUX${RESET}${CYBER_PURPLE}                           ║${RESET}"
    echo -e "${CYBER_PURPLE}╚═══════════════════════════════════════════════════════════════╝${RESET}"
    echo
    
    # Verifica se o arquivo de histórico é válido
    if ! jq empty "$HISTORY_FILE" 2>/dev/null; then
        force_clean_history
        echo -e "${CYBER_YELLOW}[!] Nenhuma requisição no histórico${RESET}"
        echo -e "${CYBER_BLUE}    Execute algumas requisições para começar a registrar.${RESET}"
        return
    fi
    
    # Verifica se há requisições no histórico
    local count=$(jq '.requests | length' "$HISTORY_FILE" 2>/dev/null)
    if [ "$count" -eq 0 ]; then
        echo -e "${CYBER_YELLOW}[!] Nenhuma requisição no histórico${RESET}"
        echo -e "${CYBER_BLUE}    Execute algumas requisições para começar a registrar.${RESET}"
        return
    fi
    
    # Obtém as últimas N requisições
    local entries=$(jq -r ".requests | sort_by(.timestamp) | reverse | .[0:$limit]" "$HISTORY_FILE" 2>/dev/null)
    
    if [ -z "$entries" ]; then
        echo -e "${CYBER_YELLOW}[!] Nenhuma requisição no histórico${RESET}"
        echo -e "${CYBER_BLUE}    Execute algumas requisições para começar a registrar.${RESET}"
        return
    fi
    
    # Processa cada entrada
    local count=1
    echo "$entries" | jq -c '.[]' 2>/dev/null | while IFS= read -r entry; do
        # Extrai os campos da entrada
        local method=$(echo "$entry" | jq -r '.method // "UNKNOWN"' 2>/dev/null)
        local url=$(echo "$entry" | jq -r '.url // "UNKNOWN"' 2>/dev/null)
        local status=$(echo "$entry" | jq -r '.status_code // "---"' 2>/dev/null)
        local timestamp=$(echo "$entry" | jq -r '.timestamp // "---"' 2>/dev/null)
        
        # Formata o método com cor
        case "$method" in
            "GET")
                method_colored="${CYBER_BLUE}${method}${RESET}"
                ;;
            "POST")
                method_colored="${CYBER_GREEN}${method}${RESET}"
                ;;
            "PUT")
                method_colored="${CYBER_YELLOW}${method}${RESET}"
                ;;
            "DELETE")
                method_colored="${CYBER_RED}${method}${RESET}"
                ;;
            *)
                method_colored="${CYBER_PURPLE}${method}${RESET}"
                ;;
        esac
        
        # Formata o status com cor
        if [[ $status =~ ^[0-9]+$ ]]; then
            if [[ $status -ge 200 && $status -lt 300 ]]; then
                status_colored="${CYBER_GREEN}$status${RESET}"
            elif [[ $status -ge 300 && $status -lt 400 ]]; then
                status_colored="${CYBER_BLUE}$status${RESET}"
            elif [[ $status -ge 400 && $status -lt 500 ]]; then
                status_colored="${CYBER_YELLOW}$status${RESET}"
            else
                status_colored="${CYBER_RED}$status${RESET}"
            fi
        else
            status_colored="${CYBER_PURPLE}$status${RESET}"
        fi
        
        echo -e "${CYBER_PURPLE}[${count}]${RESET} ${method_colored} ${CYBER_CYAN}$url${RESET}"
        echo -e "    ${CYBER_YELLOW}Status:${RESET} $status_colored | ${CYBER_YELLOW}Data:${RESET} ${CYBER_CYAN}$timestamp${RESET}"
        echo -e "    ${CYBER_PURPLE}───────────────────────────────────────────────────${RESET}"
        
        ((count++))
    done
}

# Visualiza detalhes de uma requisição específica
view_request_details() {
    local index=$1
    
    # Obtém a requisição pelo índice (invertido para mostrar mais recentes primeiro)
    local total=$(jq '.requests | length' "$HISTORY_FILE")
    local entry=$(jq -r ".requests | sort_by(.timestamp) | reverse | .[$index-1]" "$HISTORY_FILE")
    
    if [ "$entry" == "null" ]; then
        echo -e "${CYBER_RED}[✗] Requisição não encontrada${RESET}"
        return 1
    fi
    
    # Extrai os dados da requisição
    local method=$(echo "$entry" | jq -r '.method')
    local url=$(echo "$entry" | jq -r '.url')
    local headers=$(echo "$entry" | jq -r '.headers')
    local body=$(echo "$entry" | jq -r '.body')
    local response=$(echo "$entry" | jq -r '.response')
    local status_code=$(echo "$entry" | jq -r '.status_code')
    local timestamp=$(echo "$entry" | jq -r '.timestamp')
    
    # Exibe os detalhes formatados
    echo -e "${CYBER_PURPLE}╔═══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_PURPLE}║ ${CYBER_CYAN}${BOLD}DETALHES DA REQUISIÇÃO${RESET}${CYBER_PURPLE}                               ║${RESET}"
    echo -e "${CYBER_PURPLE}╚═══════════════════════════════════════════════════════════════╝${RESET}"
    echo
    echo -e "${CYBER_BLUE}${BOLD}Método:${RESET} ${CYBER_GREEN}$method${RESET}"
    echo -e "${CYBER_BLUE}${BOLD}URL:${RESET} ${CYBER_GREEN}$url${RESET}"
    echo -e "${CYBER_BLUE}${BOLD}Status:${RESET} ${CYBER_GREEN}$status_code${RESET}"
    echo -e "${CYBER_BLUE}${BOLD}Data/Hora:${RESET} ${CYBER_GREEN}$timestamp${RESET}"
    
    echo -e "\n${CYBER_BLUE}${BOLD}Headers:${RESET}"
    echo -e "${CYBER_CYAN}$headers${RESET}"
    
    if [ -n "$body" ] && [ "$body" != "null" ]; then
        echo -e "\n${CYBER_BLUE}${BOLD}Body:${RESET}"
        echo -e "${CYBER_CYAN}$body${RESET}"
    fi
    
    echo -e "\n${CYBER_BLUE}${BOLD}Resposta:${RESET}"
    echo -e "${CYBER_CYAN}$response${RESET}"
}

# Limpa o histórico de requisições
clear_request_history() {
    echo -e "${CYBER_YELLOW}[!] Esta ação irá apagar todo o histórico de requisições.${RESET}"
    echo -e "${CYBER_RED}    Os dados serão permanentemente perdidos.${RESET}"
    echo
    
    # Abordagem alternativa para colorir o prompt
    echo -ne "${CYBER_CYAN}Deseja continuar? (s/N): ${RESET}"
    read confirm
    
    if [[ "$confirm" =~ ^[Ss]$ ]]; then
        echo -e "${CYBER_BLUE}Limpando histórico...${RESET}"
        sleep 0.5
        echo '{"requests":[]}' > "$HISTORY_FILE"
        echo -e "${CYBER_GREEN}[✓] Histórico de requisições limpo${RESET}"
    else
        echo -e "${CYBER_YELLOW}[!] Operação cancelada${RESET}"
    fi
}

# Exporta histórico para arquivo
export_request_history() {
    local filename=${1:-"flux_history_$(date +%Y%m%d_%H%M%S).json"}
    
    # Verifica se o caminho é absoluto, se não for, salva na home do usuário
    if [[ "$filename" != /* ]]; then
        local export_file="$HOME/$filename"
    else
        local export_file="$filename"
    fi
    
    echo -e "${CYBER_BLUE}Exportando histórico...${RESET}"
    sleep 0.5
    cp "$HISTORY_FILE" "$export_file"
    
    # Mostra o caminho completo onde o arquivo foi salvo
    echo -e "${CYBER_GREEN}[✓] Histórico exportado para:${RESET}"
    echo -e "${CYBER_CYAN}$export_file${RESET}"
    
    # Mostra o tamanho do arquivo
    local file_size=$(du -h "$export_file" | cut -f1)
    echo -e "${CYBER_YELLOW}[i] Tamanho do arquivo: ${CYBER_GREEN}$file_size${RESET}"
}

# Mostra uma animação de carregamento cyberpunk
cyber_loading() {
    local message="$1"
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local delay=0.1
    
    for i in {1..10}; do
        for frame in "${frames[@]}"; do
            echo -ne "\r${CYBER_BLUE}${frame} ${CYBER_CYAN}${message}${RESET}"
            sleep $delay
        done
    done
    echo
}

# Inicializa o histórico ao carregar o script
init_history
