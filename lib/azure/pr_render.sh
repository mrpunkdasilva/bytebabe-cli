# ==================================================
# AZURE PULL REQUESTS — CLASSIFICAÇÃO & RENDERIZAÇÃO
# ==================================================

# Classifica o PR pelo padrão de commits convencionais ou tags comuns
_az_classify_pr() {
    local lower
    lower=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    if [[ "$lower" =~ (^|[^a-z])(fix|bug|hotfix) ]]; then
        echo "fix"
    elif [[ "$lower" =~ (^|[^a-z])(feat|feature) ]]; then
        echo "feat"
    elif [[ "$lower" =~ (^|[^a-z])(refactor|perf) ]]; then
        echo "refactor"
    elif [[ "$lower" =~ (^|[^a-z])(chore|docs|test|ci|deps|types|bump) ]]; then
        echo "chore"
    elif [[ "$lower" =~ (task|historia|pti) ]]; then
        echo "task"
    else
        echo "other"
    fi
}

_az_pr_badge() {
    case "$1" in
        feat)     printf "${CYBER_GREEN}✨ FEAT    ${RESET}" ;;
        fix)      printf "${CYBER_RED}🐛 FIX     ${RESET}" ;;
        refactor) printf "${CYBER_BLUE}♻️ REFACTOR${RESET}" ;;
        chore)    printf "${CYBER_YELLOW}🧹 CHORE   ${RESET}" ;;
        task)     printf "${CYBER_PURPLE}📋 TASK    ${RESET}" ;;
        *)        printf "${CYBER_CYAN}📦 OUTRO   ${RESET}" ;;
    esac
}

_az_pr_category_name() {
    case "$1" in
        feat)     echo "✨ FEATURES" ;;
        fix)      echo "🐛 BUG FIXES" ;;
        refactor) echo "♻️ REFACTORING" ;;
        chore)    echo "🧹 CHORES & MANUTENÇÃO" ;;
        task)     echo "📋 TAREFAS & HISTÓRIAS" ;;
        *)        echo "📦 OUTROS" ;;
    esac
}

_az_pr_category_color() {
    case "$1" in
        feat)     echo "$CYBER_GREEN" ;;
        fix)      echo "$CYBER_RED" ;;
        refactor) echo "$CYBER_BLUE" ;;
        chore)    echo "$CYBER_YELLOW" ;;
        task)     echo "$CYBER_PURPLE" ;;
        *)        echo "$CYBER_CYAN" ;;
    esac
}

