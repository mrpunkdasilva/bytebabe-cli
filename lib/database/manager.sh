#!/bin/bash

# Cores e estilos
HEADER_STYLE="${CYBER_BLUE}${BOLD}"
BORDER_COLOR="${CYBER_PURPLE}"
DATA_COLOR="${CYBER_GREEN}"

# Configurações
CONFIG_DIR="$HOME/.bytebabe/database"
CONNECTIONS_FILE="$CONFIG_DIR/connections.json"
HISTORY_FILE="$CONFIG_DIR/query_history.json"
BACKUP_DIR="$CONFIG_DIR/backups"

# Inicializa estrutura
init_config() {
    mkdir -p "$CONFIG_DIR" "$BACKUP_DIR"
    [ ! -f "$CONNECTIONS_FILE" ] && echo '{"connections":[]}' > "$CONNECTIONS_FILE"
    [ ! -f "$HISTORY_FILE" ] && echo '{"queries":[]}' > "$HISTORY_FILE"
}

# Salva uma conexão
save_connection() {
    local name="$1"
    local type="$2"
    local host="$3"
    local port="$4"
    local database="$5"
    local user="$6"
    local password="$7"
    
    local conn="{\"name\":\"$name\",\"type\":\"$type\",\"host\":\"$host\",\"port\":\"$port\",\"database\":\"$database\",\"user\":\"$user\",\"password\":\"$password\"}"
    local temp_file=$(mktemp)
    
    jq ".connections += [$conn]" "$CONNECTIONS_FILE" > "$temp_file"
    mv "$temp_file" "$CONNECTIONS_FILE"
}

# Lista conexões
list_connections() {
    jq -r '.connections[].name' "$CONNECTIONS_FILE"
}

# Obtém dados da conexão
get_connection() {
    local name="$1"
    jq -r ".connections[] | select(.name == \"$name\")" "$CONNECTIONS_FILE"
}

# Lista tabelas
list_tables() {
    local conn_data=$(get_connection "$1")
    local type=$(echo "$conn_data" | jq -r '.type')
    
    case $type in
        "PostgreSQL")
            list_postgres_tables "$conn_data"
            ;;
        "MySQL")
            list_mysql_tables "$conn_data"
            ;;
        "MongoDB")
            list_mongo_collections "$conn_data"
            ;;
        "SQLite")
            list_sqlite_tables "$conn_data"
            ;;
    esac
}

# Executa query
execute_query() {
    local conn_data=$(get_connection "$1")
    local query="$2"
    local type=$(echo "$conn_data" | jq -r '.type')
    
    case $type in
        "PostgreSQL")
            execute_postgres_query "$conn_data" "$query"
            ;;
        "MySQL")
            execute_mysql_query "$conn_data" "$query"
            ;;
        "MongoDB")
            execute_mongo_query "$conn_data" "$query"
            ;;
        "SQLite")
            execute_sqlite_query "$conn_data" "$query"
            ;;
    esac
    
    # Salva no histórico
    save_query_history "$1" "$query"
}

# Funções específicas para cada banco
list_postgres_tables() {
    local conn_data="$1"
    local host=$(echo "$conn_data" | jq -r '.host')
    local port=$(echo "$conn_data" | jq -r '.port')
    local database=$(echo "$conn_data" | jq -r '.database')
    local user=$(echo "$conn_data" | jq -r '.user')
    local password=$(echo "$conn_data" | jq -r '.password')
    
    PGPASSWORD="$password" psql -h "$host" -p "$port" -U "$user" -d "$database" -t -c "\dt"
}

execute_postgres_query() {
    local conn_data="$1"
    local query="$2"
    local host=$(echo "$conn_data" | jq -r '.host')
    local port=$(echo "$conn_data" | jq -r '.port')
    local database=$(echo "$conn_data" | jq -r '.database')
    local user=$(echo "$conn_data" | jq -r '.user')
    local password=$(echo "$conn_data" | jq -r '.password')
    
    PGPASSWORD="$password" psql -h "$host" -p "$port" -U "$user" -d "$database" -c "$query"
}

# Funções similares para MySQL, MongoDB e SQLite...

# Integração com DataVision
manage_database_with_datavision() {
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
                execute_query_interactive "$conn_data"
                ;;
            *Structure*)
                show_table_structure "$conn_data"
                ;;
            *Export*)
                export_data_menu "$conn_data"
                ;;
            *Import*)
                import_data_menu "$conn_data"
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

execute_query_interactive() {
    local conn_data="$1"
    local type=$(echo "$conn_data" | jq -r '.type')
    
    echo -e "\n${HEADER_STYLE}📝 SQL Query Editor${RESET}\n"
    echo -e "${CYBER_YELLOW}Enter your query (end with semicolon):${RESET}"
    
    local query=""
    while IFS= read -r line; do
        [ "$line" = ";" ] && break
        query="$query$line"
    done

    case $type in
        "PostgreSQL")
            execute_postgres_query "$conn_data" "$query"
            ;;
        "MySQL")
            execute_mysql_query "$conn_data" "$query"
            ;;
        "MongoDB")
            execute_mongo_query "$conn_data" "$query"
            ;;
        "SQLite")
            execute_sqlite_query "$conn_data" "$query"
            ;;
    esac

    # Save to history
    save_query_history "$(echo "$conn_data" | jq -r '.name')" "$query"
}

export_data_menu() {
    local conn_data="$1"
    
    while true; do
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
            *Back*)
                break
                ;;
        esac
    done
}

# Initialize config and expose main function
init_config
export -f manage_database_with_datavision
