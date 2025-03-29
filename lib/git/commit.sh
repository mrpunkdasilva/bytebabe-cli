#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/ui.sh"

show_commit_wizard() {
    clear
    echo "${BOLD}${CYBER_PURPLE}  ╔══════════════════════════════════════════════╗"
    echo "  ║               ${CYBER_CYAN}▓ COMMIT WIZARD ${CYBER_PURPLE}▓               "
    echo "  ╚══════════════════════════════════════════════╝${RESET}"
    echo

    # Verificar se há alterações para commit
    if [ -z "$(git status --porcelain)" ]; then
        echo "  ${CYBER_YELLOW}No changes to commit.${RESET}"
        echo
        read -p "  ${CYBER_BLUE}Press Enter to return...${RESET}"
        return
    fi

    # Mostrar diff resumido
    echo "  ${BOLD}${CYBER_CYAN}▓ Changes to be committed:${RESET}"
    git --no-pager diff --cached --stat
    echo

    # Selecionar tipo de commit (semântico)
    echo "  ${BOLD}${CYBER_GREEN}▓ Select commit type:${RESET}"
    echo "  ${CYBER_YELLOW}1) feat     - New feature"
    echo "  2) fix      - Bug fix"
    echo "  3) docs     - Documentation"
    echo "  4) style    - Formatting"
    echo "  5) refactor - Code restructuring"
    echo "  6) test     - Testing"
    echo "  7) chore    - Maintenance${RESET}"
    echo

    while true; do
        read -p "  ${CYBER_PURPLE}⌘ Type (1-7): ${RESET}" commit_type
        case $commit_type in
            1) type="feat"; break ;;
            2) type="fix"; break ;;
            3) type="docs"; break ;;
            4) type="style"; break ;;
            5) type="refactor"; break ;;
            6) type="test"; break ;;
            7) type="chore"; break ;;
            *) echo "  ${CYBER_RED}Invalid type${RESET}";;
        esac
    done

    # Input para mensagem do commit
    echo
    read -p "  ${CYBER_BLUE}Enter commit description: ${RESET}" description

    # Input para corpo do commit (opcional)
    echo
    echo "  ${CYBER_YELLOW}Enter commit body (optional, Ctrl+D to finish):${RESET}"
    body=$(cat)

    # Confirmar commit
    echo
    echo "  ${BOLD}Commit Preview:${RESET}"
    echo "  ${CYBER_CYAN}${type}: ${description}${RESET}"
    [ -n "$body" ] && echo "\n${body}" | sed 's/^/  /'
    echo

    read -p "  ${CYBER_PURPLE}Confirm commit? (Y/n): ${RESET}" confirm
    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        echo "  ${CYBER_RED}Commit canceled${RESET}"
    else
        if [ -z "$body" ]; then
            git commit -m "${type}: ${description}"
        else
            git commit -m "${type}: ${description}" -m "$body"
        fi
        echo "  ${CYBER_GREEN}✔ Commit created successfully${RESET}"
    fi

    echo
    read -p "  ${CYBER_BLUE}Press Enter to continue...${RESET}"
}