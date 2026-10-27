#!/bin/bash

# Testes de contrato dos consumidores de UI, menu, spinner e header.
# Não abre menus interativos nem executa Docker, sudo ou rede. As execuções
# dinâmicas limitam-se a source de módulos sem side effects e ao header simples.

set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/test_helpers.sh
source "$TEST_DIR/../../lib/test_helpers.sh"

FEEDBACK_FILE="$BASE_DIR/lib/core/feedback.sh"
MENU_FILE="$BASE_DIR/lib/core/menu.sh"
UI_FILE="$BASE_DIR/lib/core/ui.sh"
PKG_FILE="$BASE_DIR/lib/core/pkg.sh"
BIN_FILE="$BASE_DIR/bin/bytebabe"
INIT_FILE="$BASE_DIR/commands/init.sh"
GIT_MAIN_FILE="$BASE_DIR/commands/git/main.sh"
GIT_UI_FILE="$BASE_DIR/lib/git/ui.sh"
GIT_COMMIT_FILE="$BASE_DIR/lib/git/commit.sh"
GIT_STAGE_FILE="$BASE_DIR/lib/git/stage.sh"
DOCKER_CONTAINERS_FILE="$BASE_DIR/lib/docker/containers.sh"
DOCKER_HELPERS_FILE="$BASE_DIR/lib/docker/helpers.sh"

SHOW_SPINNER_DEFINITION_REGEX='^[[:space:]]*(function[[:space:]]+)?show_spinner[[:space:]]*\(\)'
CHOOSE_FROM_MENU_DEFINITION_REGEX='^[[:space:]]*(function[[:space:]]+)?choose_from_menu[[:space:]]*\(\)'
CHECK_DEPENDENCIES_DEFINITION_REGEX='^[[:space:]]*(function[[:space:]]+)?check_dependencies[[:space:]]*\(\)'
CHECK_DOCKER_DEPENDENCIES_DEFINITION_REGEX='^[[:space:]]*(function[[:space:]]+)?check_docker_dependencies[[:space:]]*\(\)'
SHOW_HEADER_DEFINITION_REGEX='^[[:space:]]*(function[[:space:]]+)?show_cyberpunk_header[[:space:]]*\(\)'
CYBER_ASSIGNMENT_REGEX='^[[:space:]]*(export[[:space:]]+)?CYBER_[A-Za-z0-9_]+[[:space:]]*='

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

test_show_spinner_is_defined_only_in_feedback() {
    local files
    files=$(find_definition_files "$SHOW_SPINNER_DEFINITION_REGEX")

    assert_eq "$FEEDBACK_FILE" "$files" \
        "show_spinner deve estar definida apenas em lib/core/feedback.sh"
}

test_choose_from_menu_is_defined_only_in_menu() {
    local files
    files=$(find_definition_files "$CHOOSE_FROM_MENU_DEFINITION_REGEX")

    assert_eq "$MENU_FILE" "$files" \
        "choose_from_menu deve estar definida apenas em lib/core/menu.sh"
}

test_check_dependencies_is_defined_only_in_core_pkg() {
    local files
    files=$(find_definition_files "$CHECK_DEPENDENCIES_DEFINITION_REGEX")

    assert_eq "$PKG_FILE" "$files" \
        "check_dependencies deve estar definida apenas em lib/core/pkg.sh"
}

test_docker_uses_specific_dependency_check() {
    assert_success "helpers.sh deve definir check_docker_dependencies" \
        grep -qE "$CHECK_DOCKER_DEPENDENCIES_DEFINITION_REGEX" "$DOCKER_HELPERS_FILE"
    assert_success "container_commander deve chamar check_docker_dependencies" \
        grep -q "check_docker_dependencies" "$DOCKER_CONTAINERS_FILE"
    assert_success "containers.sh não deve definir check_docker_dependencies" \
        bash -c '! grep -qE "$1" "$2"' _ \
        "$CHECK_DOCKER_DEPENDENCIES_DEFINITION_REGEX" "$DOCKER_CONTAINERS_FILE"
    assert_success "containers.sh não deve definir check_dependencies local" \
        bash -c '! grep -qE "$1" "$2"' _ \
        "$CHECK_DEPENDENCIES_DEFINITION_REGEX" "$DOCKER_CONTAINERS_FILE"
}

test_bin_uses_canonical_header() {
    local definitions
    definitions=$(grep -nE "$SHOW_HEADER_DEFINITION_REGEX" "$BIN_FILE" || true)

    assert_eq "" "$definitions" \
        "bin/bytebabe não deve redefinir show_cyberpunk_header"
    assert_success "bin/bytebabe deve chamar show_cyberpunk_header" \
        grep -qE '^[[:space:]]*show_cyberpunk_header[[:space:]]*$' "$BIN_FILE"
    assert_success "bin/bytebabe deve carregar o core via helpers" \
        grep -q 'source.*lib/core/helpers.sh' "$BIN_FILE"
}

test_init_uses_ascii_banner() {
    assert_success "init deve chamar show_cyberpunk_banner" \
        grep -q 'show_cyberpunk_banner' "$INIT_FILE"
    assert_success "init não deve chamar show_cyberpunk_header" \
        bash -c '! grep -q "show_cyberpunk_header" "$1"' _ "$INIT_FILE"
}

