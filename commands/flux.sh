#!/bin/bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$BASE_DIR/lib/core/colors.sh"
source "$BASE_DIR/lib/core/helpers.sh"
source "$BASE_DIR/lib/flux/main.sh"  # Mudamos para importar o main.sh ao invés do verbs/main.sh

# Função principal do Flux
flux_command() {
    local command="$1"
    shift

    # Chama diretamente a função main do lib/flux/main.sh
    main "$command" "$@"
}

# Executa o comando principal se não for sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    flux_command "$@"
fi
