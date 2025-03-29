#!/bin/bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$BASE_DIR/lib/git/ui.sh"
source "$BASE_DIR/lib/git/profile.sh"
source "$BASE_DIR/lib/git/stage.sh"
source "$BASE_DIR/lib/git/commit.sh"



show_spinner() {
    local -a spinner=('⣾' '⣽' '⣻' '⢿' '⡿' '⣟' '⣯' '⣷')
    for i in "${spinner[@]}"; do
        echo -ne "\r$1 $i "
        sleep 0.1
    done
    echo -ne "\r$1    \r"
}


# Custom menu selector function
function choose_from_menu() {
    local prompt="$1" outvar="$2"
    shift
    shift
    local options=("$@") cur=0 count=${#options[@]} index=0
    local esc=$(echo -en "\e")

    # Print cyberpunk-styled prompt
    echo -e "${BOLD}${CYBER_PURPLE}$prompt${RESET}"
    echo

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

setup_repository() {
    clear
    echo "${CYBER_YELLOW}⚡ Initializing Git Nexus Pro environment...${RESET}"
    echo

    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "${CYBER_RED}✗ No Git repository found${RESET}"
        echo
        read -p "${CYBER_BLUE}? Create new repository? (Y/n): ${RESET}" choice

        if [[ "$choice" =~ ^[Nn]$ ]]; then
            echo "${CYBER_YELLOW}▶ Operation canceled${RESET}"
            exit 1
        fi

        git init
        echo "${CYBER_GREEN}✔ Repository initialized${RESET}"
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
    # Show header
    echo "${BOLD}${CYBER_PURPLE}  ╔══════════════════════════════════════════════╗${RESET}"
    echo "${BOLD}${CYBER_PURPLE}  ║               ${CYBER_CYAN}▓▓▓ GIT NEXUS PRO ${CYBER_PURPLE}▓▓▓             ║${RESET}"
    echo "${BOLD}${CYBER_PURPLE}  ╚══════════════════════════════════════════════╝${RESET}"
    echo

    # Menu options
    local selections=(
      "   ${BOLD}${CYBER_GREEN}1) Profile Dashboard       ${CYBER_YELLOW}» User identity & statistics${RESET}"
      "   ${BOLD}${CYBER_GREEN}2) Smart Staging           ${CYBER_YELLOW}» Interactive file selection${RESET}"
      "   ${BOLD}${CYBER_GREEN}3) Commit Wizard           ${CYBER_YELLOW}» Guided semantic commits${RESET}"
      "   ${BOLD}${CYBER_GREEN}4) Branch Navigator        ${CYBER_YELLOW}» Visual branch management${RESET}"
      "   ${BOLD}${CYBER_GREEN}5) Push Controller         ${CYBER_YELLOW}» Advanced push operations${RESET}"
      "   ${BOLD}${CYBER_GREEN}6) Time Machine            ${CYBER_YELLOW}» Interactive commit history${RESET}"
      "   ${BOLD}${CYBER_GREEN}7) Repository Settings     ${CYBER_YELLOW}» Git configuration options${RESET}"
      "   ${BOLD}${CYBER_RED}0) Exit                    ${CYBER_YELLOW}» Quit the application${RESET}"
    )

    choose_from_menu "Select an option:" selected_choice "${selections[@]}"
    echo

   case "$selected_choice" in
      *"Profile Dashboard"*)
          echo -n "${CYBER_CYAN}🛠️  Opening Profile Dashboard"
          for i in {1..3}; do
              echo -n "."
              sleep 0.5
          done
          echo "${RESET}"
          profile_dashboard
          ;;
      *"Smart Staging"*)
          echo -n "${CYBER_CYAN}📁 Opening Smart Staging"
          for i in {1..3}; do
              echo -n "."
              sleep 0.5
          done
          echo "${RESET}"
          stage_files_interactive
          ;;
      *"Commit Wizard"*)
          echo -n "${CYBER_CYAN}✍️  Launching Commit Wizard"
          for i in {1..3}; do
              echo -n "."
              sleep 0.5
          done
          echo "${RESET}"
          show_commit_wizard
          ;;
      *"Branch Navigator"*)
          echo -n "${CYBER_CYAN}🌿 Initializing Branch Navigator"
          for i in {1..3}; do
              echo -n "."
              sleep 0.5
          done
          echo "${RESET}"
          # branch_navigator_function
          ;;
      *"Push Controller"*)
          echo -n "${CYBER_CYAN}🚀 Preparing Push Controller"
          for i in {1..3}; do
              echo -n "."
              sleep 0.5
          done
          echo "${RESET}"
          # push_controller_function
          ;;
      *"Time Machine"*)
          echo -n "${CYBER_CYAN}⏳ Activating Time Machine"
          for i in {1..3}; do
              echo -n "."
              sleep 0.5
          done
          echo "${RESET}"
          # time_machine_function
          ;;
      *"Repository Settings"*)
          echo -n "${CYBER_CYAN}⚙️  Loading Repository Settings"
          for i in {1..3}; do
              echo -n "."
              sleep 0.5
          done
          echo "${RESET}"
          # repo_settings_function
          ;;
      *"Exit"*)
          clear
          echo "${BOLD}${CYBER_PURPLE}  ╔══════════════════════════════════════════════╗"
          echo "  ║                                                    ║"
          echo "  ║          ${CYBER_CYAN}▓▓▓ THANKS FOR USING GIT NEXUS PRO ▓▓▓${CYBER_PURPLE}          ║"
          echo "  ║                                                    ║"
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
        s|S) git status; read -p "${CYBER_BLUE}Press Enter to continue...${RESET}" ;;
        c|C) echo "${CYBER_CYAN}Opening quick commit...${RESET}"; sleep 1 ;;
        b|B) git branch; read -p "${CYBER_BLUE}Press Enter to continue...${RESET}" ;;
        p|P) echo "${CYBER_CYAN}Preparing push...${RESET}"; sleep 1 ;;
        q|Q) return ;;
        *) echo "${CYBER_RED}✗ Invalid command!${RESET}"; sleep 1 ;;
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