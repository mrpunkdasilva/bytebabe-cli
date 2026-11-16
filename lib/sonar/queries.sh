#!/bin/bash

# ==================================================
# SONAR MODULE — consultas (somente leitura)
# Apenas funções; carregar este arquivo não faz requisições.
# ==================================================

_sonar_print_rule() {
    local rule_key="$1"
    local response
    local description
    local is_html=false

    response="$(sonar_get '/api/rules/show' --data-urlencode "key=$rule_key")"
    description="$(jq -r '.rule.htmlDesc // .rule.mdDesc // .rule.description // "Descrição indisponível"' <<<"$response")"
    [[ "$(jq -r '.rule.htmlDesc // empty' <<<"$response")" ]] && is_html=true

    printf '\n%bREGRA%b  %b%s%b\n' "$_SONAR_BOLD$_SONAR_CYAN" "$_SONAR_RESET" "$_SONAR_BOLD$_SONAR_WHITE" \
        "$(jq -r '.rule.name // .rule.key' <<<"$response")"
    printf '%b%s%b\n' "$_SONAR_DIM" '-----------------------------------------------------------------------' "$_SONAR_RESET"
    sonar_field 'CHAVE' "$(jq -r '.rule.key' <<<"$response")"
    sonar_field 'LINGUAGEM' "$(jq -r '.rule.langName // .rule.lang // "-"' <<<"$response")"
    sonar_field 'TIPO' "$(sonar_translate_type "$(jq -r '.rule.type // "-"' <<<"$response")")"
    sonar_field 'SEVERIDADE' "$(sonar_translate_severity "$(jq -r '.rule.severity // "-"' <<<"$response")")"
    sonar_field 'TAGS' "$(jq -r '(.rule.tags // []) | join(", ")' <<<"$response")"
    sonar_description 'POR QUE:' "$description" "$is_html"
}

_sonar_show_issue() {
    local issue_key="$1"
    local response
    local issue
    local component
    local rule_key

    response="$(sonar_get '/api/issues/search' \
        --data-urlencode "issues=$issue_key" \
        --data-urlencode "componentKeys=$_SONAR_PROJECT" \
        --data-urlencode 'p=1' --data-urlencode 'ps=1')"
    issue="$(jq -c '.issues[0] // empty' <<<"$response")"
    if [[ -z "$issue" ]]; then
        printf 'Apontamento não encontrado ou sem permissão de leitura: %s\n' "$issue_key" >&2
        return 1
    fi

    component="$(jq -r --arg key "$(jq -r '.component' <<<"$issue")" \
        '([.[] | select(.key == $key) | (.path // .longName // .name)] | first) // $key' \
        <<<"$(jq -c '.components // []' <<<"$response")")"
    rule_key="$(jq -r '.rule' <<<"$issue")"

    printf '\n'
    printf '%b%s%b\n' "$_SONAR_DIM" '=======================================================================' "$_SONAR_RESET"
    sonar_field 'CHAVE' "$(sonar_issue_link "$issue_key")"
    sonar_field 'TIPO' "$(sonar_translate_type "$(jq -r '.type // (.impacts[0].softwareQuality // "-" )' <<<"$issue")")"
    sonar_field 'SEVERIDADE' "$(sonar_translate_severity "$(jq -r '.severity // (.impacts[0].severity // "-")' <<<"$issue")")"
    sonar_field 'SITUAÇÃO' "$(sonar_translate_status "$(jq -r '.status // "-"' <<<"$issue")")"
    sonar_field 'LOCAL' "$component:$(jq -r '.line // .textRange.startLine // "-"' <<<"$issue")"
    sonar_field 'MENSAGEM' "$(jq -r '.message // "-"' <<<"$issue")"
    sonar_field 'ESFORCO' "$(jq -r '.effort // "-"' <<<"$issue")"
    sonar_field 'REGRA' "$rule_key"
    _sonar_print_rule "$rule_key"
}

