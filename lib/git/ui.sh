#!/bin/bash

# Cores
CYBER_CYAN=$(tput setaf 6)
CYBER_PURPLE=$(tput setaf 5)
CYBER_GREEN=$(tput setaf 2)
CYBER_YELLOW=$(tput setaf 3)
CYBER_RED=$(tput setaf 1)
CYBER_BLUE=$(tput setaf 4)
RESET=$(tput sgr0)
BOLD=$(tput bold)

show_header() {
    clear
    echo "${CYBER_PURPLE}
${BOLD}

   █████████   ███   █████       ██████   █████                                            ███████████                    
  ███░░░░░███ ░░░   ░░███       ░░██████ ░░███                                            ░░███░░░░░███                   
 ███     ░░░  ████  ███████      ░███░███ ░███   ██████  █████ █████ █████ ████  █████     ░███    ░███ ████████   ██████ 
░███         ░░███ ░░░███░       ░███░░███░███  ███░░███░░███ ░░███ ░░███ ░███  ███░░      ░██████████ ░░███░░███ ███░░███
░███    █████ ░███   ░███        ░███ ░░██████ ░███████  ░░░█████░   ░███ ░███ ░░█████     ░███░░░░░░   ░███ ░░░ ░███ ░███
░░███  ░░███  ░███   ░███ ███    ░███  ░░█████ ░███░░░    ███░░░███  ░███ ░███  ░░░░███    ░███         ░███     ░███ ░███
 ░░█████████  █████  ░░█████     █████  ░░█████░░██████  █████ █████ ░░████████ ██████     █████        █████    ░░██████ 
  ░░░░░░░░░  ░░░░░    ░░░░░     ░░░░░    ░░░░░  ░░░░░░  ░░░░░ ░░░░░   ░░░░░░░░ ░░░░░░     ░░░░░        ░░░░░      ░░░░░░  
                                                                                                                          
                                                                                                                          
                                                                                                                          
${RESET}"
    echo "${CYBER_PURPLE}${BOLD}  Git Nexus Pro - The Ultimate Git Orchestration Tool${RESET}"
}

show_footer() {
    echo "${CYBER_CYAN}${BOLD}  [S] Status  [C] Commit  [B] Branches  [P] Push  [Q] Quit${RESET}"
    echo "${CYBER_PURPLE}  ────────────────────────────────────────────────────────${RESET}"
}

show_menu_options() {
    echo "${BOLD}${CYBER_PURPLE}  ╔══════════════════════════════════════════════╗${RESET}"
    echo "${BOLD}${CYBER_PURPLE}  ║                 ${CYBER_CYAN}▓ MAIN MENU ${CYBER_PURPLE}▓                 ║${RESET}"
    echo "${BOLD}${CYBER_PURPLE}  ╚══════════════════════════════════════════════╝${RESET}"
    echo
    echo "   ${BOLD}${CYBER_GREEN}1) Profile Dashboard       ${CYBER_YELLOW}» User identity & statistics${RESET}"
    echo "   ${BOLD}${CYBER_GREEN}2) Smart Staging           ${CYBER_YELLOW}» Interactive file selection${RESET}"
    echo "   ${BOLD}${CYBER_GREEN}3) Commit Wizard           ${CYBER_YELLOW}» Guided semantic commits${RESET}"
    echo "   ${BOLD}${CYBER_GREEN}4) Branch Navigator        ${CYBER_YELLOW}» Visual branch management${RESET}"
    echo "   ${BOLD}${CYBER_GREEN}5) Push Controller         ${CYBER_YELLOW}» Advanced push operations${RESET}"
    echo "   ${BOLD}${CYBER_GREEN}6) Time Machine            ${CYBER_YELLOW}» Interactive commit history${RESET}"
    echo "   ${BOLD}${CYBER_GREEN}7) Repository Settings     ${CYBER_YELLOW}» Git configuration options${RESET}"
    echo "   ${BOLD}${CYBER_RED}0) Exit                    ${CYBER_YELLOW}» Quit the application${RESET}"
    echo
}