_az_pad_label() {
    local text="$1" target_width="${2:-16}"
    local clean="${text//$'\xef\xb8\x8f'/}"
    printf "%s" "$text"
    local pad=$(( target_width - ${#clean} - 1 ))
    (( pad < 0 )) && pad=0
    printf "%*s" "$pad" ""
}

_az_pr_bar() {
    local label="$1" pct="$2" count="$3" color="$4"
    local width=20 filled i bar=""
    (( pct > 100 )) && pct=100
    filled=$(( pct * width / 100 ))
    for (( i = 0; i < width; i++ )); do
        if (( i < filled )); then bar+="█"; else bar+="░"; fi
    done
    printf "  "
    _az_pad_label "$label" 16
    printf "${CYBER_PURPLE}[${color}%s${CYBER_PURPLE}]${RESET} %3d%%  ${CYBER_GRAY}(%d)${RESET}\n" "$bar" "$pct" "$count"
}

_az_prs_help() {
    echo -e "\n${CYBER_PURPLE}▓▒░ ${CYBER_BLUE}AJUDA: PESQUISA, FILTROS E CATEGORIZAÇÃO DE PRs${CYBER_PURPLE} ░▒▓${RESET}\n"
    echo -e "  ${CYBER_CYAN}bytebabe az prs [termo] [opções]${RESET}\n"
    echo -e "${CYBER_YELLOW}BUSCA E FILTROS:${RESET}"
    echo -e "  ${CYBER_GREEN}<termo>${RESET}                   Busca em título, autor, branch ou ID"
    echo -e "  ${CYBER_GREEN}-q, --query <termo>${RESET}       Busca por texto específico"
    echo -e "  ${CYBER_GREEN}-a, --author <nome>${RESET}       Filtra por nome do autor"
    echo -e "  ${CYBER_GREEN}-m, --mine${RESET}                Filtra PRs criados por você"
    echo -e "  ${CYBER_GREEN}-T, --type <tipo>${RESET}         Filtra por categoria (feat, fix, chore, refactor, task, other)"
    echo -e "  ${CYBER_GREEN}-t, --target <branch>${RESET}     Filtra por branch de destino (ex: master, develop)"
    echo -e "  ${CYBER_GREEN}-b, --source <branch>${RESET}     Filtra por branch de origem"
    echo -e "  ${CYBER_GREEN}--status <status>${RESET}         Status: active (padrão), completed, abandoned, all"
    echo -e "  ${CYBER_GREEN}-n, --top <num>${RESET}           Limite de PRs a consultar (padrão: 100)"
    echo
    echo -e "${CYBER_YELLOW}VISUALIZAÇÕES E AGRUPAMENTO:${RESET}"
    echo -e "  ${CYBER_GREEN}--group, --by-type${RESET}        Agrupa PRs por categoria (Features, Fixes, Chores...)"
    echo -e "  ${CYBER_GREEN}--by-author${RESET}               Agrupa PRs por autor"
    echo -e "  ${CYBER_GREEN}--by-target${RESET}               Agrupa PRs por branch de destino"
    echo -e "  ${CYBER_GREEN}--stats, --summary${RESET}        Exibe dashboard com métricas e distribuição gráfica"
    echo
    echo -e "${CYBER_YELLOW}EXEMPLOS:${RESET}"
    echo -e "  ${CYBER_CYAN}$ bytebabe az prs${RESET}                          # Lista estilizada com badges de tipo"
    echo -e "  ${CYBER_CYAN}$ bytebabe az prs \"rum\"${RESET}                    # Procura 'rum' em qualquer campo"
    echo -e "  ${CYBER_CYAN}$ bytebabe az prs --author \"Gustavo\"${RESET}        # PRs do Gustavo"
    echo -e "  ${CYBER_CYAN}$ bytebabe az prs --mine${RESET}                      # Meus PRs"
    echo -e "  ${CYBER_CYAN}$ bytebabe az prs --type fix${RESET}                 # Apenas correções de bugs"
    echo -e "  ${CYBER_CYAN}$ bytebabe az prs --target develop${RESET}            # Apenas com destino develop"
    echo -e "  ${CYBER_CYAN}$ bytebabe az prs --group${RESET}                     # Agrupados por categoria"
    echo -e "  ${CYBER_CYAN}$ bytebabe az prs --by-author${RESET}                 # Agrupados por autor"
    echo -e "  ${CYBER_CYAN}$ bytebabe az prs --stats${RESET}                     # Dashboard com porcentagens e barras"
    echo
}

_az_prs_render_stats() {
    local rows="$1"
    local tab
    tab=$(printf '\t')

    local total=0
    local -A cat_counts=()
    local -A author_counts=()
    local -A target_counts=()

    local id title src dst author created cat
    while IFS="$tab" read -r id title src dst author created; do
        [ -z "$id" ] && continue
        ((total++))
        cat=$(_az_classify_pr "$title")
        ((cat_counts[$cat]++))
        author="${author:-Desconhecido}"
        ((author_counts["$author"]++))
        dst="${dst#refs/heads/}"; dst="${dst#refs/tags/}"
        ((target_counts["$dst"]++))
    done <<< "$rows"

    echo -e "\n${CYBER_PURPLE}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_PURPLE}║${RESET}           ${CYBER_CYAN}📊 AZURE PULL REQUESTS DASHBOARD${RESET}                   ${CYBER_PURPLE}║${RESET}"
    echo -e "${CYBER_PURPLE}╚══════════════════════════════════════════════════════════════╝${RESET}"

    echo -e "\n  ${CYBER_BLUE}Total de PRs analisados:${RESET} ${CYBER_GREEN}${total}${RESET}\n"

    echo -e "  ${CYBER_YELLOW}⚡ DISTRIBUIÇÃO POR CATEGORIA:${RESET}"
    local c cnt pct col name
    for c in feat fix chore task refactor other; do
        cnt=${cat_counts[$c]:-0}
        pct=$(( total > 0 ? cnt * 100 / total : 0 ))
        col=$(_az_pr_category_color "$c")
        case "$c" in
            feat)     name="✨ Features" ;;
            fix)      name="🐛 Bug Fixes" ;;
            chore)    name="🧹 Chores" ;;
            task)     name="📋 Tarefas" ;;
            refactor) name="♻️ Refactor" ;;
            *)        name="📦 Outros" ;;
        esac
        _az_pr_bar "$name" "$pct" "$cnt" "$col"
    done

    echo -e "\n  ${CYBER_YELLOW}🎯 PRINCIPAIS BRANCHES DE DESTINO:${RESET}"
    for dst in "${!target_counts[@]}"; do
        printf "%d\t%s\n" "${target_counts[$dst]}" "$dst"
    done | sort -rn | head -n 5 | while IFS="$tab" read -r cnt dst; do
        printf "    ${CYBER_PURPLE}➔${RESET} ${CYBER_BLUE}%-28s${RESET} ${CYBER_GREEN}%3d PRs${RESET}\n" "$dst" "$cnt"
    done

    echo -e "\n  ${CYBER_YELLOW}👑 TOP CONTRIBUIDORES:${RESET}"
    local rank=1
    for aut in "${!author_counts[@]}"; do
        printf "%d\t%s\n" "${author_counts[$aut]}" "$aut"
    done | sort -rn | head -n 5 | while IFS="$tab" read -r cnt aut; do
        printf "    ${CYBER_CYAN}%d.${RESET} ${CYBER_WHITE}%-32.32s${RESET} ${CYBER_GREEN}%3d PR(s)${RESET}\n" "$rank" "$aut" "$cnt"
        ((rank++))
    done

    echo -e "\n${CYBER_PURPLE}▓▒░────────────────────────────────────────────────────────────░▒▓${RESET}\n"
}

