#!/bin/bash

# Define o diretório base (deve apontar para a raiz do projeto)
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Importa as cores
source "$BASE_DIR/lib/flux/display.sh"

# Verifica se o json-server está instalado
check_json_server() {
    if ! command -v json-server &> /dev/null; then
        echo -e "${CYBER_RED}[✗] json-server não encontrado${RESET}"
        echo -e "${CYBER_YELLOW}[i] Instalando json-server...${RESET}"
        npm install -g json-server
        
        if [ $? -ne 0 ]; then
            echo -e "${CYBER_RED}[✗] Falha ao instalar json-server${RESET}"
            echo -e "${CYBER_YELLOW}[i] Tente instalar manualmente:${RESET}"
            echo -e "${CYBER_CYAN}    npm install -g json-server${RESET}"
            exit 1
        fi
    fi
}

# Inicia o servidor JSON
start_json_server() {
    local db_file="$BASE_DIR/db.json"
    local port=${1:-3000}
    
    if [ ! -f "$db_file" ]; then
        echo -e "${CYBER_RED}[✗] Arquivo db.json não encontrado em $db_file${RESET}"
        echo -e "${CYBER_YELLOW}[i] Criando arquivo db.json de exemplo...${RESET}"
        
        # Cria um arquivo db.json de exemplo
        cat > "$db_file" << EOF
{
  "users": [
    { "id": 1, "name": "John Doe", "email": "john@example.com" },
    { "id": 2, "name": "Jane Smith", "email": "jane@example.com" }
  ],
  "posts": [
    { "id": 1, "title": "Hello World", "author": 1, "content": "This is my first post" },
    { "id": 2, "title": "Flux API Client", "author": 2, "content": "Testing the Flux API client" }
  ],
  "comments": [
    { "id": 1, "postId": 1, "text": "Great post!", "author": 2 },
    { "id": 2, "postId": 1, "text": "Thanks for sharing", "author": 1 }
  ]
}
EOF
        echo -e "${CYBER_GREEN}[✓] Arquivo db.json criado com sucesso${RESET}"
    fi
    
    echo -e "${CYBER_PURPLE}╔═══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_PURPLE}║ ${CYBER_CYAN}${BOLD}JSON SERVER - API REST MOCK${RESET}${CYBER_PURPLE}                           ║${RESET}"
    echo -e "${CYBER_PURPLE}╚═══════════════════════════════════════════════════════════════╝${RESET}"
    echo
    echo -e "${CYBER_GREEN}[✓] Iniciando servidor na porta ${CYBER_CYAN}$port${RESET}"
    echo -e "${CYBER_YELLOW}[i] Usando arquivo: ${CYBER_CYAN}$db_file${RESET}"
    echo -e "${CYBER_YELLOW}[i] API disponível em: ${CYBER_CYAN}http://localhost:$port${RESET}"
    echo
    echo -e "${CYBER_BLUE}Recursos disponíveis:${RESET}"
    
    # Lista os recursos disponíveis no db.json
    jq -r 'keys[]' "$db_file" | while read resource; do
        echo -e "  ${CYBER_GREEN}• ${CYBER_CYAN}/$resource${RESET}"
    done
    
    echo
    echo -e "${CYBER_PURPLE}───────────────────────────────────────────────────────────────${RESET}"
    echo -e "${CYBER_YELLOW}[i] Pressione ${CYBER_RED}Ctrl+C${CYBER_YELLOW} para parar o servidor${RESET}"
    echo -e "${CYBER_PURPLE}───────────────────────────────────────────────────────────────${RESET}"
    echo
    
    # Inicia o servidor
    json-server --watch "$db_file" --port "$port"
}

# Função principal
main() {
    local port=${1:-3000}
    
    check_json_server
    start_json_server "$port"
}

# Executa o script
main "$@"