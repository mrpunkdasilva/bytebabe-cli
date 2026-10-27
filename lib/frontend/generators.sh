#!/bin/bash

# Dispatcher canônico dos geradores frontend.
# Adaptadores específicos ficam em react/, vue/ e angular/.

source "$BASE_DIR/lib/frontend/react/generators.sh"
source "$BASE_DIR/lib/frontend/vue/generators.sh"
source "$BASE_DIR/lib/frontend/angular/generators.sh"

# Detecta o framework do projeto atual.
detect_framework() {
    if [[ ! -f "package.json" ]]; then
        echo ""
        return 0
    fi

    if grep -q '"@angular/core"' package.json; then
        echo "angular"
    elif grep -q '"vue"' package.json; then
        echo "vue"
    elif grep -q '"react"' package.json || grep -q '"next"' package.json; then
        echo "react"
    else
        echo ""
    fi
}

# Gera componente baseado no framework detectado.
generate_component() {
    local name="${1:-}"

    if [[ -z "$name" ]]; then
        echo -e "${CYBER_RED}✘ Nome do componente é obrigatório${RESET}"
        return 1
    fi

    local framework
    framework=$(detect_framework)

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
            return 1
            ;;
    esac

    echo -e "${CYBER_GREEN}✔ Componente $name gerado com sucesso${RESET}"
}

# Gera serviço baseado no framework detectado.
generate_service() {
    local name="${1:-}"

    if [[ -z "$name" ]]; then
        echo -e "${CYBER_RED}✘ Nome do serviço é obrigatório${RESET}"
        return 1
    fi

    local framework
    framework=$(detect_framework)

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
            return 1
            ;;
    esac

    echo -e "${CYBER_GREEN}✔ Serviço $name gerado com sucesso${RESET}"
}
