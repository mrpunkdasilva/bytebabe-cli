# ==================================================
# AZURE PULL REQUESTS & MERGE
# ==================================================

# Cria um pull request da branch atual
az_pr() {
    _az_check_repo || return 1
    check_az_cli || return 1

    local title=${1:-}
    local base=${2:-}

    if [ -z "$title" ]; then
        echo -e "${CYBER_RED}Especifique o título do pull request!${RESET}"
        echo -e "Uso: bytebabe azure pr <título> [base]"
        return 1
    fi

    [ -n "$base" ] || base=$(_az_default_base)
    if [ -z "$base" ]; then
        echo -e "${CYBER_RED}Não foi possível determinar a branch base!${RESET}"
        echo -e "Especifique a branch base: bytebabe azure pr \"$title\" <base>"
        return 1
    fi

    local current_branch
    current_branch=$(_az_current_branch)
    if [ -z "$current_branch" ]; then
        echo -e "${CYBER_RED}Não foi possível determinar a branch atual!${RESET}"
        return 1
    fi

    local body
    body=$(git log --format='- %s' "origin/$base..HEAD" 2>/dev/null || git log --format='- %s' "$base..HEAD" 2>/dev/null)

    echo -e "${CYBER_BLUE}Criando pull request de $current_branch para $base...${RESET}"
    if az repos pr create --detect false \
        --title "$title" \
        --source-branch "$current_branch" \
        --target-branch "$base" \
        --description "${body:-$title}" \
        --output table \
        --query '{ID:pullRequestId, Titulo:title, Status:status}'; then
        echo -e "${CYBER_GREEN}Pull request criado com sucesso!${RESET}"
    else
        echo -e "${CYBER_RED}Falha ao criar pull request!${RESET}"
        return 1
    fi
}