_sonar_query_rules() {
    local term="${1:-}"
    local response

    if [[ -n "$term" ]]; then
        response="$(sonar_get '/api/rules/search' \
            --data-urlencode "q=$term" \
            --data-urlencode 'p=1' --data-urlencode 'ps=100')"
    else
        response="$(sonar_get '/api/rules/search' \
            --data-urlencode 'p=1' --data-urlencode 'ps=100')"
    fi

    local total
    total="$(jq -r '.paging.total // 0' <<<"$response")"

    printf '%b  %-40s %-14s %-14s %-12s %s%b\n' "$_SONAR_BOLD$_SONAR_CYAN" 'REGRA' 'LINGUAGEM' 'TIPO' 'SEVERIDADE' 'NOME' "$_SONAR_RESET"
    printf '%b%s%b\n' "$_SONAR_DIM" '  ------------------------------------------------------------------------------------------------------' "$_SONAR_RESET"
    while IFS=$'\t' read -r key lang type severity name; do
        [[ -z "$key" ]] && continue
        local type_color severity_color
        type_color="$(_sonar_type_color "$type")"
        severity_color="$(_sonar_severity_color "$severity")"
        printf '  %b%-40s%b %b%-14s%b %b%-14s%b %b%-12s%b %b%s%b\n' \
            "$_SONAR_DIM" "$(printf '%-40s' "$key")" "$_SONAR_RESET" \
            "$_SONAR_WHITE" "$lang" "$_SONAR_RESET" \
            "$type_color" "$(_sonar_pad "$(sonar_translate_type "$type")" 14)" "$_SONAR_RESET" \
            "$severity_color" "$(_sonar_pad "$(sonar_translate_severity "$severity")" 12)" "$_SONAR_RESET" \
            "$_SONAR_WHITE" "$(_sonar_truncate "$name" 50)" "$_SONAR_RESET"
    done < <(jq -r '.rules[]? | [.key, (.langName // .lang // "-"), (.type // "-"), (.severity // "-"), (.name // "-")] | @tsv' <<<"$response")

    printf '\n  %bTotal:%b %b%s%b regras\n\n' "$_SONAR_BOLD" "$_SONAR_RESET" "$_SONAR_WHITE$_SONAR_BOLD" "$total" "$_SONAR_RESET"
}

_sonar_query_metrics() {
    local response
    local metric value name color

    response="$(sonar_get '/api/measures/component' \
        --data-urlencode "component=$_SONAR_PROJECT" \
        --data-urlencode "pullRequest=$_SONAR_PR" \
        --data-urlencode 'metricKeys=code_smells,bugs,vulnerabilities,coverage,duplicated_lines_density,ncloc,complexity,cognitive_complexity,sqale_index,new_code_smells,new_bugs,new_vulnerabilities,new_coverage')"

    _sonar_clear_screen
    while IFS=$'\t' read -r metric value; do
        [[ -z "$metric" ]] && continue
        name="$(_sonar_metric_name "$metric")"
        if _sonar_metric_is_percent "$metric"; then
            color="$(_sonar_percent_color "$value" "$([[ "$metric" == *duplicated* ]] && echo false || echo true)")"
            printf '  %b%s%b %b%s%b %b%s%%%b\n' \
                "$_SONAR_DIM" "$(_sonar_pad "$name" 28)" "$_SONAR_RESET" \
                "$color" "$(_sonar_bar "$value" 20)" "$_SONAR_RESET" \
                "$color$_SONAR_BOLD" "$value" "$_SONAR_RESET"
        else
            printf '  %b%s%b %b%s%b\n' \
                "$_SONAR_DIM" "$(_sonar_pad "$name" 28)" "$_SONAR_RESET" \
                "$_SONAR_BOLD$_SONAR_WHITE" "$value" "$_SONAR_RESET"
        fi
    done < <(jq -r '.component.measures[]? | [.metric, (.value // "-")] | @tsv' <<<"$response")
}

