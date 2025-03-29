#!/bin/bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$BASE_DIR/lib/git/ui.sh"
source "$BASE_DIR/lib/git/profile.sh"
source "$BASE_DIR/lib/git/stage.sh"



# Configuração inicial
setup_repository() {
    echo "${CYBER_YELLOW}⚡ Initializing Git Nexus Pro environment...${RESET}"

    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "${CYBER_RED}✗ No Git repository found in current directory${RESET}"
        read -p "${CYBER_BLUE}? Create new repository? (Y/n): ${RESET}" choice

        if [[ "$choice" =~ ^[Nn]$ ]]; then
            echo "${CYBER_YELLOW}▶ Operation canceled${RESET}"
            exit 1
        fi

        git init
        echo "${CYBER_GREEN}✔ Repository initialized${RESET}"

        # Configuração de usuário
        echo ""
        echo "${CYBER_PURPLE}▓ Identity Configuration ▓${RESET}"
        read -p "${CYBER_BLUE}? Your name: ${RESET}" name
        read -p "${CYBER_BLUE}? Your email: ${RESET}" email

        git config user.name "$name"
        git config user.email "$email"

        echo "${CYBER_GREEN}✔ Identity configured for this repository${RESET}"
        sleep 1
    fi
}

# Navegação principal
main_navigation() {
    while true; do
        show_header
        show_menu_options

        read -p "${BOLD}${CYBER_PURPLE}  ⌘ Nexus Command (1-7/0): ${RESET}" choice

        case $choice in
            1)
                echo "${CYBER_CYAN}🛠️  Opening Profile Dashboard...${RESET}"
                profile_dashboard
                sleep 1
                ;;
            2)
                echo "${CYBER_CYAN}📁 Opening Smart Staging...${RESET}"
                stage_files_interactive
                sleep 1
                ;;
            3)
                echo "${CYBER_CYAN}✍️  Starting Commit Wizard...${RESET}"
                sleep 1
                ;;
            4)
                echo "${CYBER_CYAN}🌿 Launching Branch Navigator...${RESET}"
                sleep 1
                ;;
            5)
                echo "${CYBER_CYAN}🚀 Preparing Push Controller...${RESET}"
                sleep 1
                ;;
            6)
                echo "${CYBER_CYAN}⏳ Activating Time Machine...${RESET}"
                sleep 1
                ;;
            7)
                echo "${CYBER_CYAN}⚙️  Opening Repository Settings...${RESET}"
                sleep 1
                ;;
            0|q|Q)
                echo ""
                echo "${CYBER_PURPLE}${BOLD}  ╔══════════════════════════════════════════════╗"
                echo "  ║                                                    "
                echo "  ║          ${CYBER_CYAN}Thanks for using Git Nexus Pro!${CYBER_PURPLE}          "
                echo "  ║                                                    "
                echo "  ╚══════════════════════════════════════════════╝${RESET}"
                echo ""
                exit 0
                ;;
            s|S)
                git status
                read -p "${CYBER_BLUE}Press Enter to continue...${RESET}"
                ;;
            c|C)
                echo "${CYBER_CYAN}Opening quick commit...${RESET}"
                sleep 1
                ;;
            b|B)
                git branch
                read -p "${CYBER_BLUE}Press Enter to continue...${RESET}"
                ;;
            p|P)
                echo "${CYBER_CYAN}Preparing push...${RESET}"
                sleep 1
                ;;
            *)
                echo "${CYBER_RED}✗ Invalid command${RESET}"
                sleep 1
                ;;
        esac

        show_footer
    done
}

# Ponto de entrada principal
setup_repository
main_navigation