#!/bin/bash

# ======================
# DATABASE SERVICES MANAGER - MODULAR
# ======================

# Configurações
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
DB_DIR="$BASE_DIR/docker/databases"
DB_COMPOSE_FILE="$BASE_DIR/docker-compose-db.yml"
DB_CONFIG_FILE="$BASE_DIR/docker/databases/config.json"



# Bancos disponíveis com seus templates
declare -A DB_TEMPLATES=(
    ["mysql"]='
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: "rootpassword"
      MYSQL_DATABASE: "bytebabe_db"
      MYSQL_USER: "byteuser"
      MYSQL_PASSWORD: "bytepass"
    ports:
      - "3306:3306"
    volumes:
      - "'"${DB_DIR}"'/mysql/data:/var/lib/mysql"
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
    networks:
      - bytebabe_net
    restart: unless-stopped'

    ["postgres"]='
    image: postgres:15
    environment:
      POSTGRES_USER: "byteuser"
      POSTGRES_PASSWORD: "bytepass"
      POSTGRES_DB: "bytebabe_db"
    ports:
      - "5432:5432"
    volumes:
      - "'"${DB_DIR}"'/postgres/data:/var/lib/postgresql/data"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U byteuser"]
    networks:
      - bytebabe_net
    restart: unless-stopped'

    ["mongodb"]='
    image: mongo:6
    environment:
      MONGO_INITDB_ROOT_USERNAME: "root"
      MONGO_INITDB_ROOT_PASSWORD: "example"
    ports:
      - "27017:27017"
    volumes:
      - "'"${DB_DIR}"'/mongodb/data:/data/db"
    networks:
      - bytebabe_net
    restart: unless-stopped'

    ["redis"]='
    image: redis:7
    ports:
      - "6379:6379"
    volumes:
      - "'"${DB_DIR}"'/redis/data:/data"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
    networks:
      - bytebabe_net
    restart: unless-stopped'
)





# ======================
# FUNÇÕES UTILITÁRIAS
# ======================

create_db_directories() {
    mkdir -p "$DB_DIR" || {
        echo -e "${CYBER_RED}✘ Falha ao criar diretório principal!${RESET}"
        exit 1
    }

    for db in "$@"; do
        mkdir -p "${DB_DIR}/${db}/data"
        echo -e "${CYBER_GREEN}✔ Diretório criado para ${CYBER_CYAN}${db}${RESET}"
    done
}


save_db_config() {
    local dbs=("$@")
    mkdir -p "$(dirname "$DB_CONFIG_FILE")"
    printf '%s\n' "${dbs[@]}" | jq -R . | jq -s '{enabled: .}' > "$DB_CONFIG_FILE"
}


load_db_config() {
    if [ -f "$DB_CONFIG_FILE" ]; then
        jq -r '.enabled[]' "$DB_CONFIG_FILE"
    else
        echo ""
    fi
}


generate_db_compose() {
    echo -e "\n${CYBER_BLUE}▶ Gerando arquivo Docker Compose...${RESET}"

    # Cabeçalho do compose
    echo "version: '3.8'" > "$DB_COMPOSE_FILE"
    echo "services:" >> "$DB_COMPOSE_FILE"

    # Serviços
    for db in "$@"; do
        echo "  ${db}:${DB_TEMPLATES[$db]}" >> "$DB_COMPOSE_FILE"
        echo >> "$DB_COMPOSE_FILE"
    done

    # Rede
    echo "networks:" >> "$DB_COMPOSE_FILE"
    echo "  bytebabe_net:" >> "$DB_COMPOSE_FILE"
    echo "    driver: bridge" >> "$DB_COMPOSE_FILE"

    echo -e "${CYBER_GREEN}✔ Configuração gerada em ${CYBER_CYAN}${DB_COMPOSE_FILE}${RESET}"

    # Debug: mostra o arquivo gerado
    echo -e "\n${CYBER_YELLOW}=== CONTEÚDO DO ARQUIVO ===${RESET}"
    cat "$DB_COMPOSE_FILE"
    echo -e "${CYBER_YELLOW}==========================${RESET}"
}




# ======================
# COMANDOS PRINCIPAIS
# ======================

