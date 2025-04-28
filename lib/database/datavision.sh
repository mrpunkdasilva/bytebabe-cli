#!/bin/bash

# Cores e estilos
HEADER_STYLE="${CYBER_BLUE}${BOLD}"
BORDER_COLOR="${CYBER_PURPLE}"
DATA_COLOR="${CYBER_GREEN}"

# Configurações
CONFIG_DIR="$HOME/.bytebabe/datavision"
CONNECTIONS_FILE="$CONFIG_DIR/connections.json"
HISTORY_FILE="$CONFIG_DIR/query_history.json"
EXPORT_DIR="$CONFIG_DIR/exports"

# Inicializa estrutura
init_config() {
    mkdir -p "$CONFIG_DIR" "$EXPORT_DIR"
    [ ! -f "$CONNECTIONS_FILE" ] && echo '{"connections":[]}' > "$CONNECTIONS_FILE"
    [ ! -f "$HISTORY_FILE" ] && echo '{"queries":[]}' > "$HISTORY_FILE"
}

# Função principal do DataVision
datavision_main() {
    local command="$1"
    shift

    case "$command" in
        "connect")
            connect_database "$@"
            ;;
        "add")
            add_connection "$@"
            ;;
        "list")
            list_connections
            ;;
        "remove")
            remove_connection "$@"
            ;;
        "edit")
            edit_connection "$@"
            ;;
        "import")
            import_connection "$@"
            ;;
        "export")
            export_connection "$@"
            ;;
        *)
            show_datavision_help
            ;;
    esac
}

# Adiciona nova conexão
add_connection() {
    echo -e "\n${HEADER_STYLE}📊 DataVision - Nova Conexão${RESET}\n"

    # Coleta informações da conexão
    read -p "Nome da conexão: " name
    read -p "Tipo (mysql/postgres/mongodb): " type
    read -p "Host: " host
    read -p "Porta: " port
    read -p "Usuário: " user
    read -s -p "Senha: " password
    echo
    read -p "Database: " database

    # Cria objeto JSON da conexão
    local connection="{\"name\":\"$name\",\"type\":\"$type\",\"host\":\"$host\",\"port\":$port,\"user\":\"$user\",\"password\":\"$password\",\"database\":\"$database\"}"
    
    # Adiciona ao arquivo de conexões
    local temp_file=$(mktemp)
    jq ".connections += [$connection]" "$CONNECTIONS_FILE" > "$temp_file"
    mv "$temp_file" "$CONNECTIONS_FILE"

    echo -e "\n${CYBER_GREEN}✓ Conexão adicionada com sucesso!${RESET}"
}

# Lista conexões salvas
list_connections() {
    echo -e "\n${HEADER_STYLE}📊 DataVision - Conexões Salvas${RESET}\n"
    
    jq -r '.connections[] | "Nome: \(.name)\nTipo: \(.type)\nHost: \(.host)\nPorta: \(.port)\nDatabase: \(.database)\n---"' "$CONNECTIONS_FILE"
}

# Remove conexão
remove_connection() {
    local name="$1"
    if [ -z "$name" ]; then
        echo -e "${CYBER_RED}✘ Nome da conexão não especificado${RESET}"
        return 1
    fi

    local temp_file=$(mktemp)
    jq "del(.connections[] | select(.name == \"$name\"))" "$CONNECTIONS_FILE" > "$temp_file"
    mv "$temp_file" "$CONNECTIONS_FILE"

    echo -e "${CYBER_GREEN}✓ Conexão removida com sucesso!${RESET}"
}

