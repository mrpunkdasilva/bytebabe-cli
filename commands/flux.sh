#!/bin/bash

# Define o diretório base (deve apontar para a raiz do projeto)
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Importa os módulos necessários
source "$BASE_DIR/lib/flux/display.sh"
source "$BASE_DIR/lib/flux/ui.sh"
source "$BASE_DIR/lib/flux/verbs/get/main.sh"
source "$BASE_DIR/lib/flux/verbs/post/main.sh"
source "$BASE_DIR/lib/flux/verbs/put/main.sh"
source "$BASE_DIR/lib/flux/verbs/delete/main.sh"

# Cores
export CYBER_BLUE='\033[38;5;45m'
export CYBER_GREEN='\033[38;5;118m'
export CYBER_YELLOW='\033[38;5;227m'
export CYBER_RED='\033[38;5;196m'
export CYBER_PURPLE='\033[38;5;93m'
export RESET='\033[0m'

main() {
    local verb="$1"
    shift

    clear
    show_flux_header

    case "$verb" in
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
            show_flux_help
            ;;
    esac
}


main "$@"