_sonar_query_gate() {
    local response
    local status
    local status_color
    local cond_status cond_metric cond_value cond_limit cond_color

    response="$(sonar_get '/api/qualitygates/project_status' \
        --data-urlencode "projectKey=$_SONAR_PROJECT" --data-urlencode "pullRequest=$_SONAR_PR")"
    status="$(jq -r '.projectStatus.status // "N/A"' <<<"$response")"
    status_color="$(_sonar_gate_color "$status")"

    _sonar_clear_screen
    printf '\n  %-16s %b%s%b\n' "$(printf '%-16s' 'STATUS')" \
        "$_SONAR_BOLD$(_sonar_gate_color "$status")" "$(sonar_translate_gate "$status")" "$_SONAR_RESET"
    printf '\n%b  %-22s %-28s %12s  %s%b\n' "$_SONAR_BOLD$_SONAR_CYAN" 'CONDIÇÃO' 'MÉTRICA' 'VALOR' 'LIMITE' "$_SONAR_RESET"
    printf '%b%s%b\n' "$_SONAR_DIM" '  ----------------------------------------------------------------------------------------' "$_SONAR_RESET"

    while IFS=$'\t' read -r cond_status cond_metric cond_value cond_limit; do
        [[ -z "$cond_status" ]] && continue
        cond_color="$(_sonar_gate_color "$cond_status")"
        printf '  %b%s%b %b%s%b %b%12s%b  %b%s%b\n' \
            "$cond_color" "$(_sonar_pad "$cond_status" 22)" "$_SONAR_RESET" \
            "$_SONAR_WHITE" "$(_sonar_pad "$(_sonar_metric_name "$cond_metric")" 28)" "$_SONAR_RESET" \
            "$_SONAR_BOLD$_SONAR_WHITE" "$cond_value" "$_SONAR_RESET" \
            "$_SONAR_DIM" "$cond_limit" "$_SONAR_RESET"
    done < <(jq -r '.projectStatus.conditions[]? | [.status, .metricKey, (.actualValue // "-"), ((.comparator // "") + (.errorThreshold // ""))] | @tsv' <<<"$response")
    printf '\n'
}

_sonar_query_hotspots() {
    local response
    local page=1
    local hotspot_total=0
    local rows=''
    local status status_color risk risk_color

    while :; do
        response="$(sonar_get '/api/hotspots/search' \
            --data-urlencode "projectKey=$_SONAR_PROJECT" \
            --data-urlencode "pullRequest=$_SONAR_PR" \
            --data-urlencode "p=$page" --data-urlencode "ps=100")"
        rows+="$(jq -r '.hotspots[]? | [.key, (.status // "-"), (.vulnerabilityProbability // "-"), (.component // "-"), (.line // "-"), (.message // "")] | @tsv' <<<"$response")"$'\n'
        hotspot_total="$(jq -r '.paging.total // 0' <<<"$response")"
        (( page * 100 >= hotspot_total )) && break
        page=$((page + 1))
    done

    _sonar_clear_screen
    printf '%b  %-39s %-20s %-9s %-29s %5s  %s%b\n' "$_SONAR_BOLD$_SONAR_CYAN" 'CHAVE' 'SITUAÇÃO' 'RISCO' 'COMPONENTE' 'LINHA' 'MENSAGEM' "$_SONAR_RESET"
    printf '%b%s%b\n' "$_SONAR_DIM" '  ------------------------------------------------------------------------------------------------------------' "$_SONAR_RESET"
    while IFS=$'\t' read -r key status risk component line message; do
        [[ -z "$key" ]] && continue
        status_color="$(_sonar_status_color "$(sonar_translate_status "$status")")"
        risk_color="$(_sonar_gate_color "$risk")"
        printf '  %b%-39s%b %b%-20s%b %b%-9s%b %b%-29s%b %b%5s%b  %b%s%b\n' \
            "$_SONAR_DIM" "$(_sonar_pad "$key" 39)" "$_SONAR_RESET" \
            "$status_color" "$(_sonar_pad "$(sonar_translate_status "$status")" 20)" "$_SONAR_RESET" \
            "$risk_color" "$(_sonar_pad "$risk" 9)" "$_SONAR_RESET" \
            "$_SONAR_WHITE" "$(_sonar_truncate "$component" 29)" "$_SONAR_RESET" \
            "$_SONAR_DIM" "$line" "$_SONAR_RESET" \
            "$_SONAR_WHITE" "$(_sonar_truncate "$message" 40)" "$_SONAR_RESET"
    done <<<"$rows"
    printf '\n  %bTotal:%b %b%s%b alertas de segurança\n\n' "$_SONAR_BOLD" "$_SONAR_RESET" "$_SONAR_WHITE$_SONAR_BOLD" "$hotspot_total" "$_SONAR_RESET"
}