az_prs() {
    check_az_cli || return 1

    local query="" author="" mine=false target="" source="" type="" status="active" top="100"
    local group="" stats=false
    local extra_az=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -q|--query|-s|--search)
                query="$2"; shift 2 ;;
            -a|--author|--creator)
                author="$2"; shift 2 ;;
            -m|--mine)
                mine=true; shift ;;
            -t|--target|--target-branch)
                target="$2"; shift 2 ;;
            -b|--branch|--source|--source-branch)
                source="$2"; shift 2 ;;
            -T|--type|--category)
                type="$2"; shift 2 ;;
            --status)
                status="$2"; shift 2 ;;
            -n|--top|--limit)
                top="$2"; shift 2 ;;
            --group|--by-type|--categorize)
                group="type"; shift ;;
            --by-author)
                group="author"; shift ;;
            --by-target)
                group="target"; shift ;;
            --stats|--summary)
                stats=true; shift ;;
            -h|--help)
                _az_prs_help
                return 0 ;;
            --project|-p|--repository|-r|--org|--organization)
                extra_az+=("$1" "$2"); shift 2 ;;
            -*)
                extra_az+=("$1"); shift ;;
            *)
                if [ -z "$query" ]; then query="$1"; else query="$query $1"; fi
                shift ;;
        esac
    done

    if [ "$mine" = true ]; then
        local my_user
        my_user=$(git config user.name 2>/dev/null)
        [ -z "$my_user" ] && my_user=$(az account show --query "user.name" -o tsv 2>/dev/null)
        [ -z "$my_user" ] && my_user=$(whoami 2>/dev/null)
        author="$my_user"
    fi

    local az_cmd=(repos pr list --detect false --status "$status" --top "$top" --output tsv)
    az_cmd+=(--query "[].[pullRequestId, title, sourceRefName, targetRefName, createdBy.displayName, creationDate]")
    [ ${#extra_az[@]} -gt 0 ] && az_cmd+=("${extra_az[@]}")

    local raw_rows err_tmp
    err_tmp=$(mktemp "${TMPDIR:-/tmp}/bytebabe-az-err.XXXXXX")
    if ! raw_rows=$(az "${az_cmd[@]}" 2>"$err_tmp"); then
        local err_msg
        err_msg=$(cat "$err_tmp")
        rm -f "$err_tmp"
        echo -e "${CYBER_RED}Falha ao listar pull requests!${RESET}"
        _az_guidance "$err_msg"
        echo -e "${CYBER_YELLOW}Verifique se a organização e o projeto estão configurados (bytebabe azure setup).${RESET}"
        return 1
    fi
    rm -f "$err_tmp"

    if [ -z "$raw_rows" ]; then
        echo -e "${CYBER_YELLOW}Nenhum pull request encontrado no repositório/projeto atual.${RESET}"
        return 0
    fi

    local filter_parts=()
    [ -n "$query" ]  && filter_parts+=("termo=\"$query\"")
    [ -n "$author" ] && filter_parts+=("autor=\"$author\"")
    [ -n "$type" ]   && filter_parts+=("categoria=\"$type\"")
    [ -n "$target" ] && filter_parts+=("destino=\"$target\"")
    [ -n "$source" ] && filter_parts+=("origem=\"$source\"")
    local filter_desc=""
    if [ ${#filter_parts[@]} -gt 0 ]; then
        filter_desc=$(IFS=" | "; echo "${filter_parts[*]}")
    fi

    local tab
    tab=$(printf '\t')
    local filtered_rows=""
    local id title src dst auth created pr_cat keep
    local count_filtered=0
    local total_fetched=0

    while IFS="$tab" read -r id title src dst auth created; do
        [ -z "$id" ] && continue
        ((total_fetched++))
        keep=true

        if [ -n "$type" ]; then
            pr_cat=$(_az_classify_pr "$title")
            local t_norm
            t_norm=$(echo "$type" | tr '[:upper:]' '[:lower:]')
            [[ "$pr_cat" != "$t_norm"* ]] && keep=false
        fi

        if [ "$keep" = true ] && [ -n "$author" ]; then
            local auth_lower query_auth_lower
            auth_lower=$(echo "$auth" | tr '[:upper:]' '[:lower:]')
            query_auth_lower=$(echo "$author" | tr '[:upper:]' '[:lower:]')
            [[ "$auth_lower" != *"$query_auth_lower"* ]] && keep=false
        fi

        if [ "$keep" = true ] && [ -n "$target" ]; then
            local dst_clean dst_lower target_lower
            dst_clean="${dst#refs/heads/}"; dst_clean="${dst_clean#refs/tags/}"
            dst_lower=$(echo "$dst_clean" | tr '[:upper:]' '[:lower:]')
            target_lower=$(echo "$target" | tr '[:upper:]' '[:lower:]')
            [[ "$dst_lower" != *"$target_lower"* ]] && keep=false
        fi

        if [ "$keep" = true ] && [ -n "$source" ]; then
            local src_clean src_lower source_lower
            src_clean="${src#refs/heads/}"; src_clean="${src_clean#refs/tags/}"
            src_lower=$(echo "$src_clean" | tr '[:upper:]' '[:lower:]')
            source_lower=$(echo "$source" | tr '[:upper:]' '[:lower:]')
            [[ "$src_lower" != *"$source_lower"* ]] && keep=false
        fi

        if [ "$keep" = true ] && [ -n "$query" ]; then
            local row_combined q_lower
            row_combined=$(echo "$id $title $src $dst $auth" | tr '[:upper:]' '[:lower:]')
            q_lower=$(echo "$query" | tr '[:upper:]' '[:lower:]')
            [[ "$row_combined" != *"$q_lower"* ]] && keep=false
        fi

        if [ "$keep" = true ]; then
            ((count_filtered++))
            if [ -z "$filtered_rows" ]; then
                filtered_rows=$(printf "%s\t%s\t%s\t%s\t%s\t%s" "$id" "$title" "$src" "$dst" "$auth" "$created")
            else
                filtered_rows=$(printf "%s\n%s\t%s\t%s\t%s\t%s\t%s" "$filtered_rows" "$id" "$title" "$src" "$dst" "$auth" "$created")
            fi
        fi
    done <<< "$raw_rows"

    if [ "$count_filtered" -eq 0 ]; then
        echo -e "\n${CYBER_YELLOW}⚡ Nenhum pull request encontrado com os filtros aplicados:${RESET}"
        [ -n "$filter_desc" ] && echo -e "  ${CYBER_WHITE}${filter_desc}${RESET}"
        echo -e "\n${CYBER_CYAN}Dica:${RESET} Liste todos os PRs ativos com: ${CYBER_GREEN}bytebabe az prs${RESET}\n"
        return 0
    fi

    _render_output() {
        if [ "$stats" = true ]; then
            _az_prs_render_stats "$filtered_rows"
        elif [ -n "$group" ]; then
            _az_prs_render_grouped "$filtered_rows" "$group" "$filter_desc"
        else
            _az_prs_render_list "$filtered_rows" "$filter_desc" "$total_fetched"
        fi
    }

    if command -v less >/dev/null 2>&1 && [ -t 1 ]; then
        _render_output | less -FRX
    else
        _render_output
    fi
}

az_merge() {
    check_az_cli || return 1

    local id=${1:-}
    local method=${2:-merge}
    local squash

    case "$method" in
        merge) squash=false ;;
        squash) squash=true ;;
        *)
            echo -e "${CYBER_RED}Método inválido: $method${RESET}"
            echo -e "Uso: bytebabe azure merge [id] [merge|squash]"
            return 1
            ;;
    esac

    if [ -z "$id" ]; then
        _az_check_repo || return 1
        local current_branch
        current_branch=$(_az_current_branch)
        id=$(az repos pr list --detect false --status active --source-branch "$current_branch" \
            --query "[0].pullRequestId" --output tsv 2>/dev/null)
        if [ -z "$id" ]; then
            echo -e "${CYBER_RED}Nenhum pull request ativo para a branch $current_branch!${RESET}"
            return 1
        fi
    fi

    if [[ ! "$id" =~ ^[0-9]+$ ]]; then
        echo -e "${CYBER_RED}ID de pull request inválido: $id${RESET}"
        return 1
    fi

    echo -e "${CYBER_BLUE}Fazendo merge (${method}) do pull request $id...${RESET}"
    if az repos pr update --detect false --id "$id" --status completed --squash "$squash" \
        --output table --query '{ID:pullRequestId, Status:status}'; then
        echo -e "${CYBER_GREEN}Merge solicitado com sucesso!${RESET}"
        echo -e "${CYBER_YELLOW}Se houver políticas de branch, o merge conclui após as aprovações.${RESET}"
    else
        echo -e "${CYBER_RED}Falha ao fazer merge do pull request!${RESET}"
        return 1
    fi
}
