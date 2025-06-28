#!/bin/bash

# Carrega o diretório base
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Carrega as dependências
source "$BASE_DIR/lib/core/colors.sh"
source "$BASE_DIR/lib/core/helpers.sh"
source "$BASE_DIR/lib/core/alias_help.sh"  # Adicionando o arquivo de help

ALIAS_CONFIG_FILE="$BASE_DIR/lib/core/aliases.json"
USER_ALIAS_FILE="$HOME/.bytebabe/aliases.json"

# Novas funções avançadas

BACKUP_DIR="$HOME/.bytebabe/backups/aliases"
TEMPLATES_FILE="$BASE_DIR/lib/core/alias_templates.json"

# Cria backup automático dos aliases
create_backup() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$BACKUP_DIR/aliases_$timestamp.json"
    
    mkdir -p "$BACKUP_DIR"
    
    # Combina aliases e adiciona metadados
    jq -s '{
        backup_date: now | strftime("%Y-%m-%d %H:%M:%S"),
        version: "1.0",
        default_aliases: .[0].default_aliases,
        user_aliases: .[1].user_aliases
    }' "$ALIAS_CONFIG_FILE" "$USER_ALIAS_FILE" > "$backup_file"
    
    # Mantém apenas os últimos 5 backups
    ls -t "$BACKUP_DIR"/*.json | tail -n +6 | xargs rm -f 2>/dev/null
    
    echo -e "${CYBER_GREEN}✔ Backup criado: ${CYBER_YELLOW}$backup_file${RESET}"
}

# Restaura backup
restore_backup() {
    local backup_file="$1"
    
    if [ -z "$backup_file" ]; then
        echo -e "${CYBER_BLUE}Backups disponíveis:${RESET}"
        ls -1t "$BACKUP_DIR"/*.json | while read file; do
            local date=$(jq -r '.backup_date' "$file")
            echo -e "${CYBER_YELLOW}$(basename "$file")${RESET} - ${CYBER_GREEN}$date${RESET}"
        done
        return
    fi
    
    if [ ! -f "$backup_file" ]; then
        echo -e "${CYBER_RED}✘ Arquivo de backup não encontrado${RESET}"
        return 1
    fi
    
    # Cria backup do estado atual antes de restaurar
    create_backup
    
    # Restaura apenas os aliases do usuário
    jq '.user_aliases' "$backup_file" > "$USER_ALIAS_FILE"
    
    echo -e "${CYBER_GREEN}✔ Backup restaurado com sucesso${RESET}"
}

# Valida sintaxe de um comando
validate_command() {
    local command="$1"
    
    # Verifica se o comando está vazio
    if [ -z "$command" ]; then
        echo -e "${CYBER_RED}✘ Comando não pode estar vazio${RESET}"
        return 1
    fi
    
    # Verifica caracteres especiais perigosos
    if echo "$command" | grep -q '[;&|]'; then
        echo -e "${CYBER_RED}✘ Comando contém caracteres não permitidos${RESET}"
        return 1
    fi
    
    # Verifica se o primeiro comando existe
    local first_cmd=$(echo "$command" | awk '{print $1}')
    if ! command -v "$first_cmd" &> /dev/null; then
        echo -e "${CYBER_YELLOW}⚠ Aviso: Comando '$first_cmd' não encontrado no sistema${RESET}"
    fi
    
    return 0
}

# Aplica template de aliases
apply_template() {
    local template_name="$1"
    
    if [ -z "$template_name" ]; then
        echo -e "${CYBER_BLUE}Templates disponíveis:${RESET}"
        jq -r '.templates | to_entries[] | "\(.key) - \(.value.description)"' "$TEMPLATES_FILE" | \
            while read line; do
                echo -e "${CYBER_YELLOW}$line${RESET}"
            done
        return
    fi
    
    if ! jq -e ".templates.\"$template_name\"" "$TEMPLATES_FILE" > /dev/null; then
        echo -e "${CYBER_RED}✘ Template não encontrado: $template_name${RESET}"
        return 1
    fi
    
    # Cria backup antes de aplicar template
    create_backup
    
    # Aplica os aliases do template
    local temp_file=$(mktemp)
    jq -s '.[0].user_aliases * .[1].templates."'"$template_name"'".aliases' \
        "$USER_ALIAS_FILE" "$TEMPLATES_FILE" > "$temp_file"
    mv "$temp_file" "$USER_ALIAS_FILE"
    
    echo -e "${CYBER_GREEN}✔ Template $template_name aplicado com sucesso${RESET}"
}

# Analisa uso dos aliases
analyze_usage() {
    echo -e "${CYBER_BLUE}📊 Análise de Aliases${RESET}\n"
    
    # Total de aliases
    local total_default=$(jq '.default_aliases | length' "$ALIAS_CONFIG_FILE")
    local total_user=$(jq '.user_aliases | length' "$USER_ALIAS_FILE")
    
    echo -e "${CYBER_PINK}Estatísticas:${RESET}"
    echo -e "  ${CYBER_GREEN}Aliases padrão: $total_default${RESET}"
    echo -e "  ${CYBER_GREEN}Aliases personalizados: $total_user${RESET}"
    echo -e "  ${CYBER_GREEN}Total: $((total_default + total_user))${RESET}"
    
    # Análise de categorias
    echo -e "\n${CYBER_PINK}Distribuição por categoria:${RESET}"
    jq -r '.categories | to_entries[] | "\(.key): \(.value.aliases | length)"' \
        "$BASE_DIR/lib/core/alias_categories.json" | \
        while read line; do
            echo -e "  ${CYBER_GREEN}$line${RESET}"
        done
}

# Inicializa o arquivo de alias do usuário se não existir
init_user_aliases() {
    if [ ! -d "$HOME/.bytebabe" ]; then
        mkdir -p "$HOME/.bytebabe"
    fi
    
    if [ ! -f "$USER_ALIAS_FILE" ]; then
        echo '{"user_aliases":{}}' > "$USER_ALIAS_FILE"
    fi
}

# Carrega todos os aliases (padrão + usuário)
load_aliases() {
    local default_aliases=$(cat "$ALIAS_CONFIG_FILE" | jq -r '.default_aliases')
    local user_aliases=$(cat "$USER_ALIAS_FILE" | jq -r '.user_aliases')
    
    # Combina os aliases padrão com os do usuário
    echo "$default_aliases" "$user_aliases" | jq -s 'add'
}

# Adiciona um novo alias
add_alias() {
    local alias_name="$1"
    local command="$2"
    
    # Valida o nome do alias
    if [[ ! "$alias_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo -e "${CYBER_RED}✘ Nome do alias inválido. Use apenas letras, números, _ e -${RESET}"
        return 1
    fi
    
    # Valida o comando
    if ! validate_command "$command"; then
        return 1
    fi
    
    # Verifica se o alias já existe nos padrões
    if jq -e ".default_aliases.\"$alias_name\"" "$ALIAS_CONFIG_FILE" > /dev/null; then
        echo -e "${CYBER_RED}✘ Este alias é reservado pelo sistema${RESET}"
        return 1
    fi
    
    # Adiciona/atualiza o alias do usuário
    local temp_file=$(mktemp)
    jq ".user_aliases.\"$alias_name\" = \"$command\"" "$USER_ALIAS_FILE" > "$temp_file"
    mv "$temp_file" "$USER_ALIAS_FILE"
    
    echo -e "${CYBER_GREEN}✔ Alias adicionado: ${CYBER_YELLOW}$alias_name${RESET} => ${CYBER_BLUE}$command${RESET}"
}

# Remove um alias personalizado
remove_alias() {
    local alias_name="$1"
    
    # Verifica se é um alias padrão
    if jq -e ".default_aliases.\"$alias_name\"" "$ALIAS_CONFIG_FILE" > /dev/null; then
        echo -e "${CYBER_RED}✘ Não é possível remover aliases padrão do sistema${RESET}"
        return 1
    fi
    
    # Remove o alias do usuário
    local temp_file=$(mktemp)
    jq "del(.user_aliases.\"$alias_name\")" "$USER_ALIAS_FILE" > "$temp_file"
    mv "$temp_file" "$USER_ALIAS_FILE"
    
    echo -e "${CYBER_GREEN}✔ Alias removido: ${CYBER_YELLOW}$alias_name${RESET}"
}

# Lista todos os aliases
list_aliases() {
    echo -e "${CYBER_PINK}⚡ ALIASES DISPONÍVEIS ⚡${RESET}\n"
    
    echo -e "${CYBER_BLUE}Aliases Padrão:${RESET}"
    jq -r '.default_aliases | to_entries | .[] | "  \(.key) => \(.value)"' "$ALIAS_CONFIG_FILE" | \
        while read line; do
            echo -e "${CYBER_GREEN}$line${RESET}"
        done
    
    echo -e "\n${CYBER_BLUE}Aliases Personalizados:${RESET}"
    jq -r '.user_aliases | to_entries | .[] | "  \(.key) => \(.value)"' "$USER_ALIAS_FILE" | \
        while read line; do
            echo -e "${CYBER_YELLOW}$line${RESET}"
        done
}

# Expande um alias para seu comando completo
expand_alias() {
    local alias_name="$1"
    local expanded=""
    
    # Procura nos aliases padrão
    if [ -f "$ALIAS_CONFIG_FILE" ]; then
        expanded=$(jq -r ".default_aliases.\"$alias_name\" // empty" "$ALIAS_CONFIG_FILE" 2>/dev/null || echo "")
    fi
    
    # Se não encontrou, procura nos aliases do usuário
    if [ -z "$expanded" ] && [ -f "$USER_ALIAS_FILE" ]; then
        expanded=$(jq -r ".user_aliases.\"$alias_name\" // empty" "$USER_ALIAS_FILE" 2>/dev/null || echo "")
    fi
    
    echo "$expanded"
}

# Exporta aliases para um arquivo
export_aliases() {
    local output_file="$1"
    if [ -z "$output_file" ]; then
        output_file="bytebabe_aliases_$(date +%Y%m%d).json"
    fi
    
    # Combina aliases padrão e do usuário
    jq -s '{ 
        exported_at: now | strftime("%Y-%m-%d %H:%M:%S"),
        default_aliases: .[0].default_aliases,
        user_aliases: .[1].user_aliases
    }' "$ALIAS_CONFIG_FILE" "$USER_ALIAS_FILE" > "$output_file"
    
    echo -e "${CYBER_GREEN}✔ Aliases exportados para: ${CYBER_YELLOW}$output_file${RESET}"
}

# Importa aliases de um arquivo
import_aliases() {
    local input_file="$1"
    
    if [ ! -f "$input_file" ]; then
        echo -e "${CYBER_RED}✘ Arquivo não encontrado: $input_file${RESET}"
        return 1
    fi
    
    # Valida o formato do arquivo
    if ! jq -e . "$input_file" > /dev/null 2>&1; then
        echo -e "${CYBER_RED}✘ Arquivo JSON inválido${RESET}"
        return 1
    fi
    
    # Importa apenas os aliases do usuário
    local temp_file=$(mktemp)
    jq '.user_aliases' "$input_file" > "$temp_file"
    mv "$temp_file" "$USER_ALIAS_FILE"
    
    echo -e "${CYBER_GREEN}✔ Aliases importados com sucesso${RESET}"
}

# Busca aliases por palavra-chave
search_aliases() {
    local keyword="$1"
    local results=()
    
    echo -e "${CYBER_BLUE}🔍 Buscando por: ${CYBER_YELLOW}$keyword${RESET}\n"
    
    # Busca em aliases padrão
    echo -e "${CYBER_PINK}Aliases Padrão:${RESET}"
    jq -r ".default_aliases | to_entries[] | select(.key | contains(\"$keyword\") or .value | contains(\"$keyword\")) | \"\(.key) => \(.value)\"" "$ALIAS_CONFIG_FILE" | \
        while read line; do
            echo -e "${CYBER_GREEN}  $line${RESET}"
        done
    
    # Busca em aliases do usuário
    echo -e "\n${CYBER_PINK}Aliases Personalizados:${RESET}"
    jq -r ".user_aliases | to_entries[] | select(.key | contains(\"$keyword\") or .value | contains(\"$keyword\")) | \"\(.key) => \(.value)\"" "$USER_ALIAS_FILE" | \
        while read line; do
            echo -e "${CYBER_YELLOW}  $line${RESET}"
        done
}

# Lista aliases por categoria
list_category() {
    local category="$1"
    local categories_file="$BASE_DIR/lib/core/alias_categories.json"
    
    if [ -z "$category" ]; then
        echo -e "${CYBER_BLUE}Categorias Disponíveis:${RESET}"
        jq -r '.categories | keys[]' "$categories_file" | \
            while read cat; do
                local desc=$(jq -r ".categories.\"$cat\".description" "$categories_file")
                echo -e "${CYBER_PINK}$cat${RESET} - ${CYBER_YELLOW}$desc${RESET}"
            done
        return
    fi
    
    if ! jq -e ".categories.\"$category\"" "$categories_file" > /dev/null; then
        echo -e "${CYBER_RED}✘ Categoria não encontrada: $category${RESET}"
        return 1
    fi
    
    echo -e "${CYBER_BLUE}Aliases da categoria ${CYBER_PINK}$category${RESET}:"
    jq -r ".categories.\"$category\".aliases | to_entries[] | \"\(.key) => \(.value)\"" "$categories_file" | \
        while read line; do
            echo -e "${CYBER_GREEN}  $line${RESET}"
        done
}

# Mostra a ajuda do gerenciador de alias
show_alias_help() {
    echo -e "${CYBER_BLUE}GERENCIADOR DE ALIASES${RESET}"
    echo -e "\n${CYBER_YELLOW}Uso: bytebabe alias <comando> [opções]${RESET}"
    echo -e "\n${CYBER_PINK}Comandos:${RESET}"
    echo -e "  ${CYBER_GREEN}list, ls${RESET}        Lista todos os aliases"
    echo -e "  ${CYBER_GREEN}add, a${RESET}          Adiciona um novo alias"
    echo -e "  ${CYBER_GREEN}remove, rm${RESET}      Remove um alias personalizado"
    echo -e "  ${CYBER_GREEN}search, s${RESET}       Busca aliases por palavra-chave"
    echo -e "  ${CYBER_GREEN}export, e${RESET}       Exporta aliases para arquivo"
    echo -e "  ${CYBER_GREEN}import, i${RESET}       Importa aliases de arquivo"
    echo -e "  ${CYBER_GREEN}category, c${RESET}     Lista aliases por categoria"
    echo -e "  ${CYBER_GREEN}help${RESET}            Mostra esta ajuda"
    echo -e "\n${CYBER_PINK}Exemplos:${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe alias add gp 'git push'${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe alias search git${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe alias export my_aliases.json${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe alias category dev${RESET}"
    echo -e "  ${CYBER_GREEN}template, t${RESET}     Aplica template de aliases"
    echo -e "  ${CYBER_GREEN}backup, b${RESET}       Gerencia backups de aliases"
    echo -e "  ${CYBER_GREEN}analyze, an${RESET}     Analisa uso dos aliases"
    echo -e "\n${CYBER_PINK}Exemplos adicionais:${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe alias template git${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe alias backup${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe alias analyze${RESET}"
}

# Função principal
main() {
    init_user_aliases
    
    case "$1" in
        help|--help|-h)
            show_alias_help
            ;;
            
        template|t)
            case "$2" in
                help|--help|-h)
                    show_template_help
                    ;;
                list|ls)
                    list_templates
                    ;;
                apply)
                    apply_template "$3"
                    ;;
                show)
                    show_template "$3"
                    ;;
                *)
                    show_template_help
                    ;;
            esac
            ;;
            
        backup|b)
            case "$2" in
                help|--help|-h)
                    show_backup_help
                    ;;
                create)
                    create_backup
                    ;;
                list|ls)
                    list_backups
                    ;;
                restore)
                    restore_backup "$3"
                    ;;
                *)
                    show_backup_help
                    ;;
            esac
            ;;
            
        analyze|an)
            case "$2" in
                help|--help|-h)
                    show_analyze_help
                    ;;
                --detailed)
                    analyze_usage detailed
                    ;;
                --export)
                    export_analysis "$3"
                    ;;
                *)
                    analyze_usage
                    ;;
            esac
            ;;
            
        list|ls)
            list_aliases
            ;;
        add|a)
            if [ -z "$2" ] || [ -z "$3" ]; then
                echo -e "${CYBER_RED}✘ Uso: bytebabe alias add <alias> <comando>${RESET}"
                return 1
            fi
            add_alias "$2" "$3"
            ;;
        remove|rm)
            if [ -z "$2" ]; then
                echo -e "${CYBER_RED}✘ Uso: bytebabe alias remove <alias>${RESET}"
                return 1
            fi
            remove_alias "$2"
            ;;
        search|s)
            if [ -z "$2" ]; then
                echo -e "${CYBER_RED}✘ Uso: bytebabe alias search <palavra-chave>${RESET}"
                return 1
            fi
            search_aliases "$2"
            ;;
        export|e)
            export_aliases "$2"
            ;;
        import|i)
            if [ -z "$2" ]; then
                echo -e "${CYBER_RED}✘ Uso: bytebabe alias import <arquivo>${RESET}"
                return 1
            fi
            import_aliases "$2"
            ;;
        category|c)
            list_category "$2"
            ;;
        template|t)
            apply_template "$2"
            ;;
        backup|b)
            if [ "$2" = "restore" ]; then
                restore_backup "$3"
            else
                create_backup
            fi
            ;;
        analyze|an)
            analyze_usage
            ;;
        *)
            show_alias_help
            ;;
    esac
}

# Se este script for executado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

# Inicializa os aliases quando o script é carregado
init_user_aliases