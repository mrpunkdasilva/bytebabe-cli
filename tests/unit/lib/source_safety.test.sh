#!/bin/bash

set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/test_helpers.sh
source "$TEST_DIR/../../lib/test_helpers.sh"

SOURCE_SAFE_EXCLUDES=("lib/utils/get_docker.sh")
DEVTOOLS_MODULES=(
    "api_services:api_services_main"
    "browser_services:browser_services_main"
    "database_services:database_services_main"
    "terminal_services:terminal_services_main"
)

source_is_silent() {
    local file="$1"
    local output status

    if output=$(env -i PATH="$PATH" HOME="$HOME" BASE_DIR="$BASE_DIR" \
        /bin/bash --noprofile --norc -c 'source "$1"' _ "$file" 2>&1); then
        status=0
    else
        status=$?
    fi

    if [[ $status -ne 0 || -n "$output" ]]; then
        printf 'source falhou ou gerou saída: %s (rc=%s)\n%s\n' "$file" "$status" "$output" >&2
        return 1
    fi
}

is_excluded() {
    local relative="$1"
    local excluded
    for excluded in "${SOURCE_SAFE_EXCLUDES[@]}"; do
        [[ "$relative" == "$excluded" ]] && return 0
    done
    return 1
}

test_runtime_libs_are_source_safe() {
    local file relative
    while IFS= read -r file; do
        relative="${file#"$BASE_DIR/"}"
        is_excluded "$relative" && continue
        source_is_silent "$file" || return 1
    done < <(find "$BASE_DIR/lib" -type f -name '*.sh' | sort)
}

test_command_entrypoints_are_source_safe() {
    local file
    while IFS= read -r file; do
        source_is_silent "$file" || return 1
    done < <(find "$BASE_DIR/commands" -type f -name '*.sh' | sort)
}

test_devtools_modules_expose_entrypoints() {
    local item module entry output
    for item in "${DEVTOOLS_MODULES[@]}"; do
        module="${item%%:*}"
        entry="${item##*:}"
        output=$(env -i PATH="$PATH" HOME="$HOME" BASE_DIR="$BASE_DIR" \
            /bin/bash --noprofile --norc -c 'source "$1"; declare -F "$2"' _ \
            "$BASE_DIR/lib/devtools/$module.sh" "$entry" 2>&1)
        assert_eq "$entry" "$output" "$module deve expor $entry"
    done
}

test_devtools_command_calls_modules_in_subshells() {
    local command_file="$BASE_DIR/commands/devtools.sh"
    local item module entry
    for item in "${DEVTOOLS_MODULES[@]}"; do
        module="${item%%:*}"
        entry="${item##*:}"
        assert_success "$module deve ser chamado em subshell" \
            grep -qF "( source \"\$BASE_DIR/lib/devtools/$module.sh\"; $entry \"\$@\" )" "$command_file"
    done
}

test_prime_dispatches_module_runners() {
    local command_file="$BASE_DIR/commands/prime.sh"
    local call
    for call in "run_quarantine" "run_backup" "run_log" "run_list" "run_info" "run_stats" "direct_mode"; do
        assert_success "prime deve chamar $call" grep -qF "$call \"\$@\"" "$command_file"
    done
}

test_prime_has_no_exit() {
    assert_failure "prime não deve usar exit" \
        grep -qE '\bexit\b' "$BASE_DIR/commands/prime.sh"
}

test_prime_invalid_command_returns_failure() {
    local status
    if env -i PATH="$PATH" HOME="$HOME" BASE_DIR="$BASE_DIR" \
        /bin/bash --noprofile --norc -c \
        'source "$1"; main comando-invalido' _ "$BASE_DIR/commands/prime.sh" >/dev/null 2>&1; then
        status=0
    else
        status=$?
    fi
    assert_eq "1" "$status" "prime inválido deve retornar 1"
}

test_legacy_command_entrypoints_have_no_exit() {
    local relative
    for relative in commands/db.sh commands/servers.sh commands/json-server.sh commands/git/main.sh; do
        assert_failure "$relative não deve usar exit" \
            grep -qE '\bexit\b' "$BASE_DIR/$relative"
    done
}

test_datavision_defers_initialization() {
    local file="$BASE_DIR/lib/database/datavision.sh"
    assert_failure "init_config não deve rodar no topo" \
        grep -qE '^[[:space:]]*init_config[[:space:]]*$' "$file"
    assert_success "datavision_main deve inicializar a configuração" \
        grep -qE '^[[:space:]]+init_config[[:space:]]*$' "$file"
}

test_git_menu_uses_sentinel_return() {
    local file="$BASE_DIR/commands/git/main.sh"
    assert_success "menu deve retornar sentinela 10" grep -qF 'return 10' "$file"
    assert_success "navegação deve tratar a sentinela 10" grep -qF 'status -eq 10' "$file"
}