# e guarda o resultado em variáveis globais _OV_*.
_sonar_overview_fetch() {
    local gate_response
    local measures_response
    local issues_response
    local hotspot_response
    local issue_type issue_count
    local risk_list=''
    local page=1
    local gate_points=0
    local cov=0 dup=0

    gate_response="$(sonar_get '/api/qualitygates/project_status' \
        --data-urlencode "projectKey=$_SONAR_PROJECT" \
        --data-urlencode "pullRequest=$_SONAR_PR" 2>/dev/null || printf '{}')"
    _OV_GATE="$(jq -r '.projectStatus.status // "N/A"' <<<"$gate_response")"

    measures_response="$(sonar_get '/api/measures/component' \
        --data-urlencode "component=$_SONAR_PROJECT" \
        --data-urlencode "pullRequest=$_SONAR_PR" \
        --data-urlencode 'metricKeys=coverage,duplicated_lines_density,ncloc' 2>/dev/null || printf '{}')"
    _OV_COVERAGE="$(jq -r '([.component.measures[]? | select(.metric == "coverage") | .value] | first) // "N/A"' <<<"$measures_response")"
    _OV_DUP="$(jq -r '([.component.measures[]? | select(.metric == "duplicated_lines_density") | .value] | first) // "N/A"' <<<"$measures_response")"
    _OV_LOC="$(jq -r '([.component.measures[]? | select(.metric == "ncloc") | .value] | first) // "N/A"' <<<"$measures_response")"

    issues_response="$(sonar_get '/api/issues/search' \
        --data-urlencode "componentKeys=$_SONAR_PROJECT" \
        --data-urlencode "pullRequest=$_SONAR_PR" \
        --data-urlencode 'resolved=false' \
        --data-urlencode 'facets=types,severities' \
        --data-urlencode 'p=1' --data-urlencode 'ps=1')"
    _OV_ISSUES_TOTAL="$(jq -r '.paging.total // 0' <<<"$issues_response")"

    declare -gA _OV_TYPES=()
    while IFS=$'\t' read -r issue_type issue_count; do
        [[ -z "$issue_type" ]] && continue
        _OV_TYPES["$issue_type"]="$issue_count"
    done < <(jq -r '.facets[]? | select(.property == "types") | .values[]? | [.val, .count] | @tsv' <<<"$issues_response")

    declare -gA _OV_SEVERITIES=()
    while IFS=$'\t' read -r issue_type issue_count; do
        [[ -z "$issue_type" ]] && continue
        _OV_SEVERITIES["$issue_type"]="$issue_count"
    done < <(jq -r '.facets[]? | select(.property == "severities") | .values[]? | [.val, .count] | @tsv' <<<"$issues_response")

    declare -gA _OV_RISKS=()
    while :; do
        hotspot_response="$(sonar_get '/api/hotspots/search' \
            --data-urlencode "projectKey=$_SONAR_PROJECT" \
            --data-urlencode "pullRequest=$_SONAR_PR" \
            --data-urlencode "p=$page" --data-urlencode "ps=100")"
        risk_list+="$(jq -r '.hotspots[]?.vulnerabilityProbability // empty' <<<"$hotspot_response")"$'\n'
        _OV_HOTSPOTS_TOTAL="$(jq -r '.paging.total // 0' <<<"$hotspot_response")"
        (( page * 100 >= _OV_HOTSPOTS_TOTAL )) && break
        page=$((page + 1))
    done
    while read -r issue_type issue_count; do
        [[ -z "$issue_type" ]] && continue
        _OV_RISKS["$issue_type"]="$issue_count"
    done < <(printf '%s\n' "$risk_list" | grep -v '^$' | sort | uniq -c | awk '{print $2, $1}' | sort)

    cov=0
    dup=0
    gate_points=0
    [[ "$_OV_COVERAGE" =~ ^[0-9]+(\.[0-9]+)?$ ]] && cov="$_OV_COVERAGE"
    [[ "$_OV_DUP" =~ ^[0-9]+(\.[0-9]+)?$ ]] && dup="$_OV_DUP"
    case "$_OV_GATE" in
        OK) gate_points=20 ;;
        WARN) gate_points=10 ;;
    esac
    _OV_SCORE="$(awk "BEGIN{printf \"%.0f\", 0.5 * $cov + 0.3 * (100 - $dup) + $gate_points}")"
    ((_OV_SCORE < 0)) && _OV_SCORE=0
    ((_OV_SCORE > 100)) && _OV_SCORE=100
}

# Linha "label valor" dentro de uma caixa.
_sonar_ov_kv() {
    printf '%s %s' "$(_sonar_pad "$1" 14)" "$2"
}

