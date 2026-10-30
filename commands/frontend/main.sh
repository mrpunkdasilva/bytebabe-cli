#!/bin/bash

# ==========================================
# FRONTEND COMMANDER - CYBERPUNK EDITION
# ==========================================

# Carrega bibliotecas
source "${BASE_DIR}/lib/core/colors.sh"
source "${BASE_DIR}/lib/core/helpers.sh"
source "${BASE_DIR}/lib/frontend/main.sh"
source "${BASE_DIR}/lib/frontend/config.sh"
source "${BASE_DIR}/lib/frontend/templates.sh"

# Configurações
VITE_TEMPLATES=("react" "react-ts" "vue" "vue-ts" "preact" "preact-ts" "lit" "lit-ts" "svelte" "svelte-ts")
NEXT_TEMPLATES=("default" "app" "pages" "default-ts" "app-ts" "pages-ts")

# ==========================================
# FUNÇÕES DE INSTALAÇÃO
# ==========================================

show_frontend_header() {
    clear
    echo -e "${CYBER_BG_DARK}${CYBER_PINK}"
    echo "╔══════════════════════════════════════════════╗"
    echo "║  ███████╗██████╗  ██████╗ ███╗   ██╗████████╗║"
    echo "║  ██╔════╝██╔══██╗██╔═══██╗████╗  ██║╚══██╔══╝║"
    echo "║  █████╗  ██████╔╝██║   ██║██╔██╗ ██║   ██║   ║"
    echo "║  ██╔══╝  ██╔══██╗██║   ██║██║╚██╗██║   ██║   ║"
    echo "║  ██║     ██║  ██║╚██████╔╝██║ ╚████║   ██║   ║"
    echo "║  ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${RESET}"
    cyber_divider
}

install_package_manager() {
    local pkg=$1
    case $pkg in
        "yarn")
            sudo npm install -g yarn
            echo -e "${CYBER_GREEN}✔ Yarn $(yarn --version) instalado${RESET}"
            ;;
        "pnpm")
            sudo npm install -g pnpm
            echo -e "${CYBER_GREEN}✔ pnpm $(pnpm --version) instalado${RESET}"
            ;;
        "bun")
            sudo curl -fsSL https://bun.sh/install | bash
            echo -e "${CYBER_GREEN}✔ Bun $(bun --version) instalado${RESET}"
            ;;
        "npm")
            sudo echo -e "${CYBER_GREEN}✔ npm $(npm --version) (pré-instalado)${RESET}"
            ;;
    esac
}

install_framework() {
    local fw=$1
    case $fw in
        "react")
            sudo npm install -g create-react-app create-vite
            echo -e "${CYBER_GREEN}✔ React + Vite instalados${RESET}"
            ;;
        "vue")
            sudo npm install -g @vue/cli
            echo -e "${CYBER_GREEN}✔ Vue CLI $(vue --version) instalado${RESET}"
            ;;
        "angular")
            sudo npm install -g @angular/cli
            echo -e "${CYBER_GREEN}✔ Angular CLI instalado${RESET}"
            ;;
        "next")
            sudo npm install -g create-next-app
            echo -e "${CYBER_GREEN}✔ Next.js instalado${RESET}"
            ;;
    esac
}

# ==========================================
# MENUS INTERATIVOS
# ==========================================

select_package_managers() {
    echo -e "${CYBER_YELLOW}● SELECIONE SEUS GERENCIADORES (separados por vírgulas ou 5 para todos):${RESET}"
    echo -e "${CYBER_BLUE}1) npm"
    echo -e "2) yarn"
    echo -e "3) pnpm"
    echo -e "4) bun"
    echo -e "5) Todos${RESET}"
    read -p "Opções (ex: 1,3): " pm_choices

    IFS=',' read -ra choices <<< "$pm_choices"

    if [[ " ${choices[*]} " =~ "5" ]]; then
        package_managers=("npm" "yarn" "pnpm" "bun")
    else
        package_managers=()
        for choice in "${choices[@]}"; do
            case $choice in
                1) package_managers+=("npm") ;;
                2) package_managers+=("yarn") ;;
                3) package_managers+=("pnpm") ;;
                4) package_managers+=("bun") ;;
            esac
        done
    fi

    for pm in "${package_managers[@]}"; do
        install_package_manager "$pm"
    done
}

