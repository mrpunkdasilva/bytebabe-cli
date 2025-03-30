#!/bin/bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$BASE_DIR/lib/git/ui.sh"
source "$BASE_DIR/lib/git/profile.sh"
source "$BASE_DIR/lib/git/stage.sh"
source "$BASE_DIR/lib/git/commit.sh"
source "$BASE_DIR/lib/git/branch_navigator.sh"
source "$BASE_DIR/lib/git/push_controller.sh"

# Enhanced spinner with smooth animation
show_spinner() {
    local pid=$!
    local message=$1
    local delay=0.1
    local spin_chars=('⣾' '⣽' '⣻' '⢿' '⡿' '⣟' '⣯' '⣷')
    local i=0

    printf "${CYBER_CYAN}${message}${RESET} "
    while kill -0 $pid 2>/dev/null; do
        printf "\b${spin_chars[i]}"
        i=$(( (i+1) % 8 ))
        sleep $delay
    done
    printf "\b \b\n"
}

# Robust menu selector with keyboard handling
choose_from_menu() {
    local prompt="$1" outvar="$2"
    shift
    shift
    local options=("$@") cur=0 count=${#options[@]} index=0
    local key
    local esc=$'\e'

    # Print styled prompt
    echo -e "${BOLD}${CYBER_PURPLE}$prompt${RESET}"
    echo

    while true; do
        # Display options
        index=0
        for o in "${options[@]}"; do
            if [ "$index" == "$cur" ]; then
                echo -e "${CYBER_GREEN} > ${CYBER_CYAN}${BOLD}${o}${RESET}"
            else
                echo -e "   ${CYBER_YELLOW}${o}${RESET}"
            fi
            ((index++))
        done

        # Read key input
        IFS= read -rsn1 key
        if [[ "$key" == "$esc" ]]; then
            read -rsn2 -t 0.1 key
        fi

        case "$key" in
            '[A')  # Up arrow
                ((cur--))
                [[ $cur -lt 0 ]] && cur=0
                ;;
            '[B')  # Down arrow
                ((cur++))
                [[ $cur -ge $count ]] && cur=$((count-1))
                ;;
            '')    # Enter key
                break
                ;;
            [1-9]) # Number selection
                if (( key > 0 && key <= count )); then
                    ((cur=key-1))
                    break
                fi
                ;;
            q|Q)   # Quit
                return 1
                ;;
        esac

        # Move cursor up
        printf "\033[%dA" "$count"
    done

    # Return selection
    printf -v "$outvar" "${options[$cur]}"
}

setup_repository() {
    clear
    show_spinner "⚡ Initializing Git Nexus Pro environment" &
    sleep 1  # Simulate loading

    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "${CYBER_RED}✗ No Git repository found${RESET}"
        echo
        read -p "${CYBER_BLUE}? Create new repository? (Y/n): ${RESET}" choice

        if [[ "$choice" =~ ^[Nn]$ ]]; then
            echo "${CYBER_YELLOW}▶ Operation canceled${RESET}"
            exit 1
        fi

        git init && echo "${CYBER_GREEN}✔ Repository initialized${RESET}"
        echo

        # User configuration
        echo "${CYBER_PURPLE}▓ Identity Configuration ▓${RESET}"
        read -p "${CYBER_BLUE}? Your name: ${RESET}" name
        read -p "${CYBER_BLUE}? Your email: ${RESET}" email
        echo

        git config user.name "$name"
        git config user.email "$email"
        echo "${CYBER_GREEN}✔ Identity configured${RESET}"
        sleep 1
    fi
}



