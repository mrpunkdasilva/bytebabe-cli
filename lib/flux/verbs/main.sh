#!/bin/bash

# Definição das cores
CYBER_RED='\033[1;31m'
CYBER_GREEN='\033[1;32m'
CYBER_BLUE='\033[1;34m'
RESET='\033[0m'

# Define o diretório base
export BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Carrega todos os verbos HTTP
source "$BASE_DIR/lib/flux/verbs/get/main.sh"
source "$BASE_DIR/lib/flux/verbs/post/main.sh"
source "$BASE_DIR/lib/flux/verbs/put/main.sh"
source "$BASE_DIR/lib/flux/verbs/delete/main.sh"

# Função para mostrar ajuda geral do Flux
show_flux_help() {
    echo -e "${CYBER_BLUE}Flux HTTP Client Usage:${RESET}"
    echo -e "  flux <verb> <url> [options]\n"
    
    echo -e "${CYBER_BLUE}Available Verbs:${RESET}"
    echo -e "  ${CYBER_GREEN}get${RESET}     - Perform GET request"
    echo -e "  ${CYBER_GREEN}post${RESET}    - Perform POST request"
    echo -e "  ${CYBER_GREEN}put${RESET}     - Perform PUT request"
    echo -e "  ${CYBER_GREEN}delete${RESET}  - Perform DELETE request\n"
    
    echo -e "${CYBER_BLUE}For verb-specific help:${RESET}"
    echo -e "  flux <verb> --help"
}

# Função para executar o verbo correto
execute_verb() {
    local verb="$1"
    shift

    # Se nenhum argumento adicional for fornecido, mostrar ajuda específica do verbo
    if [[ -z "$1" ]]; then
        case "${verb,,}" in
            "get")
                show_get_help
                ;;
            "post")
                show_post_help
                ;;
            "put")
                show_put_help
                ;;
            "delete")
                show_delete_help
                ;;
            *)
                show_flux_help
                return 1
                ;;
        esac
        return 0
    fi

    case "${verb,,}" in
        "get")
            execute_get "$@"
            ;;
        "post")
            execute_post "$@"
            ;;
        "put")
            execute_put "$@"
            ;;
        "delete")
            execute_delete "$@"
            ;;
        *)
            echo -e "${CYBER_RED}Error: Unknown verb '${verb}'${RESET}"
            show_flux_help
            return 1
            ;;
    esac
}