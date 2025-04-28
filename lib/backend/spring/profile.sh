#!/bin/bash

# Cria novo profile
create_profile() {
    local name="$1"
    local properties_file="src/main/resources/application-${name}.properties"
    
    if [[ -f "$properties_file" ]]; then
        echo -e "${CYBER_RED}✘ Profile ${name} já existe${RESET}"
        return 1
    fi
    
    # Cria arquivo de properties
    touch "$properties_file"
    
    echo -e "${CYBER_GREEN}✔ Profile ${name} criado com sucesso${RESET}"
}

# Lista profiles disponíveis
list_profiles() {
    echo -e "${CYBER_BLUE}Profiles disponíveis:${RESET}"
    for file in src/main/resources/application-*.properties; do
        local name=$(basename "$file" | sed 's/application-//' | sed 's/.properties//')
        echo -e "  ${CYBER_GREEN}${name}${RESET}"
    done
}

# Define profile ativo
set_active_profile() {
    local profile="$1"
    local config_file="src/main/resources/application.properties"
    
    # Atualiza profile ativo
    echo "spring.profiles.active=${profile}" > "$config_file"
    
    echo -e "${CYBER_GREEN}✔ Profile ${profile} definido como ativo${RESET}"
}