_az_prs_render_grouped() {
    local rows="$1" group_mode="$2" filter_desc="$3"
    local tab
    tab=$(printf '\t')

    case "$group_mode" in
        type)
            echo -e "\n${CYBER_PURPLE}▓▒░ ${CYBER_BLUE}PULL REQUESTS AGRUPADOS POR CATEGORIA${CYBER_PURPLE} ░▒▓${RESET}"
            [ -n "$filter_desc" ] && echo -e "  ${CYBER_YELLOW}🔍 Filtro:${RESET} ${CYBER_WHITE}${filter_desc}${RESET}"

            local c cat_name cat_col
            for c in feat fix refactor chore task other; do
                cat_name=$(_az_pr_category_name "$c")
                cat_col=$(_az_pr_category_color "$c")

                local cat_rows=""
                local cnt=0 id title src dst author created cat
                while IFS="$tab" read -r id title src dst author created; do
                    [ -z "$id" ] && continue
                    cat=$(_az_classify_pr "$title")
                    if [ "$cat" = "$c" ]; then
                        ((cnt++))
                        if [ -z "$cat_rows" ]; then
                            cat_rows=$(printf "%s\t%s\t%s\t%s\t%s\t%s" "$id" "$title" "$src" "$dst" "$author" "$created")
                        else
                            cat_rows=$(printf "%s\n%s\t%s\t%s\t%s\t%s\t%s" "$cat_rows" "$id" "$title" "$src" "$dst" "$author" "$created")
                        fi
                    fi
                done <<< "$rows"

                if [ "$cnt" -gt 0 ]; then
                    echo -e "\n  ${cat_col}${cat_name}${RESET} ${CYBER_GRAY}(${cnt})${RESET}"
                    echo -e "  ${CYBER_PURPLE}────────────────────────────────────────────────────────────────${RESET}"
                    while IFS="$tab" read -r id title src dst author created; do
                        [ -z "$id" ] && continue
                        src="${src#refs/heads/}"; src="${src#refs/tags/}"
                        dst="${dst#refs/heads/}"; dst="${dst#refs/tags/}"
                        local dt="${created%%T*}"
                        echo -e "    ${CYBER_YELLOW}⚡${RESET} ${CYBER_CYAN}#${id}${RESET}  ${CYBER_WHITE}${title}${RESET}"
                        echo -e "       ${CYBER_PURPLE}└─${RESET} ${CYBER_BLUE}${src}${RESET} ${CYBER_PURPLE}➔${RESET} ${CYBER_YELLOW}${dst}${RESET}  ${CYBER_GRAY}•  ${author}${dt:+  •  $dt}${RESET}"
                    done <<< "$cat_rows"
                fi
            done
            ;;

        author)
            echo -e "\n${CYBER_PURPLE}▓▒░ ${CYBER_BLUE}PULL REQUESTS AGRUPADOS POR AUTOR${CYBER_PURPLE} ░▒▓${RESET}"
            [ -n "$filter_desc" ] && echo -e "  ${CYBER_YELLOW}🔍 Filtro:${RESET} ${CYBER_WHITE}${filter_desc}${RESET}"

            local -A author_counts=()
            local id title src dst author created
            while IFS="$tab" read -r id title src dst author created; do
                [ -z "$id" ] && continue
                author="${author:-Desconhecido}"
                ((author_counts["$author"]++))
            done <<< "$rows"

            for aut in "${!author_counts[@]}"; do
                printf "%d\t%s\n" "${author_counts[$aut]}" "$aut"
            done | sort -rn | while IFS="$tab" read -r cnt aut; do
                echo -e "\n  ${CYBER_CYAN}👤 ${aut}${RESET} ${CYBER_GRAY}(${cnt} PRs)${RESET}"
                echo -e "  ${CYBER_PURPLE}────────────────────────────────────────────────────────────────${RESET}"
                while IFS="$tab" read -r id title src dst author created; do
                    [ -z "$id" ] && continue
                    author="${author:-Desconhecido}"
                    if [ "$author" = "$aut" ]; then
                        src="${src#refs/heads/}"; src="${src#refs/tags/}"
                        dst="${dst#refs/heads/}"; dst="${dst#refs/tags/}"
                        local cat badge dt
                        cat=$(_az_classify_pr "$title")
                        badge=$(_az_pr_badge "$cat")
                        dt="${created%%T*}"
                        echo -e "    ${CYBER_YELLOW}⚡${RESET} ${CYBER_CYAN}#${id}${RESET}  ${badge}  ${CYBER_WHITE}${title}${RESET}"
                        echo -e "       ${CYBER_PURPLE}└─${RESET} ${CYBER_BLUE}${src}${RESET} ${CYBER_PURPLE}➔${RESET} ${CYBER_YELLOW}${dst}${RESET}${dt:+  ${CYBER_GRAY}•  $dt}${RESET}"
                    fi
                done <<< "$rows"
            done
            ;;

        target)
            echo -e "\n${CYBER_PURPLE}▓▒░ ${CYBER_BLUE}PULL REQUESTS AGRUPADOS POR BRANCH DE DESTINO${CYBER_PURPLE} ░▒▓${RESET}"
            [ -n "$filter_desc" ] && echo -e "  ${CYBER_YELLOW}🔍 Filtro:${RESET} ${CYBER_WHITE}${filter_desc}${RESET}"

            local -A target_counts=()
            local id title src dst author created
            while IFS="$tab" read -r id title src dst author created; do
                [ -z "$id" ] && continue
                dst="${dst#refs/heads/}"; dst="${dst#refs/tags/}"
                ((target_counts["$dst"]++))
            done <<< "$rows"

            for t_branch in "${!target_counts[@]}"; do
                printf "%d\t%s\n" "${target_counts[$t_branch]}" "$t_branch"
            done | sort -rn | while IFS="$tab" read -r cnt t_branch; do
                echo -e "\n  ${CYBER_YELLOW}🎯 Destino: ${t_branch}${RESET} ${CYBER_GRAY}(${cnt} PRs)${RESET}"
                echo -e "  ${CYBER_PURPLE}────────────────────────────────────────────────────────────────${RESET}"
                while IFS="$tab" read -r id title src dst author created; do
                    [ -z "$id" ] && continue
                    local dst_clean="${dst#refs/heads/}"; dst_clean="${dst_clean#refs/tags/}"
                    if [ "$dst_clean" = "$t_branch" ]; then
                        src="${src#refs/heads/}"; src="${src#refs/tags/}"
                        local cat badge dt
                        cat=$(_az_classify_pr "$title")
                        badge=$(_az_pr_badge "$cat")
                        dt="${created%%T*}"
                        echo -e "    ${CYBER_YELLOW}⚡${RESET} ${CYBER_CYAN}#${id}${RESET}  ${badge}  ${CYBER_WHITE}${title}${RESET}"
                        echo -e "       ${CYBER_PURPLE}└─${RESET} ${CYBER_BLUE}${src}${RESET}  ${CYBER_GRAY}•  ${author}${dt:+  •  $dt}${RESET}"
                    fi
                done <<< "$rows"
            done
            ;;
    esac

    echo -e "\n${CYBER_PURPLE}▓▒░────────────────────────────────────────────────────────────░▒▓${RESET}\n"
}

