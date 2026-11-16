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
    echo -e "  ${CYBER_GREEN}setup${RESET}          Configura gerenciadores e frameworks"
    echo -e "  ${CYBER_GREEN}new, create${RESET}    Cria novo projeto frontend"
    echo -e "  ${CYBER_GREEN}add${RESET}            Adiciona tailwind, redux, router ou i18n"
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

# Ajuda específica de um subcomando. Chamada por <comando> --help/-h.
frontend_command_help() {
    local cmd="$1"
    local foot="${CYBER_GRAY}Ajuda geral: bytebabe frontend help${RESET}"

    echo -e "${CYBER_CYAN}━━━ bytebabe frontend ${CYBER_BOLD}${cmd}${RESET}${CYBER_CYAN} ━━━${RESET}"
    echo ""

    case "$cmd" in
        setup)
            echo -e "${CYBER_YELLOW}Assistente interativo de ambiente frontend: escolhe gerenciadores de${RESET}"
            echo -e "${CYBER_YELLOW}pacote (npm/yarn/pnpm/bun) e frameworks (React/Vue/Angular/Next) e instala${RESET}"
            echo -e "${CYBER_YELLOW}cada um globalmente com sudo. Exige Node.js já instalado.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe frontend setup"
            echo ""
            echo -e "${CYBER_YELLOW}O que acontece:${RESET}"
            echo -e "  ${CYBER_GREEN}1.${RESET} Confere Node.js e um package manager (${CYBER_GRAY}check_frontend_requirements${RESET})"
            echo -e "  ${CYBER_GREEN}2.${RESET} Menu de gerenciadores: escolha por números (ex.: ${CYBER_GREEN}1,3${RESET} ou ${CYBER_GREEN}5${RESET} = todos)"
            echo -e "  ${CYBER_GREEN}3.${RESET} Menu de frameworks: mesma mecânica (${CYBER_GREEN}5${RESET} = todos)"
            echo ""
            echo -e "${CYBER_YELLOW}Aviso:${RESET}"
            echo -e "  ${CYBER_RED}Cada item escolhido é instalado com sudo (npm install -g ou instalador oficial).${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe frontend setup${RESET}"
            echo ""
            echo -e "$foot"
            ;;
            new|create)
            echo -e "${CYBER_YELLOW}Cria um novo projeto frontend de forma não interativa e já preparado:${RESET}"
            echo -e "${CYBER_GRAY}Após criar, inicializa .bytebabe/frontend-config.json, instala dependências${RESET}"
            echo -e "${CYBER_GRAY}de qualidade (prettier, eslint, husky, lint-staged, testing-library) e mostra${RESET}"
            echo -e "${CYBER_GRAY}o comando de dev do package manager detectado.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe frontend new ${CYBER_BOLD}<framework>${RESET} ${CYBER_BOLD}<nome>${RESET} ${CYBER_GRAY}[template]${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Frameworks:${RESET}"
            echo -e "  ${CYBER_GREEN}react${RESET}     create-react-app com TypeScript (ou Vite react-ts com template vite)"
            echo -e "  ${CYBER_GREEN}vue${RESET}       create-vue oficial (ou Vite vue-ts com template vite)"
            echo -e "  ${CYBER_GREEN}angular${RESET}   @angular/cli new com SCSS, routing e strict"
            echo -e "  ${CYBER_GREEN}next${RESET}      create-next-app com TypeScript + Tailwind + ESLint"
            echo -e "  ${CYBER_GREEN}svelte${RESET}    Vite svelte-ts"
            echo ""
            echo -e "${CYBER_YELLOW}Argumentos:${RESET}"
            echo -e "  ${CYBER_GREEN}framework${RESET}  Obrigatório: react, vue, angular, next ou svelte"
            echo -e "  ${CYBER_GREEN}nome${RESET}       Obrigatório: nome da pasta do projeto"
            echo -e "  ${CYBER_GREEN}template${RESET}   Opcional: ${CYBER_GREEN}default${RESET} (padrão) ou ${CYBER_GREEN}vite${RESET} (react/vue)"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe frontend new react my-app${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe frontend new vue my-app vite${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe frontend create next admin${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        add)
            echo -e "${CYBER_YELLOW}Instala e configura uma funcionalidade no projeto atual (detecta o framework${RESET}"
            echo -e "${CYBER_GRAY}pelo package.json para router e i18n).${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe frontend add ${CYBER_BOLD}<feature>${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Funcionalidades:${RESET}"
            echo -e "  ${CYBER_GREEN}tailwind${RESET}  tailwindcss + postcss + autoprefixer, init -p e setup do config"
            echo -e "  ${CYBER_GREEN}redux${RESET}     @reduxjs/toolkit + react-redux e store de exemplo gerada"
            echo -e "  ${CYBER_GREEN}router${RESET}    react-router-dom (React) ou vue-router@4 (Vue) com rotas geradas"
            echo -e "  ${CYBER_GREEN}i18n${RESET}      react-i18next (React), vue-i18n@9 (Vue) ou @angular/localize"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe frontend add tailwind${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe frontend add router${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        generate|g)
            echo -e "${CYBER_YELLOW}Gera código dentro do projeto atual, detectando o framework pelo package.json${RESET}"
            echo -e "${CYBER_GRAY}(@angular/core → angular, vue → vue, react/next → react).${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe frontend generate ${CYBER_BOLD}<tipo>${RESET} ${CYBER_BOLD}<nome>${RESET}   ${CYBER_GRAY}(atalho: g)${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Tipos:${RESET}"
            echo -e "  ${CYBER_GREEN}component${RESET}, ${CYBER_GREEN}c${RESET}    Componente no padrão do framework detectado"
            echo -e "  ${CYBER_GREEN}service${RESET}, ${CYBER_GREEN}s${RESET}      Serviço: API service (React), store (Vue) ou service (Angular)"
            echo -e "  ${CYBER_GREEN}store${RESET}          Store de estado: Context (React) ou store (Vue)"
            echo -e "  ${CYBER_GREEN}hook${RESET}           Hook customizado — ${CYBER_RED}somente React${RESET}"
            echo -e "  ${CYBER_GREEN}guard${RESET}          Guard de rota — ${CYBER_RED}somente Angular${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe frontend g component UserProfile${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe frontend generate service Auth${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        install|i)
            echo -e "${CYBER_YELLOW}Instala dependências com o package manager detectado (npm/pnpm/yarn/bun).${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe frontend install ${CYBER_GRAY}[dev] [pacotes...]${RESET}   ${CYBER_GRAY}(atalho: i)${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Modos:${RESET}"
            echo -e "  ${CYBER_GREEN}install${RESET}          Instala as dependências já declaradas no package.json"
            echo -e "  ${CYBER_GREEN}install deps${RESET}     Igual ao anterior (install das dependências existentes)"
            echo -e "  ${CYBER_GREEN}install dev${RESET} <pkgs>  Instala como dependências de desenvolvimento (-D)"
            echo -e "  ${CYBER_GREEN}install${RESET} <pkgs>   Instala como dependências de produção"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe frontend install${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe frontend i dev vitest${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe frontend i axios${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        test|t)
            echo -e "${CYBER_YELLOW}Executa os testes do projeto via script do package.json.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe frontend test ${CYBER_GRAY}[watch|coverage]${RESET}   ${CYBER_GRAY}(atalho: t)${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Modos:${RESET}"
            echo -e "  ${CYBER_GREEN}test${RESET}             Script ${CYBER_GREEN}test${RESET} do package.json (padrão)"
            echo -e "  ${CYBER_GREEN}test watch${RESET}       Script ${CYBER_GREEN}test:watch${RESET} (re-executa ao salvar)"
            echo -e "  ${CYBER_GREEN}test coverage${RESET}    Script ${CYBER_GREEN}test:coverage${RESET} (relatório de cobertura)"
            echo -e "  Argumentos extras são repassados ao script.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe frontend t${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe frontend test coverage${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        build|b)
            echo -e "${CYBER_YELLOW}Compila o projeto via script build do package.json.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe frontend build ${CYBER_GRAY}[prod]${RESET}   ${CYBER_GRAY}(atalho: b)${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Modos:${RESET}"
            echo -e "  ${CYBER_GREEN}build${RESET}        Script ${CYBER_GREEN}build${RESET} do package.json (padrão)"
            echo -e "  ${CYBER_GREEN}build prod${RESET}   Script ${CYBER_GREEN}build:prod${RESET} (build de produção)"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe frontend b${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe frontend build prod${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        serve|s)
            echo -e "${CYBER_YELLOW}Inicia o servidor de desenvolvimento do projeto atual.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe frontend serve ${CYBER_GRAY}[prod]${RESET}   ${CYBER_GRAY}(atalho: s)${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Modos:${RESET}"
            echo -e "  ${CYBER_GREEN}serve${RESET}        Script ${CYBER_GREEN}start${RESET} do package.json (dev server)"
            echo -e "  ${CYBER_GREEN}serve prod${RESET}   Script ${CYBER_GREEN}serve:prod${RESET} (servir o build pronto)"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe frontend s${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe frontend serve prod${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        *)
            echo -e "${CYBER_YELLOW}Sem ajuda específica para este comando.${RESET}"
            echo ""
            echo -e "$foot"
            ;;
    esac
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
    # -h/--help junto ao subcomando mostra o help específico e não executa nada
    if [[ "$#" -ge 2 && ( "$2" == "-h" || "$2" == "--help" ) ]]; then
        case "$1" in
            new|create|add|generate|g|install|i|test|t|build|b|serve|s|setup)
                frontend_command_help "$1"
                return 0
                ;;
        esac
    fi

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