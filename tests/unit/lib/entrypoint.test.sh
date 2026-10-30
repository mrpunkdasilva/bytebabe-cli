#!/bin/bash

# Testes de caracterização do entrypoint bin/bytebabe.
# Não executa comandos que usam sudo, rede, Docker, Flatpak ou alteram o sistema.

set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/test_helpers.sh
source "$TEST_DIR/../../lib/test_helpers.sh"

BYTEBABE_BIN="$BASE_DIR/bin/bytebabe"

test_entrypoint_is_executable() {
    assert_success "bin/bytebabe deve existir e ser executável" test -x "$BYTEBABE_BIN"
}

test_version_shows_essential_content() {
    local output status
    if output=$(timeout 20 "$BYTEBABE_BIN" --version 2>&1); then
        status=0
    else
        status=$?
    fi

    assert_eq 0 "$status" "--version deve retornar código 0"
    assert_contains "$output" "BYTEBABE CLI" "--version deve exibir o nome da CLI"
    assert_matches "$output" 'v[0-9]+\.[0-9]+\.[0-9]+' "--version deve exibir versão semver"
    assert_contains "$output" "System:" "--version deve exibir informações do sistema"
    assert_contains "$output" "Shell:" "--version deve exibir o shell"
    assert_contains "$output" "Uptime:" "--version deve exibir o uptime"
}

test_help_shows_essential_content() {
    local output status
    if output=$(timeout 20 "$BYTEBABE_BIN" help 2>&1); then
        status=0
    else
        status=$?
    fi

    assert_eq 0 "$status" "help deve retornar código 0"
    assert_contains "$output" "BYTEBABE CLI" "help deve exibir o header"
    assert_contains "$output" "CORE COMMANDS:" "help deve listar comandos principais"
    assert_contains "$output" "hello" "help deve listar o comando hello"
    assert_contains "$output" "init" "help deve listar o comando init"
    assert_contains "$output" "SYSTEM:" "help deve listar a seção de sistema"
}

test_help_flag_shows_essential_content() {
    local output status
    if output=$(timeout 20 "$BYTEBABE_BIN" --help 2>&1); then
        status=0
    else
        status=$?
    fi

    assert_eq 0 "$status" "--help deve retornar código 0"
    assert_contains "$output" "CORE COMMANDS:" "--help deve listar comandos principais"
    assert_contains "$output" "flux" "--help deve listar o comando flux"
}

test_unknown_command_falls_back_to_help() {
    local output status
    if output=$(timeout 20 "$BYTEBABE_BIN" bytebabe_comando_que_nao_existe 2>&1); then
        status=0
    else
        status=$?
    fi

    # Comportamento atual: o entrypoint cai no help e retorna 0 (não falha).
    assert_eq 0 "$status" "comando desconhecido não deve travar nem falhar hoje"
    assert_contains "$output" "CORE COMMANDS:" "comando desconhecido deve exibir o help"
    assert_contains "$output" "hello" "comando desconhecido deve exibir comandos disponíveis"
}

test_source_guards_exist() {
    local relative file
    local commands=(
        commands/backend/main.sh
        commands/backend/spring/main.sh
        commands/byteedit/main.sh
        commands/db/main.sh
        commands/devtools/main.sh
        commands/docker/main.sh
        commands/flux/main.sh
        commands/frontend/main.sh
        commands/gh/main.sh
        commands/git/main.sh
        commands/hello/main.sh
        commands/ide/main.sh
        commands/init/main.sh
        commands/json-server/main.sh
        commands/prime/main.sh
        commands/servers/main.sh
    )

    for relative in "${commands[@]}"; do
        file="$BASE_DIR/$relative"
        assert_success "$relative deve ter guarda de source" \
            grep -F -q 'if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then' "$file"
    done
}