_az_prs_render_list() {
    local rows="$1" filter_desc="$2" total_fetched="$3"
    local tab
    tab=$(printf '\t')

    echo -e "\n${CYBER_PURPLE}▓▒░ ${CYBER_BLUE}PULL REQUESTS (AZURE DEVOPS)${CYBER_PURPLE} ░▒▓${RESET}"
    if [ -n "$filter_desc" ]; then
        echo -e "  ${CYBER_YELLOW}🔍 Filtro:${RESET} ${CYBER_WHITE}${filter_desc}${RESET}"
    fi
    echo

    local count=0 id title src dst author created cat badge dt
    while IFS="$tab" read -r id title src dst author created; do
        [ -z "$id" ] && continue
        ((count++))
        src="${src#refs/heads/}"; src="${src#refs/tags/}"
        dst="${dst#refs/heads/}"; dst="${dst#refs/tags/}"
        cat=$(_az_classify_pr "$title")
        badge=$(_az_pr_badge "$cat")
        dt="${created%%T*}"
        echo -e "  ${CYBER_YELLOW}⚡${RESET} ${CYBER_CYAN}#${id}${RESET}  ${badge}  ${CYBER_WHITE}${title}${RESET}"
        echo -e "     ${CYBER_PURPLE}└─${RESET} ${CYBER_BLUE}${src}${RESET} ${CYBER_PURPLE}➔${RESET} ${CYBER_YELLOW}${dst}${RESET}  ${CYBER_GRAY}•  ${author}${dt:+  •  $dt}${RESET}"
        echo
    done <<< "$rows"

    echo -e "${CYBER_PURPLE}▓▒░────────────────────────────────────────────────────────────░▒▓${RESET}"
    if [ "$count" -eq "$total_fetched" ]; then
        echo -e "  ${CYBER_BLUE}Total: ${CYBER_GREEN}${count}${CYBER_BLUE} pull request(s)${RESET}\n"
    else
        echo -e "  ${CYBER_BLUE}Total: ${CYBER_GREEN}${count}${CYBER_BLUE} exibido(s) de ${CYBER_GRAY}${total_fetched} analisados${RESET}\n"
    fi
}
