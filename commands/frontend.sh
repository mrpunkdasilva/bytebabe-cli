#!/bin/bash

# Importar cores
source "$(pwd)/lib/core/colors.sh"
source "$(pwd)/lib/core/helpers.sh"


# Verificar subcomandos
case $1 in
setup)
    echo -e "${CYBER_PINK}⚡ Instalando Frontend Stack...${RESET}"
    echo -e "\n${CYBER_PINK}⚡ CONFIGURAÇÃO FRONTEND ⚡${RESET}"

    # Gerenciador de pacotes
    echo -e "\n${CYBER_YELLOW}● ESCOLHA SEU GERENCIADOR (ou 5 para todos):${RESET}"
    echo -e "${CYBER_BLUE}1) npm"
    echo -e "2) yarn"
    echo -e "3) pnpm"
    echo -e "4) bun"
    echo -e "5) Todos${RESET}"
    read -p "Opção (1-5): " pkg_manager

    case $pkg_manager in
    1) npm_list=("npm") ;;
    2) npm_list=("yarn") ;;
    3) npm_list=("pnpm") ;;
    4) npm_list=("bun") ;;
    5) npm_list=("npm" "yarn" "pnpm" "bun") ;;
    esac

    for pkg in "${npm_list[@]}"; do
        case $pkg in
        "yarn")
            npm install -g yarn
            echo -e "${CYBER_GREEN}✔ Yarn $(yarn --version) instalado${RESET}"
            ;;
        "pnpm")
            npm install -g pnpm
            echo -e "${CYBER_GREEN}✔ pnpm $(pnpm --version) instalado${RESET}"
            ;;
        "bun")
            curl -fsSL https://bun.sh/install | bash
            echo -e "${CYBER_GREEN}✔ Bun instalado${RESET}"
            ;;
        *)
            echo -e "${CYBER_GREEN}✔ npm $(npm --version) (pré-instalado)${RESET}"
            ;;
        esac
    done

    # Frameworks (com opção TODOS)
    echo -e "\n${CYBER_YELLOW}● ESCOLHA SEU FRAMEWORK (ou 5 para todos):${RESET}"
    echo -e "${CYBER_BLUE}1) React"
    echo -e "2) Vue"
    echo -e "3) Angular"
    echo -e "4) Next.js"
    echo -e "5) Todos${RESET}"
    read -p "Opção (1-5): " framework

    case $framework in
    1) frameworks=("react") ;;
    2) frameworks=("vue") ;;
    3) frameworks=("angular") ;;
    4) frameworks=("next") ;;
    5) frameworks=("react" "vue" "angular" "next") ;;
    esac

    for fw in "${frameworks[@]}"; do
        case $fw in
        "react")
            npm install -g create-react-app create-vite
            echo -e "${CYBER_GREEN}✔ React + Vite instalados${RESET}"
            ;;
        "vue")
            npm install -g @vue/cli
            echo -e "${CYBER_GREEN}✔ Vue CLI $(vue --version) instalado${RESET}"
            ;;
        "angular")
            npm install -g @angular/cli
            echo -e "${CYBER_GREEN}✔ Angular CLI instalado${RESET}"
            ;;
        "next")
            npm install -g create-next-app
            echo -e "${CYBER_GREEN}✔ Next.js instalado${RESET}"
            ;;
        esac
    done

    # Finalização
    echo -e "\n${CYBER_PINK}⚡ CONFIGURAÇÃO COMPLETA! ⚡${RESET}"
    echo -e "${CYBER_BLUE}Ferramentas instaladas:"
    echo -e "• Node.js $(node -v) (via NVM)"
    echo -e "• Gerenciadores: ${npm_list[*]}"
    echo -e "• Frameworks: ${frameworks[*]}${RESET}"
    ;;
--help | -h)
    echo -e "${CYBER_BLUE}Uso: bytebabe frontend setup [--volta] [--bun]${RESET}"
    ;;
*)
    echo -e "${CYBER_ORANGE}⚠ Subcomando inválido! Use --help${RESET}"
    ;;
esac