# Conecta ao banco de dados
connect_database() {
    local name="$1"
    if [ -z "$name" ]; then
        echo -e "${CYBER_RED}✘ Nome da conexão não especificado${RESET}"
        return 1
    fi

    # Obtém dados da conexão
    local connection=$(jq -r ".connections[] | select(.name == \"$name\")" "$CONNECTIONS_FILE")
    if [ -z "$connection" ]; then
        echo -e "${CYBER_RED}✘ Conexão não encontrada${RESET}"
        return 1
    fi

    local type=$(echo $connection | jq -r '.type')
    local host=$(echo $connection | jq -r '.host')
    local port=$(echo $connection | jq -r '.port')
    local user=$(echo $connection | jq -r '.user')
    local password=$(echo $connection | jq -r '.password')
    local database=$(echo $connection | jq -r '.database')

    # Conecta baseado no tipo de banco
    case "$type" in
        "mysql")
            mysql -h "$host" -P "$port" -u "$user" -p"$password" "$database"
            ;;
        "postgres")
            PGPASSWORD="$password" psql -h "$host" -p "$port" -U "$user" "$database"
            ;;
        "mongodb")
            mongosh "mongodb://$user:$password@$host:$port/$database"
            ;;
        *)
            echo -e "${CYBER_RED}✘ Tipo de banco não suportado${RESET}"
            return 1
            ;;
    esac
}

# Importa conexões
import_connection() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo -e "${CYBER_RED}✘ Arquivo não encontrado${RESET}"
        return 1
    fi

    jq -s '.[0].connections + .[1].connections | {connections: .}' "$CONNECTIONS_FILE" "$file" > "$CONNECTIONS_FILE.tmp"
    mv "$CONNECTIONS_FILE.tmp" "$CONNECTIONS_FILE"

    echo -e "${CYBER_GREEN}✓ Conexões importadas com sucesso!${RESET}"
}

# Exporta conexões
export_connection() {
    local output="${1:-datavision_connections.json}"
    cp "$CONNECTIONS_FILE" "$output"
    echo -e "${CYBER_GREEN}✓ Conexões exportadas para $output${RESET}"
}

# Ajuda do DataVision
show_datavision_help() {
    echo -e "\n${HEADER_STYLE}📊 DataVision - Gerenciador de Conexões de Banco de Dados${RESET}\n"
    echo -e "${CYBER_YELLOW}Uso:${RESET}"
    echo -e "  bytebabe datavision ${CYBER_GREEN}<comando>${RESET} ${CYBER_BLUE}[opções]${RESET}\n"
    
    echo -e "${CYBER_YELLOW}Comandos:${RESET}"
    echo -e "  ${CYBER_GREEN}connect${RESET} ${CYBER_BLUE}<nome>${RESET}          Conecta a um banco configurado"
    echo -e "  ${CYBER_GREEN}add${RESET}                        Adiciona nova conexão"
    echo -e "  ${CYBER_GREEN}list${RESET}                       Lista todas as conexões"
    echo -e "  ${CYBER_GREEN}remove${RESET} ${CYBER_BLUE}<nome>${RESET}          Remove uma conexão"
    echo -e "  ${CYBER_GREEN}edit${RESET} ${CYBER_BLUE}<nome>${RESET}            Edita uma conexão"
    echo -e "  ${CYBER_GREEN}import${RESET} ${CYBER_BLUE}<arquivo>${RESET}       Importa conexões de arquivo"
    echo -e "  ${CYBER_GREEN}export${RESET} ${CYBER_BLUE}[arquivo]${RESET}       Exporta conexões para arquivo\n"
    
    echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
    echo -e "  bytebabe datavision add"
    echo -e "  bytebabe datavision connect my-postgres"
    echo -e "  bytebabe datavision list"
    echo -e "  bytebabe datavision export backup.json\n"
}

# Menu principal de gerenciamento
manage_database() {
    local conn_name="$1"
    local conn_data=$(get_connection "$conn_name")
    
    while true; do
        clear
        echo -e "\n${HEADER_STYLE}📊 DataVision - Database Manager${RESET}"
        echo -e "${CYBER_BLUE}Connected to:${RESET} $conn_name\n"

        local options=(
            "📋 Browse Tables"
            "📝 Execute Query"
            "📊 Table Structure"
            "📤 Export Data"
            "📥 Import Data"
            "🔄 Backup/Restore"
            "📈 Database Info"
            "📋 Query History"
            "⬅️  Back"
        )

        choose_from_menu "Select operation:" choice "${options[@]}"

        case $choice in
            *Tables*)
                browse_tables "$conn_data"
                ;;
            *Query*)
                execute_query "$conn_data"
                ;;
            *Structure*)
                show_table_structure "$conn_data"
                ;;
            *Export*)
                export_data "$conn_data"
                ;;
            *Import*)
                import_data "$conn_data"
                ;;
            *Backup*)
                backup_restore_menu "$conn_data"
                ;;
            *Info*)
                show_database_info "$conn_data"
                ;;
            *History*)
                show_query_history "$conn_name"
                ;;
            *Back*)
                break
                ;;
        esac
    done
}

