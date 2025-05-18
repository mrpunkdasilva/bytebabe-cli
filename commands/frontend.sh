#!/bin/bash

# ==========================================
# FRONTEND COMMANDER - CYBERPUNK EDITION
# ==========================================

# Carrega paths absolutos
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Importa módulos
source "$BASE_DIR/lib/core/colors.sh"
source "$BASE_DIR/lib/core/helpers.sh"
source "$BASE_DIR/lib/frontend/main.sh"
source "$BASE_DIR/lib/frontend/config.sh"
source "$BASE_DIR/lib/frontend/templates.sh"

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
    local use_sudo=""
    
    # Perguntar se deseja usar sudo (apenas uma vez)
    if [ -z "$SUDO_ASKED" ]; then
        echo -e "${CYBER_BLUE}Deseja usar sudo para instalar os pacotes? (s/n)${RESET}"
        read -p "> " use_sudo_answer
        if [[ "$use_sudo_answer" =~ ^[Ss]$ ]]; then
            use_sudo="sudo"
        fi
        export SUDO_ASKED=1
    fi
    
    case $pkg in
        "yarn")
            echo -e "${CYBER_YELLOW}Instalando Yarn...${RESET}"
            if [ -n "$use_sudo" ]; then
                sudo npm install -g yarn
            else
                npm install -g yarn
            fi
            
            if command -v yarn &> /dev/null; then
                echo -e "${CYBER_GREEN}✓ Yarn $(yarn --version) instalado com sucesso!${RESET}"
            else
                echo -e "${CYBER_RED}✘ Falha ao instalar o Yarn.${RESET}"
            fi
            ;;
        "pnpm")
            echo -e "${CYBER_YELLOW}Instalando pnpm...${RESET}"
            if [ -n "$use_sudo" ]; then
                sudo npm install -g pnpm
            else
                npm install -g pnpm
            fi
            
            if command -v pnpm &> /dev/null; then
                echo -e "${CYBER_GREEN}✓ pnpm $(pnpm --version) instalado com sucesso!${RESET}"
            else
                echo -e "${CYBER_RED}✘ Falha ao instalar o pnpm.${RESET}"
            fi
            ;;
        "bun")
            echo -e "${CYBER_YELLOW}Instalando Bun...${RESET}"
            curl -fsSL https://bun.sh/install | bash
            
            if command -v bun &> /dev/null; then
                echo -e "${CYBER_GREEN}✓ Bun $(bun --version) instalado com sucesso!${RESET}"
            else
                echo -e "${CYBER_RED}✘ Falha ao instalar o Bun.${RESET}"
            fi
            ;;
        "npm")
            if command -v npm &> /dev/null; then
                echo -e "${CYBER_GREEN}✓ npm $(npm --version) (pré-instalado)${RESET}"
            else
                echo -e "${CYBER_RED}✘ npm não encontrado, mas deveria estar instalado com o Node.js.${RESET}"
            fi
            ;;
    esac
}

install_framework() {
    local fw=$1
    local use_sudo=""
    
    # Usar a mesma configuração de sudo definida anteriormente
    if [[ "$SUDO_ASKED" == "1" && "$use_sudo_answer" =~ ^[Ss]$ ]]; then
        use_sudo="sudo"
    fi
    
    case $fw in
        "react")
            echo -e "${CYBER_YELLOW}Instalando React + Vite...${RESET}"
            if [ -n "$use_sudo" ]; then
                sudo npm install -g create-react-app create-vite
            else
                npm install -g create-react-app create-vite
            fi
            
            if command -v create-react-app &> /dev/null && command -v create-vite &> /dev/null; then
                echo -e "${CYBER_GREEN}✓ React + Vite instalados com sucesso!${RESET}"
            else
                echo -e "${CYBER_RED}✘ Falha ao instalar React + Vite.${RESET}"
            fi
            ;;
        "vue")
            echo -e "${CYBER_YELLOW}Instalando Vue CLI...${RESET}"
            if [ -n "$use_sudo" ]; then
                sudo npm install -g @vue/cli
            else
                npm install -g @vue/cli
            fi
            
            if command -v vue &> /dev/null; then
                echo -e "${CYBER_GREEN}✓ Vue CLI $(vue --version) instalado com sucesso!${RESET}"
            else
                echo -e "${CYBER_RED}✘ Falha ao instalar Vue CLI.${RESET}"
            fi
            ;;
        "angular")
            echo -e "${CYBER_YELLOW}Instalando Angular CLI...${RESET}"
            if [ -n "$use_sudo" ]; then
                sudo npm install -g @angular/cli
            else
                npm install -g @angular/cli
            fi
            
            if command -v ng &> /dev/null; then
                echo -e "${CYBER_GREEN}✓ Angular CLI $(ng version --version) instalado com sucesso!${RESET}"
            else
                echo -e "${CYBER_RED}✘ Falha ao instalar Angular CLI.${RESET}"
            fi
            ;;
        "next")
            echo -e "${CYBER_YELLOW}Instalando Next.js...${RESET}"
            if [ -n "$use_sudo" ]; then
                sudo npm install -g create-next-app
            else
                npm install -g create-next-app
            fi
            
            if command -v create-next-app &> /dev/null; then
                echo -e "${CYBER_GREEN}✓ Next.js instalado com sucesso!${RESET}"
            else
                echo -e "${CYBER_RED}✘ Falha ao instalar Next.js.${RESET}"
            fi
            ;;
    esac
}

