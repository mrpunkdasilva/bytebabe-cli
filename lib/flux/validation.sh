#!/bin/bash

# Validação compartilhada de URLs do Flux.
# Deve permanecer seguro para source: apenas define funções.

if declare -F flux_validate_url >/dev/null 2>&1; then
    return 0
fi

flux_validate_url() {
    local url="$1"
    local help_function="${2:-}"

    if [[ -z "$url" ]]; then
        echo -e "${CYBER_RED:-}Error: URL is required${RESET:-}" >&2
        if [[ -n "$help_function" ]] && declare -F "$help_function" >/dev/null 2>&1; then
            "$help_function"
        fi
        return 1
    fi

    if [[ ! "$url" =~ ^https?:// ]]; then
        echo -e "${CYBER_RED:-}Error: URL must start with http:// or https://${RESET:-}" >&2
        return 1
    fi

    return 0
}
