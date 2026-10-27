#!/bin/bash

# Arquivo de configuração do projeto
CONFIG_FILE=".bytebabe/spring-config.json"

# Inicializa ou lê configuração
init_spring_config() {
    mkdir -p .bytebabe
    
    if [[ ! -f "$CONFIG_FILE" ]]; then
        # Tenta detectar package base do projeto
        local base_package=""
        
        if [[ -f "pom.xml" ]]; then
            base_package=$(grep -o 'groupId>[^<]*' pom.xml | head -1 | cut -d'>' -f2)
        elif [[ -f "build.gradle" ]]; then
            base_package=$(grep -o 'group.*=.*' build.gradle | head -1 | cut -d"'" -f2)
        fi
        
        # Cria arquivo de configuração
        cat > "$CONFIG_FILE" << EOF
{
    "basePackage": "${base_package}",
    "defaultPackages": {
        "controller": "controller",
        "service": "service",
        "repository": "repository",
        "entity": "model",
        "dto": "dto",
        "mapper": "mapper",
        "exception": "exception",
        "config": "config"
    }
}
EOF
        echo -e "${CYBER_GREEN}✓ Configuração Spring inicializada${RESET}"
    fi
}

# Obtém package completo baseado no tipo
get_package() {
    local type="${1:-}"
    local custom_package="${2:-}"
    
    # Se fornecido package customizado, usa ele
    if [[ -n "$custom_package" ]]; then
        echo "$custom_package"
        return
    fi
    
    # Lê configuração
    if [[ ! -f "$CONFIG_FILE" ]]; then
        return 0
    fi

    local base_package
    local default_subpackage
    base_package=$(jq -r '.basePackage // empty' "$CONFIG_FILE" 2>/dev/null)
    default_subpackage=$(jq -r ".defaultPackages.$type // empty" "$CONFIG_FILE" 2>/dev/null)

    if [[ -z "$default_subpackage" ]]; then
        case "$type" in
            controller) default_subpackage="controller" ;;
            service) default_subpackage="service" ;;
            repository) default_subpackage="repository" ;;
            entity) default_subpackage="model" ;;
            dto) default_subpackage="dto" ;;
            mapper) default_subpackage="mapper" ;;
            exception) default_subpackage="exception" ;;
            config) default_subpackage="config" ;;
            *) return 0 ;;
        esac
    fi

    if [[ -z "$base_package" ]]; then
        echo "$default_subpackage"
    else
        echo "${base_package}.${default_subpackage}"
    fi
}

# Helpers de compatibilidade para geradores que usam caminhos de package
get_base_package() {
    [[ -f "$CONFIG_FILE" ]] || return 0
    jq -r '.basePackage // empty' "$CONFIG_FILE" 2>/dev/null
}

get_package_name() {
    get_base_package
}

find_package_path() {
    local base_package
    base_package=$(get_base_package)
    echo "${base_package//./\/}"
}

get_base_package_path() {
    find_package_path
}

get_default_package() {
    get_package "$1"
}

get_project_name() {
    basename "$PWD"
}

# Configura package base
set_base_package() {
    local new_package="$1"
    
    # Garante que o arquivo de configuração existe
    if [[ ! -f "$CONFIG_FILE" ]]; then
        init_spring_config
    fi
    
    # Atualiza o package base
    if ! jq --arg pkg "$new_package" '.basePackage = $pkg' "$CONFIG_FILE" > "$CONFIG_FILE.tmp"; then
        echo -e "${CYBER_RED}✖ Erro ao atualizar configuração${NC}"
        return 1
    fi
    
    mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    echo -e "${CYBER_GREEN}✓ Package base atualizado: ${new_package}${NC}"
}

# Configura package padrão para um tipo
set_default_package() {
    local type="$1"
    local subpackage="$2"
    jq --arg type "$type" --arg pkg "$subpackage" '.defaultPackages[$type] = $pkg' "$CONFIG_FILE" > "$CONFIG_FILE.tmp"
    mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    echo -e "${CYBER_GREEN}✓ Package padrão para ${type} atualizado: ${subpackage}${NC}"
}