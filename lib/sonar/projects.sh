#!/bin/bash

# ==================================================
# SONAR MODULE — Gestão de projetos via sonar.json (activeProject)
# Apenas funções.
# ==================================================

# Obtém a lista de projetos (chaves separadas por vírgula).
_sonar_projects_get_list() {
    local raw
    raw="$(_sonar_config_get projects)"
    raw="${raw//,/ }"
    printf '%s' "$raw"
}

_sonar_projects_set_list() {
    local list_str="$1"
    _sonar_config_set projects "$list_str"
}

sonar_project_current() {
    local current
    current="$(_sonar_config_get project)"
    if [[ -z "$current" ]]; then
        printf '%bNenhum projeto ativo definido em sonar.json.%b\n' "$_SONAR_DIM" "$_SONAR_RESET"
        return 1
    fi
    printf '%b%s%b\n' "$_SONAR_GREEN$_SONAR_BOLD" "$current" "$_SONAR_RESET"
}

sonar_project_next() {
    local raw_list
    local keys=()
    local current
    local i=0
    local idx=-1
    local next_key

    raw_list="$(_sonar_projects_get_list)"
    for k in $raw_list; do
        [[ -n "$k" ]] && keys+=("$k")
    done

    if (( ${#keys[@]} == 0 )); then
        _sonar_error "Nenhum projeto cadastrado na lista de projetos em sonar.json."
        return 1
    fi

    current="$(_sonar_config_get project)"

    for (( i=0; i<${#keys[@]}; i++ )); do
        if [[ "${keys[i]}" == "$current" ]]; then
            idx=$i
            break
        fi
    done

    idx=$(((idx + 1) % ${#keys[@]}))
    next_key="${keys[idx]}"

    _sonar_config_set project "$next_key"
    _sonar_success "Projeto ativo alterado para (próximo): $next_key"
    sonar_project_current
}

sonar_project_prev() {
    local raw_list
    local keys=()
    local current
    local i=0
    local idx=-1
    local prev_key

    raw_list="$(_sonar_projects_get_list)"
    for k in $raw_list; do
        [[ -n "$k" ]] && keys+=("$k")
    done

    if (( ${#keys[@]} == 0 )); then
        _sonar_error "Nenhum projeto cadastrado na lista de projetos em sonar.json."
        return 1
    fi

    current="$(_sonar_config_get project)"

    for (( i=0; i<${#keys[@]}; i++ )); do
        if [[ "${keys[i]}" == "$current" ]]; then
            idx=$i
            break
        fi
    done

    if (( idx == -1 )); then
        idx=0
    else
        idx=$(((idx - 1 + ${#keys[@]}) % ${#keys[@]}))
    fi
    prev_key="${keys[idx]}"

    _sonar_config_set project "$prev_key"
    _sonar_success "Projeto ativo alterado para (anterior): $prev_key"
    sonar_project_current
}

_sonar_project_usage() {
    printf '\n%bUso:%b bytebabe sonar %bproject%b %b<subcomando>%b %b[argumentos]%b\n\n' \
        "$_SONAR_YELLOW" "$_SONAR_RESET" "$_SONAR_GREEN" "$_SONAR_RESET" \
        "$_SONAR_GREEN" "$_SONAR_RESET" "$_SONAR_DIM" "$_SONAR_RESET"
    printf '%bSubcomandos:%b\n' "$_SONAR_YELLOW" "$_SONAR_RESET"
    printf '  %blist%b %b(ls)%b           %bLista os projetos e marca o ativo%b\n' \
        "$_SONAR_GREEN" "$_SONAR_RESET" "$_SONAR_DIM" "$_SONAR_RESET" "$_SONAR_WHITE" "$_SONAR_RESET"
    printf '  %bnext%b %b(n)%b            %bAlterna para o próximo projeto da lista (circular)%b\n' \
        "$_SONAR_GREEN" "$_SONAR_RESET" "$_SONAR_DIM" "$_SONAR_RESET" "$_SONAR_WHITE" "$_SONAR_RESET"
    printf '  %bprev%b %b(p)%b            %bAlterna para o projeto anterior da lista (circular)%b\n' \
        "$_SONAR_GREEN" "$_SONAR_RESET" "$_SONAR_DIM" "$_SONAR_RESET" "$_SONAR_WHITE" "$_SONAR_RESET"
    printf '  %bcurrent%b %b(curr)%b      %bExibe o projeto ativo no momento%b\n' \
        "$_SONAR_GREEN" "$_SONAR_RESET" "$_SONAR_DIM" "$_SONAR_RESET" "$_SONAR_WHITE" "$_SONAR_RESET"
    printf '  %bsearch%b %b[termo]%b      %bPesquisa e seleciona um projeto da lista interativamente%b\n' \
        "$_SONAR_GREEN" "$_SONAR_RESET" "$_SONAR_DIM" "$_SONAR_RESET" "$_SONAR_WHITE" "$_SONAR_RESET"
    printf '  %badd%b %b<chave>%b         %bAdiciona um projeto à lista (sonar.json)%b\n' \
        "$_SONAR_GREEN" "$_SONAR_RESET" "$_SONAR_DIM" "$_SONAR_RESET" "$_SONAR_WHITE" "$_SONAR_RESET"
    printf '  %bremove%b %b<chave>%b      %bRemove um projeto da lista%b\n' \
        "$_SONAR_GREEN" "$_SONAR_RESET" "$_SONAR_DIM" "$_SONAR_RESET" "$_SONAR_WHITE" "$_SONAR_RESET"
    printf '  %buse%b %b<chave>%b         %bDefine o projeto ativo (project=)%b\n' \
        "$_SONAR_GREEN" "$_SONAR_RESET" "$_SONAR_DIM" "$_SONAR_RESET" "$_SONAR_WHITE" "$_SONAR_RESET"
    printf '  %bset%b %b[chave]%b         %bAtalho para "use"; sem chave usa a autodetecção do diretório%b\n' \
        "$_SONAR_GREEN" "$_SONAR_RESET" "$_SONAR_DIM" "$_SONAR_RESET" "$_SONAR_WHITE" "$_SONAR_RESET"
    printf '  %bvalidate%b %b<chave>%b    %bConfere se o projeto existe na instância%b\n' \
        "$_SONAR_GREEN" "$_SONAR_RESET" "$_SONAR_DIM" "$_SONAR_RESET" "$_SONAR_WHITE" "$_SONAR_RESET"
    printf '\n%bAtalho:%b bytebabe sonar %bproj%b %b<subcomando>%b\n\n' \
        "$_SONAR_YELLOW" "$_SONAR_RESET" "$_SONAR_GREEN" "$_SONAR_RESET" "$_SONAR_DIM" "$_SONAR_RESET"
}

sonar_project_validate() {
    local key="$1"
    local response

    if [[ -z "$key" ]]; then
        _sonar_project_usage >&2
        return 2
    fi
    if [[ -z "$SONAR_TOKEN" ]]; then
        printf '%b✗ Nenhum token configurado. Execute:%b %bbytebabe sonar login%b\n' \
            "$_SONAR_RED$_SONAR_BOLD" "$_SONAR_RESET" \
            "$_SONAR_GREEN$_SONAR_BOLD" "$_SONAR_RESET" >&2
        return 2
    fi

    if ! response="$(sonar_get '/api/components/show' \
        --data-urlencode "component=$key")"; then
        _sonar_error "Projeto não encontrado na instância: $key"
        return 1
    fi

    if jq -e '.component.key == $key' --arg key "$key" >/dev/null 2>&1 <<<"$response"; then
        _sonar_success "Projeto encontrado na instância: $key"
        return 0
    fi
    _sonar_error "Projeto não encontrado na instância: $key"
    return 1
}

sonar_project_list() {
    local active_key
    local raw_list
    local keys=()
    local k
    local marker
    local count=0

    active_key="$(_sonar_config_get project)"
    raw_list="$(_sonar_projects_get_list)"

    printf '\n%bPROJETOS CONFIGURADOS (sonar.json)%b\n\n' \
        "$_SONAR_BOLD$_SONAR_CYAN" "$_SONAR_RESET"

    for k in $raw_list; do
        [[ -z "$k" ]] && continue
        keys+=("$k")
        count=$((count + 1))
        marker="${_SONAR_DIM}·${_SONAR_RESET}"
        [[ "$k" == "$active_key" ]] && marker="${_SONAR_GREEN}${_SONAR_BOLD}✔${_SONAR_RESET}"
        printf '  %b %b%s%b\n' "$marker" "$_SONAR_WHITE$_SONAR_BOLD" "$k" "$_SONAR_RESET"
    done

    if (( count == 0 )); then
        printf '  %b(nenhum projeto na lista)%b\n' "$_SONAR_DIM" "$_SONAR_RESET"
    fi

    printf '\n  %bProjeto ativo (project=):%b %b%s%b\n' \
        "$_SONAR_DIM" "$_SONAR_RESET" "$_SONAR_GREEN$_SONAR_BOLD" "${active_key:-<vazio>}" "$_SONAR_RESET"
    printf '\n%b✔ ativo   Gerencie:%b %bbytebabe sonar project next/prev/search/use/add/remove%b\n\n' \
        "$_SONAR_GREEN" "$_SONAR_RESET" "$_SONAR_WHITE" "$_SONAR_RESET"
}

sonar_project_search() {
    local term="${1:-}"
    local raw_list
    local keys=()
    local filtered=()
    local k
    local choice
    local i=0

    raw_list="$(_sonar_projects_get_list)"
    for k in $raw_list; do
        [[ -n "$k" ]] && keys+=("$k")
    done

    if (( ${#keys[@]} == 0 )); then
        _sonar_error "Nenhum projeto na lista para pesquisar."
        return 1
    fi

    if [[ -n "$term" ]]; then
        for k in "${keys[@]}"; do
            if [[ "$k" == *"$term"* ]]; then
                filtered+=("$k")
            fi
        done
    else
        filtered=("${keys[@]}")
    fi

    if (( ${#filtered[@]} == 0 )); then
        _sonar_error "Nenhum projeto encontrado com o termo: $term"
        return 1
    fi

    if (( ${#filtered[@]} == 1 )); then
        sonar_project_use "${filtered[0]}"
        return $?
    fi

    printf '\n%bPESQUISAR PROJETO (selecione um)%b\n' "$_SONAR_BOLD$_SONAR_CYAN" "$_SONAR_RESET"
    for (( i=0; i<${#filtered[@]}; i++ )); do
        printf '  %b[%d]%b %s\n' "$_SONAR_GREEN" "$((i + 1))" "$_SONAR_RESET" "${filtered[i]}"
    done
    printf '  %b[q]%b cancelar\n' "$_SONAR_RED" "$_SONAR_RESET"

    printf '\nOpção: '
    read -r choice
    [[ "$choice" == "q" ]] && return 0

    if [[ "$choice" =~ ^[1-9][0-9]*$ ]] && (( choice <= ${#filtered[@]} )); then
        sonar_project_use "${filtered[$((choice - 1))]}"
    else
        _sonar_error "Opção inválida."
        return 1
    fi
}

sonar_project_add() {
    local key="${1:-}"
    local raw_list
    local keys=()
    local found=0
    local new_list=""
    local k

    if [[ -z "$key" ]]; then
        _sonar_project_usage >&2
        return 2
    fi

    raw_list="$(_sonar_projects_get_list)"
    for k in $raw_list; do
        [[ -n "$k" ]] && keys+=("$k")
        [[ "$k" == "$key" ]] && found=1
    done

    if (( found == 1 )); then
        _sonar_error "Projeto já está na lista: $key"
        return 2
    fi

    keys+=("$key")
    new_list="${keys[*]}"
    new_list="${new_list// /,}"

    _sonar_projects_set_list "$new_list"
    
    _sonar_success "Projeto adicionado à lista: $key"
    printf '%bPara definir como ativo, use:%b %bbytebabe sonar project use %s%b\n' \
        "$_SONAR_DIM" "$_SONAR_RESET" "$_SONAR_WHITE" "$key" "$_SONAR_RESET"

    if [[ -n "$SONAR_TOKEN" ]]; then
        sonar_project_validate "$key"
    fi
}

sonar_project_remove() {
    local key="${1:-}"
    local raw_list
    local keys=()
    local found=0
    local new_list=""
    local k

    if [[ -z "$key" ]]; then
        _sonar_project_usage >&2
        return 2
    fi

    raw_list="$(_sonar_projects_get_list)"
    for k in $raw_list; do
        if [[ "$k" == "$key" ]]; then
            found=1
        else
            [[ -n "$k" ]] && keys+=("$k")
        fi
    done

    if (( found == 0 )); then
        _sonar_error "Projeto não encontrado na lista: $key"
        return 2
    fi

    new_list="${keys[*]}"
    new_list="${new_list// /,}"

    _sonar_projects_set_list "$new_list"
    _sonar_success "Projeto removido da lista: $key"

    if [[ "$(_sonar_config_get project)" == "$key" ]]; then
        _sonar_config_set project "${keys[0]:-}"
        printf '%bℹ Ele era o projeto ativo; ativo alterado para: %s%b\n' \
            "$_SONAR_CYAN" "${keys[0]:-<vazio>}" "$_SONAR_RESET"
    fi
}

sonar_project_use() {
    local key="${1:-}"
    local raw_list
    local found=0
    local keys=()
    local new_list=""
    local k

    if [[ -z "$key" ]]; then
        key="$(_sonar_detect_project)"
        if [[ -z "$key" ]]; then
            printf '%b✗ Nenhum sonar-project.properties/.sonarcloud.properties encontrado a partir do diretório atual.%b\n' \
                "$_SONAR_RED$_SONAR_BOLD" "$_SONAR_RESET" >&2
            printf '%bInforme a chave explicitamente:%b %bbytebabe sonar project use <chave>%b\n' \
                "$_SONAR_DIM" "$_SONAR_RESET" "$_SONAR_WHITE" "$_SONAR_RESET" >&2
            return 2
        fi
        printf '%bℹ Autodetectado do diretório atual: %s%b\n' "$_SONAR_CYAN" "$key" "$_SONAR_RESET"
    fi

    raw_list="$(_sonar_projects_get_list)"
    for k in $raw_list; do
        [[ -n "$k" ]] && keys+=("$k")
        [[ "$k" == "$key" ]] && found=1
    done

    if (( found == 0 )); then
        keys+=("$key")
        new_list="${keys[*]}"
        new_list="${new_list// /,}"
        _sonar_projects_set_list "$new_list"
        printf '%bℹ Chave nova; adicionada à lista de projetos em sonar.json.%b\n' "$_SONAR_CYAN" "$_SONAR_RESET"
    fi

    _sonar_config_set project "$key"
    _sonar_success "Projeto ativo atualizado: $key"
}

# Dispatcher do CRUD: bytebabe sonar project <sub> [args].
# Sem subcomando, exibe o help.
sonar_project_cmd() {
    if (( $# == 0 )); then
        _sonar_project_usage
        return 0
    fi
    local sub="$1"
    shift 2>/dev/null || true

    case "$sub" in
        list|ls)
            sonar_project_list
            ;;
        next|n)
            sonar_project_next
            ;;
        prev|p)
            sonar_project_prev
            ;;
        current|curr|active)
            sonar_project_current
            ;;
        search)
            sonar_project_search "$@"
            ;;
        add)
            sonar_project_add "$@"
            ;;
        remove|rm)
            sonar_project_remove "$@"
            ;;
        use|set)
            sonar_project_use "$@"
            ;;
        validate)
            sonar_project_validate "$@"
            ;;
        help|-h|--help)
            _sonar_project_usage
            ;;
        *)
            printf 'Subcomando project inválido: %s\n' "$sub" >&2
            _sonar_project_usage >&2
            return 2
            ;;
    esac
}
