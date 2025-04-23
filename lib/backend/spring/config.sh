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
        "dto": "dto"
    }
}
EOF
        echo -e "${CYBER_GREEN}✓ Configuração Spring inicializada${NC}"
    fi
}

# Obtém package completo baseado no tipo
get_package() {
    local type="$1"
    local custom_package="$2"
    
    # Se fornecido package customizado, usa ele
    if [[ -n "$custom_package" ]]; then
        echo "$custom_package"
        return
    fi
    
    # Lê configuração
    local base_package=$(jq -r '.basePackage' "$CONFIG_FILE")
    local default_subpackage=$(jq -r ".defaultPackages.$type" "$CONFIG_FILE")
    
    echo "${base_package}.${default_subpackage}"
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