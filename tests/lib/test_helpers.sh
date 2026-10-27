#!/bin/bash

# Helpers reutilizáveis para a suíte de caracterização do ByteBabe CLI.
# Uso: source tests/lib/test_helpers.sh
#
# Este arquivo foi desenhado para funcionar com `set -euo pipefail`.
# As asserções retornam status 0/1; use-as dentro de run_test_case para que
# uma falha esperada seja registrada sem abortar o restante da suíte.

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    echo "test_helpers.sh deve ser carregado via source" >&2
    exit 1
fi

if [[ -n "${_BYTEBABE_TEST_HELPERS_LOADED:-}" ]]; then
    return 0
fi
_BYTEBABE_TEST_HELPERS_LOADED=1

_BYTEBABE_HELPER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "${_BYTEBABE_HELPER_DIR}/../.." && pwd)"
BYTEBABE_ROOT="$BASE_DIR"
export BASE_DIR BYTEBABE_ROOT

# Contadores globais no padrão esperado pelo runner.
TOTAL_TESTS="${TOTAL_TESTS:-0}"
PASSED_TESTS="${PASSED_TESTS:-0}"
FAILED_TESTS="${FAILED_TESTS:-0}"

_TEST_RED=$'\033[0;31m'
_TEST_GREEN=$'\033[0;32m'
_TEST_RESET=$'\033[0m'

setup_test_env() {
    if [[ -n "${TEST_TMP_DIR:-}" && -d "${TEST_TMP_DIR:-}" ]]; then
        rm -rf "$TEST_TMP_DIR" || true
    fi

    TEST_TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/bytebabe-test.XXXXXX")"
    TEST_ORIGINAL_HOME="${HOME:-}"
    TEST_ORIGINAL_PATH="${PATH:-}"
    TEST_HOME_DIR="$TEST_TMP_DIR/home"
    TEST_STUB_DIR="$TEST_TMP_DIR/stubs"

    mkdir -p "$TEST_HOME_DIR" "$TEST_STUB_DIR"

    export HOME="$TEST_HOME_DIR"
    export PATH="$TEST_STUB_DIR:${TEST_ORIGINAL_PATH}"

    export TEST_TMP_DIR TEST_HOME_DIR TEST_STUB_DIR
    export TEST_ORIGINAL_HOME TEST_ORIGINAL_PATH
}

cleanup_test_env() {
    if [[ -n "${TEST_TMP_DIR:-}" && -d "${TEST_TMP_DIR:-}" ]]; then
        rm -rf "$TEST_TMP_DIR" || true
    fi

    if [[ -n "${TEST_ORIGINAL_HOME:-}" ]]; then
        export HOME="$TEST_ORIGINAL_HOME"
    fi
    if [[ -n "${TEST_ORIGINAL_PATH:-}" ]]; then
        export PATH="$TEST_ORIGINAL_PATH"
    fi

    unset TEST_TMP_DIR TEST_HOME_DIR TEST_STUB_DIR
    unset TEST_ORIGINAL_HOME TEST_ORIGINAL_PATH
}

# Cria um executável falso no diretório de stubs (ou no diretório informado).
# stub_command <nome> [saída] [código_de_saída] [diretório]
stub_command() {
    local name="${1:?stub_command: nome do comando é obrigatório}"
    local output="${2:-}"
    local exit_code="${3:-0}"
    local target_dir="${4:-${TEST_STUB_DIR:-}}"

    if [[ -z "$target_dir" ]]; then
        echo "stub_command: diretório de stubs não definido" >&2
        return 1
    fi

    mkdir -p "$target_dir"
    local stub_path="$target_dir/$name"

    {
        printf '#!/bin/bash\n'
        if [[ -n "$output" ]]; then
            printf 'printf "%%s\\n" %q\n' "$output"
        fi
        printf 'exit %s\n' "$exit_code"
    } > "$stub_path"
    chmod +x "$stub_path"

    printf '%s\n' "$stub_path"
}

assert_eq() {
    local expected="$1"
    local actual="$2"
    local message="${3:-valores diferentes}"

    if [[ "$expected" == "$actual" ]]; then
        return 0
    fi

    printf '    assert_eq falhou: %s\n' "$message" >&2
    printf '      esperado: [%s]\n' "$expected" >&2
    printf '      obtido:   [%s]\n' "$actual" >&2
    return 1
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-texto não encontrado}"

    if [[ "$haystack" == *"$needle"* ]]; then
        return 0
    fi

    printf '    assert_contains falhou: %s\n' "$message" >&2
    printf '      trecho esperado: [%s]\n' "$needle" >&2
    return 1
}

assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-texto inesperado encontrado}"

    if [[ "$haystack" != *"$needle"* ]]; then
        return 0
    fi

    printf '    assert_not_contains falhou: %s\n' "$message" >&2
    printf '      trecho inesperado: [%s]\n' "$needle" >&2
    return 1
}

assert_matches() {
    local text="$1"
    local pattern="$2"
    local message="${3:-texto não corresponde ao padrão}"

    if [[ "$text" =~ $pattern ]]; then
        return 0
    fi

    printf '    assert_matches falhou: %s\n' "$message" >&2
    printf '      padrão esperado: [%s]\n' "$pattern" >&2
    printf '      texto obtido:    [%s]\n' "$text" >&2
    return 1
}

# assert_success <descrição> <comando...>
assert_success() {
    local description="${1:-comando}"
    shift || true

    if "$@" >/dev/null 2>&1; then
        return 0
    fi

    printf '    assert_success falhou: %s\n' "$description" >&2
    return 1
}

# assert_failure <descrição> <comando...>
# Passa quando o comando retorna status diferente de zero (falha esperada).
assert_failure() {
    local description="${1:-comando}"
    shift || true

    if "$@" >/dev/null 2>&1; then
        printf '    assert_failure falhou (comando teve sucesso): %s\n' "$description" >&2
        return 1
    fi

    return 0
}

# Executa um caso de teste. A função recebida é rodada em subshell; qualquer
# status diferente de zero é contabilizado como falha sem abortar a suíte.
run_test_case() {
    local name="$1"
    shift

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    local output status
    if output=$("$@" 2>&1); then
        status=0
    else
        status=$?
    fi

    if [[ $status -eq 0 ]]; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        printf '%sPASS%s %s\n' "$_TEST_GREEN" "$_TEST_RESET" "$name"
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        printf '%sFAIL%s %s\n' "$_TEST_RED" "$_TEST_RESET" "$name"
        if [[ -n "$output" ]]; then
            printf '%s\n' "$output" | sed 's/^/    /'
        fi
    fi

    return 0
}

show_test_summary() {
    echo
    echo "Total: $TOTAL_TESTS"
    echo "Passou: $PASSED_TESTS"
    echo "Falhou: $FAILED_TESTS"

    if [[ $FAILED_TESTS -eq 0 ]]; then
        return 0
    fi
    return 1
}