# Contagens coloridas em linha única: "LABEL n  LABEL n...".
# Recebe chave de cor via "$3" = nome da cor ("type", "severity", "risk").
_sonar_ov_counts_line() {
    local -n counts="$1"
    local kind="$2"
    local first=1
    local key count color label

    for key in "${!counts[@]}"; do
        count="${counts[$key]}"
        case "$kind" in
            type) color="$(_sonar_type_color "$key")"; label="$(sonar_translate_type "$key")" ;;
            severity) color="$(_sonar_severity_color "$key")"; label="$(sonar_translate_severity "$key")" ;;
            risk) color="$(_sonar_gate_color "$key")"; label="$key" ;;
        esac
        (( first )) || printf '  '
        printf '%b%s%b %b%s%b' \
            "$_SONAR_DIM" "$(_sonar_pad "$label" 12)" "$_SONAR_RESET" \
            "$color${_SONAR_BOLD}" "$count" "$_SONAR_RESET"
        first=0
    done
}

# Painel do overview com molduras.
_sonar_overview_render() {
    local width=74
    local counts_line

    _sonar_box_top "$width" 'PAINEL GERAL DE QUALIDADE'
    _sonar_box_line "$width" "${_SONAR_WHITE}${_SONAR_BOLD}${_SONAR_PROJECT}${_SONAR_RESET}${_SONAR_DIM}   PR: ${_SONAR_PR:-todos}${_SONAR_RESET}"
    _sonar_box_line "$width" "$(_sonar_ov_kv 'PORTÃO' "$(_sonar_gate_color "$_OV_GATE")${_SONAR_BOLD}$(sonar_translate_gate "$_OV_GATE")${_SONAR_RESET}")"
    _sonar_box_line "$width" "$(_sonar_ov_kv 'Cobertura' "$(_sonar_percent_color "$_OV_COVERAGE" true)$(_sonar_bar "$_OV_COVERAGE" 26)${_SONAR_RESET} ${_SONAR_BOLD}${_OV_COVERAGE}%${_SONAR_RESET}")"
    _sonar_box_line "$width" "$(_sonar_ov_kv 'Duplicação' "$(_sonar_percent_color "$_OV_DUP" false)$(_sonar_bar "$_OV_DUP" 26)${_SONAR_RESET} ${_SONAR_BOLD}${_OV_DUP}%${_SONAR_RESET}")"
    _sonar_box_line "$width" "$(_sonar_ov_kv 'Linhas' "${_SONAR_BOLD}${_SONAR_WHITE}${_OV_LOC}${_SONAR_RESET}")"
    _sonar_box_line "$width" "$(_sonar_ov_kv 'Saúde' "$(_sonar_score_color "$_OV_SCORE")${_SONAR_BOLD}${_OV_SCORE}/100${_SONAR_RESET}")"
    _sonar_box_bottom "$width"

    printf '\n'
    _sonar_box_top "$width" 'APONTAMENTOS ABERTOS'
    if (( _OV_ISSUES_TOTAL > 0 )); then
        _sonar_box_line "$width" "Total ${_SONAR_WHITE}${_SONAR_BOLD}${_OV_ISSUES_TOTAL}${_SONAR_RESET}"
        counts_line="$(_sonar_ov_counts_line _OV_TYPES type)"
        [[ -n "$counts_line" ]] && _sonar_box_line "$width" "  ${counts_line}"
        counts_line="$(_sonar_ov_counts_line _OV_SEVERITIES severity)"
        [[ -n "$counts_line" ]] && _sonar_box_line "$width" "  ${counts_line}"
    else
        _sonar_box_line "$width" "${_SONAR_GREEN}${_SONAR_BOLD}Nenhum apontamento aberto${_SONAR_RESET}"
    fi
    _sonar_box_bottom "$width"

    printf '\n'
    _sonar_box_top "$width" 'HOTSPOTS DE SEGURANÇA'
    if (( _OV_HOTSPOTS_TOTAL > 0 )); then
        _sonar_box_line "$width" "Total ${_SONAR_WHITE}${_SONAR_BOLD}${_OV_HOTSPOTS_TOTAL}${_SONAR_RESET}"
        counts_line="$(_sonar_ov_counts_line _OV_RISKS risk)"
        [[ -n "$counts_line" ]] && _sonar_box_line "$width" "  ${counts_line}"
    else
        _sonar_box_line "$width" "${_SONAR_GREEN}${_SONAR_BOLD}Nenhum hotspot de segurança${_SONAR_RESET}"
    fi
    _sonar_box_bottom "$width"
}

