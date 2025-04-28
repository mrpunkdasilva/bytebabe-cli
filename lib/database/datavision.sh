#!/bin/bash

# Cores e estilos
HEADER_STYLE="${CYBER_BLUE}${BOLD}"
BORDER_COLOR="${CYBER_PURPLE}"
DATA_COLOR="${CYBER_GREEN}"
NULL_COLOR="${CYBER_RED}"
COUNT_COLOR="${CYBER_YELLOW}"

# Símbolos para bordas e decorações
declare -A SYMBOLS=(
    ["top_left"]="╭"
    ["top_right"]="╮"
    ["bottom_left"]="╰"
    ["bottom_right"]="╯"
    ["horizontal"]="─"
    ["vertical"]="│"
    ["t_down"]="┬"
    ["t_up"]="┴"
    ["t_right"]="├"
    ["t_left"]="┤"
    ["cross"]="┼"
)

# Função principal do DataVision
datavision_main() {
    local command="$1"
    shift

    case "$command" in
        "show")
            show_table_data "$@"
            ;;
        "schema")
            show_table_schema "$@"
            ;;
        "stats")
            show_table_stats "$@"
            ;;
        "search")
            search_data "$@"
            ;;
        "relations")
            show_table_relations "$@"
            ;;
        *)
            show_datavision_help
            ;;
    esac
}

# Mostra dados da tabela com paginação
show_table_data() {
    local table="$1"
    local page="${2:-1}"
    local limit="${3:-10}"
    local offset=$(( (page - 1) * limit ))

    echo -e "\n${HEADER_STYLE}📊 DataVision - Visualizando $table${RESET}\n"

    # Executa query baseada no tipo de banco
    case "$DB_TYPE" in
        "postgres")
            psql -U "$DB_USER" -d "$DB_NAME" -c "\
                SELECT COUNT(*) FROM $table;
                SELECT * FROM $table LIMIT $limit OFFSET $offset;"
            ;;
        "mysql")
            mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "\
                SELECT COUNT(*) FROM $table;
                SELECT * FROM $table LIMIT $offset, $limit;"
            ;;
    esac | format_table_output
}