select_frameworks() {
    echo -e "\n${CYBER_YELLOW}● SELECIONE SEUS FRAMEWORKS (separados por vírgulas ou 5 para todos):${RESET}"
    echo -e "${CYBER_BLUE}1) React"
    echo -e "2) Vue"
    echo -e "3) Angular"
    echo -e "4) Next.js"
    echo -e "5) Todos${RESET}"
    read -p "Opções (ex: 1,3): " fw_choices

    IFS=',' read -ra choices <<< "$fw_choices"

    if [[ " ${choices[*]} " =~ "5" ]]; then
        frameworks=("react" "vue" "angular" "next")
    else
        frameworks=()
        for choice in "${choices[@]}"; do
            case $choice in
                1) frameworks+=("react") ;;
                2) frameworks+=("vue") ;;
                3) frameworks+=("angular") ;;
                4) frameworks+=("next") ;;
            esac
        done
    fi

    for fw in "${frameworks[@]}"; do
        install_framework "$fw"
    done
}

# ==========================================
# PROCESSAMENTO DE COMANDOS
# ==========================================

process_setup() {
    show_frontend_header
    echo -e "${CYBER_PINK}⚡ CONFIGURAÇÃO FRONTEND ⚡${RESET}"

    # Verificar Node.js e package manager
    if ! check_frontend_requirements; then
        echo -e "${CYBER_PINK}bytebabe backend install node${RESET}"
        return 1
    fi

    # Gerenciadores de pacote
    select_package_managers

    # Frameworks
    select_frameworks

    # Finalização
    echo -e "\n${CYBER_PINK}⚡ CONFIGURAÇÃO COMPLETA! ⚡${RESET}"
    echo -e "${CYBER_BLUE}Ferramentas instaladas:"
    echo -e "• Node.js $(node -v)"
    echo -e "• Gerenciadores: ${package_managers[*]}"
    echo -e "• Frameworks: ${frameworks[*]}${RESET}"
}

show_help() {
    show_frontend_header
    echo -e "${CYBER_BLUE}USO: bytebabe frontend [comando]"
    echo -e "\nCOMANDOS DISPONÍVEIS:"
    echo -e "  ${CYBER_PINK}setup${RESET}   - Configura ambiente frontend"
    echo -e "  ${CYBER_PINK}help${RESET}    - Mostra esta ajuda"
    echo -e "\nEXEMPLOS:"
    echo -e "  ${CYBER_YELLOW}bytebabe frontend setup"
    echo -e "  ${CYBER_YELLOW}bytebabe frontend help${RESET}"
    cyber_divider
}

show_frontend_help() {
    echo -e "${CYBER_BLUE}${CYBER_BOLD}FRONTEND CLI - COMANDOS DISPONÍVEIS${RESET}"
    echo ""
    echo -e "${CYBER_YELLOW}Uso: bytebabe frontend <comando> [opções]${RESET}"
    echo ""
    echo -e "${CYBER_PINK}Comandos Gerais:${RESET}"
    echo -e "  ${CYBER_GREEN}new, create${RESET}    Cria novo projeto frontend"
    echo -e "  ${CYBER_GREEN}generate, g${RESET}    Gera componentes e outros recursos"
    echo -e "  ${CYBER_GREEN}install, i${RESET}     Instala dependências"
    echo -e "  ${CYBER_GREEN}test, t${RESET}        Executa testes"
    echo -e "  ${CYBER_GREEN}build, b${RESET}       Compila o projeto"
    echo -e "  ${CYBER_GREEN}serve, s${RESET}       Inicia servidor de desenvolvimento"
    echo ""
    echo -e "${CYBER_PINK}Comandos de Geração:${RESET}"
    echo -e "  ${CYBER_GREEN}g component${RESET}    Gera novo componente"
    echo -e "  ${CYBER_GREEN}g service${RESET}      Gera novo serviço"
    echo -e "  ${CYBER_GREEN}g store${RESET}        Gera nova store (Vue/React)"
    echo -e "  ${CYBER_GREEN}g hook${RESET}         Gera novo hook (React)"
    echo -e "  ${CYBER_GREEN}g guard${RESET}        Gera novo guard (Angular)"
    echo ""
    echo -e "${CYBER_PINK}Exemplos:${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe frontend new react my-app${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe frontend g component UserProfile${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe frontend g service Auth${RESET}"
}

