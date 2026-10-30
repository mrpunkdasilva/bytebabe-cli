#!/bin/bash

# Testes de contrato e dispatch não interativo dos módulos Docker.
# Usa stubs de docker/sudo/jq/less; não requer Docker real, rede ou sudo.

set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/test_helpers.sh
source "$TEST_DIR/../../lib/test_helpers.sh"

DOCKER_COMMAND="$BASE_DIR/commands/docker/main.sh"
DOCKER_HELPERS="$BASE_DIR/lib/docker/helpers.sh"
DOCKER_UI="$BASE_DIR/lib/docker/ui.sh"
DOCKER_CONTAINERS="$BASE_DIR/lib/docker/containers.sh"
DOCKER_IMAGES="$BASE_DIR/lib/docker/images.sh"
DOCKER_COMPOSE="$BASE_DIR/lib/docker/compose.sh"

run_isolated_bash() {
    local script="$1"
    shift
    /bin/bash --noprofile --norc -c "$script" _ "$@"
}

create_docker_stubs() {
    mkdir -p "$TEST_STUB_DIR"

    cat > "$TEST_STUB_DIR/docker" <<'SCRIPT'
#!/bin/bash
printf 'docker %s\n' "$*" >> "${DOCKER_LOG:?}"
if [[ "${1:-}" == "ps" ]]; then
    if [[ "${FAKE_DOCKER_NEEDS_SUDO:-0}" == "1" && "${FAKE_DOCKER_ROOT:-0}" != "1" ]]; then
        exit 1
    fi
    echo "web (Up 2 minutes) nginx:latest"
    exit 0
fi
if [[ "${1:-}" == "compose" && "${2:-}" == "version" ]]; then
    [[ "${FAKE_COMPOSE_MISSING:-0}" == "1" ]] && exit 1
    echo "Docker Compose version v2.0.0"
    exit 0
fi
exit 0
SCRIPT

    cat > "$TEST_STUB_DIR/sudo" <<'SCRIPT'
#!/bin/bash
printf 'sudo %s\n' "$*" >> "${DOCKER_LOG:?}"
if [[ "${1:-}" == "docker" ]]; then
    export FAKE_DOCKER_ROOT=1
fi
exec "$@"
SCRIPT

    cat > "$TEST_STUB_DIR/jq" <<'SCRIPT'
#!/bin/bash
cat
SCRIPT

    cat > "$TEST_STUB_DIR/less" <<'SCRIPT'
#!/bin/bash
cat
SCRIPT

    chmod +x "$TEST_STUB_DIR/docker" "$TEST_STUB_DIR/sudo" "$TEST_STUB_DIR/jq" "$TEST_STUB_DIR/less"
}

