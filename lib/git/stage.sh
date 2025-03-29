#!/bin/bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$(dirname "${BASH_SOURCE[0]}")/ui.sh"


show_staging_header() {
    clear
    echo "${BOLD}${CYBER_PURPLE}  ╔══════════════════════════════════════════════╗"
    echo "  ║               ${CYBER_CYAN}▓ SMART STAGING ${CYBER_PURPLE}▓                "
    echo "  ╚══════════════════════════════════════════════╝${RESET}"
}

get_file_status() {
    local file=$1
    local status=$(git status --porcelain "$file" | cut -c1-2)
    echo "$status"
}

show_file_status() {
    local file=$1
    local status=$2

    case "$status" in
        "M ") echo "  ${CYBER_YELLOW}● Modified:${RESET} $file" ;;
        "A ") echo "  ${CYBER_GREEN}● Added:${RESET} $file" ;;
        "??") echo "  ${CYBER_RED}● Untracked:${RESET} $file" ;;
        "D ") echo "  ${CYBER_RED}● Deleted:${RESET} $file" ;;
        "R ") echo "  ${CYBER_CYAN}● Renamed:${RESET} $file" ;;
        "C ") echo "  ${CYBER_BLUE}● Copied:${RESET} $file" ;;
        *)    echo "  ● $file" ;;
    esac
}

stage_files_interactive() {
    while true; do
        show_staging_header

        # Obter lista de arquivos com alterações
        local changed_files=($(git status --porcelain | awk '{print $2}'))
        local staged_files=($(git diff --cached --name-only))

        if [ ${#changed_files[@]} -eq 0 ]; then
            echo "\n  ${CYBER_YELLOW}No changes to stage.${RESET}"
            read -p "\n  ${CYBER_BLUE}Press Enter to return...${RESET}"
            return
        fi

        echo "\n  ${BOLD}${CYBER_GREEN}╔════════════════════════════════╗"
        echo "  ║       ${CYBER_CYAN}SELECT FILES ${CYBER_GREEN}▓▓▓       "
        echo "  ╚════════════════════════════════╝${RESET}"

        # Mostrar arquivos com status
        local index=1
        for file in "${changed_files[@]}"; do
            local status=$(get_file_status "$file")
            local is_staged=" "

            # Verificar se o arquivo já está staged
            if [[ " ${staged_files[*]} " =~ " ${file} " ]]; then
                is_staged="${CYBER_GREEN}✓${RESET}"
            fi

            printf "  ${CYBER_PURPLE}%2d)${RESET} " $index
            show_file_status "$file" "$status"
            echo "    $is_staged"
            ((index++))
        done

        echo "\n  ${BOLD}${CYBER_GREEN}╔════════════════════════════════╗"
        echo "  ║       ${CYBER_CYAN}ACTIONS ${CYBER_GREEN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
        echo "  ╚════════════════════════════════╝${RESET}"
        echo "  ${CYBER_YELLOW}[1-${#changed_files[@]}] Select file"
        echo "  ${CYBER_GREEN}[a] Stage all"
        echo "  ${CYBER_CYAN}[u] Unstage all"
        echo "  ${CYBER_BLUE}[s] Show staged files"
        echo "  ${CYBER_PURPLE}[c] Commit staged files"
        echo "  ${CYBER_RED}[q] Quit${RESET}"

        read -p "\n  ${BOLD}${CYBER_PURPLE}⌘ Select option: ${RESET}" choice

        case $choice in
            [0-9]*)
                if [ $choice -ge 1 ] && [ $choice -le ${#changed_files[@]} ]; then
                    local selected_file="${changed_files[$((choice-1))]}"
                    git add "$selected_file"
                    echo "\n  ${CYBER_GREEN}✔ Staged: $selected_file${RESET}"
                    sleep 1
                else
                    echo "\n  ${CYBER_RED}✖ Invalid selection${RESET}"
                    sleep 1
                fi
                ;;
            a|A)
                git add .
                echo "\n  ${CYBER_GREEN}✔ All changes staged${RESET}"
                sleep 1
                ;;
            u|U)
                git reset
                echo "\n  ${CYBER_CYAN}✔ All changes unstaged${RESET}"
                sleep 1
                ;;
            s|S)
                clear
                echo "\n  ${BOLD}${CYBER_BLUE}STAGED FILES:${RESET}"
                git diff --cached --name-status
                read -p "\n  ${CYBER_BLUE}Press Enter to continue...${RESET}"
                ;;
            c|C)
                read -p "\n  ${CYBER_BLUE}Enter commit message: ${RESET}" msg
                git commit -m "$msg"
                read -p "\n  ${CYBER_BLUE}Press Enter to continue...${RESET}"
                ;;
            q|Q)
                return 0
                ;;
            *)
                echo "\n  ${CYBER_RED}✖ Invalid option${RESET}"
                sleep 1
                ;;
        esac
    done
}