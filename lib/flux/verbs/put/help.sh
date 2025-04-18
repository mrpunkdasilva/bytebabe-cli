#!/bin/bash

show_put_help() {
    echo -e "${CYBER_BLUE}Flux PUT Command Usage:${RESET}"
    echo -e "  flux put <url> [options]\n"
    
    echo -e "${CYBER_BLUE}Options:${RESET}"
    echo -e "  ${CYBER_GREEN}-H, --header${RESET}    Add custom header"
    echo -e "  ${CYBER_GREEN}-d, --data${RESET}      Add PUT data"
    echo -e "  ${CYBER_GREEN}--json${RESET}          Add JSON Accept header\n"
    
    echo -e "${CYBER_BLUE}Examples:${RESET}"
    echo -e "  ${CYBER_YELLOW}flux put https://api.example.com/resource/1 -d '{\"key\":\"value\"}'${RESET}"
    echo -e "  ${CYBER_YELLOW}flux put https://api.example.com/resource/1 -H 'Authorization: Bearer token'${RESET}"
}