# Função para criar novo projeto
create_frontend_project() {
    local framework=$1
    local name=$2
    local template=$3

    if [[ -z "$name" ]]; then
        echo -e "${CYBER_RED}✘ Nome do projeto é obrigatório${RESET}"
        return 1
    fi

    case $framework in
        "react")
            if [[ "$template" == "vite" ]]; then
                frontend_create_vite "$name" "react-ts" || return $?
            else
                frontend_exec create-react-app "$name" --template typescript || return $?
            fi
            ;;
        "vue")
            if [[ "$template" == "vite" ]]; then
                frontend_create_vite "$name" "vue-ts" || return $?
            else
                frontend_create_vue "$name" || return $?
            fi
            ;;
        "angular")
            frontend_exec @angular/cli new "$name" --style=scss --routing=true --strict || return $?
            ;;
        "next")
            frontend_exec create-next-app@latest "$name" --typescript --tailwind --eslint || return $?
            ;;
        "svelte")
            frontend_create_vite "$name" "svelte-ts" || return $?
            ;;
        *)
            echo -e "${CYBER_RED}✘ Framework não suportado: $framework${RESET}"
            return 1
            ;;
    esac

    # Configuração pós-criação
    cd "$name" || return 1
    
    # Inicializa configuração ByteBabe
    init_frontend_config

    # Instala dependências comuns
    frontend_install dev \
        @testing-library/jest-dom \
        @testing-library/user-event \
        prettier \
        eslint \
        husky \
        lint-staged || return $?

    # Configurações específicas por framework
    case $framework in
        "react"|"next")
            frontend_install dev \
                @testing-library/react \
                @types/react-test-renderer || return $?
            ;;
        "vue")
            frontend_install dev \
                @vue/test-utils \
                @vitejs/plugin-vue || return $?
            ;;
        "angular")
            frontend_install dev \
                @types/jasmine \
                karma-coverage || return $?
            ;;
    esac

    echo -e "${CYBER_GREEN}✔ Projeto $name criado com sucesso!${RESET}"
    echo -e "${CYBER_BLUE}Para começar:${RESET}"
    echo -e "  cd $name"
    echo -e "  $(detect_node_pkg_manager) run dev"
}

# Função para adicionar funcionalidades
add_feature() {
    local feature=$1
    shift
    local options=("$@")

    case $feature in
        "tailwind")
            frontend_install dev tailwindcss postcss autoprefixer || return $?
            frontend_exec tailwindcss init -p || return $?
            setup_tailwind
            ;;
        "redux")
            frontend_install prod @reduxjs/toolkit react-redux || return $?
            generate_redux_store
            ;;
        "router")
            local framework
            framework=$(detect_framework)
            case $framework in
                "react")
                    frontend_install prod react-router-dom || return $?
                    generate_react_router
                    ;;
                "vue")
                    frontend_install prod vue-router@4 || return $?
                    generate_vue_router
                    ;;
                *)
                    echo -e "${CYBER_RED}✘ Router não suportado para este framework${RESET}"
                    return 1
                    ;;
            esac
            ;;
        "i18n")
            local framework
            framework=$(detect_framework)
            case $framework in
                "react")
                    frontend_install prod react-i18next i18next || return $?
                    generate_i18n_setup
                    ;;
                "vue")
                    frontend_install prod vue-i18n@9 || return $?
                    generate_vue_i18n
                    ;;
                "angular")
                    ng add @angular/localize
                    ;;
                *)
                    echo -e "${CYBER_RED}✘ i18n não suportado para este framework${RESET}"
                    return 1
                    ;;
            esac
            ;;
        *)
            echo -e "${CYBER_RED}✘ Funcionalidade não suportada: $feature${RESET}"
            return 1
            ;;
    esac
}

