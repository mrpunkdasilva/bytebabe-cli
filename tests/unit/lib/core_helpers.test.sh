#!/bin/bash

# Testes de caracterização de lib/core/colors.sh e lib/core/helpers.sh.
# Funções que poderiam instalar pacotes ou usar sudo são executadas apenas em
# ramos seguros (sem argumentos/gerenciador desconhecido) ou via subshell.

set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/test_helpers.sh
source "$TEST_DIR/../../lib/test_helpers.sh"

COLORS_FILE="$BASE_DIR/lib/core/colors.sh"
HELPERS_FILE="$BASE_DIR/lib/core/helpers.sh"
MENU_FILE="$BASE_DIR/lib/core/menu.sh"

run_isolated_bash() {
    local script="$1"
    shift
    /bin/bash --noprofile --norc -c "$script" _ "$@"
}

test_colors_source_without_output() {
    local output status
    if output=$(run_isolated_bash 'source "$1"' "$COLORS_FILE" 2>&1); then
        status=0
    else
        status=$?
    fi

    assert_eq 0 "$status" "colors.sh deve poder ser carregado"
    assert_eq "" "$output" "colors.sh não deve produzir saída ao ser carregado"
}

test_colors_define_variables_and_functions() {
    assert_success "colors.sh deve definir cores e funções de estilo" \
        run_isolated_bash '
            set -euo pipefail
            source "$1"
            for var in CYBER_BLUE CYBER_PINK CYBER_GREEN CYBER_YELLOW \
                       CYBER_ORANGE CYBER_GRAY CYBER_PURPLE CYBER_RED \
                       CYBER_GLITCH CYBER_BLINK CYBER_BOLD CYBER_UNDERLINE \
                       CYBER_BG_BLACK CYBER_BG_DARK RESET CYBER_DIVIDER CYBER_LINE; do
                [[ -n "${!var:-}" ]] || { echo "variável ausente: $var" >&2; exit 1; }
            done
            declare -F cyber_header >/dev/null
            declare -F cyber_divider >/dev/null
            declare -F cyber_echo >/dev/null
        ' "$COLORS_FILE"
}

test_helpers_source_without_output() {
    local output status
    if output=$(run_isolated_bash 'source "$1"' "$HELPERS_FILE" 2>&1); then
        status=0
    else
        status=$?
    fi

    assert_eq 0 "$status" "helpers.sh deve poder ser carregado"
    assert_eq "" "$output" "helpers.sh não deve produzir saída ao ser carregado"
}

detect_with_stub() {
    local manager="$1"
    local dir="$TEST_TMP_DIR/stubs/detect-$manager"

    stub_command "$manager" "" 0 "$dir" >/dev/null

    PATH="$dir" run_isolated_bash 'source "$1"; detect_pkg_manager' "$HELPERS_FILE"
}

test_detect_apt() {
    assert_eq "apt" "$(detect_with_stub apt-get)" "apt-get deve mapear para apt"
}

test_detect_dnf() {
    assert_eq "dnf" "$(detect_with_stub dnf)" "dnf deve mapear para dnf"
}

test_detect_yum() {
    assert_eq "yum" "$(detect_with_stub yum)" "yum deve mapear para yum"
}

test_detect_pacman() {
    assert_eq "pacman" "$(detect_with_stub pacman)" "pacman deve mapear para pacman"
}

test_detect_zypper() {
    assert_eq "zypper" "$(detect_with_stub zypper)" "zypper deve mapear para zypper"
}

test_detect_apk() {
    assert_eq "apk" "$(detect_with_stub apk)" "apk deve mapear para apk"
}

test_detect_unknown() {
    local dir="$TEST_TMP_DIR/stubs/detect-unknown"
    mkdir -p "$dir"

    local result
    result=$(PATH="$dir" run_isolated_bash 'source "$1"; detect_pkg_manager' "$HELPERS_FILE")
    assert_eq "unknown" "$result" "sem gerenciadores no PATH deve retornar unknown"
}

test_detect_precedence() {
    local dir="$TEST_TMP_DIR/stubs/detect-precedence"
    stub_command dnf "" 0 "$dir" >/dev/null
    stub_command apt-get "" 0 "$dir" >/dev/null

    local result
    result=$(PATH="$dir" run_isolated_bash 'source "$1"; detect_pkg_manager' "$HELPERS_FILE")
    assert_eq "apt" "$result" "apt-get deve ter precedência sobre dnf na ordem atual"
}

