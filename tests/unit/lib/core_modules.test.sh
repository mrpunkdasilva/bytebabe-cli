#!/bin/bash

# Testes dos módulos canônicos de lib/core/.
# Não executa sudo, rede ou Docker; operações de pacote são exercitadas apenas
# em ramos seguros (sem argumentos/gerenciador desconhecido) ou com overrides.

set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/test_helpers.sh
source "$TEST_DIR/../../lib/test_helpers.sh"

COLORS_FILE="$BASE_DIR/lib/core/colors.sh"
HELPERS_FILE="$BASE_DIR/lib/core/helpers.sh"
PATHS_FILE="$BASE_DIR/lib/core/paths.sh"
PKG_FILE="$BASE_DIR/lib/core/pkg.sh"
FEEDBACK_FILE="$BASE_DIR/lib/core/feedback.sh"
MENU_FILE="$BASE_DIR/lib/core/menu.sh"
UI_FILE="$BASE_DIR/lib/core/ui.sh"
HEADERS_FILE="$BASE_DIR/lib/utils/headers.sh"

run_isolated_bash() {
    local script="$1"
    shift
    /bin/bash --noprofile --norc -c "$script" _ "$@"
}

test_core_modules_source_without_output() {
    local file output status
    for file in "$PATHS_FILE" "$PKG_FILE" "$FEEDBACK_FILE" "$MENU_FILE" "$UI_FILE"; do
        if output=$(run_isolated_bash 'source "$1"' "$file" 2>&1); then
            status=0
        else
            status=$?
        fi
        assert_eq 0 "$status" "$(basename "$file") deve carregar sem erro"
        assert_eq "" "$output" "$(basename "$file") não deve produzir saída"
    done
}

test_colors_exposes_bold_compat_alias() {
    local bold cyber_bold
    bold=$(run_isolated_bash 'source "$1"; printf "%s" "$BOLD"' "$COLORS_FILE")
    cyber_bold=$(run_isolated_bash 'source "$1"; printf "%s" "$CYBER_BOLD"' "$COLORS_FILE")

    assert_eq "$cyber_bold" "$bold" "BOLD deve espelhar CYBER_BOLD"
}

