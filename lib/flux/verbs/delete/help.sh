#!/bin/bash

show_delete_help() {
    echo -e "${CYBER_BLUE}Flux DELETE Command Usage:${RESET}"
    echo -e "  flux delete <url> [options]\n"
    
    echo -e "${CYBER_BLUE}Options:${RESET}"
    echo -e "  ${CYBER_GREEN}-H, --header${RESET}    Add custom header"
    echo -e "  ${CYBER_GREEN}--json${RESET}          Add JSON Accept header\n"
    
    echo -e "${CYBER_BLUE}Examples:${RESET}"
    echo -e "  ${CYBER_YELLOW}flux delete https://api.example.com/resource/1${RESET}"
    echo -e "  ${CYBER_YELLOW}flux delete https://api.example.com/resource/1 -H 'Authorization: Bearer token'${RESET}"
}