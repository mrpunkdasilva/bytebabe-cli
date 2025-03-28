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
    local current_config=($(load_db_config))
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
    [ -f "$DB_COMPOSE_FILE" ] || {
        echo -e "${CYBER_RED}✘ Execute 'bytebabe db setup' primeiro!${RESET}"
        return 1
    }

    echo -e "\n${CYBER_BLUE}▶ Iniciando bancos...${RESET}"
    sudo docker compose -f "$DB_COMPOSE_FILE" up -d

    echo -e "\n${CYBER_PINK}═════════════════════════════════════════════════${RESET}"
    echo -e "${CYBER_GREEN} BANCOS INICIADOS:"
    sudo docker compose -f "$DB_COMPOSE_FILE" ps --format "table {{.Service}}\t{{.Status}}\t{{.Ports}}"
    echo -e "${CYBER_PINK}═════════════════════════════════════════════════${RESET}"
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
    [ -f "$DB_COMPOSE_FILE" ] || {
        echo -e "${CYBER_RED}✘ Nenhum banco configurado!${RESET}"
        return 1
    }

    echo -e "\n${CYBER_BLUE}▶ Status dos bancos:${RESET}"
    sudo docker compose -f "$DB_COMPOSE_FILE" ps
}