#!/bin/bash

show_delete_help() {
    echo -e "${CYBER_BLUE}DELETE Command Usage${RESET}"
    echo -e "${CYBER_YELLOW}Description:${RESET} Perform HTTP DELETE requests with cyberpunk style"
    echo
    echo -e "${CYBER_YELLOW}Syntax:${RESET}"
    echo "  bytebabe flux delete <url> [options]"
    echo
    echo -e "${CYBER_YELLOW}Options:${RESET}"
    echo "  -H, --header <header>    Add custom header (can be used multiple times)"
    echo "  --json                   Set Accept header to application/json"
    echo "  --loading <style>        Set loading animation style (default|matrix|cyber)"
    echo "  -f, --force             Skip confirmation prompt"
    echo "  -h, --help              Show this help message"
    echo
    echo -e "${CYBER_YELLOW}Examples:${RESET}"
    echo "  bytebabe flux delete http://api.example.com/users/123"
    echo "  bytebabe flux delete http://api.example.com/posts/456 --json"
    echo "  bytebabe flux delete http://api.example.com/data -H 'Authorization: Bearer token'"
    echo "  bytebabe flux delete http://api.example.com/critical --force"
    echo
    echo -e "${CYBER_YELLOW}Loading Styles:${RESET}"
    echo "  default    Classic spinner animation"
    echo "  matrix     Matrix-style loading effect"
    echo "  cyber      Cyberpunk-themed animation"
}