# Handler principal de comandos
run_frontend_command() {
    case "$1" in
        new|create)
            shift
            case "$1" in
                react|vue|angular|next|svelte)
                    framework=$1
                    shift
                    name=$1
                    shift
                    template=${1:-"default"}
                    create_frontend_project "$framework" "$name" "$template"
                    ;;
                help|--help|-h)
                    [ "$(type -t show_frontend_new_help)" = "function" ] && show_frontend_new_help || show_frontend_help
                    ;;
                *)
                    echo -e "${CYBER_RED}✘ Framework não especificado ou não suportado${RESET}"
                    [ "$(type -t show_frontend_new_help)" = "function" ] && show_frontend_new_help || show_frontend_help
                    return 1
                    ;;
            esac
            ;;
        
        add)
            shift
            case "$1" in
                tailwind|redux|router|i18n)
                    feature=$1
                    shift
                    add_feature "$feature" "$@"
                    ;;
                help|--help|-h)
                    [ "$(type -t show_frontend_add_help)" = "function" ] && show_frontend_add_help || show_frontend_help
                    ;;
                *)
                    echo -e "${CYBER_RED}✘ Funcionalidade não especificada ou não suportada${RESET}"
                    [ "$(type -t show_frontend_add_help)" = "function" ] && show_frontend_add_help || show_frontend_help
                    return 1
                    ;;
            esac
            ;;
        
        generate|g)
            shift
            case "$1" in
                component|c)
                    shift
                    generate_component "$1"
                    ;;
                service|s)
                    shift
                    generate_service "$1"
                    ;;
                store)
                    shift
                    framework=$(detect_framework)
                    case "$framework" in
                        "react")
                            generate_react_context "$1"
                            ;;
                        "vue")
                            generate_vue_store "$1"
                            ;;
                        *)
                            echo -e "${CYBER_RED}✘ Store não suportada para este framework${RESET}"
                            return 1
                            ;;
                    esac
                    ;;
                hook)
                    shift
                    framework=$(detect_framework)
                    if [[ "$framework" == "react" ]]; then
                        generate_react_hook "$1"
                    else
                        echo -e "${CYBER_RED}✘ Hooks são específicos do React${RESET}"
                        return 1
                    fi
                    ;;
                guard)
                    shift
                    framework=$(detect_framework)
                    if [[ "$framework" == "angular" ]]; then
                        generate_angular_guard "$1"
                    else
                        echo -e "${CYBER_RED}✘ Guards são específicos do Angular${RESET}"
                        return 1
                    fi
                    ;;
                *)
                    echo -e "${CYBER_RED}✘ Tipo de geração não especificado ou inválido${RESET}"
                    echo -e "Tipos disponíveis: component, service, store, hook, guard"
                    return 1
                    ;;
            esac
            ;;
        
        install|i)
            shift
            case "$1" in
                deps)
                    frontend_install_deps
                    ;;
                dev)
                    shift
                    frontend_install dev "$@"
                    ;;
                *)
                    if [[ $# -eq 0 ]]; then
                        frontend_install_deps
                    else
                        frontend_install prod "$@"
                    fi
                    ;;
            esac
            ;;
        
        test|t)
            shift
            case "$1" in
                watch)
                    frontend_run_script test:watch
                    ;;
                coverage)
                    frontend_run_script test:coverage
                    ;;
                *)
                    frontend_run_script test "$@"
                    ;;
            esac
            ;;
        
        build|b)
            shift
            case "$1" in
                prod)
                    frontend_run_script build:prod
                    ;;
                *)
                    frontend_run_script build
                    ;;
            esac
            ;;
        
        serve|s)
            shift
            case "$1" in
                prod)
                    frontend_run_script serve:prod
                    ;;
                *)
                    frontend_run_script start
                    ;;
            esac
            ;;
        
        help|--help|-h)
            show_frontend_help
            ;;
        
        setup)
            process_setup
            ;;
        
        *)
            echo -e "${CYBER_RED}✘ Comando não reconhecido: $1${RESET}"
            show_frontend_help
            return 1
            ;;
    esac
}

# ==========================================
# FUNÇÃO PRINCIPAL
# ==========================================

main() {
    if [ $# -eq 0 ]; then
        run_frontend_command help
        return
    fi
    case $1 in
        "setup")
            process_setup
            ;;
        "help"|"--help"|"-h")
            run_frontend_command help
            ;;
        *)
            run_frontend_command "$@"
            ;;
    esac
}

# ==========================================
# INICIALIZAÇÃO
# ==========================================

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi