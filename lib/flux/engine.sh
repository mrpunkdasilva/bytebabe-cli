#!/bin/bash

# Engine HTTP compartilhada do Flux.
# Responsável por parse, validação, execução, renderização e histórico.
# Deve permanecer seguro para source: apenas define funções.

if declare -F flux_execute_request >/dev/null 2>&1; then
    return 0
fi

_flux_engine_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=args.sh
source "$_flux_engine_dir/args.sh"
# shellcheck source=validation.sh
source "$_flux_engine_dir/validation.sh"
if ! declare -F show_response >/dev/null 2>&1; then
    # shellcheck source=display.sh
    source "$_flux_engine_dir/display.sh"
fi
if ! declare -F show_loading >/dev/null 2>&1; then
    # shellcheck source=../core/feedback.sh
    source "$_flux_engine_dir/../core/feedback.sh"
fi
unset _flux_engine_dir

FLUX_CANCELLED=0

_flux_build_url() {
    local url="$1"
    local separator="?"
    local query

    if [[ "$url" == *\?* ]]; then
        separator="&"
    fi

    for query in "${FLUX_QUERY[@]}"; do
        url+="${separator}${query}"
        separator="&"
    done

    printf '%s' "$url"
}

_flux_parse_response() {
    local response_file="$1"
    local headers_var="$2"
    local body_var="$3"
    local status_var="$4"
    local duration_var="$5"

    local headers_value body_value status_value duration_raw duration_value

    headers_value=$(awk '{ sub(/\r$/, ""); if ($0 == "") exit; print }' "$response_file")
    body_value=$(awk '{ sub(/\r$/, ""); if (seen) print; else if ($0 == "") seen = 1 }' "$response_file" | head -n -2)
    status_value=$(awk '{ sub(/\r$/, ""); sub(/[[:space:]]+$/, ""); if (NF) { previous = last; last = $0 } } END { print previous }' "$response_file")
    duration_raw=$(awk '{ sub(/\r$/, ""); sub(/[[:space:]]+$/, ""); if (NF) last = $0 } END { print last }' "$response_file")

    if [[ ! "$status_value" =~ ^[0-9]{3}$ ]]; then
        status_value="000"
    fi

    duration_value=$(awk -v value="$duration_raw" 'BEGIN { if (value == "") value = 0; printf "%.0f", value * 1000 }')

    printf -v "$headers_var" '%s' "$headers_value"
    printf -v "$body_var" '%s' "$body_value"
    printf -v "$status_var" '%s' "$status_value"
    printf -v "$duration_var" '%s' "$duration_value"
}

flux_execute_request() {
    local method="${1:-}"
    local output_file err_file curl_args response_file
    local url response_headers response_body status_code duration
    local curl_status=0 curl_pid=0

    if [[ -z "$method" ]]; then
        return 1
    fi
    shift

    if ! flux_parse_request_args "$method" "$@"; then
        return 1
    fi

    if [[ "$FLUX_HELP" -eq 1 ]]; then
        flux_show_method_help "$method"
        return 0
    fi

    if [[ -z "$FLUX_URL" ]]; then
        flux_show_method_help "$method"
        return 1
    fi

    if ! flux_validate_url "$FLUX_URL"; then
        return 1
    fi

    if ! command -v curl >/dev/null 2>&1; then
        echo -e "${CYBER_RED:-}Error: curl is required${RESET:-}" >&2
        return 1
    fi

    url="$(_flux_build_url "$FLUX_URL")"
    local temp_dir
    if ! temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/bytebabe-flux.XXXXXX")"; then
        echo -e "${CYBER_RED:-}Error: could not create temporary files${RESET:-}" >&2
        return 1
    fi

    response_file="$temp_dir/response"
    err_file="$temp_dir/error"
    FLUX_CANCELLED=0

    clear
    show_flux_header
    show_request_header "$method" "$url"

    curl_args=(curl -s -i -w '\n%{http_code}\n%{time_total}' -X "$method")
    curl_args+=(-H 'User-Agent: Flux-HTTP-Client/1.0')

    case "$method" in
        GET|DELETE)
            curl_args+=(-H 'Accept: application/json')
            ;;
        POST|PUT)
            curl_args+=(-H 'Content-Type: application/json')
            ;;
    esac

    local header
    for header in "${FLUX_HEADERS[@]}"; do
        curl_args+=(-H "$header")
    done

    if [[ -n "$FLUX_DATA" ]]; then
        curl_args+=(-d "$FLUX_DATA")
    fi

    if [[ -n "$FLUX_OUTPUT" ]]; then
        curl_args+=(-o "$FLUX_OUTPUT")
    fi

    if [[ "$FLUX_INCLUDE" -eq 1 ]]; then
        : # curl já é executado com -i para permitir parse dos headers
    fi

    if [[ "$FLUX_VERBOSE" -eq 1 ]]; then
        curl_args+=(-v)
    fi

    curl_args+=("$url")

    if [[ "${#FLUX_HEADERS[@]}" -gt 0 ]]; then
        show_request_headers "${FLUX_HEADERS[@]}"
    fi

    if [[ -n "$FLUX_DATA" ]]; then
        echo -e "${CYBER_BLUE:-}Body:${RESET:-}"
        echo "$FLUX_DATA"
        echo
    fi

    trap 'FLUX_CANCELLED=1; kill "$curl_pid" 2>/dev/null || true' INT

    "${curl_args[@]}" >"$response_file" 2>"$err_file" &
    curl_pid=$!

    local monitor_status=0 wait_status=0
    show_loading "$curl_pid" "Making $method request to $url..." || monitor_status=$?
    wait "$curl_pid" 2>/dev/null || wait_status=$?
    [[ "$wait_status" -eq 127 ]] && wait_status=0
    curl_status="$monitor_status"
    if [[ "$curl_status" -eq 0 ]]; then
        curl_status="$wait_status"
    fi

    trap - INT

    if [[ "$FLUX_CANCELLED" -eq 1 ]]; then
        rm -rf "$temp_dir"
        return 130
    fi

    if [[ "$FLUX_VERBOSE" -eq 1 && -s "$err_file" ]]; then
        echo -e "${CYBER_BLUE:-}Request details:${RESET:-}"
        sed 's/^/  /' "$err_file"
        echo
    fi

    _flux_parse_response "$response_file" \
        response_headers response_body status_code duration
    rm -rf "$temp_dir"

    if [[ "$curl_status" -ne 0 ]]; then
        echo -e "${CYBER_RED:-}Error: request failed (curl exit $curl_status)${RESET:-}" >&2
        return 1
    fi

    show_response "$status_code" "$response_headers" "$response_body" "$duration"

    if declare -F process_request_for_history >/dev/null 2>&1; then
        if declare -F init_history >/dev/null 2>&1; then
            init_history >/dev/null 2>&1 || true
        fi
        process_request_for_history "$method" "$url" \
            "$(printf '%s\n' "${FLUX_HEADERS[@]}")" "$FLUX_DATA" \
            "$response_body" "$status_code" >/dev/null 2>&1 || true
    fi

    if [[ "$status_code" == "000" ]]; then
        return 1
    fi

    if (( 10#$status_code >= 400 )); then
        return 1
    fi

    return 0
}