test_failure_paths_return_instead_of_exit() {
    local relative
    for relative in \
        lib/server/servers_services.sh \
        lib/database/db_services.sh \
        lib/pkg/clean/main.sh \
        lib/pkg/neo/main.sh \
        lib/core/helpers.sh; do
        assert_failure "$relative não deve usar exit" \
            grep -qE '\bexit\b' "$BASE_DIR/$relative"
    done
}

test_server_docker_check_returns_failure_without_docker() {
    local empty_path output
    empty_path="$TEST_TMP_DIR/empty-path"
    mkdir -p "$empty_path"

    output=$(env -i PATH="$empty_path" HOME="$HOME" BASE_DIR="$BASE_DIR" \
        /bin/bash --noprofile --norc -c \
        'source "$1"; check_docker_installed; echo "rc=$?"; echo AFTER' _ \
        "$BASE_DIR/lib/server/servers_services.sh" 2>&1)

    assert_contains "$output" "rc=1" "check_docker_installed deve retornar 1"
    assert_contains "$output" "AFTER" "source/check não deve encerrar o shell"
}

test_neo_missing_jq_returns_failure() {
    local empty_path output
    empty_path="$TEST_TMP_DIR/empty-path"
    mkdir -p "$empty_path"

    output=$(env -i PATH="$empty_path" HOME="$HOME" BASE_DIR="$BASE_DIR" \
        /bin/bash --noprofile --norc -c \
        'source "$1"; run_neo_mode --help; echo "rc=$?"; echo AFTER' _ \
        "$BASE_DIR/lib/pkg/neo/main.sh" 2>&1)

    assert_contains "$output" "rc=1" "run_neo_mode deve propagar falha de load_config"
    assert_contains "$output" "AFTER" "run_neo_mode não deve encerrar o shell"
}

test_clean_invalid_mode_returns_failure() {
    local output
    output=$(env -i PATH="$PATH" HOME="$HOME" BASE_DIR="$BASE_DIR" \
        /bin/bash --noprofile --norc -c \
        'source "$1"; show_header_custom() { :; }; run_clean invalido; echo "rc=$?"; echo AFTER' _ \
        "$BASE_DIR/lib/pkg/clean/main.sh" 2>&1)

    assert_contains "$output" "rc=1" "modo inválido deve retornar 1"
    assert_contains "$output" "AFTER" "run_clean não deve encerrar o shell"
}

test_quarantine_help_does_not_require_sudo() {
    local stub_dir marker
    stub_dir="$TEST_TMP_DIR/stubs/quarantine"
    marker="$TEST_TMP_DIR/sudo-called"
    mkdir -p "$stub_dir"
    printf '#!/bin/bash\ntouch %q\nexit 1\n' "$marker" > "$stub_dir/sudo"
    chmod +x "$stub_dir/sudo"

    env -i PATH="$stub_dir:$PATH" HOME="$HOME" BASE_DIR="$BASE_DIR" MARKER="$marker" \
        /bin/bash --noprofile --norc -c \
        'source "$1"; run_quarantine --help' _ "$BASE_DIR/lib/pkg/quarantine/main.sh" >/dev/null 2>&1

    if [[ -e "$marker" ]]; then
        printf 'run_quarantine --help chamou sudo\n' >&2
        return 1
    fi
}

main() {
    setup_test_env
    trap cleanup_test_env EXIT

    run_test_case "bibliotecas de runtime são source-safe" test_runtime_libs_are_source_safe
    run_test_case "entrypoints de comandos são source-safe" test_command_entrypoints_are_source_safe
    run_test_case "módulos devtools expõem entrypoints" test_devtools_modules_expose_entrypoints
    run_test_case "devtools chama módulos em subshells" test_devtools_command_calls_modules_in_subshells
    run_test_case "prime despacha runners dos módulos" test_prime_dispatches_module_runners
    run_test_case "prime não usa exit" test_prime_has_no_exit
    run_test_case "prime inválido retorna 1" test_prime_invalid_command_returns_failure
    run_test_case "comandos legados não usam exit" test_legacy_command_entrypoints_have_no_exit
    run_test_case "datavision adia inicialização" test_datavision_defers_initialization
    run_test_case "menu git usa sentinela" test_git_menu_uses_sentinel_return
    run_test_case "ajuda da quarentena não exige sudo" test_quarantine_help_does_not_require_sudo
    run_test_case "caminhos de falha não usam exit" test_failure_paths_return_instead_of_exit
    run_test_case "servers retorna falha sem Docker" test_server_docker_check_returns_failure_without_docker
    run_test_case "neo retorna falha sem jq" test_neo_missing_jq_returns_failure
    run_test_case "clean inválido retorna 1" test_clean_invalid_mode_returns_failure

    show_test_summary
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