# Barra de atalhos do modo interativo.
_sonar_overview_shortcuts() {
    printf '\n  %b[1]%b apontamentos   %b[2]%b hotspots   %b[3]%b métricas   %b[r]%b atualizar   %b[q]%b sair\n' \
        "$_SONAR_CYAN$_SONAR_BOLD" "$_SONAR_RESET" \
        "$_SONAR_CYAN$_SONAR_BOLD" "$_SONAR_RESET" \
        "$_SONAR_CYAN$_SONAR_BOLD" "$_SONAR_RESET" \
        "$_SONAR_CYAN$_SONAR_BOLD" "$_SONAR_RESET" \
        "$_SONAR_CYAN$_SONAR_BOLD" "$_SONAR_RESET"
}

# Executa uma visão detalhada em tela cheia e volta ao painel ao pressionar tecla.
_sonar_overview_overlay() {
    printf '\033[H\033[2J'
    "$@"
    printf '\n  %b— pressione qualquer tecla para voltar ao painel —%b\n' \
        "$_SONAR_DIM" "$_SONAR_RESET"
    read -rsn1
}

# bytebabe sonar overview — ponto de entrada: TUI interativa quando
# stdin/stdout são terminais; render estático caso contrário.
_sonar_query_overview() {
    local key

    if [[ -t 0 && -t 1 ]]; then
        while :; do
            _sonar_overview_fetch
            printf '\033[H\033[2J'
            _sonar_overview_render
            _sonar_overview_shortcuts
            read -rsn1 key
            case "$key" in
                q|Q|$'\x1b')
                    printf '\n'
                    return 0
                    ;;
                1|i|I) _sonar_overview_overlay sonar_report_issues ;;
                2|h|H) _sonar_overview_overlay _sonar_query_hotspots ;;
                3|m|M) _sonar_overview_overlay _sonar_query_metrics ;;
                r|R|'') ;;
            esac
        done
    fi

    _sonar_overview_fetch
    _sonar_clear_screen
    _sonar_overview_render
}


