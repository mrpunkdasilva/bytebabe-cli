#!/bin/bash

# Testes de caracterização do parser, validação e engine HTTP do Flux.
# curl/clear/jq são substituídos por stubs; nenhuma requisição de rede é feita.

set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/test_helpers.sh
source "$TEST_DIR/../../lib/test_helpers.sh"

FLUX_DIR="$BASE_DIR/lib/flux"

source "$BASE_DIR/lib/core/colors.sh"
source "$BASE_DIR/lib/core/feedback.sh"
source "$FLUX_DIR/display.sh"
source "$FLUX_DIR/engine.sh"
source "$FLUX_DIR/request.sh"
source "$FLUX_DIR/verbs/get/main.sh"
source "$FLUX_DIR/verbs/post/main.sh"
source "$FLUX_DIR/verbs/put/main.sh"
source "$FLUX_DIR/verbs/delete/main.sh"

process_request_for_history() {
    :
}

stub_response() {
    local status="$1"
    local body="${2:-}"
    local response=$'HTTP/1.1 '"$status"$' Test\r\nContent-Type: application/json\r\n\r\n'"$body"$'\n'"$status"$'\n0.012\n'
    stub_command curl "$response" 0 >/dev/null
}

test_flux_files_are_source_safe() {
    local file output status
    while IFS= read -r file; do
        if output=$(timeout 5 /bin/bash --noprofile --norc -c \
            'BASE_DIR="$1"; source "$2"' _ "$BASE_DIR" "$file" 2>&1); then
            status=0
        else
            status=$?
        fi

        assert_eq 0 "$status" "source de ${file#$BASE_DIR/} deve retornar 0"
        assert_eq "" "$output" "source de ${file#$BASE_DIR/} não deve produzir saída"
    done < <(find "$FLUX_DIR" -name '*.sh' -type f | sort)
    assert_success "commands/flux/main.sh deve ser source-safe" \
        /bin/bash --noprofile --norc -c 'BASE_DIR="$1"; source "$2"' _ "$BASE_DIR" "$BASE_DIR/commands/flux/main.sh"
}

test_flux_has_no_eval_or_legacy_source() {
    local files=("$FLUX_DIR" "$BASE_DIR/commands/flux/main.sh")
    assert_success "Flux não deve usar eval" \
        bash -c '! grep -RInE "\beval\b" "$@"' _ "${files[@]}"
    assert_success "Flux não deve referenciar postFeature/main.sh" \
        bash -c '! grep -RIn "postFeature/main.sh" "$@"' _ "${files[@]}"
    assert_success "postFeature deve estar arquivado" \
        test -f "$BASE_DIR/archive/legacy/flux/postFeature/executor.sh"
    assert_failure "postFeature não deve existir no código ativo" \
        test -e "$FLUX_DIR/verbs/postFeature"
}

test_get_parser_collects_options() {
    flux_parse_request_args GET \
        -H 'Authorization: Bearer x' \
        -q 'page=1' \
        -q 'limit=10' \
        -o 'out.json' \
        --json -i -v \
        'https://api.example.com'

    assert_eq "GET" "$FLUX_METHOD" "método deve ser GET"
    assert_eq "https://api.example.com" "$FLUX_URL" "URL deve ser capturada"
    assert_eq "Authorization: Bearer x" "${FLUX_HEADERS[0]}" "header customizado"
    assert_eq "Accept: application/json" "${FLUX_HEADERS[1]}" "--json deve adicionar Accept"
    assert_eq "page=1" "${FLUX_QUERY[0]}" "primeiro query param"
    assert_eq "limit=10" "${FLUX_QUERY[1]}" "segundo query param"
    assert_eq "out.json" "$FLUX_OUTPUT" "arquivo de saída"
    assert_eq 1 "$FLUX_INCLUDE" "-i deve ser registrado"
    assert_eq 1 "$FLUX_VERBOSE" "-v deve ser registrado"
}

test_parser_rejects_invalid_get_options() {
    local output status

    if output=$(flux_parse_request_args GET --opcao-invalida 2>&1); then
        status=0
    else
        status=$?
    fi
    assert_eq 1 "$status" "opção inválida no GET deve retornar 1"
    assert_contains "$output" "Unknown option" "deve informar opção desconhecida"
    assert_contains "$output" "FLUX GET" "deve exibir a ajuda do GET"

    if output=$(flux_parse_request_args GET -H --json 2>&1); then
        status=0
    else
        status=$?
    fi
    assert_eq 1 "$status" "header sem valor no GET deve retornar 1"
    assert_contains "$output" "value is required" "deve informar valor obrigatório"

    if output=$(flux_parse_request_args GET -d '{"a":1}' 2>&1); then
        status=0
    else
        status=$?
    fi
    assert_eq 1 "$status" "GET não deve aceitar -d"
    assert_contains "$output" "Unknown option" "deve rejeitar opção fora do verbo"
}

