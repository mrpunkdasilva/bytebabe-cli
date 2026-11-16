#!/bin/bash

# ==================================================
# SONAR MODULE — Gestão de pull requests via sonar.json
# Por projeto: .projects[].prs (lista) e .projects[].activePr (ativo)
# Fallback do ativo: defaultPullRequest (padrão global do login).
# Apenas funções.
# ==================================================

# Projeto ativo ou falha com mensagem.
_sonar_pulls_proj() {
    local proj
    proj="$(_sonar_config_get project)"
    if [[ -z "$proj" ]]; then
        _sonar_error "Nenhum projeto ativo. Defina um projeto primeiro: bytebabe sonar project use <chave>"
        return 1
    fi
    printf '%s' "$proj"
}

# Chave de config da lista de PRs do projeto ativo.
_sonar_pulls_list_key() {
    local proj
    proj="$(_sonar_pulls_proj)" || return 1
    printf 'pullRequests.%s' "$proj"
}

# Chave de config do PR ativo do projeto atual.
_sonar_pulls_active_key() {
    local proj
    proj="$(_sonar_pulls_proj)" || return 1
    printf 'pullRequest.%s' "$proj"
}

# PR ativo efetivo do projeto atual: activePr do projeto com
# fallback para defaultPullRequest (definido no login).
_sonar_pulls_active_get() {
    local active_key legacy
    active_key="$(_sonar_pulls_active_key)" || return 1
    local active
    active="$(_sonar_config_get "$active_key")"
    if [[ -n "$active" ]]; then
        printf '%s' "$active"
        return 0
    fi
    legacy="$(_sonar_config_get pullRequest)"
    printf '%s' "$legacy"
}

# Obtém a lista de PRs do projeto ativo (números separados por espaço).
_sonar_pulls_get_list() {
    local list_key
    list_key="$(_sonar_pulls_list_key)" || return 1
    local raw
    raw="$(_sonar_config_get "$list_key")"
    raw="${raw//,/ }"
    printf '%s' "$raw"
}

_sonar_pulls_set_list() {
    local list_key
    list_key="$(_sonar_pulls_list_key)" || return 1
    _sonar_config_set "$list_key" "$1"
}

_sonar_pull_usage() {
    printf '\n%bUso:%b bytebabe sonar %bpr%b %b<subcomando>%b %b[argumentos]%b\n\n' \
        "$_SONAR_YELLOW" "$_SONAR_RESET" "$_SONAR_GREEN" "$_SONAR_RESET" \
        "$_SONAR_GREEN" "$_SONAR_RESET" "$_SONAR_DIM" "$_SONAR_RESET"
    printf '%bCada projeto tem sua lista %b%b(prs)%b %be seu PR ativo %b%b(activePr)%b %bem sonar.json.%b\n\n' \
        "$_SONAR_WHITE" "$_SONAR_RESET" "$_SONAR_DIM" "$_SONAR_RESET" \
        "$_SONAR_WHITE" "$_SONAR_RESET" "$_SONAR_DIM" "$_SONAR_RESET" "$_SONAR_WHITE" "$_SONAR_RESET"
    printf '%bSubcomandos:%b\n' "$_SONAR_YELLOW" "$_SONAR_RESET"
    printf '  %blist%b %b(ls)%b           %bLista os PRs do projeto ativo e marca o ativo dele%b\n' \
        "$_SONAR_GREEN" "$_SONAR_RESET" "$_SONAR_DIM" "$_SONAR_RESET" "$_SONAR_WHITE" "$_SONAR_RESET"
    printf '  %badd%b %b<numero>%b        %bAdiciona um PR à lista do projeto ativo%b\n' \
        "$_SONAR_GREEN" "$_SONAR_RESET" "$_SONAR_DIM" "$_SONAR_RESET" "$_SONAR_WHITE" "$_SONAR_RESET"
    printf '  %bremove%b %b<numero>%b     %bRemove um PR da lista do projeto ativo%b\n' \
        "$_SONAR_GREEN" "$_SONAR_RESET" "$_SONAR_DIM" "$_SONAR_RESET" "$_SONAR_WHITE" "$_SONAR_RESET"
    printf '  %bsearch%b %b[termo]%b      %bPesquisa e seleciona um PR da lista interativamente%b\n' \
        "$_SONAR_GREEN" "$_SONAR_RESET" "$_SONAR_DIM" "$_SONAR_RESET" "$_SONAR_WHITE" "$_SONAR_RESET"
    printf '  %buse%b %b<numero>%b        %bDefine o PR ativo deste projeto; números novos entram na lista%b\n' \
        "$_SONAR_GREEN" "$_SONAR_RESET" "$_SONAR_DIM" "$_SONAR_RESET" "$_SONAR_WHITE" "$_SONAR_RESET"
    printf '\n%bAtalho:%b bytebabe sonar %bpull%b %b<subcomando>%b\n\n' \
        "$_SONAR_YELLOW" "$_SONAR_RESET" "$_SONAR_GREEN" "$_SONAR_RESET" "$_SONAR_DIM" "$_SONAR_RESET"
}

