#!/bin/bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$BASE_DIR/lib/core/colors.sh"
source "$BASE_DIR/lib/core/helpers.sh"
source "$BASE_DIR/lib/flux/display.sh"  # Adicionado import do display
source "$BASE_DIR/lib/flux/main.sh"

# Função principal do Flux
flux_command() {
    local command="$1"
    shift

    # Mostra o header do Flux
    show_flux_header

    # Chama diretamente a função main do lib/flux/main.sh
    main "$command" "$@"
}

# Executa o comando principal se não for sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    flux_command "$@"
fi