# Navegar tabelas
browse_tables() {
    local conn_data="$1"
    local db_type=$(echo "$conn_data" | jq -r '.type')
    local tables

    case $db_type in
        "mysql")
            tables=$(mysql_list_tables "$conn_data")
            ;;
        "postgres")
            tables=$(postgres_list_tables "$conn_data")
            ;;
        "mongodb")
            tables=$(mongo_list_collections "$conn_data")
            ;;
    esac

    while true; do
        echo -e "\n${HEADER_STYLE}📋 Tables${RESET}\n"
        local table_options=($tables "⬅️  Back")
        
        choose_from_menu "Select table:" table_choice "${table_options[@]}"
        
        [ "$table_choice" = "⬅️  Back" ] && break
        
        show_table_menu "$conn_data" "$table_choice"
    done
}

# Menu de operações da tabela
show_table_menu() {
    local conn_data="$1"
    local table_name="$2"

    while true; do
        echo -e "\n${HEADER_STYLE}Table: $table_name${RESET}\n"
        
        local options=(
            "👀 View Data"
            "📊 Show Structure"
            "📝 Edit Data"
            "📤 Export Table"
            "🗑️  Truncate Table"
            "⬅️  Back"
        )

        choose_from_menu "Select operation:" choice "${options[@]}"

        case $choice in
            *View*)
                view_table_data "$conn_data" "$table_name"
                ;;
            *Structure*)
                show_table_structure "$conn_data" "$table_name"
                ;;
            *Edit*)
                edit_table_data "$conn_data" "$table_name"
                ;;
            *Export*)
                export_table "$conn_data" "$table_name"
                ;;
            *Truncate*)
                truncate_table "$conn_data" "$table_name"
                ;;
            *Back*)
                break
                ;;
        esac
    done
}

# Executar query
execute_query() {
    local conn_data="$1"
    local db_type=$(echo "$conn_data" | jq -r '.type')
    
    echo -e "\n${HEADER_STYLE}📝 SQL Query Editor${RESET}\n"
    echo -e "${CYBER_YELLOW}Enter your query (end with semicolon):${RESET}"
    
    local query=""
    while IFS= read -r line; do
        [ "$line" = ";" ] && break
        query="$query$line"
    done

    case $db_type in
        "mysql")
            mysql_execute_query "$conn_data" "$query"
            ;;
        "postgres")
            postgres_execute_query "$conn_data" "$query"
            ;;
        "mongodb")
            mongo_execute_query "$conn_data" "$query"
            ;;
    esac

    # Salva no histórico
    save_query_history "$(echo "$conn_data" | jq -r '.name')" "$query"
}

# Exportar dados
export_data() {
    local conn_data="$1"
    local db_type=$(echo "$conn_data" | jq -r '.type')
    
    echo -e "\n${HEADER_STYLE}📤 Export Data${RESET}\n"
    
    local options=(
        "📋 Export Table"
        "📊 Export Query Result"
        "📦 Export Full Database"
        "⬅️  Back"
    )

    choose_from_menu "Select export type:" choice "${options[@]}"

    case $choice in
        *Table*)
            export_table_data "$conn_data"
            ;;
        *Query*)
            export_query_result "$conn_data"
            ;;
        *Database*)
            export_full_database "$conn_data"
            ;;
    esac
}

# Importar dados
import_data() {
    local conn_data="$1"
    local db_type=$(echo "$conn_data" | jq -r '.type')
    
    echo -e "\n${HEADER_STYLE}📥 Import Data${RESET}\n"
    
    local options=(
        "📋 Import CSV"
        "📊 Import SQL"
        "📦 Import Backup"
        "⬅️  Back"
    )

    choose_from_menu "Select import type:" choice "${options[@]}"

    case $choice in
        *CSV*)
            import_csv "$conn_data"
            ;;
        *SQL*)
            import_sql "$conn_data"
            ;;
        *Backup*)
            import_backup "$conn_data"
            ;;
    esac
}