test_pkg_install_without_args_is_noop() {
    local dir="$TEST_TMP_DIR/stubs/pkg-install-empty"
    mkdir -p "$dir"

    assert_success "pkg_install sem argumentos deve retornar 0 sem efeitos" \
        env PATH="$dir" /bin/bash --noprofile --norc -c 'source "$1"; pkg_install' _ "$HELPERS_FILE"
}

test_invalid_command_help_output() {
    local output status
    if output=$(run_isolated_bash '
            set -euo pipefail
            source "$1"
            source "$2"
            show_invalid_command_prime "comando_x"
        ' "$COLORS_FILE" "$HELPERS_FILE" 2>&1); then
        status=0
    else
        status=$?
    fi

    assert_eq 0 "$status" "show_invalid_command_prime deve apenas imprimir ajuda"
    assert_contains "$output" "INVALID COMMAND DETECTED" "deve exibir o banner de comando inválido"
    assert_contains "$output" "Unknown command:" "deve indicar comando desconhecido"
    assert_contains "$output" "comando_x" "deve citar o comando recebido"
}

test_check_dependencies_skips_installed() {
    assert_success "dependência já instalada não deve chamar install_pkg" \
        run_isolated_bash '
            set -euo pipefail
            source "$1"
            source "$2"
            install_pkg() { return 99; }
            check_dependencies bash
        ' "$COLORS_FILE" "$HELPERS_FILE"
}

test_check_dependencies_installs_missing() {
    local output
    output=$(run_isolated_bash '
        set -euo pipefail
        source "$1"
        source "$2"
        install_pkg() { printf "install:%s" "$1"; }
        check_dependencies comando_inexistente_bytebabe
    ' "$COLORS_FILE" "$HELPERS_FILE")

    assert_eq "install:comando_inexistente_bytebabe" "$output" \
        "dependência ausente deve ser delegada a install_pkg"
}

test_show_spinner_with_finished_process() {
    local output status
    if output=$(run_isolated_bash '
            set -euo pipefail
            source "$1"
            source "$2"
            sleep 0.01 &
            child_pid=$!
            wait "$child_pid"
            show_spinner "$child_pid" "carregando"
        ' "$COLORS_FILE" "$HELPERS_FILE" 2>&1); then
        status=0
    else
        status=$?
    fi

    assert_eq 0 "$status" "show_spinner deve retornar quando o processo já terminou"
    assert_contains "$output" "carregando" "show_spinner deve exibir a mensagem"
    assert_contains "$output" "✔" "show_spinner deve exibir conclusão"
}

test_choose_from_menu_enter_selects_first() {
    local output status
    if output=$(printf '\n' | run_isolated_bash '
            set -euo pipefail
            source "$1"
            source "$2"
            choice=""
            choose_from_menu "Prompt" choice "primeira" "segunda"
            printf "choice=%s" "$choice"
        ' "$COLORS_FILE" "$MENU_FILE" 2>&1); then
        status=0
    else
        status=$?
    fi

    assert_eq 0 "$status" "choose_from_menu deve aceitar Enter"
    assert_contains "$output" "Prompt" "menu deve exibir o prompt"
    assert_contains "$output" "choice=primeira" "Enter deve selecionar a primeira opção"
}

main() {
    setup_test_env
    trap cleanup_test_env EXIT

    run_test_case "colors.sh sem side effects na carga" test_colors_source_without_output
    run_test_case "colors.sh define variáveis e funções" test_colors_define_variables_and_functions
    run_test_case "helpers.sh sem side effects na carga" test_helpers_source_without_output
    run_test_case "detect_pkg_manager: apt-get -> apt" test_detect_apt
    run_test_case "detect_pkg_manager: dnf -> dnf" test_detect_dnf
    run_test_case "detect_pkg_manager: yum -> yum" test_detect_yum
    run_test_case "detect_pkg_manager: pacman -> pacman" test_detect_pacman
    run_test_case "detect_pkg_manager: zypper -> zypper" test_detect_zypper
    run_test_case "detect_pkg_manager: apk -> apk" test_detect_apk
    run_test_case "detect_pkg_manager: desconhecido" test_detect_unknown
    run_test_case "detect_pkg_manager: precedência atual" test_detect_precedence
    run_test_case "pkg_install sem argumentos é no-op" test_pkg_install_without_args_is_noop
    run_test_case "show_invalid_command_prime" test_invalid_command_help_output
    run_test_case "check_dependencies ignora dependência instalada" test_check_dependencies_skips_installed
    run_test_case "check_dependencies instala dependência ausente" test_check_dependencies_installs_missing
    run_test_case "show_spinner encerra com processo finalizado" test_show_spinner_with_finished_process
    run_test_case "choose_from_menu seleciona com Enter" test_choose_from_menu_enter_selects_first

    show_test_summary
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
