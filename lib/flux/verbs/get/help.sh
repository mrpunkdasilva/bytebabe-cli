#!/bin/bash

show_get_help() {
    echo -e "\n${CYBER_BLUE}╭─────────── FLUX GET ───────────╮${RESET}"
    echo -e "${CYBER_BLUE}│${RESET} HTTP GET Request Client"
    echo -e "${CYBER_BLUE}╰────────────────────────────────╯${RESET}\n"
    
    echo -e "${CYBER_BLUE}Usage:${RESET}"
    echo -e "  flux get ${CYBER_YELLOW}<url>${RESET} [options]\n"
    
    echo -e "${CYBER_BLUE}Options:${RESET}"
    echo -e "  ${CYBER_GREEN}-H, --header${RESET}    Add custom header (can be used multiple times)"
    echo -e "                  Example: -H 'Authorization: Bearer token'"
    echo -e "  ${CYBER_GREEN}-o, --output${RESET}    Save response to file"
    echo -e "                  Example: -o response.json"
    echo -e "  ${CYBER_GREEN}--json${RESET}          Add Accept: application/json header"
    echo -e "  ${CYBER_GREEN}-i, --include${RESET}   Include response headers in output"
    echo -e "  ${CYBER_GREEN}-h, --help${RESET}      Show this help message\n"
    
    echo -e "${CYBER_BLUE}Examples:${RESET}"
    echo -e "  ${CYBER_YELLOW}# Basic GET request${RESET}"
    echo -e "  flux get https://api.example.com\n"
    
    echo -e "  ${CYBER_YELLOW}# GET request with JSON header${RESET}"
    echo -e "  flux get https://api.example.com --json\n"
    
    echo -e "  ${CYBER_YELLOW}# GET request with custom header${RESET}"
    echo -e "  flux get https://api.example.com -H 'Authorization: Bearer token'\n"
    
    echo -e "  ${CYBER_YELLOW}# GET request with output to file${RESET}"
    echo -e "  flux get https://api.example.com -o response.json\n"
    
    echo -e "  ${CYBER_YELLOW}# GET request with multiple headers${RESET}"
    echo -e "  flux get https://api.example.com -H 'Authorization: Bearer token' -H 'Accept: application/json'\n"
}