test_post_put_delete_parsers() {
    flux_parse_request_args POST -H 'X-Test: 1' -d '{"a":1}' --json --loading-style pulse 'https://api.example.com'
    assert_eq "POST" "$FLUX_METHOD" "método POST"
    assert_eq '{"a":1}' "$FLUX_DATA" "body do POST"
    assert_eq "pulse" "$FLUX_LOADING_STYLE" "loading style"
    assert_eq "X-Test: 1" "${FLUX_HEADERS[0]}" "header do POST"

    flux_parse_request_args PUT -d '{"b":2}' 'https://api.example.com'
    assert_eq "PUT" "$FLUX_METHOD" "método PUT"
    assert_eq '{"b":2}' "$FLUX_DATA" "body do PUT"

    flux_parse_request_args DELETE -H 'X-Test: 1' --json -f --loading pulse 'https://api.example.com'
    assert_eq "DELETE" "$FLUX_METHOD" "método DELETE"
    assert_eq 1 "$FLUX_FORCE" "-f deve ser registrado"
    assert_eq "pulse" "$FLUX_LOADING_STYLE" "loading do DELETE"

    local output status
    if output=$(flux_parse_request_args POST -q 'x=1' 2>&1); then
        status=0
    else
        status=$?
    fi
    assert_eq 1 "$status" "POST não deve aceitar -q"
    assert_contains "$output" "Unknown option" "deve rejeitar query no POST"
}

test_help_flags_and_missing_url() {
    flux_parse_request_args GET --help
    assert_eq 1 "$FLUX_HELP" "--help deve marcar ajuda"

    local output status
    if output=$(flux_execute_request GET 2>&1); then
        status=0
    else
        status=$?
    fi
    assert_eq 1 "$status" "verbo sem URL deve retornar 1"
    assert_contains "$output" "FLUX GET" "verbo sem URL deve mostrar ajuda específica"
}

run_verb_validator() {
    local verb="$1"
    local url="$2"

    /bin/bash --noprofile --norc -c '
        set -euo pipefail
        BASE_DIR="$1"
        verb="$2"
        url="$3"
        source "$BASE_DIR/lib/core/colors.sh"
        source "$BASE_DIR/lib/flux/verbs/$verb/help.sh"
        source "$BASE_DIR/lib/flux/verbs/$verb/validator.sh"
        validate_url "$url"
    ' _ "$BASE_DIR" "$verb" "$url"
}

test_url_validation_for_all_verbs() {
    local verb
    for verb in get post put delete; do
        assert_success "$verb deve aceitar https" run_verb_validator "$verb" 'https://api.example.com'
        assert_failure "$verb deve rejeitar esquema inválido" run_verb_validator "$verb" 'ftp://api.example.com'
        assert_failure "$verb deve rejeitar URL vazia" run_verb_validator "$verb" ''
    done
}

test_get_executor_with_stubs() {
    stub_command clear "" 0 >/dev/null
    stub_response 200 '{"ok":true}'

    local output status
    if output=$(flux_execute_request GET 'https://api.example.com/test' 2>&1); then
        status=0
    else
        status=$?
    fi

    assert_eq 0 "$status" "GET 200 deve retornar 0"
    assert_contains "$output" "GET" "deve exibir o método GET"
    assert_contains "$output" "https://api.example.com/test" "deve exibir a URL solicitada"
    assert_contains "$output" "Status:" "deve exibir o status da resposta"
    assert_contains "$output" "200" "deve exibir o status 200 do stub"
    assert_contains "$output" "12ms" "deve exibir a duração convertida"
    assert_contains "$output" '{"ok":true}' "deve exibir o corpo retornado pelo stub"
}

test_http_error_returns_one() {
    stub_command clear "" 0 >/dev/null
    stub_response 404 '{"error":"missing"}'

    assert_failure "HTTP 404 deve retornar 1" \
        flux_execute_request GET 'https://api.example.com/missing'
}

test_network_error_returns_one() {
    stub_command curl "" 7 >/dev/null

    local output status
    if output=$(flux_execute_request GET 'https://api.example.com/fail' 2>&1); then
        status=0
    else
        status=$?
    fi

    assert_eq 1 "$status" "falha de rede deve retornar 1"
    assert_contains "$output" "curl exit 7" "deve informar a falha do curl"
}

