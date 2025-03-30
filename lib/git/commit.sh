#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/ui.sh"

show_loading() {
    local message=$1
    echo -n "${CYBER_CYAN}${message}"
    for i in {1..3}; do
        echo -n "."
        sleep 0.5
    done
    echo "${RESET}"
}

choose_from_menu() {
    local prompt="$1" outvar="$2"
    shift
    shift
    local options=("$@") cur=0 count=${#options[@]} index=0
    local esc=$(echo -en "\e")

    while true; do
        index=0
        for o in "${options[@]}"; do
            if [ "$index" == "$cur" ]; then
                echo -e "${CYBER_GREEN} > ${CYBER_CYAN}${BOLD}${o}${RESET}"
            else
                echo -e "   ${CYBER_YELLOW}${o}${RESET}"
            fi
            ((index++))
        done

        read -s -n3 key
        readonly ESC=$'\033'
        readonly UP="${ESC}[A"
        readonly DOWN="${ESC}[B"

        if [[ $key == $UP ]]; then
            ((cur--))
            [[ $cur -lt 0 ]] && cur=0
        elif [[ $key == $DOWN ]]; then
            ((cur++))
            [[ $cur -ge $count ]] && cur=$((count-1))
        elif [[ $key == "" ]]; then
            break
        fi
        echo -en "\e[${count}A"
    done
    printf -v "$outvar" "${options[$cur]}"
}

show_commit_wizard() {
    clear
    echo "${BOLD}${CYBER_PURPLE}  ╔══════════════════════════════════════════════╗"
    echo "  ║               ${CYBER_CYAN}▓▓▓ COMMIT WIZARD ${CYBER_PURPLE}▓▓▓            ║"
    echo "  ╚══════════════════════════════════════════════╝${RESET}"
    echo

    # Check for staged changes first
    staged_changes=$(git diff --cached --name-only)
    if [ -z "$staged_changes" ]; then
        echo "  ${CYBER_YELLOW}No staged changes to commit.${RESET}"
        echo "  ${CYBER_BLUE}You need to stage changes first (use Smart Staging).${RESET}"
        echo
        read -p "  ${CYBER_BLUE}Press Enter to return...${RESET}"
        return
    fi

    # Show loading animation
    show_loading "  🔍 Analyzing changes"

    # Show changes that will be committed
    echo "  ${BOLD}${CYBER_CYAN}▓▓▓ Changes to be committed:${RESET}"
    echo

    # Show detailed diff of staged changes
    git --no-pager diff --cached --stat
    echo
    git --no-pager diff --cached --name-status | while read status file; do
        case "$status" in
            "M") echo "  ${CYBER_YELLOW}● Modified:${RESET} $file" ;;
            "A") echo "  ${CYBER_GREEN}● Added:${RESET} $file" ;;
            "D") echo "  ${CYBER_RED}● Deleted:${RESET} $file" ;;
            "R") echo "  ${CYBER_CYAN}● Renamed:${RESET} $file" ;;
            "C") echo "  ${CYBER_BLUE}● Copied:${RESET} $file" ;;
            *)   echo "  ● $file" ;;
        esac
    done
    echo

    # Commit type selection
    echo "  ${BOLD}${CYBER_GREEN}▓▓▓ Select commit type:${RESET}"

    local commit_types=(
        "${CYBER_GREEN}feat     - New feature"
        "${CYBER_RED}fix      - Bug fix"
        "${CYBER_BLUE}docs     - Documentation"
        "${CYBER_YELLOW}style    - Formatting"
        "${CYBER_CYAN}refactor - Code restructuring"
        "${CYBER_PURPLE}test     - Testing"
        "${CYBER_WHITE}chore    - Maintenance"
    )

    choose_from_menu "Select commit type:" selected_type "${commit_types[@]}"
    echo

    # Extract type from selection
    type=$(echo "$selected_type" | awk '{print $1}')
    type_description=$(echo "$selected_type" | cut -d'-' -f2-)

    echo "  ${CYBER_CYAN}Selected: ${BOLD}$type${RESET}${CYBER_CYAN} ($type_description)${RESET}"
    echo

    # Commit description
    read -p "  ${CYBER_BLUE}Enter commit description: ${RESET}" description
    [ -z "$description" ] && description="Minor updates"

    # Commit body (optional)
    echo
    echo "  ${CYBER_YELLOW}Enter commit body (optional, Ctrl+D to finish):${RESET}"
    body=$(cat)

    # Show full diff preview if wanted
    echo
    read -p "  ${CYBER_BLUE}Show full diff preview? (y/N): ${RESET}" show_diff
    if [[ "$show_diff" =~ ^[Yy]$ ]]; then
        git --no-pager diff --cached
        echo
    fi

    # Confirmation
    echo
    echo "  ${BOLD}${CYBER_PURPLE}▓▓▓ Commit Preview:${RESET}"
    echo "  ${CYBER_CYAN}${type}: ${description}${RESET}"
    [ -n "$body" ] && echo "\n${body}" | sed 's/^/  /'
    echo

    local confirm_options=(
        "${CYBER_GREEN}Yes, commit now"
        "${CYBER_RED}No, cancel"
        "${CYBER_YELLOW}Edit message"
    )

    choose_from_menu "Confirm commit?" confirm_action "${confirm_options[@]}"
    echo

    case "$confirm_action" in
        *"Yes"*)
            show_loading "  💾 Creating commit"
            if [ -z "$body" ]; then
                git commit -m "${type}: ${description}"
            else
                git commit -m "${type}: ${description}" -m "$body"
            fi
            echo "  ${CYBER_GREEN}✔ Commit created successfully${RESET}"
            ;;
        *"Edit"*)
            $EDITOR $(git rev-parse --git-dir)/COMMIT_EDITMSG
            git commit --edit --file=$(git rev-parse --git-dir)/COMMIT_EDITMSG
            ;;
        *)
            echo "  ${CYBER_RED}✗ Commit canceled${RESET}"
            ;;
    esac

    echo
    read -p "  ${CYBER_BLUE}Press Enter to continue...${RESET}"
}