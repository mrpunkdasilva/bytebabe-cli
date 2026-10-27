#!/bin/bash

# Parser de opções compartilhado pelos verbos HTTP do Flux.
# Deve permanecer seguro para source: apenas define funções.

if declare -F flux_parse_request_args >/dev/null 2>&1; then
    return 0
fi

FLUX_METHOD=""
FLUX_URL=""
FLUX_HEADERS=()
FLUX_QUERY=()
FLUX_DATA=""
FLUX_OUTPUT=""
FLUX_INCLUDE=0
FLUX_VERBOSE=0
FLUX_FORCE=0
FLUX_HELP=0
FLUX_LOADING_STYLE="default"

flux_reset_request_args() {
    FLUX_METHOD=""
    FLUX_URL=""
    FLUX_HEADERS=()
    FLUX_QUERY=()
    FLUX_DATA=""
    FLUX_OUTPUT=""
    FLUX_INCLUDE=0
    FLUX_VERBOSE=0
    FLUX_FORCE=0
    FLUX_HELP=0
    FLUX_LOADING_STYLE="default"
}

flux_show_method_help() {
    case "$1" in
        GET) show_get_help ;;
        POST) show_post_help ;;
        PUT) show_put_help ;;
        DELETE) show_delete_help ;;
        *) return 1 ;;
    esac
}

_flux_invalid_value() {
    local option="$1"
    local value="$2"

    if [[ "$value" == *$'\n'* || "$value" == *$'\r'* ]]; then
        echo -e "${CYBER_RED:-}Error: invalid value for $option${RESET:-}" >&2
        return 1
    fi
    return 0
}

_flux_require_value() {
    local option="$1"
    local value="${2:-}"

    if [[ -z "$value" || "$value" == -* ]]; then
        echo -e "${CYBER_RED:-}Error: $option value is required${RESET:-}" >&2
        return 1
    fi

    _flux_invalid_value "$option" "$value"
}

flux_parse_request_args() {
    local method="${1:-}"
    local option value positional

    if [[ -z "$method" ]]; then
        return 1
    fi
    shift

    flux_reset_request_args
    FLUX_METHOD="$method"

    while [[ $# -gt 0 ]]; do
        option="$1"

        case "$option" in
            -h|--help)
                FLUX_HELP=1
                shift
                ;;
            -H|--header)
                _flux_require_value "$option" "${2:-}" || return 1
                FLUX_HEADERS+=("$2")
                shift 2
                ;;
            --json)
                FLUX_HEADERS+=("Accept: application/json")
                shift
                ;;
            -i|--include)
                FLUX_INCLUDE=1
                shift
                ;;
            -v|--verbose)
                FLUX_VERBOSE=1
                shift
                ;;
            -d|--data)
                if [[ "$method" != "POST" && "$method" != "PUT" ]]; then
                    echo -e "${CYBER_RED:-}Error: Unknown option '$option' for $method${RESET:-}" >&2
                    flux_show_method_help "$method"
                    return 1
                fi
                _flux_require_value "$option" "${2:-}" || return 1
                FLUX_DATA="$2"
                shift 2
                ;;
            -q|--query)
                if [[ "$method" != "GET" ]]; then
                    echo -e "${CYBER_RED:-}Error: Unknown option '$option' for $method${RESET:-}" >&2
                    flux_show_method_help "$method"
                    return 1
                fi
                _flux_require_value "$option" "${2:-}" || return 1
                FLUX_QUERY+=("$2")
                shift 2
                ;;
            -o|--output)
                if [[ "$method" != "GET" ]]; then
                    echo -e "${CYBER_RED:-}Error: Unknown option '$option' for $method${RESET:-}" >&2
                    flux_show_method_help "$method"
                    return 1
                fi
                _flux_require_value "$option" "${2:-}" || return 1
                FLUX_OUTPUT="$2"
                shift 2
                ;;
            -f|--force)
                if [[ "$method" != "DELETE" ]]; then
                    echo -e "${CYBER_RED:-}Error: Unknown option '$option' for $method${RESET:-}" >&2
                    flux_show_method_help "$method"
                    return 1
                fi
                FLUX_FORCE=1
                shift
                ;;
            --loading|--loading-style)
                _flux_require_value "$option" "${2:-}" || return 1
                FLUX_LOADING_STYLE="$2"
                shift 2
                ;;
            --)
                shift
                while [[ $# -gt 0 ]]; do
                    if [[ -z "$FLUX_URL" ]]; then
                        FLUX_URL="$1"
                    else
                        echo -e "${CYBER_RED:-}Error: Unexpected argument '$1'${RESET:-}" >&2
                        return 1
                    fi
                    shift
                done
                ;;
            -*)
                echo -e "${CYBER_RED:-}Error: Unknown option '$option'${RESET:-}" >&2
                flux_show_method_help "$method"
                return 1
                ;;
            *)
                positional="$option"
                _flux_invalid_value "URL" "$positional" || return 1
                if [[ -z "$FLUX_URL" ]]; then
                    FLUX_URL="$positional"
                else
                    echo -e "${CYBER_RED:-}Error: Unexpected argument '$positional'${RESET:-}" >&2
                    return 1
                fi
                shift
                ;;
        esac
    done

    return 0
}
