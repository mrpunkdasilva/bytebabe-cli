#!/bin/bash

show_post_help() {
    echo -e "${CYBER_BLUE}Flux POST Command Usage:${RESET}"
    echo -e "  flux post <url> [options]\n"
    
    echo -e "${CYBER_BLUE}Options:${RESET}"
    echo -e "  ${CYBER_GREEN}-H, --header${RESET}    Add custom header"
    echo -e "  ${CYBER_GREEN}-d, --data${RESET}      Add POST data"
    echo -e "  ${CYBER_GREEN}--json${RESET}          Add JSON Accept header\n"
    
    echo -e "${CYBER_BLUE}Examples:${RESET}"
    echo -e "  ${CYBER_YELLOW}flux post https://api.example.com -d '{\"key\":\"value\"}'${RESET}"
    echo -e "  ${CYBER_YELLOW}flux post https://api.example.com -H 'Authorization: Bearer token'${RESET}"
}