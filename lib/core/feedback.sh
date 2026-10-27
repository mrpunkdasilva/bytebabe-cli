#!/bin/bash

# Feedback visual (spinner/loading) com degradação para ambientes não TTY.
# Este arquivo apenas declara funções; carregá-lo não inicia animações.

if [[ -n "${_BYTEBABE_CORE_FEEDBACK_LOADED:-}" ]]; then
    return 0
fi
_BYTEBABE_CORE_FEEDBACK_LOADED=1

if [[ -z "${CYBER_BLUE:-}" ]]; then
    if [[ "${BASH_SOURCE[0]}" == */* ]]; then
        _bytebabe_feedback_dir="${BASH_SOURCE[0]%/*}"
    else
        _bytebabe_feedback_dir="."
    fi
    _bytebabe_feedback_dir="$(cd -P -- "$_bytebabe_feedback_dir" && pwd)"
    source "$_bytebabe_feedback_dir/colors.sh"
    unset _bytebabe_feedback_dir
fi

# Aguarda o processo quando possível, preservando seu código de saída.
# PIDs que não são filhos do shell atual (wait retorna 127) não são tratados
# como falha, pois o spinner apenas observa o processo.
_bytebabe_feedback_wait_status() {
    local pid="$1"
    local status

    [[ -n "$pid" ]] || return 0

    if wait "$pid" 2>/dev/null; then
        return 0
    fi

    status=$?
    [[ $status -eq 127 ]] && return 0
    return "$status"
}

# show_spinner <pid> <mensagem>  -> monitora o processo
# show_spinner <mensagem>        -> modo não bloqueante (compatível com "&")
show_spinner() {
    local pid=""
    local msg=""
    local delay=0.1
    local spinstr='⣾⣽⣻⢿⡿⣟⣯⣷'
    local i

    if [[ $# -ge 2 ]]; then
        pid="$1"
        msg="$2"

        if [[ ! -t 1 ]]; then
            printf '%b%s%b %b✔%b\n' "$CYBER_BLUE" "$msg" "$RESET" "$CYBER_GREEN" "$RESET"
            _bytebabe_feedback_wait_status "$pid"
            return $?
        fi

        printf '%b   [ ] %s%b' "$CYBER_BLUE" "$msg" "$RESET"
        while kill -0 "$pid" 2>/dev/null; do
            for i in 0 1 2 3 4 5 6 7; do
                printf '%b\b%s%b' "$CYBER_PINK" "${spinstr:$i:1}" "$RESET"
                sleep "$delay"
                kill -0 "$pid" 2>/dev/null || break
            done
        done
        printf '\b%b✔%b\n' "$CYBER_GREEN" "$RESET"
        _bytebabe_feedback_wait_status "$pid"
        return $?
    fi

    msg="${1:-}"
    printf '%b%s%b\n' "$CYBER_BLUE" "$msg" "$RESET"
    return 0
}

# show_loading <pid> <mensagem> -> monitora o processo
# show_loading <mensagem>       -> imprime mensagem e reticências e retorna
show_loading() {
    local pid=""
    local msg=""
    local delay=0.1
    local spin=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local i

    if [[ $# -ge 2 ]]; then
        pid="$1"
        msg="$2"

        if [[ ! -t 1 ]]; then
            printf '%b%s%b %b✔%b\n' "$CYBER_BLUE" "$msg" "$RESET" "$CYBER_GREEN" "$RESET"
            _bytebabe_feedback_wait_status "$pid"
            return $?
        fi

        i=0
        while kill -0 "$pid" 2>/dev/null; do
            printf '\r%b%s %s%b' "$CYBER_BLUE" "${spin[$i]}" "$msg" "$RESET"
            i=$(( (i + 1) % 10 ))
            sleep "$delay"
        done
        printf '\r\033[K'
        _bytebabe_feedback_wait_status "$pid"
        return $?
    fi

    msg="${1:-}"
    printf '%b%s...%b\n' "$CYBER_BLUE" "$msg" "$RESET"
    return 0
}
