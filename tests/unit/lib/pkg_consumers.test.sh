#!/bin/bash

# Testes de contrato dos consumidores de gerenciador de pacotes.
# Não executa sudo, rede, instalação real nem carrega comandos com efeitos.
# A única execução dinâmica é o source do módulo de core via helpers, com PATH
# isolado contendo apenas stubs.

set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/test_helpers.sh
source "$TEST_DIR/../../lib/test_helpers.sh"

CORE_PKG_FILE="$BASE_DIR/lib/core/pkg.sh"
HELPERS_FILE="$BASE_DIR/lib/core/helpers.sh"

PACKAGE_CONSUMERS=(
    "commands/backend/main.sh"
    "lib/devtools/api_services.sh"
    "lib/devtools/browser_services.sh"
    "lib/devtools/database_services.sh"
    "lib/devtools/terminal_services.sh"
    "lib/pkg/upgrade/main.sh"
)

DETECT_DEFINITION_REGEX='^[[:space:]]*(function[[:space:]]+)?detect_pkg_manager[[:space:]]*\(\)'
INSTALL_DEFINITION_REGEX='^[[:space:]]*(function[[:space:]]+)?(install_pkg|pkg_install)[[:space:]]*\(\)'

run_isolated_bash() {
    local script="$1"
    shift
    /bin/bash --noprofile --norc -c "$script" _ "$@"
}

find_definition_files() {
    local regex="$1"
    grep -RIlE --include='*.sh' "$regex" \
        "$BASE_DIR/bin" "$BASE_DIR/commands" "$BASE_DIR/lib" 2>/dev/null | \
        sort -u || true
}

find_definitions_outside_core() {
    local regex="$1"
    grep -RInE --include='*.sh' "$regex" \
        "$BASE_DIR/bin" "$BASE_DIR/commands" "$BASE_DIR/lib" 2>/dev/null | \
        grep -v "^${CORE_PKG_FILE}:" || true
}

detect_with_stub() {
    local manager="$1"
    local dir="$TEST_TMP_DIR/stubs/helpers-$manager"
    stub_command "$manager" "" 0 "$dir" >/dev/null

    PATH="$dir" run_isolated_bash '
        set -euo pipefail
        source "$1"
        detect_pkg_manager
    ' "$HELPERS_FILE"
}

test_detect_is_defined_only_in_core_pkg() {
    local files
    files=$(find_definition_files "$DETECT_DEFINITION_REGEX")

    assert_eq "$CORE_PKG_FILE" "$files" \
        "detect_pkg_manager deve estar definida apenas em lib/core/pkg.sh"
}

test_install_helpers_are_not_redefined_outside_core() {
    local definitions
    definitions=$(find_definitions_outside_core "$INSTALL_DEFINITION_REGEX")

    assert_eq "" "$definitions" \
        "install_pkg/pkg_install não devem ser redefinidos fora do core"
}

test_package_consumers_have_no_local_detection() {
    local relative file definitions
    for relative in "${PACKAGE_CONSUMERS[@]}"; do
        file="$BASE_DIR/$relative"
        definitions=$(grep -nE "$DETECT_DEFINITION_REGEX" "$file" || true)
        assert_eq "" "$definitions" \
            "$relative não deve conter definição local de detect_pkg_manager"
    done
}

test_package_consumers_use_canonical_detection() {
    local relative file
    for relative in "${PACKAGE_CONSUMERS[@]}"; do
        file="$BASE_DIR/$relative"
        assert_success "$relative deve chamar detect_pkg_manager" \
            grep -q "detect_pkg_manager" "$file"
    done
}

test_helpers_detect_apt_via_stub() {
    assert_eq "apt" "$(detect_with_stub apt-get)" \
        "helpers deve expor detecção canônica de apt"
}

test_helpers_detect_brew_via_stub() {
    assert_eq "brew" "$(detect_with_stub brew)" \
        "helpers deve expor detecção canônica de brew"
}

main() {
    setup_test_env
    trap cleanup_test_env EXIT

    run_test_case "detect_pkg_manager definida apenas no core" test_detect_is_defined_only_in_core_pkg
    run_test_case "install_pkg/pkg_install não são redefinidos fora do core" test_install_helpers_are_not_redefined_outside_core
    run_test_case "consumidores não definem detecção local" test_package_consumers_have_no_local_detection
    run_test_case "consumidores usam a detecção canônica" test_package_consumers_use_canonical_detection
    run_test_case "helpers detecta apt via stub" test_helpers_detect_apt_via_stub
    run_test_case "helpers detecta brew via stub" test_helpers_detect_brew_via_stub

    show_test_summary
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