test_colors_defines_legacy_palette() {
    local output
    output=$(run_isolated_bash '
        set -euo pipefail
        source "$1"
        for color in CYBER_CYAN CYBER_MAGENTA CYBER_WHITE; do
            [[ -n "${!color}" ]] || exit 1
        done
        printf "ok"
    ' "$COLORS_FILE")

    assert_eq "ok" "$output" "colors.sh deve definir CYBER_CYAN, CYBER_MAGENTA e CYBER_WHITE"
}

test_helpers_derives_base_dir_when_unset() {
    local expected output
    expected="$(cd -P "$BASE_DIR" && pwd)"
    output=$(run_isolated_bash '
        set -euo pipefail
        unset BASE_DIR
        source "$1"
        printf "%s" "$BASE_DIR"
    ' "$HELPERS_FILE")

    assert_eq "$expected" "$output" "helpers.sh deve derivar BASE_DIR quando vazio"
}

test_helpers_preserves_base_dir_and_is_idempotent() {
    local output
    output=$(run_isolated_bash '
        set -euo pipefail
        BASE_DIR="/tmp/bytebabe-custom-base"
        source "$1"
        source "$1"
        printf "%s" "$BASE_DIR"
    ' "$HELPERS_FILE")

    assert_eq "/tmp/bytebabe-custom-base" "$output" \
        "helpers.sh não deve sobrescrever BASE_DIR nem duplicar saída"
}

test_paths_resolve_symlink_chain() {
    local root="$TEST_TMP_DIR/paths-symlink"
    mkdir -p "$root/real" "$root/links"
    printf '#!/bin/bash\n' > "$root/real/target.sh"
    ln -s ../real/target.sh "$root/links/first.sh"
    ln -s first.sh "$root/links/second.sh"

    local expected actual
    expected="$(cd -P "$root/real" && pwd)/target.sh"
    actual=$(run_isolated_bash '
        set -euo pipefail
        source "$1"
        bytebabe_resolve_symlink "$2"
    ' "$PATHS_FILE" "$root/links/second.sh")

    assert_eq "$expected" "$actual" "deve resolver a cadeia completa de symlinks"
}

test_paths_script_dir_resolves_symlink() {
    local root="$TEST_TMP_DIR/paths-script"
    mkdir -p "$root/real" "$root/bin"
    printf '#!/bin/bash\n' > "$root/real/script.sh"
    ln -s ../real/script.sh "$root/bin/link.sh"

    local expected actual
    expected="$(cd -P "$root/real" && pwd)"
    actual=$(run_isolated_bash '
        set -euo pipefail
        source "$1"
        bytebabe_script_dir "$2"
    ' "$PATHS_FILE" "$root/bin/link.sh")

    assert_eq "$expected" "$actual" "script_dir deve retornar o diretório real do script"
}

test_paths_entrypoint_base_dir() {
    local root="$TEST_TMP_DIR/paths-entrypoint"
    mkdir -p "$root/project/bin"
    printf '#!/bin/bash\n' > "$root/project/bin/bytebabe"

    local expected actual
    expected="$(cd -P "$root/project" && pwd)"
    actual=$(run_isolated_bash '
        set -euo pipefail
        source "$1"
        bytebabe_entrypoint_base_dir "$2"
    ' "$PATHS_FILE" "$root/project/bin/bytebabe")

    assert_eq "$expected" "$actual" "entrypoint_base_dir deve subir um nível a partir de bin/"
}

test_paths_do_not_depend_on_cwd() {
    local root="$TEST_TMP_DIR/paths-cwd"
    mkdir -p "$root/real" "$root/bin"
    printf '#!/bin/bash\n' > "$root/real/script.sh"
    ln -s ../real/script.sh "$root/bin/link.sh"

    local from_root from_tmp
    from_root=$(run_isolated_bash '
        set -euo pipefail
        cd /
        source "$1"
        bytebabe_script_dir "$2"
    ' "$PATHS_FILE" "$root/bin/link.sh")
    from_tmp=$(run_isolated_bash '
        set -euo pipefail
        cd "$3"
        source "$1"
        bytebabe_script_dir "$2"
    ' "$PATHS_FILE" "$root/bin/link.sh" "$TEST_TMP_DIR")

    assert_eq "$from_root" "$from_tmp" "resolução não deve variar com o diretório atual"
}

detect_with_stub() {
    local manager="$1"
    local dir="$TEST_TMP_DIR/stubs/detect-$manager"
    stub_command "$manager" "" 0 "$dir" >/dev/null

    PATH="$dir" run_isolated_bash '
        set -euo pipefail
        source "$1"
        detect_pkg_manager
    ' "$PKG_FILE"
}

test_detect_apt_command_fallback() {
    assert_eq "apt" "$(detect_with_stub apt)" "apt deve ser reconhecido como apt"
}

test_detect_brew() {
    assert_eq "brew" "$(detect_with_stub brew)" "brew deve ser reconhecido"
}

test_detect_precedence() {
    local dir="$TEST_TMP_DIR/stubs/detect-precedence-pkg"
    stub_command brew "" 0 "$dir" >/dev/null
    stub_command dnf "" 0 "$dir" >/dev/null
    stub_command apt "" 0 "$dir" >/dev/null
    stub_command apt-get "" 0 "$dir" >/dev/null

    local result
    result=$(PATH="$dir" run_isolated_bash '
        set -euo pipefail
        source "$1"
        detect_pkg_manager
    ' "$PKG_FILE")

    assert_eq "apt" "$result" "apt-get deve ter precedência na ordem canônica"
}

test_detect_unknown() {
    local dir="$TEST_TMP_DIR/stubs/detect-unknown-pkg"
    mkdir -p "$dir"

    local result
    result=$(PATH="$dir" run_isolated_bash '
        set -euo pipefail
        source "$1"
        detect_pkg_manager
    ' "$PKG_FILE")

    assert_eq "unknown" "$result" "sem gerenciadores no PATH deve retornar unknown"
}

test_pkg_install_without_args_is_noop() {
    local dir="$TEST_TMP_DIR/stubs/pkg-install-empty"
    mkdir -p "$dir"

    assert_success "pkg_install sem argumentos deve retornar 0 sem efeitos" \
        env PATH="$dir" /bin/bash --noprofile --norc -c 'source "$1"; pkg_install' _ "$PKG_FILE"
}

test_pkg_install_unknown_manager_does_not_use_sudo() {
    local dir="$TEST_TMP_DIR/stubs/pkg-install-unknown"
    mkdir -p "$dir"
    stub_command sudo "SUDO_WAS_CALLED" 0 "$dir" >/dev/null

    local output status
    if output=$(PATH="$dir" run_isolated_bash '
        source "$1"
        pkg_install pacote_inexistente
    ' "$PKG_FILE" 2>&1); then
        status=0
    else
        status=$?
    fi

    assert_eq 1 "$status" "gerenciador desconhecido deve retornar 1"
    assert_contains "$output" "não suportado" "deve informar gerenciador não suportado"
    assert_not_contains "$output" "SUDO_WAS_CALLED" "não deve chamar sudo sem gerenciador"
}

test_pkg_install_brew_does_not_use_sudo() {
    local dir="$TEST_TMP_DIR/stubs/pkg-install-brew"
    stub_command brew "" 0 "$dir" >/dev/null
    stub_command sudo "SUDO_WAS_CALLED" 0 "$dir" >/dev/null

    local output
    output=$(PATH="$dir" run_isolated_bash '
        source "$1"
        pkg_install pacote_teste
    ' "$PKG_FILE" 2>&1)

    assert_not_contains "$output" "SUDO_WAS_CALLED" \
        "brew não deve ser executado via sudo"
}

test_check_dependencies_skips_installed() {
    assert_success "dependência já instalada não deve chamar install_pkg" \
        run_isolated_bash '
            set -euo pipefail
            source "$1"
            install_pkg() { return 99; }
            check_dependencies bash
        ' "$PKG_FILE"
}

test_check_dependencies_delegates_missing() {
    local output
    output=$(run_isolated_bash '
        set -euo pipefail
        source "$1"
        install_pkg() { printf "install:%s" "$1"; }
        check_dependencies comando_inexistente_bytebabe
    ' "$PKG_FILE")

    assert_eq "install:comando_inexistente_bytebabe" "$output" \
        "dependência ausente deve ser delegada a install_pkg"
}

test_show_spinner_finished_pid() {
    local output status
    if output=$(run_isolated_bash '
        set -euo pipefail
        source "$1"
        sleep 0.01 &
        child_pid=$!
        wait "$child_pid"
        show_spinner "$child_pid" "carregando"
    ' "$FEEDBACK_FILE" 2>&1); then
        status=0
    else
        status=$?
    fi

    assert_eq 0 "$status" "show_spinner deve retornar quando o processo já terminou"
    assert_contains "$output" "carregando" "show_spinner deve exibir a mensagem"
    assert_contains "$output" "✔" "show_spinner deve exibir conclusão"
}

test_show_spinner_message_only() {
    local output status
    if output=$(run_isolated_bash '
        set -euo pipefail
        source "$1"
        show_spinner "mensagem sem pid"
    ' "$FEEDBACK_FILE" 2>&1); then
        status=0
    else
        status=$?
    fi

    assert_eq 0 "$status" "show_spinner com apenas mensagem deve retornar 0"
    assert_contains "$output" "mensagem sem pid" "show_spinner deve imprimir a mensagem"
}

test_show_loading_finished_pid() {
    local output status
    if output=$(run_isolated_bash '
        set -euo pipefail
        source "$1"
        sleep 0.01 &
        child_pid=$!
        wait "$child_pid"
        show_loading "$child_pid" "carregando dados"
    ' "$FEEDBACK_FILE" 2>&1); then
        status=0
    else
        status=$?
    fi

    assert_eq 0 "$status" "show_loading deve retornar quando o processo já terminou"
    assert_contains "$output" "carregando dados" "show_loading deve exibir a mensagem"
}

test_show_loading_message_only() {
    local output status
    if output=$(run_isolated_bash '
        set -euo pipefail
        source "$1"
        show_loading "aguarde"
    ' "$FEEDBACK_FILE" 2>&1); then
        status=0
    else
        status=$?
    fi

    assert_eq 0 "$status" "show_loading com apenas mensagem deve retornar 0"
    assert_contains "$output" "aguarde" "show_loading deve imprimir a mensagem"
    assert_contains "$output" "..." "show_loading deve imprimir reticências"
}

test_choose_from_menu_enter_selects_first() {
    local output status
    if output=$(printf '\n' | run_isolated_bash '
        set -euo pipefail
        source "$1"
        choice=""
        choose_from_menu "Prompt" choice "primeira" "segunda"
        printf "choice=%s" "$choice"
    ' "$MENU_FILE" 2>&1); then
        status=0
    else
        status=$?
    fi

    assert_eq 0 "$status" "choose_from_menu deve aceitar Enter"
    assert_contains "$output" "Prompt" "menu deve exibir o prompt"
    assert_contains "$output" "choice=primeira" "Enter deve selecionar a primeira opção"
}

test_choose_from_menu_q_cancels() {
    local output
    output=$(printf 'q' | run_isolated_bash '
        set -euo pipefail
        source "$1"
        choice=""
        if choose_from_menu "Prompt" choice "primeira" "segunda"; then
            rc=0
        else
            rc=$?
        fi
        printf "rc=%s" "$rc"
    ' "$MENU_FILE" 2>&1)

    assert_contains "$output" "rc=1" "q deve cancelar com retorno 1"
}

test_choose_from_menu_without_options() {
    local output
    output=$(run_isolated_bash '
        set -euo pipefail
        source "$1"
        choice=""
        if choose_from_menu "Prompt" choice; then
            rc=0
        else
            rc=$?
        fi
        printf "rc=%s" "$rc"
    ' "$MENU_FILE" 2>&1)

    assert_contains "$output" "Nenhuma opção disponível" "deve informar ausência de opções"
    assert_contains "$output" "rc=1" "lista vazia deve retornar 1"
}

test_headers_shim_sources_ui_without_output() {
    local output status
    if output=$(run_isolated_bash 'source "$1"' "$HEADERS_FILE" 2>&1); then
        status=0
    else
        status=$?
    fi

    assert_eq 0 "$status" "headers.sh deve carregar sem erro"
    assert_eq "" "$output" "headers.sh não deve produzir saída ao ser carregado"
}

test_headers_shim_exposes_canonical_functions() {
    local output
    output=$(run_isolated_bash '
        set -euo pipefail
        source "$1"
        declare -F show_cyberpunk_header >/dev/null
        declare -F show_cyberpunk_banner >/dev/null
        declare -F show_section_header >/dev/null
        declare -F show_header_custom >/dev/null
        show_cyberpunk_header
    ' "$HEADERS_FILE" 2>&1)

    assert_contains "$output" "BYTEBABE CLI" "header simples deve identificar a CLI"
    assert_not_contains "$output" "888888b" "header simples não deve usar o banner ASCII"
}

main() {
    setup_test_env
    trap cleanup_test_env EXIT

    run_test_case "módulos de core carregam sem saída" test_core_modules_source_without_output
    run_test_case "colors.sh expõe alias BOLD" test_colors_exposes_bold_compat_alias
    run_test_case "colors.sh expõe paleta legada" test_colors_defines_legacy_palette
    run_test_case "helpers.sh deriva BASE_DIR quando vazio" test_helpers_derives_base_dir_when_unset
    run_test_case "helpers.sh preserva BASE_DIR e é idempotente" test_helpers_preserves_base_dir_and_is_idempotent
    run_test_case "paths.sh resolve cadeia de symlinks" test_paths_resolve_symlink_chain
    run_test_case "paths.sh resolve diretório de script" test_paths_script_dir_resolves_symlink
    run_test_case "paths.sh deriva raiz do entrypoint" test_paths_entrypoint_base_dir
    run_test_case "paths.sh não depende do cwd" test_paths_do_not_depend_on_cwd
    run_test_case "detect_pkg_manager reconhece apt" test_detect_apt_command_fallback
    run_test_case "detect_pkg_manager reconhece brew" test_detect_brew
    run_test_case "detect_pkg_manager mantém precedência" test_detect_precedence
    run_test_case "detect_pkg_manager retorna unknown" test_detect_unknown
    run_test_case "pkg_install sem argumentos é no-op" test_pkg_install_without_args_is_noop
    run_test_case "pkg_install desconhecido não usa sudo" test_pkg_install_unknown_manager_does_not_use_sudo
    run_test_case "pkg_install com brew não usa sudo" test_pkg_install_brew_does_not_use_sudo
    run_test_case "check_dependencies ignora instalada" test_check_dependencies_skips_installed
    run_test_case "check_dependencies delega ausente" test_check_dependencies_delegates_missing
    run_test_case "show_spinner encerra com pid finalizado" test_show_spinner_finished_pid
    run_test_case "show_spinner aceita apenas mensagem" test_show_spinner_message_only
    run_test_case "show_loading encerra com pid finalizado" test_show_loading_finished_pid
    run_test_case "show_loading aceita apenas mensagem" test_show_loading_message_only
    run_test_case "choose_from_menu seleciona com Enter" test_choose_from_menu_enter_selects_first
    run_test_case "choose_from_menu cancela com q" test_choose_from_menu_q_cancels
    run_test_case "choose_from_menu sem opções retorna 1" test_choose_from_menu_without_options
    run_test_case "headers.sh carrega sem saída" test_headers_shim_sources_ui_without_output
    run_test_case "headers.sh expõe funções canônicas" test_headers_shim_exposes_canonical_functions

    show_test_summary
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