# ==========================================
# MENUS INTERATIVOS
# ==========================================

select_package_managers() {
    # Verificar se o Node.js está instalado
    if ! command -v node &> /dev/null; then
        echo -e "${CYBER_YELLOW}⚠ Node.js não está instalado. Pulando instalação de gerenciadores de pacotes.${RESET}"
        return
    fi
    
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

    # Verificar quais gerenciadores já estão instalados
    echo -e "${CYBER_BLUE}Verificando gerenciadores de pacotes instalados...${RESET}"
    for pm in "${package_managers[@]}"; do
        if command -v "$pm" &> /dev/null; then
            echo -e "${CYBER_GREEN}✓ $pm $($pm --version 2>/dev/null || echo 'instalado') já está instalado${RESET}"
        else
            echo -e "${CYBER_YELLOW}⚠ $pm não está instalado${RESET}"
            echo -e "${CYBER_BLUE}Deseja instalar $pm? (s/n)${RESET}"
            read -p "> " install_pm
            
            if [[ "$install_pm" =~ ^[Ss]$ ]]; then
                install_package_manager "$pm"
            else
                echo -e "${CYBER_YELLOW}⚠ Pulando instalação de $pm${RESET}"
            fi
        fi
    done
}

select_frameworks() {
    # Verificar se o Node.js está instalado
    if ! command -v node &> /dev/null; then
        echo -e "${CYBER_YELLOW}⚠ Node.js não está instalado. Pulando instalação de frameworks.${RESET}"
        return
    fi
    
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

    # Verificar quais frameworks já estão instalados
    echo -e "${CYBER_BLUE}Verificando frameworks instalados...${RESET}"
    for fw in "${frameworks[@]}"; do
        case $fw in
            "react")
                if command -v create-react-app &> /dev/null; then
                    echo -e "${CYBER_GREEN}✓ React já está instalado${RESET}"
                else
                    echo -e "${CYBER_YELLOW}⚠ React não está instalado${RESET}"
                    echo -e "${CYBER_BLUE}Deseja instalar React? (s/n)${RESET}"
                    read -p "> " install_fw
                    
                    if [[ "$install_fw" =~ ^[Ss]$ ]]; then
                        install_framework "$fw"
                    else
                        echo -e "${CYBER_YELLOW}⚠ Pulando instalação de React${RESET}"
                    fi
                fi
                ;;
            "vue")
                if command -v vue &> /dev/null; then
                    echo -e "${CYBER_GREEN}✓ Vue já está instalado${RESET}"
                else
                    echo -e "${CYBER_YELLOW}⚠ Vue não está instalado${RESET}"
                    echo -e "${CYBER_BLUE}Deseja instalar Vue? (s/n)${RESET}"
                    read -p "> " install_fw
                    
                    if [[ "$install_fw" =~ ^[Ss]$ ]]; then
                        install_framework "$fw"
                    else
                        echo -e "${CYBER_YELLOW}⚠ Pulando instalação de Vue${RESET}"
                    fi
                fi
                ;;
            "angular")
                if command -v ng &> /dev/null; then
                    echo -e "${CYBER_GREEN}✓ Angular já está instalado${RESET}"
                else
                    echo -e "${CYBER_YELLOW}⚠ Angular não está instalado${RESET}"
                    echo -e "${CYBER_BLUE}Deseja instalar Angular? (s/n)${RESET}"
                    read -p "> " install_fw
                    
                    if [[ "$install_fw" =~ ^[Ss]$ ]]; then
                        install_framework "$fw"
                    else
                        echo -e "${CYBER_YELLOW}⚠ Pulando instalação de Angular${RESET}"
                    fi
                fi
                ;;
            "next")
                if command -v create-next-app &> /dev/null; then
                    echo -e "${CYBER_GREEN}✓ Next.js já está instalado${RESET}"
                else
                    echo -e "${CYBER_YELLOW}⚠ Next.js não está instalado${RESET}"
                    echo -e "${CYBER_BLUE}Deseja instalar Next.js? (s/n)${RESET}"
                    read -p "> " install_fw
                    
                    if [[ "$install_fw" =~ ^[Ss]$ ]]; then
                        install_framework "$fw"
                    else
                        echo -e "${CYBER_YELLOW}⚠ Pulando instalação de Next.js${RESET}"
                    fi
                fi
                ;;
        esac
    done
}

