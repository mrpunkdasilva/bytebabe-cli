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

# Filtra histórico por método HTTP
filter_request_history() {
    local method="$1"
    local limit=${2:-10}  # Limite padrão de 10 entradas
    
    echo -e "${CYBER_PURPLE}╔═══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_PURPLE}║ ${CYBER_CYAN}${BOLD}HISTÓRICO FILTRADO: $method${RESET}${CYBER_PURPLE}                              ║${RESET}"
    echo -e "${CYBER_PURPLE}╚═══════════════════════════════════════════════════════════════╝${RESET}"
    echo
    
    # Verifica se o arquivo de histórico é válido
    if ! jq empty "$HISTORY_FILE" 2>/dev/null; then
        force_clean_history
        echo -e "${CYBER_YELLOW}[!] Nenhuma requisição no histórico${RESET}"
        return
    fi
    
    # Filtra as requisições pelo método
    local entries=$(jq -r ".requests | map(select(.method == \"$method\")) | sort_by(.timestamp) | reverse | .[0:$limit]" "$HISTORY_FILE" 2>/dev/null)
    
    if [ -z "$entries" ] || [ "$entries" == "[]" ]; then
        echo -e "${CYBER_YELLOW}[!] Nenhuma requisição $method encontrada no histórico${RESET}"
        return
    fi
    
    # Processa cada entrada
    local count=1
    echo "$entries" | jq -c '.[]' 2>/dev/null | while IFS= read -r entry; do
        # Extrai os campos da entrada
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

# Formata JSON para exibição
format_json_output() {
    local json_data="$1"
    
    # Verifica se é um JSON válido
    if echo "$json_data" | jq empty 2>/dev/null; then
        # Formata o JSON com cores
        echo "$json_data" | jq -C '.'
    else
        # Se não for JSON válido, retorna o texto original
        echo "$json_data"
    fi
}

# Visualiza detalhes de uma requisição específica com formatação melhorada
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
    
    echo -e "${CYBER_BLUE}${BOLD}Método:${RESET} ${method_colored}"
    echo -e "${CYBER_BLUE}${BOLD}URL:${RESET} ${CYBER_GREEN}$url${RESET}"
    
    # Formata o status com cor
    if [[ $status_code =~ ^[0-9]+$ ]]; then
        if [[ $status_code -ge 200 && $status_code -lt 300 ]]; then
            status_colored="${CYBER_GREEN}$status_code${RESET}"
        elif [[ $status_code -ge 300 && $status_code -lt 400 ]]; then
            status_colored="${CYBER_BLUE}$status_code${RESET}"
        elif [[ $status_code -ge 400 && $status_code -lt 500 ]]; then
            status_colored="${CYBER_YELLOW}$status_code${RESET}"
        else
            status_colored="${CYBER_RED}$status_code${RESET}"
        fi
    else
        status_colored="${CYBER_PURPLE}$status_code${RESET}"
    fi
    
    echo -e "${CYBER_BLUE}${BOLD}Status:${RESET} ${status_colored}"
    echo -e "${CYBER_BLUE}${BOLD}Data/Hora:${RESET} ${CYBER_GREEN}$timestamp${RESET}"
    
    echo -e "\n${CYBER_BLUE}${BOLD}Headers:${RESET}"
    echo -e "${CYBER_CYAN}$headers${RESET}"
    
    if [ -n "$body" ] && [ "$body" != "null" ]; then
        echo -e "\n${CYBER_BLUE}${BOLD}Body:${RESET}"
        format_json_output "$body"
    fi
    
    echo -e "\n${CYBER_BLUE}${BOLD}Resposta:${RESET}"
    format_json_output "$response"
    
    # Opções adicionais
    echo -e "\n${CYBER_PURPLE}───────────────────────────────────────────────────${RESET}"
    echo -e "${CYBER_YELLOW}Opções:${RESET}"
    echo -e "  ${CYBER_BLUE}[r]${RESET} ${CYBER_CYAN}Reexecutar esta requisição${RESET}"
    echo -e "  ${CYBER_BLUE}[c]${RESET} ${CYBER_CYAN}Copiar como comando curl${RESET}"
    echo -e "  ${CYBER_BLUE}[q]${RESET} ${CYBER_CYAN}Voltar${RESET}"
    
    echo -ne "${CYBER_PINK}Escolha uma opção: ${RESET}"
    read option
    
    case "$option" in
        r|R)
            echo -e "${CYBER_YELLOW}[!] Reexecutando requisição...${RESET}"
            reexecute_request "$method" "$url" "$headers" "$body"
            ;;
        c|C)
            generate_curl_command "$method" "$url" "$headers" "$body"
            ;;
        *)
            return
            ;;
    esac
}

