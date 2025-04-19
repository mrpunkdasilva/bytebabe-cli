#!/bin/bash

parse_delete_args() {
    local args=()
    local loading_style="default"
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -H|--header)
                if [[ -z "$2" ]]; then
                    echo -e "${CYBER_RED}Error: Header value is required${RESET}" >&2
                    return 1
                fi
                args+=("-H '$2'")
                shift 2
                ;;
            --json)
                args+=("-H 'Accept: application/json'")
                shift
                ;;
            --loading)
                if [[ -z "$2" ]]; then
                    echo -e "${CYBER_RED}Error: Loading style is required${RESET}" >&2
                    return 1
                fi
                loading_style="$2"
                shift 2
                ;;
            -f|--force)
                args+=("--force")
                shift
                ;;
            *)
                echo -e "${CYBER_RED}Error: Unknown option: $1${RESET}" >&2
                return 1
                ;;
        esac
    done
    
    echo "${args[*]}|$loading_style"
}