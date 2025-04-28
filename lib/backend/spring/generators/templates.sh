#!/bin/bash

# Diretório de templates
TEMPLATES_DIR="$BASE_DIR/templates/spring"

# Carrega template
load_template() {
    local template_type="$1"
    local template_file="$TEMPLATES_DIR/${template_type}.template"
    
    if [[ -f "$template_file" ]]; then
        cat "$template_file"
    else
        echo "DEFAULT"
    fi
}

# Lista templates disponíveis
list_templates() {
    echo -e "${CYBER_BLUE}Templates disponíveis:${RESET}"
    for template in "$TEMPLATES_DIR"/*.template; do
        local name=$(basename "$template" .template)
        echo -e "  ${CYBER_GREEN}${name}${RESET}"
    done
}

# Adiciona template customizado
add_template() {
    local type="$1"
    local content="$2"
    local template_file="$TEMPLATES_DIR/${type}.template"
    
    mkdir -p "$TEMPLATES_DIR"
    echo "$content" > "$template_file"
    
    echo -e "${CYBER_GREEN}✔ Template ${type} adicionado com sucesso${RESET}"
}