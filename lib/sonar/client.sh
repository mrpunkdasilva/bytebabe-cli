#!/bin/bash

# ==================================================
# SONAR MODULE — cliente HTTP (curl) com spinner
# Apenas funções; carregar este arquivo não faz requisições.
# ==================================================

sonar_require_deps() {
    local required_command
    for required_command in "$@"; do
        if ! command -v "$required_command" >/dev/null 2>&1; then
            printf 'Erro: comando necessário não encontrado: %s\n' "$required_command" >&2
            return 2
        fi
    done
}

_sonar_curl() {
    local label="$1"
    local request_url="$2"
    local auth_token="$3"
    shift 3

    local response_file
    local error_file
    local curl_status=0
    local started_at="$SECONDS"
    local elapsed=0
    local frame_index=0
    local -a frames=('|' '/' '-' '\')

    error_file="$(mktemp)"
    response_file="$(mktemp)"

    curl --fail --silent --show-error \
        --connect-timeout "$_SONAR_CONNECT_TIMEOUT" \
        --max-time "$_SONAR_TIMEOUT" \
        --config <(printf 'user = "%s:"\n' "$auth_token") \
        --get "$request_url" \
        "$@" >"$response_file" 2>"$error_file" &
    local curl_pid=$!

    if [[ -t 2 ]]; then
        while kill -0 "$curl_pid" 2>/dev/null; do
            elapsed=$((SECONDS - started_at))
            printf '\r\033[K%b%s%b %s (%02ds)' \
                "$_SONAR_CYAN$_SONAR_BOLD" "${frames[$frame_index]}" "$_SONAR_RESET" "$label" "$elapsed" >&2
            frame_index=$(((frame_index + 1) % ${#frames[@]}))
            sleep 0.1
        done
    fi

    if wait "$curl_pid"; then
        elapsed=$((SECONDS - started_at))
        if [[ -s "$error_file" ]]; then
            cat "$error_file" >&2
        fi
        if [[ -t 2 ]]; then
            printf '\r\033[K%bOK%b %s concluído em %02ds\n' \
                "$_SONAR_GREEN$_SONAR_BOLD" "$_SONAR_RESET" "$label" "$elapsed" >&2
        fi
        rm -f "$error_file"
        cat "$response_file"
        rm -f "$response_file"
        return 0
    fi

    curl_status=$?
    elapsed=$((SECONDS - started_at))
    if [[ -t 2 ]]; then
        printf '\r\033[K%bERRO%b %s após %02ds\n' \
            "$_SONAR_RED$_SONAR_BOLD" "$_SONAR_RESET" "$label" "$elapsed" >&2
    fi
    if [[ "$curl_status" == '28' ]]; then
        printf 'Tempo limite excedido (%ss). Confira a conexão e tente novamente.\n' "$_SONAR_TIMEOUT" >&2
    elif [[ -s "$error_file" ]]; then
        cat "$error_file" >&2
    fi
    rm -f "$error_file"
    rm -f "$response_file"
    return "$curl_status"
}

# sonar_get <endpoint> [args curl...] — GET na API do SonarQube com rótulo amigável.
sonar_get() {
    local endpoint="$1"
    shift
    local label='Consultando o SonarQube'

    case "$endpoint" in
        /api/issues/search) label='Buscando apontamentos' ;;
        /api/rules/show) label='Carregando detalhes da regra' ;;
        /api/rules/search) label='Pesquisando regras' ;;
        /api/measures/component) label='Buscando métricas' ;;
        /api/qualitygates/project_status) label='Verificando portão de qualidade' ;;
        /api/hotspots/search) label='Buscando alertas de segurança' ;;
    esac

    _sonar_curl "$label" "$SONAR_URL$endpoint" "$SONAR_TOKEN" "$@"
}

sonar_print_json() {
    if [[ -t 1 && -z "${_SONAR_NO_COLOR:-}" ]]; then
        jq -C .
    else
        jq .
    fi
}
