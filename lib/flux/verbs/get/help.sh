#!/bin/bash

show_get_help() {
    echo -e "${CYBER_BLUE}Flux GET Command Usage:${RESET}"
    echo -e "  flux get <url> [options]\n"
    
    echo -e "${CYBER_BLUE}Options:${RESET}"
    echo -e "  ${CYBER_GREEN}-H, --header${RESET}    Add custom header"
    echo -e "  ${CYBER_GREEN}-o, --output${RESET}    Save response to file"
    echo -e "  ${CYBER_GREEN}--json${RESET}          Add JSON Accept header"
    echo -e "  ${CYBER_GREEN}-i, --include${RESET}   Include response headers\n"
    
    echo -e "${CYBER_BLUE}Examples:${RESET}"
    echo -e "  ${CYBER_YELLOW}flux get https://api.example.com${RESET}"
    echo -e "  ${CYBER_YELLOW}flux get https://api.example.com --json${RESET}"
    echo -e "  ${CYBER_YELLOW}flux get https://api.example.com -H 'Authorization: Bearer token'${RESET}"
}