sonar_pull_list() {
    local proj
    local active_num
    local raw_list
    local nums=()
    local n
    local marker
    local count=0

    proj="$(_sonar_pulls_proj)" || return $?
    active_num="$(_sonar_pulls_active_get)" || return $?
    raw_list="$(_sonar_pulls_get_list)" || return $?

    printf '\n%bPULL REQUESTS DE %b%b%s%b\n\n' \
        "$_SONAR_BOLD$_SONAR_CYAN" "$_SONAR_RESET" "$_SONAR_WHITE$_SONAR_BOLD" "$proj" "$_SONAR_RESET"

    for n in $raw_list; do
        [[ -z "$n" ]] && continue
        nums+=("$n")
        count=$((count + 1))
        marker="${_SONAR_DIM}·${_SONAR_RESET}"
        [[ "$n" == "$active_num" ]] && marker="${_SONAR_GREEN}${_SONAR_BOLD}✔${_SONAR_RESET}"
        printf '  %b %b#%s%b\n' "$marker" "$_SONAR_WHITE$_SONAR_BOLD" "$n" "$_SONAR_RESET"
    done

    if (( count == 0 )); then
        printf '  %b(nenhum PR na lista deste projeto; use um com: bytebabe sonar pr use <numero>)%b\n' \
            "$_SONAR_DIM" "$_SONAR_RESET"
    fi

    printf '\n  %bPR ativo deste projeto:%b %b#%s%b\n' \
        "$_SONAR_DIM" "$_SONAR_RESET" "$_SONAR_GREEN$_SONAR_BOLD" "${active_num:-<nenhum>}" "$_SONAR_RESET"
    local in_list=0
    local n2
    for n2 in "${nums[@]:-}"; do
        [[ -z "$n2" ]] && continue
        [[ "$n2" == "$active_num" ]] && in_list=1
    done
    if [[ -n "$active_num" && "$in_list" == 0 ]]; then
        printf '  %bℹ Ativo herdado do padrão do login (defaultPullRequest); vincule com:%b %bbytebabe sonar pr use %s%b\n' \
            "$_SONAR_YELLOW" "$_SONAR_RESET" "$_SONAR_WHITE" "$active_num" "$_SONAR_RESET"
    elif [[ -z "$active_num" ]]; then
        printf '  %bAs consultas analisam o projeto inteiro até você escolher um PR.%b\n' \
            "$_SONAR_DIM" "$_SONAR_RESET"
    fi
    printf '  %bTroque de projeto (project use) para ver e trocar os PRs dele.%b\n\n' \
        "$_SONAR_DIM" "$_SONAR_RESET"
}

sonar_pull_use() {
    local num="${1:-}"
    local raw_list
    local nums=()
    local found=0
    local new_list=""
    local n

    if [[ -z "$num" ]]; then
        printf '%b✗ Informe o número do PR:%b %bbytebabe sonar pr use <numero>%b\n' \
            "$_SONAR_RED$_SONAR_BOLD" "$_SONAR_RESET" "$_SONAR_WHITE" "$_SONAR_RESET" >&2
        return 2
    fi

    raw_list="$(_sonar_pulls_get_list)" || return $?
    for n in $raw_list; do
        [[ -n "$n" ]] && nums+=("$n")
        [[ "$n" == "$num" ]] && found=1
    done

    if (( found == 0 )); then
        nums+=("$num")
        new_list="${nums[*]}"
        new_list="${new_list// /,}"
        _sonar_pulls_set_list "$new_list"
        printf '%bℹ PR novo; adicionado à lista do projeto ativo.%b\n' "$_SONAR_CYAN" "$_SONAR_RESET"
    fi

    _sonar_config_set "$(_sonar_pulls_active_key)" "$num"
    _sonar_success "PR ativo atualizado: #$num"
}

