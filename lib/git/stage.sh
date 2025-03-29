#!/bin/bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$BASE_DIR/lib/git/ui.sh"

get_git_root() {
    git rev-parse --show-toplevel 2>/dev/null
}

show_staging_header() {
    clear
    echo "${BOLD}${CYBER_PURPLE}  ╔══════════════════════════════════════════════╗"
    echo "  ║               ${CYBER_CYAN}▓▓▓ SMART STAGING ${CYBER_PURPLE}▓▓▓             ║"
    echo "  ╚══════════════════════════════════════════════╝${RESET}"
    echo
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
        "M ") echo "${CYBER_YELLOW}● Modified:${RESET} $display_file" ;;
        "A ") echo "${CYBER_GREEN}● Added:${RESET} $display_file" ;;
        "??") echo "${CYBER_RED}● Untracked:${RESET} $display_file" ;;
        "D ") echo "${CYBER_RED}● Deleted:${RESET} $display_file" ;;
        "R ") echo "${CYBER_CYAN}● Renamed:${RESET} $display_file" ;;
        "C ") echo "${CYBER_BLUE}● Copied:${RESET} $display_file" ;;
        *)    echo "● $display_file" ;;
    esac
}

# Custom menu selector function for staging
function choose_staging_option() {
    local prompt="$1" outvar="$2"
    shift
    shift
    local options=("$@") cur=0 count=${#options[@]} index=0
    local esc=$(echo -en "\e")

    while true; do
        # List all options
        index=0
        for o in "${options[@]}"; do
            if [ "$index" == "$cur" ]; then
                echo -e "${CYBER_GREEN} > ${CYBER_CYAN}${BOLD}${o}${RESET}"  # Highlight current option
            else
                echo -e "   ${CYBER_YELLOW}${o}${RESET}"
            fi
            ((index++))
        done

        # Read single key
        read -s -n3 key

        if [[ $key == $esc[A ]]; then  # Up arrow
            ((cur--))
            [[ $cur -lt 0 ]] && cur=0
        elif [[ $key == $esc[B ]]; then  # Down arrow
            ((cur++))
            [[ $cur -ge $count ]] && cur=$((count-1))
        elif [[ $key == "" ]]; then  # Enter key
            break
        fi

        # Move cursor up to re-render menu
        echo -en "\e[${count}A"
    done

    # Return selection
    printf -v "$outvar" "${options[$cur]}"
}

stage_files_interactive() {
    local git_root=$(get_git_root)
    if [ -z "$git_root" ]; then
        echo
        echo "  ${CYBER_RED}✗ Error: Not a git repository${RESET}"
        echo
        read -p "  ${CYBER_BLUE}Press Enter to return...${RESET}"
        return 1
    fi

    while true; do
        show_staging_header

        # Get changed files
        local changed_files=()
        while IFS= read -r line; do
            local file=$(echo "$line" | awk '{print $2}')
            changed_files+=("$file")
        done < <(git -C "$git_root" status --porcelain 2>/dev/null)

        if [ ${#changed_files[@]} -eq 0 ]; then
            echo
            echo "  ${CYBER_YELLOW}No changes to stage.${RESET}"
            echo
            read -p "  ${CYBER_BLUE}Press Enter to return...${RESET}"
            return
        fi

        # Get staged files
        local staged_files=($(git -C "$git_root" diff --cached --name-only 2>/dev/null))

        # Prepare menu items
        local menu_items=()
        local index=1
        for file in "${changed_files[@]}"; do
            local status=$(git -C "$git_root" status --porcelain "$file" 2>/dev/null | cut -c1-2)
            local is_staged=""

            if [[ " ${staged_files[@]} " =~ " ${file} " ]]; then
                is_staged="${CYBER_GREEN} ✓ ${RESET}"
            fi

            menu_items+=("$(printf "%2d) " $index)$(show_file_status "$file" "$status") $is_staged")
            ((index++))
        done

        # Add actions to menu
        menu_items+=("${CYBER_GREEN}Stage all changes${RESET}")
        menu_items+=("${CYBER_CYAN}Unstage all changes${RESET}")
        menu_items+=("${CYBER_BLUE}Show staged files${RESET}")
        menu_items+=("${CYBER_PURPLE}Commit staged files${RESET}")
        menu_items+=("${CYBER_RED}Return to main menu${RESET}")

        # Show interactive menu
        echo "${BOLD}${CYBER_PURPLE}▓▓▓ Select files to stage ▓▓▓${RESET}"
        echo
        choose_staging_option "Select an option:" selected_choice "${menu_items[@]}"
        echo

        # Process selection
        case "$selected_choice" in
            *"Stage all changes"*)
                (cd "$git_root" && git add .)
                echo "  ${CYBER_GREEN}✔ All changes staged${RESET}"
                sleep 1
                ;;
            *"Unstage all changes"*)
                (cd "$git_root" && git reset)
                echo "  ${CYBER_CYAN}✔ All changes unstaged${RESET}"
                sleep 1
                ;;
            *"Show staged files"*)
                clear
                echo
                echo "  ${BOLD}${CYBER_BLUE}STAGED FILES:${RESET}"
                (cd "$git_root" && git diff --cached --name-status) || echo "  No staged files"
                echo
                read -p "  ${CYBER_BLUE}Press Enter to continue...${RESET}"
                ;;
            *"Commit staged files"*)
                echo
                read -p "  ${CYBER_BLUE}Enter commit message: ${RESET}" msg
                if [ -n "$msg" ]; then
                    (cd "$git_root" && git commit -m "$msg")
                else
                    echo "  ${CYBER_RED}Commit message cannot be empty${RESET}"
                fi
                echo
                read -p "  ${CYBER_BLUE}Press Enter to continue...${RESET}"
                ;;
            *"Return to main menu"*)
                return 0
                ;;
            *)
                # Handle file selection (1-9)
                if [[ "$selected_choice" =~ ^[0-9]+\) ]]; then
                    local choice=$(echo "$selected_choice" | awk '{print $1}' | tr -d ')')
                    if [ $choice -ge 1 ] && [ $choice -le ${#changed_files[@]} ]; then
                        local selected_file="${changed_files[$((choice-1))]}"
                        (cd "$git_root" && git add "$selected_file")
                        echo
                        echo "  ${CYBER_GREEN}✔ Staged: $selected_file${RESET}"
                        sleep 1
                    fi
                fi
                ;;
        esac
    done
}