# ==========================================
# PROCESSAMENTO DE COMANDOS
# ==========================================

process_setup() {
    show_frontend_header
    echo -e "${CYBER_PINK}⚡ CONFIGURAÇÃO FRONTEND ⚡${RESET}"

    # Verificar Node.js
    if ! command -v node &> /dev/null; then
        echo -e "${CYBER_YELLOW}⚠ Node.js não encontrado!${RESET}"
        echo -e "${CYBER_BLUE}Para instalar o Node.js, você pode usar:${RESET}"
        echo -e "${CYBER_PINK}  • Ubuntu/Debian: sudo apt install nodejs npm${RESET}"
        echo -e "${CYBER_PINK}  • Fedora: sudo dnf install nodejs npm${RESET}"
        echo -e "${CYBER_PINK}  • Arch Linux: sudo pacman -S nodejs npm${RESET}"
        echo -e "${CYBER_PINK}  • macOS: brew install node${RESET}"
        echo -e "${CYBER_PINK}  • Windows: Baixe o instalador em https://nodejs.org/${RESET}"
        echo -e "${CYBER_YELLOW}Após instalar o Node.js, execute este comando novamente.${RESET}"
        
        # Perguntar se deseja continuar sem Node.js
        echo -e "${CYBER_BLUE}Deseja continuar mesmo sem o Node.js? (s/n)${RESET}"
        read -p "> " continue_without_node
        
        if [[ ! "$continue_without_node" =~ ^[Ss]$ ]]; then
            echo -e "${CYBER_RED}✘ Configuração cancelada.${RESET}"
            return 1
        fi
        
        echo -e "${CYBER_YELLOW}⚠ Continuando sem Node.js. Algumas funcionalidades podem não funcionar corretamente.${RESET}"
    else
        echo -e "${CYBER_GREEN}✓ Node.js $(node -v) encontrado!${RESET}"
    fi

    # Gerenciadores de pacote
    select_package_managers

    # Frameworks
    select_frameworks

    # Finalização
    echo -e "\n${CYBER_PINK}⚡ CONFIGURAÇÃO COMPLETA! ⚡${RESET}"
    echo -e "${CYBER_BLUE}Ferramentas instaladas:"
    
    # Verificar se o Node.js está instalado
    if command -v node &> /dev/null; then
        echo -e "• Node.js $(node -v)"
    else
        echo -e "• Node.js ${CYBER_RED}não instalado${RESET}"
    fi
    
    # Verificar se há gerenciadores de pacotes instalados
    if [ ${#package_managers[@]} -gt 0 ]; then
        echo -e "• Gerenciadores: ${package_managers[*]}"
    else
        echo -e "• Gerenciadores: ${CYBER_YELLOW}nenhum selecionado${RESET}"
    fi
    
    # Verificar se há frameworks instalados
    if [ ${#frameworks[@]} -gt 0 ]; then
        echo -e "• Frameworks: ${frameworks[*]}"
    else
        echo -e "• Frameworks: ${CYBER_YELLOW}nenhum selecionado${RESET}"
    fi
    
    echo -e "${RESET}"
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

    case $framework in
        "react")
            if [[ "$template" == "vite" ]]; then
                npm create vite@latest "$name" -- --template react-ts
            else
                npx create-react-app "$name" --template typescript
            fi
            ;;
        "vue")
            if [[ "$template" == "vite" ]]; then
                npm create vite@latest "$name" -- --template vue-ts
            else
                npm create vue@latest "$name"
            fi
            ;;
        "angular")
            npx @angular/cli new "$name" --style=scss --routing=true --strict
            ;;
        "next")
            npx create-next-app@latest "$name" --typescript --tailwind --eslint
            ;;
        "svelte")
            npm create vite@latest "$name" -- --template svelte-ts
            ;;
        *)
            echo -e "${CYBER_RED}✘ Framework não suportado: $framework${RESET}"
            exit 1
            ;;
    esac

    # Configuração pós-criação
    cd "$name" || exit
    
    # Inicializa configuração ByteBabe
    init_frontend_config

    # Instala dependências comuns
    npm install --save-dev \
        @testing-library/jest-dom \
        @testing-library/user-event \
        prettier \
        eslint \
        husky \
        lint-staged

    # Configurações específicas por framework
    case $framework in
        "react"|"next")
            npm install --save-dev \
                @testing-library/react \
                @types/react-test-renderer
            ;;
        "vue")
            npm install --save-dev \
                @vue/test-utils \
                @vitejs/plugin-vue
            ;;
        "angular")
            npm install --save-dev \
                @types/jasmine \
                karma-coverage
            ;;
    esac

    echo -e "${CYBER_GREEN}✔ Projeto $name criado com sucesso!${RESET}"
    echo -e "${CYBER_BLUE}Para começar:${RESET}"
    echo -e "  cd $name"
    echo -e "  npm run dev"
}