db_setup() {
    echo -e "\n${CYBER_BLUE}▶ Selecione os bancos para instalar:${RESET}"

    # Lista bancos disponíveis
    local i=1
    local db_names=()
    for db in "${!DB_TEMPLATES[@]}"; do
        echo "$i) $db"
        db_names+=("$db")
        ((i++))
    done
    echo "$i) Finalizar"

    # Seleção
    PS3="Digite os números separados por espaço: "
    read -p "$PS3" -a numbers

    # Processa seleção
    local selected=()
    for n in "${numbers[@]}"; do
        if [[ "$n" -eq "$i" ]]; then
            break
        elif [[ "$n" -gt 0 && "$n" -lt "$i" ]]; then
            selected+=("${db_names[$((n-1))]}")
        fi
    done

    if [ ${#selected[@]} -eq 0 ]; then
        echo -e "${CYBER_RED}✘ Nenhum banco selecionado!${RESET}"
        return 1
    fi

    # Cria diretórios e configura
    create_db_directories "${selected[@]}"
    save_db_config "${selected[@]}"
    generate_db_compose "${selected[@]}"

    echo -e "\n${CYBER_PINK}═════════════════════════════════════════════════${RESET}"
    echo -e "${CYBER_GREEN} BANCOS CONFIGURADOS COM SUCESSO: ${CYBER_CYAN}${selected[*]}${RESET}"
    echo -e "${CYBER_PINK}═════════════════════════════════════════════════${RESET}"
}

db_install() {
    local target_db="$1"

    [ -z "$target_db" ] && {
        echo -e "${CYBER_RED}✘ Especifique um banco para instalar!${RESET}"
        echo -e "Bancos disponíveis: ${!DB_TEMPLATES[*]}"
        return 1
    }

    [[ ! -v DB_TEMPLATES[$target_db] ]] && {
        echo -e "${CYBER_RED}✘ Banco não suportado!${RESET}"
        return 1
    }

    # Carrega e atualiza configuração
    local -a current_config
    mapfile -t current_config < <(load_db_config)

    if ! printf '%s\n' "${current_config[@]}" | grep -qx "$target_db"; then
        current_config+=("$target_db")
        save_db_config "${current_config[@]}"
        create_db_directories "$target_db"
        generate_db_compose "${current_config[@]}"
        echo -e "${CYBER_GREEN}✔ ${target_db} instalado com sucesso!${RESET}"
    else
        echo -e "${CYBER_YELLOW}⚠ ${target_db} já está instalado!${RESET}"
    fi
}

db_start() {
    # Verifica se o arquivo compose existe
    [ -f "$DB_COMPOSE_FILE" ] || {
        echo -e "\n${CYBER_RED}✘ Arquivo de configuração não encontrado!${RESET}"
        echo -e "${CYBER_YELLOW}Execute 'bytebabe db setup' primeiro.${RESET}"
        return 1
    }

    local target_db="$1"
    local compose_cmd="docker-compose"

    # Detecta a versão correta do compose
    if docker compose version &>/dev/null; then
        compose_cmd="docker compose"
    elif ! command -v docker-compose &>/dev/null; then
        echo -e "\n${CYBER_RED}✘ Docker Compose não está instalado!${RESET}"
        echo -e "${CYBER_YELLOW}Instale com:"
        echo -e "  sudo apt install docker-compose-plugin (para Docker v2+)"
        echo -e "  ou sudo apt install docker-compose (para Docker v1)${RESET}"
        return 1
    fi

    echo -e "\n${CYBER_BLUE}▶ Verificando ambiente Docker...${RESET}"

    # Verifica se o Docker está rodando
    if ! sudo docker info >/dev/null 2>&1; then
        echo -e "${CYBER_RED}✘ Docker não está em execução!${RESET}"
        echo -e "${CYBER_YELLOW}Inicie o serviço Docker antes de continuar.${RESET}"
        return 1
    fi

    # Inicia os bancos
    if [ -z "$target_db" ]; then
        echo -e "\n${CYBER_BLUE}▶ Iniciando TODOS os bancos de dados...${RESET}"
        sudo $compose_cmd -f "$DB_COMPOSE_FILE" up -d
    else
        # Verifica se o banco existe no compose
        if ! grep -q "^  ${target_db}:" "$DB_COMPOSE_FILE"; then
            echo -e "\n${CYBER_RED}✘ Banco '${target_db}' não configurado!${RESET}"
            echo -e "${CYBER_YELLOW}Bancos disponíveis:"
            grep "^  [a-z]" "$DB_COMPOSE_FILE" | awk '{print $1}' | tr -d ':'
            echo -e "${RESET}"
            return 1
        fi

        echo -e "\n${CYBER_BLUE}▶ Iniciando apenas ${CYBER_CYAN}${target_db}${CYBER_BLUE}...${RESET}"
        sudo $compose_cmd -f "$DB_COMPOSE_FILE" up -d "$target_db"
    fi

    # Mostra status
    show_db_status
}

show_db_status() {
    echo -e "\n${CYBER_PINK}═════════════════════════════════════════════════${RESET}"
    echo -e "${CYBER_GREEN} STATUS ATUAL DOS BANCOS${RESET}"
    echo -e "${CYBER_PINK}═════════════════════════════════════════════════${RESET}"

    if sudo $compose_cmd -f "$DB_COMPOSE_FILE" ps | grep -q "Up"; then
        sudo $compose_cmd -f "$DB_COMPOSE_FILE" ps --format "table {{.Service}}\t{{.Status}}\t{{.Ports}}" | \
        while IFS= read -r line; do
            if [[ "$line" == *"NAME"* ]]; then
                echo -e "${CYBER_CYAN}${line}${RESET}"
            elif [[ "$line" == *"Up"* ]]; then
                echo -e "${CYBER_GREEN}${line}${RESET}"
            else
                echo -e "${CYBER_YELLOW}${line}${RESET}"
            fi
        done
    else
        echo -e "${CYBER_RED}Nenhum banco em execução!${RESET}"
    fi

    echo -e "${CYBER_PINK}═════════════════════════════════════════════════${RESET}"
    echo -e "${CYBER_BLUE}╭─────────────────────────────────────────────╮"
    echo -e "│ ${CYBER_YELLOW}Comandos Úteis:${RESET}"
    echo -e "│ ${CYBER_GREEN}bytebabe db stop [nome]${RESET}  - Parar bancos"
    echo -e "│ ${CYBER_GREEN}bytebabe db logs [nome]${RESET}  - Ver logs"
    echo -e "╰─────────────────────────────────────────────╯${RESET}"
}

db_stop() {
    local target_db="$1"

    if [ -z "$target_db" ]; then
        echo -e "\n${CYBER_BLUE}▶ Parando TODOS os bancos...${RESET}"
        sudo docker compose -f "$DB_COMPOSE_FILE" down
        echo -e "${CYBER_GREEN}✔ Todos os bancos foram parados${RESET}"
    else
        echo -e "\n${CYBER_BLUE}▶ Parando ${CYBER_CYAN}${target_db}${RESET}..."
        sudo docker compose -f "$DB_COMPOSE_FILE" stop "$target_db"
        sudo docker compose -f "$DB_COMPOSE_FILE" rm -f "$target_db"
        echo -e "${CYBER_GREEN}✔ Banco '${target_db}' parado${RESET}"
    fi
}

db_status() {
    # Verifica se o arquivo de composição existe
    [ -f "$DB_COMPOSE_FILE" ] || {
        echo -e "\n${CYBER_RED}✘ Nenhum banco configurado!${RESET}"
        echo -e "${CYBER_YELLOW}Execute 'bytebabe db setup' primeiro.${RESET}"
        return 1
    }

    echo -e "\n${CYBER_PINK}═════════════════════════════════════════════════${RESET}"
    echo -e "${CYBER_BLUE}▶ Status dos Bancos de Dados${RESET}"
    echo -e "${CYBER_PINK}═════════════════════════════════════════════════${RESET}"

    # Executa o comando de status com formatação colorida
    sudo docker compose -f "$DB_COMPOSE_FILE" ps 2>&1 | while read -r line; do
        if [[ "$line" == *"NAME"* ]] || [[ "$line" == *"CONTAINER ID"* ]]; then
            echo -e "${CYBER_CYAN}${line}${RESET}"
        elif [[ "$line" == *"Up"* ]]; then
            echo -e "${CYBER_GREEN}${line}${RESET}"
        elif [[ "$line" == *"Exit"* ]] || [[ "$line" == *"exited"* ]]; then
            echo -e "${CYBER_RED}${line}${RESET}"
        else
            echo -e "${CYBER_YELLOW}${line}${RESET}"
        fi
    done

    echo -e "${CYBER_PINK}═════════════════════════════════════════════════${RESET}"
    echo -e "${CYBER_BLUE}╭─────────────────────────────────────────────╮"
    echo -e "│ ${CYBER_YELLOW}Comandos Úteis:${RESET}"
    echo -e "│ ${CYBER_GREEN}bytebabe db start${RESET}  - Iniciar bancos"
    echo -e "│ ${CYBER_GREEN}bytebabe db stop${RESET}   - Parar bancos"
    echo -e "╰─────────────────────────────────────────────╯${RESET}"
}

db_log() {
    local target_db="$1"
    local follow="${2:-false}"
    local lines="${3:-100}"
    local compose_cmd

    # Detecção automática do comando compose
    if docker compose version &>/dev/null; then
        compose_cmd="docker compose"
    elif command -v docker-compose &>/dev/null; then
        compose_cmd="docker-compose"
    else
        echo -e "\n${CYBER_RED}✘ Docker Compose não está instalado!${RESET}"
        echo -e "${CYBER_YELLOW}Instale com:"
        echo -e "  sudo apt install docker-compose-plugin (para Docker v2+)"
        echo -e "  ou sudo apt install docker-compose (para Docker v1)${RESET}"
        return 1
    fi

    [ -f "$DB_COMPOSE_FILE" ] || {
        echo -e "\n${CYBER_RED}✘ Arquivo de configuração não encontrado!${RESET}"
        return 1
    }

    if ! sudo docker info >/dev/null 2>&1; then
        echo -e "${CYBER_RED}✘ Docker não está em execução!${RESET}"
        return 1
    fi

    echo -e "\n${CYBER_PINK}═════════════════════════════════════════════════${RESET}"
    echo -e "${CYBER_BLUE}▶ LOGS DO BANCO DE DADOS${RESET}"
    echo -e "${CYBER_PINK}═════════════════════════════════════════════════${RESET}"

    if [ -z "$target_db" ]; then
        echo -e "${CYBER_YELLOW}⚠ Mostrando logs para TODOS os bancos${RESET}"
        echo -e "${CYBER_PINK}───────────────────────────────────────────────${RESET}"
        sudo $compose_cmd -f "$DB_COMPOSE_FILE" logs --tail="$lines" --timestamps 2>/dev/null || {
            echo -e "${CYBER_RED}Erro ao acessar logs. Verifique se os containers estão em execução.${RESET}"
            return 1
        }
    else
        if ! grep -q "^  ${target_db}:" "$DB_COMPOSE_FILE"; then
            echo -e "${CYBER_RED}✘ Banco '${target_db}' não encontrado!${RESET}"
            echo -e "${CYBER_YELLOW}Bancos disponíveis:"
            grep "^  [a-z]" "$DB_COMPOSE_FILE" | awk '{print $1}' | tr -d ':'
            return 1
        fi

        if [ "$follow" = "true" ]; then
            echo -e "${CYBER_GREEN}▶ Monitorando logs de ${CYBER_CYAN}${target_db}${RESET} ${CYBER_GREEN}(CTRL+C para sair)${RESET}"
            echo -e "${CYBER_PINK}───────────────────────────────────────────────${RESET}"
            sudo $compose_cmd -f "$DB_COMPOSE_FILE" logs --follow --tail="$lines" "$target_db" 2>/dev/null || {
                echo -e "${CYBER_RED}Erro ao monitorar logs. Verifique se o container está em execução.${RESET}"
                return 1
            }
        else
            echo -e "${CYBER_GREEN}▶ Últimas ${lines} linhas de ${CYBER_CYAN}${target_db}${RESET}"
            echo -e "${CYBER_PINK}───────────────────────────────────────────────${RESET}"
            sudo $compose_cmd -f "$DB_COMPOSE_FILE" logs --tail="$lines" "$target_db" 2>/dev/null || {
                echo -e "${CYBER_RED}Erro ao acessar logs. Verifique se o container está em execução.${RESET}"
                return 1
            }
        fi
    fi

    echo -e "${CYBER_PINK}═════════════════════════════════════════════════${RESET}"
    echo -e "${CYBER_BLUE}╭─────────────────────────────────────────────╮"
    echo -e "│ ${CYBER_YELLOW}Opções Avançadas:${RESET}"
    echo -e "│ ${CYBER_GREEN}bytebabe db log [nome]${RESET}         - Últimas 100 linhas"
    echo -e "│ ${CYBER_GREEN}bytebabe db log [nome] true${RESET}    - Monitorar em tempo real"
    echo -e "│ ${CYBER_GREEN}bytebabe db log [nome] false 50${RESET} - Últimas 50 linhas"
    echo -e "╰─────────────────────────────────────────────╯${RESET}"
}