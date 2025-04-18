#!/bin/bash

# Obtém o diretório base do script
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Importa os módulos necessários
source "$BASE_DIR/lib/flux/display.sh"  # Novo arquivo de display
source "$BASE_DIR/lib/flux/verbs/main.sh"
source "$BASE_DIR/lib/flux/ui.sh"

main() {
    # Verifica se foi passado algum argumento
    if [[ $# -eq 0 ]]; then
        show_flux_help
        return 1
    fi

    # Captura o verbo HTTP (primeiro argumento)
    local verb="$1"
    shift

    # Verifica se há uma URL (segundo argumento)
    if [[ $# -eq 0 && "$verb" != "--help" && "$verb" != "-h" ]]; then
        echo -e "${CYBER_RED}Error: URL is required${RESET}"
        show_flux_help
        return 1
    fi

    # Executa o verbo apropriado
    execute_verb "$verb" "$@"
}

# Executa a função principal passando todos os argumentos
main "$@"