# Gera um comando curl a partir de uma requisição
generate_curl_command() {
    local method="$1"
    local url="$2"
    local headers="$3"
    local body="$4"
    
    local curl_cmd="curl -X $method"
    
    # Adiciona headers
    if [ -n "$headers" ] && [ "$headers" != "null" ]; then
        # Divide os headers por linha e adiciona cada um
        echo "$headers" | while IFS= read -r header; do
            if [ -n "$header" ]; then
                curl_cmd="$curl_cmd -H \"$header\""
            fi
        done
    fi
    
    # Adiciona body se existir
    if [ -n "$body" ] && [ "$body" != "null" ]; then
        curl_cmd="$curl_cmd -d '$body'"
    fi
    
    # Adiciona URL
    curl_cmd="$curl_cmd \"$url\""
    
    # Exibe o comando
    echo -e "\n${CYBER_GREEN}Comando curl:${RESET}"
    echo -e "${CYBER_CYAN}$curl_cmd${RESET}"
    
    # Copia para a área de transferência se o comando xclip estiver disponível
    if command -v xclip &> /dev/null; then
        echo -n "$curl_cmd" | xclip -selection clipboard
        echo -e "${CYBER_GREEN}[✓] Comando copiado para a área de transferência${RESET}"
    elif command -v pbcopy &> /dev/null; then
        echo -n "$curl_cmd" | pbcopy
        echo -e "${CYBER_GREEN}[✓] Comando copiado para a área de transferência${RESET}"
    else
        echo -e "${CYBER_YELLOW}[!] Comando de cópia não disponível. Copie manualmente.${RESET}"
    fi
    
    echo -ne "\n${CYBER_BLUE}Pressione Enter para continuar...${RESET}"
    read
}

# Reexecuta uma requisição do histórico
reexecute_request() {
    local method="$1"
    local url="$2"
    local headers="$3"
    local body="$4"
    
    echo -e "${CYBER_BLUE}[i] Reexecutando requisição:${RESET}"
    echo -e "  ${CYBER_YELLOW}Método:${RESET} $method"
    echo -e "  ${CYBER_YELLOW}URL:${RESET} $url"
    
    # Mostra uma animação de carregamento
    echo -e "\n${CYBER_CYAN}Enviando requisição...${RESET}"
    
    # Prepara os headers para o curl
    local header_args=""
    if [ -n "$headers" ] && [ "$headers" != "null" ]; then
        while IFS= read -r header; do
            if [ -n "$header" ]; then
                header_args="$header_args -H \"$header\""
            fi
        done <<< "$headers"
    fi
    
    # Prepara o body para o curl
    local body_arg=""
    if [ -n "$body" ] && [ "$body" != "null" ]; then
        body_arg="-d '$body'"
    fi
    
    # Constrói o comando curl
    local curl_cmd="curl -s -X $method $header_args $body_arg \"$url\""
    
    # Executa o comando curl
    local response=$(eval $curl_cmd)
    local status=$?
    
    if [ $status -eq 0 ]; then
        echo -e "${CYBER_GREEN}[✓] Requisição executada com sucesso${RESET}"
        
        # Exibe a resposta formatada
        echo -e "\n${CYBER_BLUE}${BOLD}Resposta:${RESET}"
        format_json_output "$response"
        
        # Salva a nova requisição no histórico
        save_request "$method" "$url" "$headers" "$body" "$response" "200"
    else
        echo -e "${CYBER_RED}[✗] Falha ao executar requisição${RESET}"
        echo -e "${CYBER_YELLOW}Código de erro: $status${RESET}"
    fi
    
    echo -ne "\n${CYBER_BLUE}Pressione Enter para continuar...${RESET}"
    read
}