# Função para adicionar funcionalidades
add_feature() {
    local feature=$1
    shift
    local options=("$@")

    case $feature in
        "tailwind")
            npm install -D tailwindcss postcss autoprefixer
            npx tailwindcss init -p
            setup_tailwind
            ;;
        "redux")
            npm install @reduxjs/toolkit react-redux
            generate_redux_store
            ;;
        "router")
            local framework=$(detect_framework)
            case $framework in
                "react")
                    npm install react-router-dom
                    generate_react_router
                    ;;
                "vue")
                    npm install vue-router@4
                    generate_vue_router
                    ;;
            esac
            ;;
        "i18n")
            local framework=$(detect_framework)
            case $framework in
                "react")
                    npm install react-i18next i18next
                    generate_i18n_setup
                    ;;
                "vue")
                    npm install vue-i18n@9
                    generate_vue_i18n
                    ;;
                "angular")
                    ng add @angular/localize
                    ;;
            esac
            ;;
        *)
            echo -e "${CYBER_RED}✘ Funcionalidade não suportada: $feature${RESET}"
            exit 1
            ;;
    esac
}

# Handler principal de comandos
case "$1" in
    setup)
        process_setup
        ;;
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
                show_frontend_new_help
                ;;
            *)
                echo -e "${CYBER_RED}✘ Framework não especificado ou não suportado${RESET}"
                show_frontend_new_help
                exit 1
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
                show_frontend_add_help
                ;;
            *)
                echo -e "${CYBER_RED}✘ Funcionalidade não especificada ou não suportada${RESET}"
                show_frontend_add_help
                exit 1
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
                fi
                ;;
            guard)
                shift
                framework=$(detect_framework)
                if [[ "$framework" == "angular" ]]; then
                    generate_angular_guard "$1"
                else
                    echo -e "${CYBER_RED}✘ Guards são específicos do Angular${RESET}"
                fi
                ;;
            *)
                echo -e "${CYBER_RED}✘ Tipo de geração não especificado ou inválido${RESET}"
                echo -e "Tipos disponíveis: component, service, store, hook, guard"
                ;;
        esac
        ;;
    
    install|i)
        shift
        case "$1" in
            deps)
                npm install
                ;;
            dev)
                shift
                npm install --save-dev "$@"
                ;;
            *)
                npm install "$@"
                ;;
        esac
        ;;
    
    test|t)
        shift
        case "$1" in
            watch)
                npm run test:watch
                ;;
            coverage)
                npm run test:coverage
                ;;
            *)
                npm test "$@"
                ;;
        esac
        ;;
    
    build|b)
        shift
        case "$1" in
            prod)
                npm run build:prod
                ;;
            *)
                npm run build
                ;;
        esac
        ;;
    
    serve|s)
        shift
        case "$1" in
            prod)
                npm run serve:prod
                ;;
            *)
                npm run start
                ;;
        esac
        ;;
    
    help|--help|-h)
        show_frontend_help
        ;;
    
    *)
        echo -e "${CYBER_RED}✘ Comando não reconhecido: $1${RESET}"
        show_frontend_help
        exit 1
        ;;
esac

# ==========================================
# FUNÇÃO PRINCIPAL
# ==========================================

main() {
    case $1 in
        "setup")
            process_setup
            ;;
        "new"|"create"|"add"|"generate"|"g"|"serve"|"s")
            # Esses comandos já foram processados pelo bloco principal
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            if [ -z "$1" ]; then
                show_help
            fi
            ;;
    esac
}

# ==========================================
# INICIALIZAÇÃO
# ==========================================

# Se nenhum comando foi processado pelo bloco principal, chama a função main
if [ $? -eq 0 ]; then
    main "$@"
fi