# Formata saída em tabela estilizada
format_table_output() {
    # Lê os dados e formata em uma tabela bonita com bordas
    local IFS=$'\n'
    local -a lines=()
    while read -r line; do
        lines+=("$line")
    done

    # Processa cabeçalho
    local -a headers=(${lines[0]})
    local -a widths=()
    for header in "${headers[@]}"; do
        widths+=(${#header})
    done

    # Calcula larguras máximas das colunas
    for line in "${lines[@]:1}"; do
        local -a fields=($line)
        for i in "${!fields[@]}"; do
            if [ ${#fields[$i]} -gt ${widths[$i]} ]; then
                widths[$i]=${#fields[$i]}
            fi
        done
    done

    # Desenha cabeçalho
    draw_table_border "top" widths
    printf "${BORDER_COLOR}${SYMBOLS[vertical]}${RESET}"
    for i in "${!headers[@]}"; do
        printf " ${HEADER_STYLE}%-*s${RESET} ${BORDER_COLOR}${SYMBOLS[vertical]}${RESET}" "${widths[$i]}" "${headers[$i]}"
    done
    echo
    draw_table_border "middle" widths

    # Desenha linhas de dados
    for line in "${lines[@]:1}"; do
        local -a fields=($line)
        printf "${BORDER_COLOR}${SYMBOLS[vertical]}${RESET}"
        for i in "${!fields[@]}"; do
            if [ "${fields[$i]}" == "NULL" ]; then
                printf " ${NULL_COLOR}%-*s${RESET} ${BORDER_COLOR}${SYMBOLS[vertical]}${RESET}" "${widths[$i]}" "NULL"
            else
                printf " ${DATA_COLOR}%-*s${RESET} ${BORDER_COLOR}${SYMBOLS[vertical]}${RESET}" "${widths[$i]}" "${fields[$i]}"
            fi
        done
        echo
    done

    # Desenha rodapé
    draw_table_border "bottom" widths
}

# Desenha bordas da tabela
draw_table_border() {
    local border_type="$1"
    local -n widths_ref="$2"

    printf "${BORDER_COLOR}"
    case "$border_type" in
        "top")
            printf "${SYMBOLS[top_left]}"
            for i in "${!widths_ref[@]}"; do
                printf "%*s" "$((widths_ref[i] + 2))" | tr ' ' "${SYMBOLS[horizontal]}"
                if [ $i -lt $((${#widths_ref[@]} - 1)) ]; then
                    printf "${SYMBOLS[t_down]}"
                fi
            done
            printf "${SYMBOLS[top_right]}"
            ;;
        "middle")
            printf "${SYMBOLS[t_right]}"
            for i in "${!widths_ref[@]}"; do
                printf "%*s" "$((widths_ref[i] + 2))" | tr ' ' "${SYMBOLS[horizontal]}"
                if [ $i -lt $((${#widths_ref[@]} - 1)) ]; then
                    printf "${SYMBOLS[cross]}"
                fi
            done
            printf "${SYMBOLS[t_left]}"
            ;;
        "bottom")
            printf "${SYMBOLS[bottom_left]}"
            for i in "${!widths_ref[@]}"; do
                printf "%*s" "$((widths_ref[i] + 2))" | tr ' ' "${SYMBOLS[horizontal]}"
                if [ $i -lt $((${#widths_ref[@]} - 1)) ]; then
                    printf "${SYMBOLS[t_up]}"
                fi
            done
            printf "${SYMBOLS[bottom_right]}"
            ;;
    esac
    printf "${RESET}\n"
}

# Mostra estatísticas da tabela
show_table_stats() {
    local table="$1"
    
    echo -e "\n${HEADER_STYLE}📊 DataVision - Estatísticas de $table${RESET}\n"

    case "$DB_TYPE" in
        "postgres")
            psql -U "$DB_USER" -d "$DB_NAME" -c "\
                SELECT 
                    (SELECT COUNT(*) FROM $table) as total_rows,
                    pg_size_pretty(pg_total_relation_size('$table')) as table_size,
                    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = '$table') as column_count;"
            ;;
        "mysql")
            mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "\
                SELECT 
                    (SELECT COUNT(*) FROM $table) as total_rows,
                    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = '$table') as column_count,
                    (SELECT data_length + index_length FROM information_schema.tables WHERE table_name = '$table') as table_size;"
            ;;
    esac | format_table_output
}

# Mostra esquema da tabela
show_table_schema() {
    local table="$1"

    echo -e "\n${HEADER_STYLE}📊 DataVision - Esquema de $table${RESET}\n"

    case "$DB_TYPE" in
        "postgres")
            psql -U "$DB_USER" -d "$DB_NAME" -c "\
                SELECT 
                    column_name,
                    data_type,
                    is_nullable,
                    column_default
                FROM information_schema.columns 
                WHERE table_name = '$table'
                ORDER BY ordinal_position;"
            ;;
        "mysql")
            mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "\
                SELECT 
                    column_name,
                    data_type,
                    is_nullable,
                    column_default
                FROM information_schema.columns 
                WHERE table_name = '$table'
                ORDER BY ordinal_position;"
            ;;
    esac | format_table_output
}

# Busca dados na tabela
search_data() {
    local table="$1"
    local column="$2"
    local value="$3"

    echo -e "\n${HEADER_STYLE}📊 DataVision - Buscando em $table${RESET}\n"

    case "$DB_TYPE" in
        "postgres")
            psql -U "$DB_USER" -d "$DB_NAME" -c "\
                SELECT * FROM $table 
                WHERE $column ILIKE '%$value%'
                LIMIT 10;"
            ;;
        "mysql")
            mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "\
                SELECT * FROM $table 
                WHERE $column LIKE '%$value%'
                LIMIT 10;"
            ;;
    esac | format_table_output
}

# Mostra relações da tabela
show_table_relations() {
    local table="$1"

    echo -e "\n${HEADER_STYLE}📊 DataVision - Relações de $table${RESET}\n"

    case "$DB_TYPE" in
        "postgres")
            psql -U "$DB_USER" -d "$DB_NAME" -c "\
                SELECT
                    tc.table_schema, 
                    tc.constraint_name, 
                    tc.table_name, 
                    kcu.column_name,
                    ccu.table_name AS foreign_table_name,
                    ccu.column_name AS foreign_column_name
                FROM 
                    information_schema.table_constraints AS tc 
                    JOIN information_schema.key_column_usage AS kcu
                      ON tc.constraint_name = kcu.constraint_name
                    JOIN information_schema.constraint_column_usage AS ccu
                      ON ccu.constraint_name = tc.constraint_name
                WHERE tc.table_name = '$table'
                  AND tc.constraint_type = 'FOREIGN KEY';"
            ;;
        "mysql")
            mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "\
                SELECT
                    TABLE_NAME as table_name,
                    COLUMN_NAME as column_name,
                    REFERENCED_TABLE_NAME as foreign_table_name,
                    REFERENCED_COLUMN_NAME as foreign_column_name
                FROM
                    information_schema.KEY_COLUMN_USAGE
                WHERE
                    TABLE_NAME = '$table'
                    AND REFERENCED_TABLE_NAME IS NOT NULL;"
            ;;
    esac | format_table_output
}

# Ajuda do DataVision
show_datavision_help() {
    echo -e "\n${HEADER_STYLE}📊 DataVision - Visualizador de Banco de Dados${RESET}\n"
    echo -e "${CYBER_YELLOW}Uso:${RESET}"
    echo -e "  bytebabe datavision ${CYBER_GREEN}<comando>${RESET} ${CYBER_BLUE}[opções]${RESET}\n"
    
    echo -e "${CYBER_YELLOW}Comandos:${RESET}"
    echo -e "  ${CYBER_GREEN}show${RESET} ${CYBER_BLUE}<tabela> [página] [limite]${RESET}    Mostra dados da tabela"
    echo -e "  ${CYBER_GREEN}schema${RESET} ${CYBER_BLUE}<tabela>${RESET}                    Mostra esquema da tabela"
    echo -e "  ${CYBER_GREEN}stats${RESET} ${CYBER_BLUE}<tabela>${RESET}                     Mostra estatísticas da tabela"
    echo -e "  ${CYBER_GREEN}search${RESET} ${CYBER_BLUE}<tabela> <coluna> <valor>${RESET}  Busca dados na tabela"
    echo -e "  ${CYBER_GREEN}relations${RESET} ${CYBER_BLUE}<tabela>${RESET}                 Mostra relações da tabela\n"
    
    echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
    echo -e "  bytebabe datavision show users"
    echo -e "  bytebabe datavision schema products"
    echo -e "  bytebabe datavision search users name john"
    echo -e "  bytebabe datavision stats orders\n"
}