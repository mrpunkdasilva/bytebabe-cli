#!/bin/bash

# ==========================================
# FRONTEND COMMANDER - CYBERPUNK EDITION
# ==========================================

# Carrega paths absolutos
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Importa módulos
source "$BASE_DIR/lib/core/colors.sh"
source "$BASE_DIR/lib/core/helpers.sh"

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

    # Verificar Node.js
    if ! command -v node &> /dev/null; then
        echo -e "${CYBER_RED}✘ Node.js não encontrado! Instale primeiro com:${RESET}"
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

# ==========================================
# FUNÇÃO PRINCIPAL
# ==========================================

main() {
    case $1 in
        "setup")
            process_setup
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            show_help
            ;;
    esac
}

# ==========================================
# INICIALIZAÇÃO
# ==========================================

main "$@"