# Função para salvar uma requisição no histórico
save_request() {
    local method="$1"
    local url="$2"
    local headers="$3"
    local body="$4"
    local response="$5"
    local status_code="$6"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    # Verifica se o arquivo de histórico existe e é válido
    if [ ! -f "$HISTORY_FILE" ] || ! jq empty "$HISTORY_FILE" 2>/dev/null; then
        # Se não existir ou não for válido, cria um novo
        echo '{"requests":[]}' > "$HISTORY_FILE"
    fi
    
    # Cria um objeto JSON com os dados da requisição usando jq
    local request_json=$(jq -n \
        --arg method "$method" \
        --arg url "$url" \
        --arg headers "$headers" \
        --arg body "$body" \
        --arg response "$response" \
        --arg status_code "$status_code" \
        --arg timestamp "$timestamp" \
        '{method: $method, url: $url, headers: $headers, body: $body, response: $response, status_code: $status_code, timestamp: $timestamp}')
    
    # Adiciona a nova requisição ao histórico
    local temp_file=$(mktemp)
    if jq ".requests += [$request_json]" "$HISTORY_FILE" > "$temp_file" 2>/dev/null; then
        mv "$temp_file" "$HISTORY_FILE"
        echo -e "${CYBER_GREEN}[✓] Requisição salva no histórico${RESET}"
    else
        echo -e "${CYBER_RED}[✗] Erro ao atualizar histórico${RESET}" >&2
        rm -f "$temp_file"
        return 1
    fi
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

# Função para analisar estatísticas do histórico
analyze_history_stats() {
    echo -e "${CYBER_PURPLE}╔═══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_PURPLE}║ ${CYBER_CYAN}${BOLD}ESTATÍSTICAS DO HISTÓRICO${RESET}${CYBER_PURPLE}                              ║${RESET}"
    echo -e "${CYBER_PURPLE}╚═══════════════════════════════════════════════════════════════╝${RESET}"
    echo
    
    # Verifica se o arquivo de histórico é válido
    if ! jq empty "$HISTORY_FILE" 2>/dev/null; then
        force_clean_history
        echo -e "${CYBER_YELLOW}[!] Nenhuma requisição no histórico${RESET}"
        return
    fi
    
    # Obtém o total de requisições
    local total=$(jq '.requests | length' "$HISTORY_FILE")
    echo -e "${CYBER_BLUE}${BOLD}Total de requisições:${RESET} ${CYBER_GREEN}$total${RESET}"
    
    # Contagem por método
    local get_count=$(jq '.requests | map(select(.method == "GET")) | length' "$HISTORY_FILE")
    local post_count=$(jq '.requests | map(select(.method == "POST")) | length' "$HISTORY_FILE")
    local put_count=$(jq '.requests | map(select(.method == "PUT")) | length' "$HISTORY_FILE")
    local delete_count=$(jq '.requests | map(select(.method == "DELETE")) | length' "$HISTORY_FILE")
    
    echo -e "\n${CYBER_BLUE}${BOLD}Requisições por método:${RESET}"
    echo -e "  ${CYBER_BLUE}GET:${RESET}    ${CYBER_GREEN}$get_count${RESET}"
    echo -e "  ${CYBER_GREEN}POST:${RESET}   ${CYBER_GREEN}$post_count${RESET}"
    echo -e "  ${CYBER_YELLOW}PUT:${RESET}    ${CYBER_GREEN}$put_count${RESET}"
    echo -e "  ${CYBER_RED}DELETE:${RESET} ${CYBER_GREEN}$delete_count${RESET}"
    
    # Contagem por status
    local success_count=$(jq '.requests | map(select(.status_code | startswith("2"))) | length' "$HISTORY_FILE")
    local redirect_count=$(jq '.requests | map(select(.status_code | startswith("3"))) | length' "$HISTORY_FILE")
    local client_error_count=$(jq '.requests | map(select(.status_code | startswith("4"))) | length' "$HISTORY_FILE")
    local server_error_count=$(jq '.requests | map(select(.status_code | startswith("5"))) | length' "$HISTORY_FILE")
    
    echo -e "\n${CYBER_BLUE}${BOLD}Requisições por status:${RESET}"
    echo -e "  ${CYBER_GREEN}Sucesso (2xx):${RESET}       ${CYBER_GREEN}$success_count${RESET}"
    echo -e "  ${CYBER_BLUE}Redirecionamento (3xx):${RESET} ${CYBER_GREEN}$redirect_count${RESET}"
    echo -e "  ${CYBER_YELLOW}Erro de cliente (4xx):${RESET}  ${CYBER_GREEN}$client_error_count${RESET}"
    echo -e "  ${CYBER_RED}Erro de servidor (5xx):${RESET} ${CYBER_GREEN}$server_error_count${RESET}"
    
    # URLs mais acessadas
    echo -e "\n${CYBER_BLUE}${BOLD}URLs mais acessadas:${RESET}"
    jq -r '.requests | group_by(.url) | map({url: .[0].url, count: length}) | sort_by(.count) | reverse | .[0:5] | .[] | "  \(.count) requisições: \(.url)"' "$HISTORY_FILE" | \
    while IFS= read -r line; do
        echo -e "${CYBER_CYAN}$line${RESET}"
    done
}

# Inicializa o histórico ao carregar o script
init_history