test_docker_config_without_sudo() {
    local output
    output=$(run_isolated_bash '
        set -euo pipefail
        export DOCKER_LOG="$3"
        source "$1/lib/docker/helpers.sh"
        configure_docker >/dev/null
        printf "%s\n" "$cmd_docker"
    ' "$BASE_DIR" "" "$TEST_TMP_DIR/docker.log" 2>&1)

    assert_eq "docker" "$output" "configure_docker deve usar docker sem sudo"
    assert_contains "$(cat "$TEST_TMP_DIR/docker.log")" "docker ps" \
        "configure_docker deve validar docker ps"
}

test_docker_config_with_sudo() {
    local output log
    output=$(run_isolated_bash '
        set -euo pipefail
        export DOCKER_LOG="$3"
        export FAKE_DOCKER_NEEDS_SUDO=1
        source "$1/lib/docker/helpers.sh"
        configure_docker >/dev/null
        printf "%s\n" "$cmd_docker"
    ' "$BASE_DIR" "" "$TEST_TMP_DIR/docker-sudo.log" 2>&1)

    assert_eq "sudo docker" "$output" "configure_docker deve usar sudo docker quando necessário"
    log=$(cat "$TEST_TMP_DIR/docker-sudo.log")
    assert_contains "$log" "docker ps" "deve tentar docker ps sem sudo"
    assert_contains "$log" "sudo docker ps" "deve tentar sudo docker ps"
}

test_docker_config_without_docker() {
    local output status
    if output=$(run_isolated_bash '
        export DOCKER_LOG="$3"
        export DOCKER_BIN=bytebabe-missing-docker
        source "$1/lib/docker/helpers.sh"
        configure_docker
    ' "$BASE_DIR" "" "$TEST_TMP_DIR/missing.log" 2>&1); then
        status=0
    else
        status=$?
    fi

    assert_eq 1 "$status" "configure_docker deve retornar 1 sem Docker"
    assert_contains "$output" "Docker não instalado" "deve orientar a instalação"
}

test_docker_help_does_not_require_docker() {
    local output status
    if output=$(run_isolated_bash '
        export DOCKER_BIN=/nonexistent-docker
        timeout 15 "$1/bin/bytebabe" docker help
    ' "$BASE_DIR" 2>&1); then
        status=0
    else
        status=$?
    fi

    assert_eq 0 "$status" "docker help deve funcionar sem Docker"
    assert_contains "$output" "TRIDENTE DE COMANDOS" "docker help deve exibir a ajuda"
}

test_docker_subcommand_help_without_docker() {
    local specification status args output
    local cases=("containers help" "images --help" "compose help" "volumes help")

    for specification in "${cases[@]}"; do
        read -r -a args <<< "$specification"
        if output=$(run_isolated_bash '
            export DOCKER_BIN=/nonexistent-docker
            timeout 15 "$1/bin/bytebabe" docker "${@:2}"
        ' "$BASE_DIR" "${args[@]}" 2>&1); then
            status=0
        else
            status=$?
        fi

        assert_eq 0 "$status" "docker $specification deve funcionar sem Docker"
        assert_contains "$output" "bytebabe docker" "docker $specification deve exibir ajuda"
    done
}

test_container_list_non_interactive() {
    local output log
    output=$(run_isolated_bash '
        set -euo pipefail
        export DOCKER_LOG="$3"
        export PATH="$2"
        source "$1/commands/docker/main.sh"
        configure_docker >/dev/null
        container_commander ls -a
    ' "$BASE_DIR" "$TEST_STUB_DIR" "$TEST_TMP_DIR/docker-list.log" 2>&1)

    assert_contains "$output" "web (Up 2 minutes)" "list deve exibir a saída do docker"
    log=$(cat "$TEST_TMP_DIR/docker-list.log")
    assert_contains "$log" "docker ps -a --format" "list -a deve usar docker ps -a"
}

test_container_running_non_interactive() {
    local log
    run_isolated_bash '
        set -euo pipefail
        export DOCKER_LOG="$3"
        export PATH="$2"
        source "$1/commands/docker/main.sh"
        configure_docker >/dev/null
        container_commander running
    ' "$BASE_DIR" "$TEST_STUB_DIR" "$TEST_TMP_DIR/docker-running.log" >/dev/null 2>&1

    log=$(cat "$TEST_TMP_DIR/docker-running.log")
    assert_contains "$log" "docker ps --format" "running deve usar docker ps"
    assert_not_contains "$log" "docker ps -a" "running não deve usar -a"
}

test_container_action_non_interactive() {
    local log
    run_isolated_bash '
        set -euo pipefail
        export DOCKER_LOG="$3"
        export PATH="$2"
        source "$1/commands/docker/main.sh"
        configure_docker >/dev/null
        container_commander stop web
    ' "$BASE_DIR" "$TEST_STUB_DIR" "$TEST_TMP_DIR/docker-stop.log" >/dev/null 2>&1

    log=$(cat "$TEST_TMP_DIR/docker-stop.log")
    assert_contains "$log" "docker stop web" "stop deve repassar o container"
}

test_container_invalid_action_returns_one() {
    local status
    if run_isolated_bash '
        export DOCKER_LOG="$3"
        export PATH="$2"
        source "$1/commands/docker/main.sh"
        configure_docker >/dev/null
        container_commander acao_invalida
    ' "$BASE_DIR" "$TEST_STUB_DIR" "$TEST_TMP_DIR/docker-invalid.log" >/dev/null 2>&1; then
        status=0
    else
        status=$?
    fi

    assert_eq 1 "$status" "ação inválida de container deve retornar 1"
}

test_compose_help_does_not_require_compose() {
    local output status
    if output=$(run_isolated_bash '
        set -euo pipefail
        source "$1/commands/docker/main.sh"
        handle_compose_command help
    ' "$BASE_DIR" 2>&1); then
        status=0
    else
        status=$?
    fi

    assert_eq 0 "$status" "compose help deve funcionar sem Docker Compose"
    assert_contains "$output" "Docker Compose Manager" "compose help deve exibir ajuda"
}

test_compose_dispatch_non_interactive() {
    local log
    run_isolated_bash '
        set -euo pipefail
        export DOCKER_LOG="$3"
        export PATH="$2"
        source "$1/commands/docker/main.sh"
        configure_docker >/dev/null
        handle_compose_command up -d
    ' "$BASE_DIR" "$TEST_STUB_DIR" "$TEST_TMP_DIR/docker-compose.log" >/dev/null 2>&1

    log=$(cat "$TEST_TMP_DIR/docker-compose.log")
    assert_contains "$log" "docker compose version" "deve validar o plugin compose"
    assert_contains "$log" "docker compose up -d" "deve repassar up -d ao compose"
}

test_compose_missing_returns_one() {
    local status
    if run_isolated_bash '
        export DOCKER_LOG="$3"
        export PATH="$2"
        export FAKE_COMPOSE_MISSING=1
        source "$1/commands/docker/main.sh"
        configure_docker >/dev/null
        handle_compose_command up
    ' "$BASE_DIR" "$TEST_STUB_DIR" "$TEST_TMP_DIR/docker-no-compose.log" >/dev/null 2>&1; then
        status=0
    else
        status=$?
    fi

    assert_eq 1 "$status" "compose ausente deve retornar 1"
}

test_volume_list_non_interactive() {
    local log
    run_isolated_bash '
        set -euo pipefail
        export DOCKER_LOG="$3"
        export PATH="$2"
        source "$1/commands/docker/main.sh"
        configure_docker >/dev/null
        volume_commander list
    ' "$BASE_DIR" "$TEST_STUB_DIR" "$TEST_TMP_DIR/docker-volume-list.log" >/dev/null 2>&1

    log=$(cat "$TEST_TMP_DIR/docker-volume-list.log")
    assert_contains "$log" "docker volume ls" "volumes list deve usar docker volume ls"
}

test_volume_lifecycle_non_interactive() {
    local log
    run_isolated_bash '
        set -euo pipefail
        export DOCKER_LOG="$3"
        export PATH="$2"
        source "$1/commands/docker/main.sh"
        configure_docker >/dev/null
        volume_commander create data
        volume_commander rm data -f
        volume_commander prune -f
    ' "$BASE_DIR" "$TEST_STUB_DIR" "$TEST_TMP_DIR/docker-volume.log" >/dev/null 2>&1

    log=$(cat "$TEST_TMP_DIR/docker-volume.log")
    assert_contains "$log" "docker volume create data" "create deve criar o volume"
    assert_contains "$log" "docker volume rm data" "rm -f deve remover o volume"
    assert_contains "$log" "docker volume prune --force" "prune -f deve limpar volumes"
}

test_volume_invalid_name_returns_one() {
    local status
    if run_isolated_bash '
        export DOCKER_LOG="$3"
        export PATH="$2"
        source "$1/commands/docker/main.sh"
        configure_docker >/dev/null
        volume_commander create "nome invalido"
    ' "$BASE_DIR" "$TEST_STUB_DIR" "$TEST_TMP_DIR/docker-volume-invalid.log" >/dev/null 2>&1; then
        status=0
    else
        status=$?
    fi

    assert_eq 1 "$status" "nome de volume inválido deve retornar 1"
}

test_docker_libs_do_not_exit() {
    local definitions
    definitions=$(grep -nE '^[[:space:]]*exit([[:space:]]|$)' \
        "$DOCKER_HELPERS" "$DOCKER_UI" "$DOCKER_CONTAINERS" "$DOCKER_IMAGES" "$DOCKER_COMPOSE" || true)

    assert_eq "" "$definitions" "libs Docker não devem chamar exit"
}

test_docker_libs_do_not_use_eval() {
    local uses
    uses=$(grep -RInE '(^|[;&|[:space:]])eval([[:space:]]|$)' "$BASE_DIR/lib/docker" || true)

    assert_eq "" "$uses" "libs Docker não devem montar comandos com eval"
}

test_run_image_builds_arguments_without_eval() {
    local log
    run_isolated_bash '
        set -euo pipefail
        export DOCKER_LOG="$3"
        export PATH="$2"
        source "$1/commands/docker/main.sh"
        configure_docker >/dev/null
        printf "web-check\n8080:80\n\n" | run_image nginx
    ' "$BASE_DIR" "$TEST_STUB_DIR" "$TEST_TMP_DIR/docker-run.log" >/dev/null 2>&1

    log=$(cat "$TEST_TMP_DIR/docker-run.log")
    assert_contains "$log" "docker run -d --name web-check -p 8080:80 nginx" \
        "run_image deve montar argumentos separados sem eval"
}

main() {
    setup_test_env
    trap cleanup_test_env EXIT
    create_docker_stubs

    run_test_case "Docker sem sudo" test_docker_config_without_sudo
    run_test_case "Docker com sudo" test_docker_config_with_sudo
    run_test_case "Docker ausente" test_docker_config_without_docker
    run_test_case "docker help sem daemon" test_docker_help_does_not_require_docker
    run_test_case "ajuda de subcomandos sem daemon" test_docker_subcommand_help_without_docker
    run_test_case "containers list não interativo" test_container_list_non_interactive
    run_test_case "containers running não interativo" test_container_running_non_interactive
    run_test_case "containers ação não interativa" test_container_action_non_interactive
    run_test_case "containers ação inválida" test_container_invalid_action_returns_one
    run_test_case "compose help sem compose" test_compose_help_does_not_require_compose
    run_test_case "compose dispatch não interativo" test_compose_dispatch_non_interactive
    run_test_case "compose ausente" test_compose_missing_returns_one
    run_test_case "volumes list não interativo" test_volume_list_non_interactive
    run_test_case "volumes ciclo de vida não interativo" test_volume_lifecycle_non_interactive
    run_test_case "volumes nome inválido" test_volume_invalid_name_returns_one
    run_test_case "libs Docker sem exit" test_docker_libs_do_not_exit
    run_test_case "libs Docker sem eval" test_docker_libs_do_not_use_eval
    run_test_case "run_image sem eval" test_run_image_builds_arguments_without_eval

    show_test_summary
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
