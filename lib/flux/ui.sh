#!/bin/bash

show_flux_help() {
    echo -e "${CYBER_BLUE}Flux HTTP Client Usage:${RESET}"
    echo -e "  flux <verb> <url> [options]\n"
    
    echo -e "${CYBER_BLUE}Supported Verbs:${RESET}"
    echo -e "  ${CYBER_GREEN}get${RESET}     - Make GET request"
    echo -e "  ${CYBER_GREEN}post${RESET}    - Make POST request"
    echo -e "  ${CYBER_GREEN}put${RESET}     - Make PUT request"
    echo -e "  ${CYBER_GREEN}delete${RESET}  - Make DELETE request\n"
    
    echo -e "${CYBER_BLUE}Common Options:${RESET}"
    echo -e "  ${CYBER_GREEN}-H, --header${RESET}    Add custom header"
    echo -e "  ${CYBER_GREEN}--json${RESET}          Add JSON Accept header"
    echo -e "  ${CYBER_GREEN}-h, --help${RESET}      Show help for specific verb\n"
    
    echo -e "${CYBER_BLUE}Examples:${RESET}"
    echo -e "  ${CYBER_YELLOW}flux get https://api.example.com${RESET}"
    echo -e "  ${CYBER_YELLOW}flux post https://api.example.com --json${RESET}"
    echo -e "  ${CYBER_YELLOW}flux get https://api.example.com -H 'Authorization: Bearer token'${RESET}"
}