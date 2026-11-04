# ==================================================
# AZURE PROJECTS, REPOS, BRANCHES & OPERATIONS
# ==================================================

# Lista projetos da organização (padrão configurado ou informada)
az_projects() {
    check_az_cli || return 1

    local args=(devops project list --detect false --output tsv)
    local org_url=""
    if [ -n "${1:-}" ]; then
        org_url=$(_az_org_url "$1")
        args+=(--organization "$org_url")
    fi
    # Versões novas do az retornam {value: [...]}; antigas, uma lista
    args+=(--query "sort_by((value || @), &name)[].[name, visibility, lastUpdateTime]")

    local rows err_tmp
    err_tmp=$(mktemp "${TMPDIR:-/tmp}/bytebabe-az-err.XXXXXX")
    if ! rows=$(az "${args[@]}" 2>"$err_tmp"); then
        local err_msg
        err_msg=$(cat "$err_tmp")
        rm -f "$err_tmp"
        echo -e "${CYBER_RED}Falha ao listar projetos!${RESET}"
        _az_guidance "$err_msg"
        echo -e "${CYBER_YELLOW}Verifique a organização (nome ou URL https://dev.azure.com/<org>) e o login (az login).${RESET}"
        echo -e "${CYBER_YELLOW}Sem argumento, é usada a organização padrão: bytebabe azure setup <org>${RESET}"
        return 1
    fi
    rm -f "$err_tmp"

    if [ -z "$rows" ]; then
        echo -e "${CYBER_YELLOW}Nenhum projeto encontrado.${RESET}"
        return 0
    fi

    echo -e "${CYBER_BLUE}Projetos do Azure DevOps${org_url:+ em ${CYBER_CYAN}${org_url}}${RESET}\n"
    printf "  ${CYBER_PURPLE}%-4s %-40s %-12s %s${RESET}\n" "#" "PROJETO" "VISIBILIDADE" "ATUALIZADO"
    local i=0 name visibility updated
    while IFS=$'\t' read -r name visibility updated; do
        i=$((i + 1))
        printf "  ${CYBER_CYAN}%-4s${RESET} ${CYBER_GREEN}%-40.40s${RESET} %-12s %s\n" "$i" "$name" "$visibility" "${updated%%T*}"
    done <<< "$rows"
    echo -e "\n${CYBER_BLUE}Total: ${CYBER_GREEN}${i}${CYBER_BLUE} projeto(s)${RESET}"
}

# Lista refs (branchs ou tags) de um repositório em tabela compacta e paginada
_az_refs_table() {
    local repo=$1 kind=$2 org=${3:-}
    local prefix label usage noun
    case "$kind" in
        heads)
            prefix="refs/heads/"
            label="BRANCH"
            noun="branchs"
            usage="bytebabe az branches <repo> [organização]"
            ;;
        tags)
            prefix="refs/tags/"
            label="TAG"
            noun="tags"
            usage="bytebabe az tags <repo> [organização]"
            ;;
        *)
            return 1
            ;;
    esac

    check_az_cli || return 1

    if [ -z "$repo" ]; then
        echo -e "${CYBER_RED}Especifique o repositório!${RESET}"
        echo -e "Uso: $usage"
        return 1
    fi

    local args=(repos ref list --detect false --repository "$repo" --output json)
    local org_url=""
    if [ -n "$org" ]; then
        org_url=$(_az_org_url "$org")
        args+=(--organization "$org_url")
    fi
    local query_str="[?starts_with(name, '${prefix}')].{ref: name, id: objectId, autor: (creator.displayName || '-')}"
    args+=(--query "$query_str")

    local payload err_tmp
    err_tmp=$(mktemp "${TMPDIR:-/tmp}/bytebabe-az-err.XXXXXX")
    if ! payload=$(az "${args[@]}" 2>"$err_tmp"); then
        local err_msg
        err_msg=$(cat "$err_tmp")
        rm -f "$err_tmp"
        echo -e "${CYBER_RED}Falha ao listar $noun do repositório '$repo'!${RESET}"
        _az_guidance "$err_msg"
        echo -e "${CYBER_YELLOW}Verifique o nome/ID do repositório e as suas permissões.${RESET}"
        return 1
    fi
    rm -f "$err_tmp"

    # Versões novas do az retornam {value: [...]}; antigas, uma lista.
    # Aceita tanto o payload já projetado pela --query (ref/id/autor)
    # quanto o payload cru (name/objectId/creator.displayName).
    local rows
    rows=$(printf '%s' "$payload" | jq -r '
        ( .value // . )
        | map({
            ref:   ((.ref // .name) // "" | sub("^refs/(heads|tags)/"; "")),
            id:    ((.id // .objectId) // "" | if (type == "string" or type == "number") and (length | tonumber) >= 8 then tostring[0:8] else tostring end),
            autor: ((.autor // (.creator.displayName // null)) // "-")
          })
        | sort_by(.ref)
        | .[] | [.ref, .id, .autor]
        | @tsv' 2>/dev/null)
    if [ -z "$rows" ]; then
        echo -e "${CYBER_YELLOW}Nenhum(a) $noun encontrado(a).${RESET}"
        return 0
    fi

    local noun_cap
    noun_cap="$(tr '[:lower:]' '[:upper:]' <<< "${noun:0:1}")${noun:1}"

    echo -e "${CYBER_BLUE}${noun_cap} de ${CYBER_CYAN}$repo${org_url:+ em ${CYBER_CYAN}$org_url}${RESET}\n"
    if command -v less >/dev/null 2>&1 && [ -t 1 ]; then
        printf '%s\tID\tAUTOR\n%s\n' "$label" "$rows" | _az_print_tsv_table list | less -FRX
    else
        printf '%s\tID\tAUTOR\n%s\n' "$label" "$rows" | _az_print_tsv_table list
    fi
    echo -e "\n${CYBER_BLUE}Total: ${CYBER_GREEN}$(printf '%s\n' "$rows" | wc -l)${CYBER_BLUE} $noun${RESET}"
}

az_branches() {
    _az_refs_table "${1:-}" heads "${2:-}"
}

# Lista as tags (refs/tags) de um repositório em tabela compacta e paginada
az_tags() {
    _az_refs_table "${1:-}" tags "${2:-}"
}

az_operations() {
    local group=$1
    shift
    local args=()
    if [[ "$group" == cli ]]; then
        if ! command -v az >/dev/null 2>&1; then
            echo "Azure CLI não instalado. Execute: bytebabe azure install" >&2
            return 1
        fi
    else
        check_az_cli || return 1
        case "$group" in
            project) args=(devops project) ;;
            repo) args=(repos) ;;
            pr-manage) args=(repos pr) ;;
            pipeline) args=(pipelines) ;;
            boards) args=(boards) ;;
            artifacts) args=(artifacts) ;;
            devops) args=(devops) ;;
            *) return 1 ;;
        esac
    fi
    if (( $# == 0 )); then
        args+=(--help)
    else
        args+=("$@")
    fi
    _az_run "${args[@]}"
}