test_command_modules_expose_main() {
    local relative file
    local commands=(
        commands/backend/main.sh
        commands/backend/spring/main.sh
        commands/byteedit/main.sh
        commands/db/main.sh
        commands/devtools/main.sh
        commands/docker/main.sh
        commands/flux/main.sh
        commands/frontend/main.sh
        commands/gh/main.sh
        commands/git/main.sh
        commands/hello/main.sh
        commands/ide/main.sh
        commands/init/main.sh
        commands/json-server/main.sh
        commands/prime/main.sh
        commands/servers/main.sh
    )

    for relative in "${commands[@]}"; do
        file="$BASE_DIR/$relative"
        assert_success "$relative deve expor main()" \
            grep -qE '^main\(\)' "$file"
    done
}

test_dispatch_does_not_pass_args_to_source() {
    assert_success "bin deve usar run_command" \
        grep -q 'run_command()' "$BYTEBABE_BIN"
    assert_success "bin não deve passar argumentos ao source" \
        bash -c '! grep -qE "source .*\"\$\{@:" "$1"' _ "$BYTEBABE_BIN"
    assert_success "bin deve chamar o entrypoint main" \
        grep -q 'run_command .* main ' "$BYTEBABE_BIN"
}

test_commands_source_without_side_effects() {
    local relative file output status
    local commands=(
        commands/backend/main.sh
        commands/backend/spring/main.sh
        commands/byteedit/main.sh
        commands/db/main.sh
        commands/devtools/main.sh
        commands/docker/main.sh
        commands/flux/main.sh
        commands/frontend/main.sh
        commands/gh/main.sh
        commands/git/main.sh
        commands/hello/main.sh
        commands/ide/main.sh
        commands/init/main.sh
        commands/json-server/main.sh
        commands/prime/main.sh
        commands/servers/main.sh
    )

    for relative in "${commands[@]}"; do
        file="$BASE_DIR/$relative"
        if output=$(timeout 5 /bin/bash --noprofile --norc -c 'source "$1"' _ "$file" 2>&1); then
            status=0
        else
            status=$?
        fi

        assert_eq 0 "$status" "$relative deve carregar sem erro"
        assert_eq "" "$output" "$relative não deve produzir efeitos no source"
    done
}

test_git_does_not_start_at_source_time() {
    local git_main="$BASE_DIR/commands/git/main.sh"

    assert_success "git/main.sh não deve chamar main_navigation no topo" \
        bash -c '! grep -qE "^main_navigation$" "$1"' _ "$git_main"
    assert_success "git/main.sh não deve chamar setup_repository no topo" \
        bash -c '! grep -qE "^setup_repository$" "$1"' _ "$git_main"
}

test_hello_dispatches_via_main() {
    local output status
    if output=$(timeout 20 "$BYTEBABE_BIN" hello 2>&1); then
        status=0
    else
        status=$?
    fi

    assert_eq 0 "$status" "hello deve executar via dispatch main"
    assert_contains "$output" "BYTEBABE SAYS HI" "hello deve exibir seu header"
}

main() {
    setup_test_env
    trap cleanup_test_env EXIT

    run_test_case "entrypoint executável" test_entrypoint_is_executable
    run_test_case "--version informa versão e ambiente" test_version_shows_essential_content
    run_test_case "help exibe conteúdo essencial" test_help_shows_essential_content
    run_test_case "--help exibe conteúdo essencial" test_help_flag_shows_essential_content
    run_test_case "comando desconhecido cai no help" test_unknown_command_falls_back_to_help
    run_test_case "comandos possuem guarda de source" test_source_guards_exist
    run_test_case "comandos expõem main()" test_command_modules_expose_main
    run_test_case "dispatch não passa argumentos ao source" test_dispatch_does_not_pass_args_to_source
    run_test_case "comandos carregam sem efeitos colaterais" test_commands_source_without_side_effects
    run_test_case "git não inicia no carregamento" test_git_does_not_start_at_source_time
    run_test_case "hello executa via main" test_hello_dispatches_via_main

    show_test_summary
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