# Funções auxiliares para cada tipo de banco

# MySQL
mysql_list_tables() {
    local conn_data="$1"
    local host=$(echo "$conn_data" | jq -r '.host')
    local port=$(echo "$conn_data" | jq -r '.port')
    local user=$(echo "$conn_data" | jq -r '.user')
    local pass=$(echo "$conn_data" | jq -r '.password')
    local db=$(echo "$conn_data" | jq -r '.database')

    mysql -h "$host" -P "$port" -u "$user" -p"$pass" "$db" -N -e "SHOW TABLES;"
}

mysql_execute_query() {
    local conn_data="$1"
    local query="$2"
    local host=$(echo "$conn_data" | jq -r '.host')
    local port=$(echo "$conn_data" | jq -r '.port')
    local user=$(echo "$conn_data" | jq -r '.user')
    local pass=$(echo "$conn_data" | jq -r '.password')
    local db=$(echo "$conn_data" | jq -r '.database')

    mysql -h "$host" -P "$port" -u "$user" -p"$pass" "$db" -e "$query"
}

# PostgreSQL
postgres_list_tables() {
    local conn_data="$1"
    local host=$(echo "$conn_data" | jq -r '.host')
    local port=$(echo "$conn_data" | jq -r '.port')
    local user=$(echo "$conn_data" | jq -r '.user')
    local pass=$(echo "$conn_data" | jq -r '.password')
    local db=$(echo "$conn_data" | jq -r '.database')

    PGPASSWORD="$pass" psql -h "$host" -p "$port" -U "$user" -d "$db" -t -c "\dt"
}

postgres_execute_query() {
    local conn_data="$1"
    local query="$2"
    local host=$(echo "$conn_data" | jq -r '.host')
    local port=$(echo "$conn_data" | jq -r '.port')
    local user=$(echo "$conn_data" | jq -r '.user')
    local pass=$(echo "$conn_data" | jq -r '.password')
    local db=$(echo "$conn_data" | jq -r '.database')

    PGPASSWORD="$pass" psql -h "$host" -p "$port" -U "$user" -d "$db" -c "$query"
}

# MongoDB
mongo_list_collections() {
    local conn_data="$1"
    local host=$(echo "$conn_data" | jq -r '.host')
    local port=$(echo "$conn_data" | jq -r '.port')
    local user=$(echo "$conn_data" | jq -r '.user')
    local pass=$(echo "$conn_data" | jq -r '.password')
    local db=$(echo "$conn_data" | jq -r '.database')

    mongosh "mongodb://$user:$pass@$host:$port/$db" --quiet --eval "db.getCollectionNames()"
}

mongo_execute_query() {
    local conn_data="$1"
    local query="$2"
    local host=$(echo "$conn_data" | jq -r '.host')
    local port=$(echo "$conn_data" | jq -r '.port')
    local user=$(echo "$conn_data" | jq -r '.user')
    local pass=$(echo "$conn_data" | jq -r '.password')
    local db=$(echo "$conn_data" | jq -r '.database')

    mongosh "mongodb://$user:$pass@$host:$port/$db" --quiet --eval "$query"
}

# Histórico de queries
save_query_history() {
    local conn_name="$1"
    local query="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    local new_entry="{\"connection\":\"$conn_name\",\"query\":\"$query\",\"timestamp\":\"$timestamp\"}"
    local temp_file=$(mktemp)
    
    jq ".queries += [$new_entry]" "$HISTORY_FILE" > "$temp_file"
    mv "$temp_file" "$HISTORY_FILE"
}

show_query_history() {
    local conn_name="$1"
    
    echo -e "\n${HEADER_STYLE}📋 Query History${RESET}\n"
    
    jq -r ".queries[] | select(.connection == \"$conn_name\") | \"\(.timestamp): \(.query)\"" "$HISTORY_FILE"
    
    read -n 1 -s -r -p "Press any key to continue..."
}

# Inicializa configurações
init_config