sonar_pull_add() {
    local num="${1:-}"
    local raw_list
    local nums=()
    local found=0
    local new_list=""
    local n

    if [[ -z "$num" ]]; then
        _sonar_pull_usage >&2
        return 2
    fi

    raw_list="$(_sonar_pulls_get_list)" || return $?
    for n in $raw_list; do
        [[ -n "$n" ]] && nums+=("$n")
        [[ "$n" == "$num" ]] && found=1
    done

    if (( found == 1 )); then
        _sonar_error "PR já está na lista do projeto ativo: #$num"
        return 2
    fi

    nums+=("$num")
    new_list="${nums[*]}"
    new_list="${new_list// /,}"

    _sonar_pulls_set_list "$new_list"
    _sonar_success "PR adicionado à lista do projeto ativo: #$num"
    printf '%bPara definir como ativo, use:%b %bbytebabe sonar pr use %s%b\n' \
        "$_SONAR_DIM" "$_SONAR_RESET" "$_SONAR_WHITE" "$num" "$_SONAR_RESET"
}

sonar_pull_remove() {
    local num="${1:-}"
    local raw_list
    local nums=()
    local found=0
    local new_list=""
    local n

    if [[ -z "$num" ]]; then
        _sonar_pull_usage >&2
        return 2
    fi

    raw_list="$(_sonar_pulls_get_list)" || return $?
    for n in $raw_list; do
        if [[ "$n" == "$num" ]]; then
            found=1
        else
            [[ -n "$n" ]] && nums+=("$n")
        fi
    done

    if (( found == 0 )); then
        _sonar_error "PR não encontrado na lista do projeto ativo: #$num"
        return 2
    fi

    new_list="${nums[*]}"
    new_list="${new_list// /,}"

    _sonar_pulls_set_list "$new_list"
    _sonar_success "PR removido da lista do projeto ativo: #$num"

    if [[ "$(_sonar_pulls_active_get)" == "$num" ]]; then
        _sonar_config_set "$(_sonar_pulls_active_key)" "${nums[0]:-}"
        printf '%bℹ Ele era o PR ativo; ativo alterado para: #%s%b\n' \
            "$_SONAR_CYAN" "${nums[0]:-<vazio>}" "$_SONAR_RESET"
    fi
}

sonar_pull_search() {
    local term="${1:-}"
    local raw_list
    local nums=()
    local filtered=()
    local n
    local choice

    raw_list="$(_sonar_pulls_get_list)" || return $?
    for n in $raw_list; do
        [[ -n "$n" ]] && nums+=("$n")
    done

    if (( ${#nums[@]} == 0 )); then
        _sonar_error "Nenhum PR na lista do projeto ativo. Use um primeiro: bytebabe sonar pr use <numero>"
        return 1
    fi

    if [[ -n "$term" ]]; then
        for n in "${nums[@]}"; do
            if [[ "$n" == *"$term"* ]]; then
                filtered+=("$n")
            fi
        done
    else
        filtered=("${nums[@]}")
    fi

    if (( ${#filtered[@]} == 0 )); then
        _sonar_error "Nenhum PR encontrado com o termo: $term"
        return 1
    fi

    if (( ${#filtered[@]} == 1 )); then
        sonar_pull_use "${filtered[0]}"
        return $?
    fi

    printf '\n%bPESQUISAR PR (selecione um)%b\n' "$_SONAR_BOLD$_SONAR_CYAN" "$_SONAR_RESET"
    local i=0
    for (( i=0; i<${#filtered[@]}; i++ )); do
        printf '  %b[%d]%b #%s\n' "$_SONAR_GREEN" "$((i + 1))" "$_SONAR_RESET" "${filtered[i]}"
    done
    printf '  %b[q]%b cancelar\n' "$_SONAR_RED" "$_SONAR_RESET"

    printf '\nOpção: '
    read -r choice
    [[ "$choice" == "q" ]] && return 0

    if [[ "$choice" =~ ^[1-9][0-9]*$ ]] && (( choice <= ${#filtered[@]} )); then
        sonar_pull_use "${filtered[$((choice - 1))]}"
    else
        _sonar_error "Opção inválida."
        return 1
    fi
}

# Dispatcher do CRUD: bytebabe sonar pr <sub> [args].
# Sem subcomando, exibe o help.
sonar_pull_cmd() {
    if (( $# == 0 )); then
        _sonar_pull_usage
        return 0
    fi
    local sub="$1"
    shift 2>/dev/null || true

    case "$sub" in
        list|ls)
            sonar_pull_list
            ;;
        add)
            sonar_pull_add "$@"
            ;;
        remove|rm)
            sonar_pull_remove "$@"
            ;;
        search)
            sonar_pull_search "$@"
            ;;
        use)
            sonar_pull_use "$@"
            ;;
        help|-h|--help)
            _sonar_pull_usage
            ;;
        *)
            printf 'Subcomando pr inválido: %s\n' "$sub" >&2
            _sonar_pull_usage >&2
            return 2
            ;;
    esac
}