show_main_menu() {
    clear
    show_header_git_nexus
    echo

    local selections=(
        "${BOLD}${CYBER_GREEN}1) 🧑‍ Profile Dashboard      ${CYBER_YELLOW}» User identity & statistics${RESET}"
        "${BOLD}${CYBER_GREEN}2) 📂 Smart Staging           ${CYBER_YELLOW}» Interactive file selection${RESET}"
        "${BOLD}${CYBER_GREEN}3) ✍️ Commit Wizard           ${CYBER_YELLOW}» Guided semantic commits${RESET}"
        "${BOLD}${CYBER_GREEN}4) 🌿 Branch Navigator        ${CYBER_YELLOW}» Visual branch management${RESET}"
        "${BOLD}${CYBER_GREEN}5) 🚀 Push Controller         ${CYBER_YELLOW}» Advanced push operations${RESET}"
        "${BOLD}${CYBER_GREEN}6) ⏳  Time Machine            ${CYBER_YELLOW}» Interactive commit history${RESET}"
        "${BOLD}${CYBER_GREEN}7) ⚙️ Repository Settings     ${CYBER_YELLOW}» Git configuration options${RESET}"
        "${BOLD}${CYBER_RED}0) 🚪 Exit                    ${CYBER_YELLOW}» Quit the application${RESET}"
    )

    choose_from_menu "Select an option:" selected_choice "${selections[@]}"
    echo

    case "$selected_choice" in
        *"Profile Dashboard"*)
            show_spinner "🛠️  Opening Profile Dashboard" &
            profile_dashboard
            ;;
        *"Smart Staging"*)
            show_spinner "📂 Opening Smart Staging" &
            stage_files_interactive
            ;;
        *"Commit Wizard"*)
            show_spinner "✍️  Launching Commit Wizard" &
            show_commit_wizard
            ;;
        *"Branch Navigator"*)
            show_spinner "🌿 Initializing Branch Navigator" &
            show_branch_navigator
            ;;
        *"Push Controller"*)
            show_spinner "🚀 Preparing Push Controller" &
            show_push_controller
            ;;
        *"Time Machine"*)
            show_spinner "⏳ Activating Time Machine" &
            # time_machine_function
            sleep 1
            ;;
        *"Repository Settings"*)
            show_spinner "⚙️  Loading Repository Settings" &
            # repo_settings_function
            sleep 1
            ;;
        *"Exit"*)
            clear
            echo "${BOLD}${CYBER_PURPLE}  ╔══════════════════════════════════════════════╗"
            echo "  ║                                                    "
            echo "  ║          ${CYBER_CYAN}▓▓▓ THANKS FOR USING GIT NEXUS PRO ▓▓▓${CYBER_PURPLE}          "
            echo "  ║                                                    "
            echo "  ╚══════════════════════════════════════════════╝${RESET}"
            echo
            exit 0
            ;;
    esac
}

show_quick_actions() {
    echo
    echo "${BOLD}${CYBER_CYAN}  ╔════════════════════════════════╗"
    echo "  ║       ${CYBER_PURPLE}▓▓▓ QUICK ACTIONS ${CYBER_CYAN}▓▓▓       ║"
    echo "  ╚════════════════════════════════╝${RESET}"
    echo "  ${CYBER_YELLOW}[s] Status  [c] Commit  [b] Branches  [p] Push${RESET}"
    echo "  ${CYBER_RED}[q] Back to Menu${RESET}"
    echo

    read -p "${BOLD}${CYBER_PURPLE}  ⌘ Quick command: ${RESET}" cmd

    case $cmd in
        s|S)
            show_spinner "Checking repository status" &
            git status
            read -p "${CYBER_BLUE}Press Enter to continue...${RESET}"
            ;;
        c|C)
            show_spinner "Preparing quick commit" &
            git commit -m "Quick commit" || echo "${CYBER_RED}✖ No changes to commit${RESET}"
            ;;
        b|B)
            show_spinner "Listing branches" &
            git branch -a
            read -p "${CYBER_BLUE}Press Enter to continue...${RESET}"
            ;;
        p|P)
            show_spinner "Pushing changes" &
            git push || echo "${CYBER_RED}✖ Push failed${RESET}"
            ;;
        q|Q) return ;;
        *)
            echo "${CYBER_RED}✗ Invalid command!${RESET}"
            sleep 1
            ;;
    esac
}

main_navigation() {
    while true; do
        show_main_menu
        show_quick_actions
    done
}

# Start application
setup_repository
main_navigation