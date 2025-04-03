#!/bin/bash

show_firewall_menu() {
    echo -e "${CYBER_PURPLE}╔════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_PURPLE}║${CYBER_CYAN}           FIREWALL CONTROL PANEL${CYBER_PURPLE}         ║${RESET}"
    echo -e "${CYBER_PURPLE}╚════════════════════════════════════════════╝${RESET}"
    echo
    echo -e "${CYBER_PURPLE}1) ${CYBER_GREEN}View Firewall Status${RESET}"
    echo -e "${CYBER_PURPLE}2) ${CYBER_BLUE}Enable Firewall${RESET}"
    echo -e "${CYBER_PURPLE}3) ${CYBER_RED}Disable Firewall${RESET}"
    echo -e "${CYBER_PURPLE}4) ${CYBER_YELLOW}List Active Rules${RESET}"
    echo -e "${CYBER_PURPLE}5) ${CYBER_CYAN}Add New Rule${RESET}"
    echo -e "${CYBER_PURPLE}6) ${CYBER_RED}Remove Rule${RESET}"
    echo -e "${CYBER_PURPLE}7) ${CYBER_YELLOW}Reset All Rules${RESET}"
    echo -e "${CYBER_PURPLE}8) ${CYBER_BLUE}Quick Setup Profiles${RESET}"
    echo -e "${CYBER_PURPLE}9) ${CYBER_GREEN}Advanced Options${RESET}"
    echo -e "${CYBER_PURPLE}0) ${CYBER_RED}Exit${RESET}"
    echo
}

show_setup_profiles() {
    echo -e "${CYBER_PURPLE}╔════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_PURPLE}║${CYBER_CYAN}           FIREWALL SETUP PROFILES${CYBER_PURPLE}        ║${RESET}"
    echo -e "${CYBER_PURPLE}╚════════════════════════════════════════════╝${RESET}"
    echo
    echo -e "${CYBER_PURPLE}1) ${CYBER_GREEN}Software Developer${RESET}"
    echo -e "   ${CYBER_YELLOW}» Development servers & APIs${RESET}"
    echo -e "   ${CYBER_YELLOW}» Database connections${RESET}"
    echo -e "   ${CYBER_YELLOW}» Git & SSH services${RESET}"
    echo
    echo -e "${CYBER_PURPLE}2) ${CYBER_BLUE}DevOps Engineer${RESET}"
    echo -e "   ${CYBER_YELLOW}» Container & orchestration${RESET}"
    echo -e "   ${CYBER_YELLOW}» CI/CD pipelines${RESET}"
    echo -e "   ${CYBER_YELLOW}» Monitoring stack${RESET}"
    echo
    echo -e "${CYBER_PURPLE}3) ${CYBER_RED}Cybersecurity Specialist${RESET}"
    echo -e "   ${CYBER_YELLOW}» Enhanced security & logging${RESET}"
    echo -e "   ${CYBER_YELLOW}» Security tools & scanners${RESET}"
    echo -e "   ${CYBER_YELLOW}» VPN & secure tunnels${RESET}"
    echo
    echo -e "${CYBER_PURPLE}0) ${CYBER_RED}Back${RESET}"
    echo
}

show_advanced_menu() {
    echo -e "${CYBER_PURPLE}╔════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_PURPLE}║${CYBER_CYAN}           ADVANCED FIREWALL OPTIONS${CYBER_PURPLE}      ║${RESET}"
    echo -e "${CYBER_PURPLE}╚════════════════════════════════════════════╝${RESET}"
    echo
    echo -e "${CYBER_PURPLE}1) ${CYBER_GREEN}Configure Rate Limiting${RESET}"
    echo -e "${CYBER_PURPLE}2) ${CYBER_BLUE}Setup Port Forwarding${RESET}"
    echo -e "${CYBER_PURPLE}3) ${CYBER_YELLOW}Manage Logging Levels${RESET}"
    echo -e "${CYBER_PURPLE}4) ${CYBER_RED}Block IP Ranges${RESET}"
    echo -e "${CYBER_PURPLE}5) ${CYBER_CYAN}Backup/Restore Rules${RESET}"
    echo -e "${CYBER_PURPLE}6) ${CYBER_PURPLE}View Active Connections${RESET}"
    echo -e "${CYBER_PURPLE}0) ${CYBER_RED}Back${RESET}"
    echo
}