test_git_main_uses_core_spinner_and_menu() {
    local definitions order helpers_line ui_line

    definitions=$(grep -nE "$SHOW_SPINNER_DEFINITION_REGEX" "$GIT_MAIN_FILE" || true)
    assert_eq "" "$definitions" \
        "commands/git/main.sh não deve redefinir show_spinner"

    definitions=$(grep -nE "$CHOOSE_FROM_MENU_DEFINITION_REGEX" "$GIT_MAIN_FILE" || true)
    assert_eq "" "$definitions" \
        "commands/git/main.sh não deve redefinir choose_from_menu"

    helpers_line=$(grep -nE 'source.*lib/core/helpers\.sh' "$GIT_MAIN_FILE" | head -n 1 | cut -d: -f1)
    ui_line=$(grep -nE 'source.*lib/git/ui\.sh' "$GIT_MAIN_FILE" | head -n 1 | cut -d: -f1)
    order="no"
    if [[ -n "$helpers_line" && -n "$ui_line" && "$helpers_line" -lt "$ui_line" ]]; then
        order="yes"
    fi

    assert_eq "yes" "$order" \
        "commands/git/main.sh deve carregar helpers antes de lib/git/ui.sh"
    assert_success "source de helpers deve ser relativo a BASH_SOURCE" \
        grep -q 'BASE_DIR=.*BASH_SOURCE' "$GIT_MAIN_FILE"
}

test_git_ui_uses_core_colors() {
    local assignments
    assignments=$(grep -nE "$CYBER_ASSIGNMENT_REGEX" "$GIT_UI_FILE" || true)

    assert_eq "" "$assignments" \
        "lib/git/ui.sh não deve redefinir variáveis CYBER_*"
    assert_success "lib/git/ui.sh não deve usar tput para cores" \
        bash -c '! grep -q "tput" "$1"' _ "$GIT_UI_FILE"
    assert_success "lib/git/ui.sh deve carregar lib/core/colors.sh" \
        grep -q 'source.*core/colors\.sh' "$GIT_UI_FILE"
    assert_success "lib/git/ui.sh deve usar BASH_SOURCE para o caminho" \
        grep -q 'BASH_SOURCE' "$GIT_UI_FILE"
}

test_git_consumers_remove_local_helpers() {
    local definitions

    definitions=$(grep -nE '^[[:space:]]*(function[[:space:]]+)?show_loading[[:space:]]*\(\)' \
        "$GIT_COMMIT_FILE" "$GIT_STAGE_FILE" || true)
    assert_eq "" "$definitions" \
        "commit.sh e stage.sh não devem redefinir show_loading"

    definitions=$(grep -nE "$CHOOSE_FROM_MENU_DEFINITION_REGEX" "$GIT_COMMIT_FILE" || true)
    assert_eq "" "$definitions" \
        "commit.sh não deve redefinir choose_from_menu"
}

test_core_ui_modules_source_without_output() {
    local file output status
    for file in "$UI_FILE" "$MENU_FILE" "$FEEDBACK_FILE"; do
        if output=$(run_isolated_bash 'source "$1"' "$file" 2>&1); then
            status=0
        else
            status=$?
        fi
        assert_eq 0 "$status" "$(basename "$file") deve carregar sem erro"
        assert_eq "" "$output" "$(basename "$file") não deve produzir saída"
    done
}

test_simple_header_contains_bytebabe() {
    local output
    output=$(run_isolated_bash '
        set -euo pipefail
        source "$1"
        declare -F show_cyberpunk_banner >/dev/null
        show_cyberpunk_header
    ' "$UI_FILE" 2>&1)

    assert_contains "$output" "BYTEBABE" \
        "show_cyberpunk_header deve identificar a CLI"
    assert_not_contains "$output" "888888b" \
        "show_cyberpunk_header não deve executar o banner ASCII"
}

test_docker_containers_source_without_output() {
    local output status
    if output=$(run_isolated_bash '
            set -euo pipefail
            source "$1"
            [[ -n "$CYBER_BLUE" ]] || exit 1
            declare -F choose_from_menu >/dev/null
            declare -F check_docker_dependencies >/dev/null
        ' "$DOCKER_CONTAINERS_FILE" 2>&1); then
        status=0
    else
        status=$?
    fi

    assert_eq 0 "$status" \
        "containers.sh deve carregar helpers canônicos sem erro"
    assert_eq "" "$output" \
        "containers.sh não deve produzir saída ao ser carregado"
}

main() {
    setup_test_env
    trap cleanup_test_env EXIT

    run_test_case "show_spinner definida apenas no core" test_show_spinner_is_defined_only_in_feedback
    run_test_case "choose_from_menu definida apenas no core" test_choose_from_menu_is_defined_only_in_menu
    run_test_case "check_dependencies definida apenas no core" test_check_dependencies_is_defined_only_in_core_pkg
    run_test_case "Docker usa check_docker_dependencies" test_docker_uses_specific_dependency_check
    run_test_case "bin usa header canônico" test_bin_uses_canonical_header
    run_test_case "init usa banner ASCII" test_init_uses_ascii_banner
    run_test_case "git main usa feedback/menu do core" test_git_main_uses_core_spinner_and_menu
    run_test_case "git ui usa cores do core" test_git_ui_uses_core_colors
    run_test_case "commit/stage sem helpers locais" test_git_consumers_remove_local_helpers
    run_test_case "ui/menu/feedback carregam sem saída" test_core_ui_modules_source_without_output
    run_test_case "header simples contém BYTEBABE" test_simple_header_contains_bytebabe
    run_test_case "containers carrega core sem saída" test_docker_containers_source_without_output

    show_test_summary
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