# bytebabe sonar issues — dashboard de qualidade + lista de apontamentos.
sonar_report_issues() {
    local quality_gate_response
    local measures_response
    local quality_gate
    local coverage
    local duplication
    local lines_of_code
    local issues='[]'
    local components='[]'
    local total=0
    local page=1
    local response

    quality_gate_response="$(sonar_get '/api/qualitygates/project_status' \
        --data-urlencode "projectKey=$_SONAR_PROJECT" \
        --data-urlencode "pullRequest=$_SONAR_PR" 2>/dev/null || printf '{}')"
    measures_response="$(sonar_get '/api/measures/component' \
        --data-urlencode "component=$_SONAR_PROJECT" \
        --data-urlencode "pullRequest=$_SONAR_PR" \
        --data-urlencode 'metricKeys=coverage,duplicated_lines_density,ncloc' 2>/dev/null || printf '{}')"

    quality_gate="$(jq -r '.projectStatus.status // "N/A"' <<<"$quality_gate_response")"
    coverage="$(jq -r '([.component.measures[]? | select(.metric == "coverage") | .value] | first) // "N/A"' <<<"$measures_response")"
    duplication="$(jq -r '([.component.measures[]? | select(.metric == "duplicated_lines_density") | .value] | first) // "N/A"' <<<"$measures_response")"
    lines_of_code="$(jq -r '([.component.measures[]? | select(.metric == "ncloc") | .value] | first) // "N/A"' <<<"$measures_response")"

    while :; do
        response="$(sonar_get '/api/issues/search' \
            --data-urlencode "componentKeys=$_SONAR_PROJECT" \
            --data-urlencode "pullRequest=$_SONAR_PR" \
            --data-urlencode 'types=CODE_SMELL,BUG,VULNERABILITY' \
            --data-urlencode 'resolved=false' \
            --data-urlencode "p=$page" \
            --data-urlencode "ps=100")"

        total="$(jq -r '.paging.total // 0' <<<"$response")"
        issues="$(jq -cn --argjson current "$issues" --argjson response "$response" '$current + ($response.issues // [])')"
        components="$(jq -cn --argjson current "$components" --argjson response "$response" '($current + ($response.components // [])) | unique_by(.key)')"

        if (( page * 100 >= total )); then
            break
        fi

        page=$((page + 1))
    done

    local code_smell_count
    local bug_count
    local vulnerability_count
    code_smell_count="$(jq '[.[] | select(.type == "CODE_SMELL" or any(.impacts[]?; .softwareQuality == "MAINTAINABILITY"))] | length' <<<"$issues")"
    bug_count="$(jq '[.[] | select(.type == "BUG" or any(.impacts[]?; .softwareQuality == "RELIABILITY"))] | length' <<<"$issues")"
    vulnerability_count="$(jq '[.[] | select(.type == "VULNERABILITY" or any(.impacts[]?; .softwareQuality == "SECURITY"))] | length' <<<"$issues")"

    _sonar_clear_screen
    printf '%b%s%b\n' "$_SONAR_DIM" '=======================================================================' "$_SONAR_RESET"
    sonar_field 'PROJETO' "$_SONAR_PROJECT"
    sonar_field 'PR' "${_SONAR_PR:-todos}"
    sonar_field 'ABERTOS' "$total apontamentos"
    printf '\n  %bRESUMO%b  %bProblemas de manutenção: %s%b  |  %bDefeitos: %s%b  |  %bVulnerabilidades: %s%b\n' \
        "$_SONAR_CYAN$_SONAR_BOLD" "$_SONAR_RESET" \
        "$_SONAR_YELLOW$_SONAR_BOLD" "$code_smell_count" "$_SONAR_RESET" \
        "$_SONAR_RED$_SONAR_BOLD" "$bug_count" "$_SONAR_RESET" \
        "$_SONAR_MAGENTA$_SONAR_BOLD" "$vulnerability_count" "$_SONAR_RESET"
    printf '\n  %bPORTÃO%b  %b%s%b  %bCobertura:%b %s%%  %bDuplicação:%b %s%%  %bLinhas de código:%b %s\n' \
        "$_SONAR_CYAN$_SONAR_BOLD" "$_SONAR_RESET" \
        "$(_sonar_gate_color "$quality_gate")$_SONAR_BOLD" "$(sonar_translate_gate "$quality_gate")" "$_SONAR_RESET" \
        "$_SONAR_DIM" "$_SONAR_RESET" "$(_sonar_percent_color "$coverage" true)$_SONAR_BOLD$coverage$_SONAR_RESET" \
        "$_SONAR_DIM" "$_SONAR_RESET" "$(_sonar_percent_color "$duplication" false)$_SONAR_BOLD$duplication$_SONAR_RESET" \
        "$_SONAR_DIM" "$_SONAR_RESET" "$_SONAR_BOLD$lines_of_code$_SONAR_RESET"
    printf '%b%s%b\n' "$_SONAR_DIM" '=======================================================================' "$_SONAR_RESET"

    if [[ "${_SONAR_SUMMARY_ONLY:-0}" == 1 ]]; then
        return 0
    fi

    if [[ "$total" == '0' ]]; then
        printf '%b✔ Nenhum apontamento aberto foi encontrado.%b\n' "$_SONAR_GREEN$_SONAR_BOLD" "$_SONAR_RESET"
        return 0
    fi

    local -A RULE_NAMES=()
    local -A RULE_DESCRIPTIONS=()
    local -A RULE_DESCRIPTION_IS_HTML=()
    local rule_key
    local rule_response
    local html_description

    while IFS= read -r rule_key; do
        [[ -z "$rule_key" ]] && continue

        if rule_response="$(sonar_get '/api/rules/show' --data-urlencode "key=$rule_key")"; then
            RULE_NAMES["$rule_key"]="$(jq -r '.rule.name // .rule.key // "Regra desconhecida"' <<<"$rule_response")"
            html_description="$(jq -r '.rule.htmlDesc // empty' <<<"$rule_response")"
            if [[ -n "$html_description" ]]; then
                RULE_DESCRIPTIONS["$rule_key"]="$html_description"
                RULE_DESCRIPTION_IS_HTML["$rule_key"]='true'
            else
                RULE_DESCRIPTIONS["$rule_key"]="$(jq -r '(.rule.mdDesc // .rule.description // "Descrição indisponível") | gsub("[\\r\\n\\t ]+"; " ") | sub("^ "; "") | sub(" $"; "")' <<<"$rule_response")"
                RULE_DESCRIPTION_IS_HTML["$rule_key"]='false'
            fi
        else
            RULE_NAMES["$rule_key"]="$rule_key"
            RULE_DESCRIPTIONS["$rule_key"]='Detalhes da regra indisponíveis; confira o acesso à instância.'
            RULE_DESCRIPTION_IS_HTML["$rule_key"]='false'
        fi
    done < <(jq -r '[.[] | .rule] | unique | .[]' <<<"$issues")

    local index=0
    local issue_key issue_type severity status effort component line rule_name rule_description file_path
    local issue_color severity_color

    while IFS=$'\t' read -r issue_key issue_type severity status effort component line rule_key message; do
        index=$((index + 1))
        file_path="$(jq -r --arg key "$component" '([.[] | select(.key == $key) | (.path // .longName // .name)] | first) // $key' <<<"$components")"
        rule_name="${RULE_NAMES[$rule_key]:-$rule_key}"
        rule_description="${RULE_DESCRIPTIONS[$rule_key]:-Descrição da regra indisponível.}"

        case "$issue_type" in
            BUG|RELIABILITY) issue_color="$_SONAR_RED" ;;
            VULNERABILITY|SECURITY) issue_color="$_SONAR_MAGENTA" ;;
            CODE_SMELL|MAINTAINABILITY) issue_color="$_SONAR_YELLOW" ;;
            *) issue_color="$_SONAR_CYAN" ;;
        esac

        case "$severity" in
            BLOCKER|CRITICAL|HIGH) severity_color="$_SONAR_RED" ;;
            MAJOR|MEDIUM) severity_color="$_SONAR_YELLOW" ;;
            MINOR|LOW) severity_color="$_SONAR_CYAN" ;;
            *) severity_color="$_SONAR_DIM" ;;
        esac

        printf '\n%b[%02d/%02d] %s%b  |  %b%s%b\n' \
            "$_SONAR_BOLD$issue_color" "$index" "$total" "$(sonar_translate_type "$issue_type")" "$_SONAR_RESET" \
            "$severity_color$_SONAR_BOLD" "$(sonar_translate_severity "$severity")" "$_SONAR_RESET"
        sonar_field 'CHAVE' "$(sonar_issue_link "$issue_key")"
        sonar_field 'SITUAÇÃO' "$(sonar_translate_status "$status")"
        sonar_field 'LOCAL' "$file_path:$line"
        sonar_field 'REGRA' "$rule_name ($rule_key)"
        sonar_field 'MENSAGEM' "$message"
        sonar_field 'ESFORCO' "$effort"
        sonar_description 'POR QUE:' "$rule_description" "${RULE_DESCRIPTION_IS_HTML[$rule_key]:-false}"
        printf '%b%s%b\n' "$_SONAR_DIM" '-----------------------------------------------------------------------' "$_SONAR_RESET"
    done < <(jq -r --argjson components "$components" '
        .[] as $issue |
        [
            $issue.key,
            ($issue.type // ($issue.impacts[0].softwareQuality // "ISSUE")),
            ($issue.severity // ($issue.impacts[0].severity // "-")),
            ($issue.status // "-"),
            ($issue.effort // "-") ,
            $issue.component,
            ($issue.line // $issue.textRange.startLine // "-"),
            $issue.rule,
            ($issue.message // "")
        ] | @tsv
    ' <<<"$issues")
}

# Executa uma consulta do núcleo. Retorna 2 para uso inválido.
sonar_run_query() {
    local command="$1"
    local first="${SONAR_POSITIONAL_ARGS[0]:-}"

    case "$command" in
        overview|resumo|painel|ov)
            sonar_require_project "$_SONAR_PROJECT" || return $?
            _sonar_query_overview
            ;;
        show|issue)
            [[ -n "$first" ]] || return 2
            sonar_require_project "$_SONAR_PROJECT" || return $?
            _sonar_show_issue "$first"
            ;;
        rule)
            [[ -n "$first" ]] || return 2
            _sonar_print_rule "$first"
            ;;
        rules)
            _sonar_query_rules "$first"
            ;;
        metrics)
            sonar_require_project "$_SONAR_PROJECT" || return $?
            _sonar_query_metrics
            ;;
        gate)
            sonar_require_project "$_SONAR_PROJECT" || return $?
            _sonar_query_gate
            ;;
        hotspots)
            sonar_require_project "$_SONAR_PROJECT" || return $?
            _sonar_query_hotspots
            ;;
        issues)
            sonar_require_project "$_SONAR_PROJECT" || return $?
            sonar_report_issues
            ;;
        *)
            return 2
            ;;
    esac
}
