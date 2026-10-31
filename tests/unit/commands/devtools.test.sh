#!/bin/bash

set -euo pipefail

readonly BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
readonly DEVTOOLS_FILE="$BASE_DIR/commands/devtools/main.sh"

assert_contains() {
    local description="$1"
    local expected="$2"

    if grep -Fq "$expected" "$DEVTOOLS_FILE"; then
        printf 'PASS: %s\n' "$description"
    else
        printf 'FAIL: %s\n' "$description" >&2
        return 1
    fi
}

main() {
    assert_contains "Docker aparece no menu" "5) Instalar Docker"
    assert_contains "Docker pode ser chamado diretamente" '"docker"|"install-docker")'
    assert_contains "opção interativa chama o instalador" '5) call_docker_install ;;'
    assert_contains "chamada executa get_docker.sh" 'env -u VERSION bash "$BASE_DIR/lib/utils/get_docker.sh"'
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
