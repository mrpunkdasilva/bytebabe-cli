#!/bin/bash

# Carrega as dependências
source "$BASE_DIR/lib/core/colors.sh"
source "$BASE_DIR/lib/core/helpers.sh"
source "$BASE_DIR/lib/frontend/config.sh"
source "$BASE_DIR/lib/frontend/templates.sh"
source "$BASE_DIR/lib/frontend/commands.sh"

# Carrega geradores específicos de cada framework
source "$BASE_DIR/lib/frontend/react/generators.sh"
source "$BASE_DIR/lib/frontend/vue/generators.sh"
source "$BASE_DIR/lib/frontend/angular/generators.sh"

# Verifica requisitos básicos
check_frontend_requirements() {
    if ! command -v node &> /dev/null; then
        echo -e "${CYBER_RED}✘ Node.js não encontrado! Por favor, instale o Node.js${RESET}"
        exit 1
    fi

    if ! command -v npm &> /dev/null; then
        echo -e "${CYBER_RED}✘ NPM não encontrado! Por favor, instale o NPM${RESET}"
        exit 1
    fi
}

# Detecta o framework do projeto
detect_framework() {
    if [[ -f "package.json" ]]; then
        if grep -q '"react"' package.json; then
            echo "react"
        elif grep -q '"vue"' package.json; then
            echo "vue"
        elif grep -q '"@angular/core"' package.json; then
            echo "angular"
        else
            echo ""
        fi
    else
        echo ""
    fi
}

# Gera componente baseado no framework detectado
generate_component() {
    local framework=$(detect_framework)
    local name="$1"
    
    case "$framework" in
        "react")
            generate_react_component "$name"
            ;;
        "vue")
            generate_vue_component "$name"
            ;;
        "angular")
            generate_angular_component "$name"
            ;;
        *)
            echo -e "${CYBER_RED}✘ Framework não detectado ou não suportado${RESET}"
            exit 1
            ;;
    esac
    
    echo -e "${CYBER_GREEN}✔ Componente $name gerado com sucesso${RESET}"
}

# Gera serviço baseado no framework detectado
generate_service() {
    local framework=$(detect_framework)
    local name="$1"
    
    case "$framework" in
        "react")
            generate_api_service "$name"
            ;;
        "vue")
            generate_vue_store "$name"
            ;;
        "angular")
            generate_angular_service "$name"
            ;;
        *)
            echo -e "${CYBER_RED}✘ Framework não detectado ou não suportado${RESET}"
            exit 1
            ;;
    esac
    
    echo -e "${CYBER_GREEN}✔ Serviço $name gerado com sucesso${RESET}"
}