test_post_passes_arguments_without_eval() {
    local args_file="$TEST_TMP_DIR/curl-args"
    local marker="$TEST_TMP_DIR/pwned"

    cat > "$TEST_STUB_DIR/curl" <<'STUB'
#!/bin/bash
printf '%s\n' "$@" > "$FLUX_TEST_ARGS"
printf 'HTTP/1.1 201 Created\r\nContent-Type: application/json\r\n\r\n{"created":true}\n201\n0.020\n'
STUB
    chmod +x "$TEST_STUB_DIR/curl"
    stub_command clear "" 0 >/dev/null

    export FLUX_TEST_ARGS="$args_file"
    local output status
    if output=$(flux_execute_request POST 'https://api.example.com/users' \
        -H 'X-Test: 1' \
        -d '{"name":"John"}' 2>&1); then
        status=0
    else
        status=$?
    fi

    assert_eq 0 "$status" "POST 201 deve retornar 0"
    assert_success "stub deve registrar os argumentos" test -f "$args_file"
    assert_contains "$(cat "$args_file")" "-d" "curl deve receber -d como argumento"
    assert_contains "$(cat "$args_file")" '{"name":"John"}' "curl deve receber o body literal"

    if output=$(flux_execute_request POST 'https://api.example.com/users' \
        -H 'X-Test: $(touch "$TEST_TMP_DIR/pwned")' \
        -d '{"name":"John"}' 2>&1); then
        status=0
    else
        status=$?
    fi
    assert_eq 0 "$status" "header com metacaractere não deve quebrar a execução"
    assert_failure "engine não deve executar substituição em headers" test -e "$marker"
}

test_put_and_delete_execute() {
    stub_command clear "" 0 >/dev/null
    stub_response 200 '{"updated":true}'

    assert_success "PUT deve concluir com 200" \
        flux_execute_request PUT 'https://api.example.com/users/1' -d '{"name":"Jane"}'

    stub_response 204 ''
    assert_success "DELETE 204 deve retornar 0" \
        flux_execute_request DELETE 'https://api.example.com/users/1' -f
}

test_temporary_files_are_removed() {
    local flux_tmp="$TEST_TMP_DIR/flux-tmp"
    mkdir -p "$flux_tmp"
    stub_command clear "" 0 >/dev/null
    stub_response 200 '{"ok":true}'

    TMPDIR="$flux_tmp" flux_execute_request GET 'https://api.example.com/tmp' >/dev/null

    assert_eq "" "$(find "$flux_tmp" -mindepth 1 -print -quit)" \
        "engine deve remover o diretório temporário"
}

test_history_source_has_no_side_effects() {
    local output status
    local source_home="$TEST_TMP_DIR/history-source-home"
    mkdir -p "$source_home"

    if output=$(HOME="$source_home" timeout 5 /bin/bash --noprofile --norc -c '
        set -euo pipefail
        BASE_DIR="$1"
        source "$BASE_DIR/lib/core/colors.sh"
        source "$BASE_DIR/lib/flux/history.sh"
    ' _ "$BASE_DIR" 2>&1); then
        status=0
    else
        status=$?
    fi

    assert_eq 0 "$status" "history.sh deve carregar sem erro"
    assert_eq "" "$output" "history.sh não deve imprimir ao carregar"
    assert_failure "history.sh não deve criar histórico ao carregar" \
        test -e "$source_home/bytebabe/flux/request_history.json"
}

test_flux_help_returns_zero() {
    local output status
    if output=$(timeout 5 /bin/bash --noprofile --norc -c \
        'BASE_DIR="$1"; source "$BASE_DIR/commands/flux/main.sh"; main help' _ "$BASE_DIR" 2>&1); then
        status=0
    else
        status=$?
    fi

    assert_eq 0 "$status" "flux help deve retornar 0"
    assert_contains "$output" "FLUX API CLIENT" "help deve exibir o título"
    assert_contains "$output" "history" "help deve listar history"
}

main() {
    setup_test_env
    trap cleanup_test_env EXIT

    stub_command clear "" 0 >/dev/null
    printf '#!/bin/bash\ncat\n' > "$TEST_STUB_DIR/jq"
    chmod +x "$TEST_STUB_DIR/jq"

    run_test_case "FLUX: arquivos são source-safe" test_flux_files_are_source_safe
    run_test_case "FLUX: sem eval e sem source legado" test_flux_has_no_eval_or_legacy_source
    run_test_case "FLUX GET: parser coleta opções" test_get_parser_collects_options
    run_test_case "FLUX GET: rejeita opções inválidas" test_parser_rejects_invalid_get_options
    run_test_case "FLUX POST/PUT/DELETE: parsers" test_post_put_delete_parsers
    run_test_case "FLUX: ajuda e URL ausente" test_help_flags_and_missing_url
    run_test_case "FLUX: validação de URL" test_url_validation_for_all_verbs
    run_test_case "FLUX GET: executor com stubs" test_get_executor_with_stubs
    run_test_case "FLUX: HTTP >= 400 retorna 1" test_http_error_returns_one
    run_test_case "FLUX: falha de rede retorna 1" test_network_error_returns_one
    run_test_case "FLUX POST: argumentos sem eval" test_post_passes_arguments_without_eval
    run_test_case "FLUX PUT/DELETE: execução com stubs" test_put_and_delete_execute
    run_test_case "FLUX: temporários são removidos" test_temporary_files_are_removed
    run_test_case "FLUX: history é source-safe" test_history_source_has_no_side_effects
    run_test_case "FLUX: help retorna 0" test_flux_help_returns_zero

    show_test_summary
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
