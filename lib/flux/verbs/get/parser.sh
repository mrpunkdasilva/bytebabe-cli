#!/bin/bash

parse_get_args() {
    local params=""
    local output_file=""
    local query_params=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -H|--header)
                if [[ -z "$2" || "${2:0:1}" == "-" ]]; then
                    echo -e "${CYBER_RED}Error: Header value is required${RESET}"
                    return 1
                fi
                params+=" -H '$2'"
                shift 2
                ;;
            -o|--output)
                if [[ -z "$2" || "${2:0:1}" == "-" ]]; then
                    echo -e "${CYBER_RED}Error: Output file name is required${RESET}"
                    return 1
                fi
                output_file="$2"
                params+=" -o '$output_file'"
                shift 2
                ;;
            --json)
                params+=" -H 'Accept: application/json'"
                shift
                ;;
            -i|--include)
                params+=" -i"
                shift
                ;;
            -q|--query)
                if [[ -z "$2" || "${2:0:1}" == "-" ]]; then
                    echo -e "${CYBER_RED}Error: Query parameter is required${RESET}"
                    return 1
                fi
                if [[ -n "$query_params" ]]; then
                    query_params+="&$2"
                else
                    query_params="?$2"
                fi
                shift 2
                ;;
            -v|--verbose)
                params+=" -v"
                shift
                ;;
            *)
                if [[ "${1:0:1}" == "-" ]]; then
                    echo -e "${CYBER_RED}Error: Unknown option '$1'${RESET}"
                    show_get_help
                    return 1
                fi
                # Se não é uma opção, assume que é parte da URL
                if [[ -n "$query_params" ]]; then
                    params+=" '${1}${query_params}'"
                else
                    params+=" '$1'"
                fi
                shift
                ;;
        esac
    done

    echo "$params"
}