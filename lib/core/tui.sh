#!/bin/bash

# Dependências necessárias
check_tui_dependencies() {
    if ! command -v dialog &> /dev/null; then
        echo -e "${CYBER_RED}✘ Dialog não encontrado. Instalando...${RESET}"
        if command -v apt &> /dev/null; then
            sudo apt install -y dialog
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y dialog
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm dialog
        fi
    fi
}

# Configurações da TUI
DIALOG_BACKTITLE="ByteBabe CLI - Cyberpunk Dev Tools"
DIALOG_HEIGHT=20
DIALOG_WIDTH=70

# Menu principal
show_main_menu() {
    local choice
    
    choice=$(dialog --clear \
                   --backtitle "$DIALOG_BACKTITLE" \
                   --title "[ Main Menu ]" \
                   --menu "Choose your destiny:" \
                   $DIALOG_HEIGHT $DIALOG_WIDTH 7 \
                   "1" "Spring Tools" \
                   "2" "Docker Management" \
                   "3" "Git Operations" \
                   "4" "Dev Tools" \
                   "5" "Database Tools" \
                   "6" "Settings" \
                   "7" "Exit" \
                   2>&1 >/dev/tty)

    case $choice in
        1) show_spring_menu ;;
        2) show_docker_menu ;;
        3) show_git_menu ;;
        4) show_devtools_menu ;;
        5) show_database_menu ;;
        6) show_settings_menu ;;
        7) clear; exit 0 ;;
    esac
}

# Exemplo de submenu (Spring)
show_spring_menu() {
    local choice
    
    choice=$(dialog --clear \
                   --backtitle "$DIALOG_BACKTITLE" \
                   --title "[ Spring Tools ]" \
                   --menu "Select operation:" \
                   $DIALOG_HEIGHT $DIALOG_WIDTH 6 \
                   "1" "Create New Project" \
                   "2" "Generate Components" \
                   "3" "Manage Dependencies" \
                   "4" "Run Project" \
                   "5" "Build Project" \
                   "6" "Back to Main Menu" \
                   2>&1 >/dev/tty)

    case $choice in
        1) create_spring_project_dialog ;;
        2) generate_components_dialog ;;
        3) manage_dependencies_dialog ;;
        4) run_project_dialog ;;
        5) build_project_dialog ;;
        6) show_main_menu ;;
    esac
}

# Função de exemplo para criar projeto
create_spring_project_dialog() {
    local project_name
    
    project_name=$(dialog --clear \
                        --backtitle "$DIALOG_BACKTITLE" \
                        --title "[ Create Spring Project ]" \
                        --inputbox "Enter project name:" \
                        $DIALOG_HEIGHT $DIALOG_WIDTH \
                        2>&1 >/dev/tty)
    
    if [[ $? -eq 0 ]]; then
        clear
        create_spring_project "$project_name"
        read -p "Press Enter to continue..."
        show_spring_menu
    fi
}