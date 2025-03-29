#!/bin/bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$BASE_DIR/lib/git/ui.sh"

get_git_root() {
    git rev-parse --show-toplevel 2>/dev/null
}

show_staging_header() {
    clear
    echo "${BOLD}${CYBER_PURPLE}  ╔══════════════════════════════════════════════╗"
    echo "  ║               ${CYBER_CYAN}▓ SMART STAGING ${CYBER_PURPLE}▓                ║"
    echo "  ╚══════════════════════════════════════════════╝${RESET}"
}

get_file_status() {
    local file=$1
    git status --porcelain "$file" 2>/dev/null | cut -c1-2
}

show_file_status() {
    local file=$1
    local status=$2
    local display_file="${file#./}"

    case "$status" in
        "M ") echo "  ${CYBER_YELLOW}● Modified:${RESET} $display_file" ;;
        "A ") echo "  ${CYBER_GREEN}● Added:${RESET} $display_file" ;;
        "??") echo "  ${CYBER_RED}● Untracked:${RESET} $display_file" ;;
        "D ") echo "  ${CYBER_RED}● Deleted:${RESET} $display_file" ;;
        "R ") echo "  ${CYBER_CYAN}● Renamed:${RESET} $display_file" ;;
        "C ") echo "  ${CYBER_BLUE}● Copied:${RESET} $display_file" ;;
        *)    echo "  ● $display_file" ;;
    esac
}

stage_files_interactive() {
    local git_root=$(get_git_root)
    if [ -z "$git_root" ]; then
        echo "\n  ${CYBER_RED}Error: Not a git repository${RESET}"
        read -p "\n  ${CYBER_BLUE}Press Enter to return...${RESET}"
        return 1
    fi

    while true; do
        show_staging_header

        # Obter lista de arquivos com alterações (usando caminhos relativos)
        local changed_files=()
        while IFS= read -r line; do
            # Extrair o caminho do arquivo (coluna 2 no output --porcelain)
            local file=$(echo "$line" | awk '{print $2}')
            changed_files+=("$file")
        done < <(git -C "$git_root" status --porcelain 2>/dev/null)

        if [ ${#changed_files[@]} -eq 0 ]; then
            echo "\n  ${CYBER_YELLOW}No changes to stage.${RESET}"
            read -p "\n  ${CYBER_BLUE}Press Enter to return...${RESET}"
            return
        fi

        # Obter arquivos staged
        local staged_files=($(git -C "$git_root" diff --cached --name-only 2>/dev/null))

        echo "\n  ${BOLD}${CYBER_GREEN}╔════════════════════════════════╗"
        echo "  ║       ${CYBER_CYAN}SELECT FILES ${CYBER_GREEN}▓▓▓       ║"
        echo "  ╚════════════════════════════════╝${RESET}"

        # Mostrar arquivos com status
        local index=1
        for file in "${changed_files[@]}"; do
            local status=$(git -C "$git_root" status --porcelain "$file" 2>/dev/null | cut -c1-2)
            local is_staged=" "

            if [[ " ${staged_files[@]} " =~ " ${file} " ]]; then
                is_staged="${CYBER_GREEN}✓${RESET}"
            fi

            printf "  ${CYBER_PURPLE}%2d)${RESET} " $index
            show_file_status "$file" "$status"
            echo "    $is_staged"
            ((index++))
        done

        echo "\n  ${BOLD}${CYBER_GREEN}╔════════════════════════════════╗"
        echo "  ║       ${CYBER_CYAN}ACTIONS ${CYBER_GREEN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓║"
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
                    (cd "$git_root" && git add "$selected_file")
                    echo "\n  ${CYBER_GREEN}✔ Staged: $selected_file${RESET}"
                    sleep 1
                else
                    echo "\n  ${CYBER_RED}✖ Invalid selection${RESET}"
                    sleep 1
                fi
                ;;
            a|A)
                (cd "$git_root" && git add .)
                echo "\n  ${CYBER_GREEN}✔ All changes staged${RESET}"
                sleep 1
                ;;
            u|U)
                (cd "$git_root" && git reset)
                echo "\n  ${CYBER_CYAN}✔ All changes unstaged${RESET}"
                sleep 1
                ;;
            s|S)
                clear
                echo "\n  ${BOLD}${CYBER_BLUE}STAGED FILES:${RESET}"
                (cd "$git_root" && git diff --cached --name-status) || echo "  No staged files"
                read -p "\n  ${CYBER_BLUE}Press Enter to continue...${RESET}"
                ;;
            c|C)
                echo ""
                read -p "${CYBER_BLUE}Enter commit message: ${RESET}" msg
                if [ -n "$msg" ]; then
                    (cd "$git_root" && git commit -m "$msg")
                else
                    echo "${CYBER_RED}Commit message cannot be empty${RESET}"
                fi
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