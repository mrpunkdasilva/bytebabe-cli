#!/bin/bash

# Definição das cores se ainda não estiverem definidas
: ${CYBER_RED:='\033[1;31m'}
: ${CYBER_GREEN:='\033[1;32m'}
: ${CYBER_BLUE:='\033[1;34m'}
: ${CYBER_YELLOW:='\033[1;33m'}
: ${RESET:='\033[0m'}

show_post_help() {
    echo -e "\n${CYBER_BLUE}╭─────────── FLUX POST ───────────╮${RESET}"
    echo -e "${CYBER_BLUE}│${RESET} HTTP POST Request Client"
    echo -e "${CYBER_BLUE}╰────────────────────────────────╯${RESET}\n"
    
    echo -e "${CYBER_BLUE}Usage:${RESET}"
    echo -e "  flux post ${CYBER_YELLOW}<url>${RESET} [options]\n"
    
    echo -e "${CYBER_BLUE}Options:${RESET}"
    echo -e "  ${CYBER_GREEN}-H, --header${RESET}         Add custom header (can be used multiple times)"
    echo -e "                      Example: -H 'Authorization: Bearer token'"
    echo -e "  ${CYBER_GREEN}-d, --data${RESET}           Add POST data"
    echo -e "                      Example: -d '{\"name\":\"value\"}'"
    echo -e "  ${CYBER_GREEN}--json${RESET}               Add Accept: application/json header"
    echo -e "  ${CYBER_GREEN}--loading-style${RESET}      Set loading animation style (default|matrix|pulse)"
    echo -e "  ${CYBER_GREEN}-h, --help${RESET}          Show this help message\n"

    echo -e "${CYBER_BLUE}Examples:${RESET}"
    echo -e "  ${CYBER_YELLOW}# Basic POST request with JSON data${RESET}"
    echo -e "  flux post https://api.example.com/users -d '{\"name\":\"John\"}'\n"

    echo -e "  ${CYBER_YELLOW}# POST with custom header${RESET}"
    echo -e "  flux post https://api.example.com -H 'Authorization: Bearer token'\n"
    
    echo -e "  ${CYBER_YELLOW}# POST with JSON data and custom loading style${RESET}"
    echo -e "  flux post https://api.example.com -d '{\"key\":\"value\"}' --loading-style matrix\n"
}
