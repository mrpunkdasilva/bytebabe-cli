# ==================================================
# AZURE DEVOPS OUTPUT RENDERING & RUNNER
# ==================================================

# Recebe linhas TSV (colunas separadas por tab) no stdin e imprime a
# tabela alinhada com cores: cabeçalho destacado, separador e linhas coloridas.
# Modo "kv": primeira coluna ciano, demais verdes. Modo "list": linhas alternadas.
_az_print_tsv_table() {
    local mode=${1:-list} input
    local cyan purple green white reset bold
    cyan=$(printf '%b' "$CYBER_CYAN")
    purple=$(printf '%b' "$CYBER_PURPLE")
    green=$(printf '%b' "$CYBER_GREEN")
    white=$(printf '%b' "$CYBER_WHITE")
    reset=$(printf '%b' "$RESET")
    bold=$(printf '%b' "$CYBER_BOLD")
    input=$(cat)
    if [[ -z "$input" ]]; then
        return 1
    fi
    printf '%s\n' "$input" | awk -v mode="$mode" \
        -v hc="${purple}${bold}" -v pc="$purple" -v rc="$reset" \
        -v c1="$cyan" -v c2="$green" -v ca="$white" -v sep='─' '
    BEGIN { FS = "\t" }
    { rows[NR] = $0; if (NF > cols) cols = NF
      for (i = 1; i <= NF; i++) if (length($i) > w[i]) w[i] = length($i) }
    END {
        if (NR == 0) exit 1
        if (!cols) cols = 1
        total = 2 * (cols - 1)
        for (i = 1; i <= cols; i++) total += w[i]
        line = ""
        n = split(rows[1], f, FS)
        for (i = 1; i <= cols; i++)
            line = line sprintf("%-*s", w[i], (i <= n ? f[i] : "")) ((i < cols) ? "  " : "")
        gsub(/[ \t]+$/, "", line)
        printf "%s%s%s\n", hc, line, rc
        line = ""
        for (i = 0; i < total; i++) line = line sep
        printf "%s%s%s\n", pc, line, rc
        for (r = 2; r <= NR; r++) {
            n = split(rows[r], f, FS)
            line = ""
            for (i = 1; i <= cols; i++)
                line = line sprintf("%-*s", w[i], (i <= n ? f[i] : "")) ((i < cols) ? "  " : "")
            gsub(/[ \t]+$/, "", line)
            if (mode == "kv") {
                line = c1 substr(line, 1, w[1]) rc c2 substr(line, w[1] + 1) rc
            } else if (mode == "list") {
                line = (r % 2 == 0 ? ca : c2) line rc
            }
            printf "%s\n", line
        }
    }'
}

# Converte um objeto JSON (resposta de `az devops project show` e similares)
# em linhas TSV CAMPO\tVALOR, achando estruturas aninhadas com notação de ponto
_az_render_kv() {
    printf '%s' "$1" | jq -r '
        paths as $p
        | getpath($p) as $v
        | select(($v | type) != "object" and ($v | type) != "array")
        | (($p | map(tostring) | join(".")) + "\t" +
           ($v | if . == null then "—" else tostring end
             | gsub("[\\t\\r\\n]+"; " ")
             | if length > 72 then (.[0:71] + "…") else . end))' 2>/dev/null
}

# Converte uma lista de objetos JSON em TSV colunar compacto: escolhe no
# máximo 6 colunas úteis (nome/displayName, ids, status), descarta colunas
# nulas, antecipa URLs (prioridade baixa), encurta GUIDs/SHAs e remove o
# prefixo refs/heads|tags/ do campo name
_az_render_list() {
    printf '%s' "$1" | jq -r '
        def flat:
            [ paths as $p
              | (getpath($p) as $v
                | select(($v | type) != "object" and ($v | type) != "array")
                | { ($p | map(tostring) | join(".")): $v }) ]
            | add // {};
        def compact:
            if type == "string" then
                ( gsub("^refs/(heads|tags)/"; "")
                  | if test("^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$|^[0-9a-f]{40}$") then .[0:8] else . end )
            else tostring end;
        def cell:
            if . == null then "—"
            elif type == "object" then "<objeto>"
            elif type == "array" then (if length == 0 then "—" else "<" + (length | tostring) + " itens>" end)
            else compact end
            | gsub("[\\t\\r\\n]+"; " ")
            | if length > 28 then (.[0:27] + "…") else . end;
        def prio($k):
            if $k == "name" then 0
            elif $k | test("(?i)\\.?name$|displayName") then 1
            elif $k | test("(?i)id$|uuid$") then 2
            elif $k | test("(?i)status|state$") then 3
            elif $k | test("(?i)url") then 8
            else 5 end;
        def nonnull($rows; $k):
            [ $rows[] | .[$k] | select(. != null) ] | length;
        map(flat) as $rows
        | ($rows | length) as $n
        | ( [ $rows[] | keys[] ] | unique )
        | map(select(nonnull($rows; .) > 0)) as $kcols
        | ( $kcols
            | map(. as $k
                | { k: $k
                  , p: ((prio($k) * 1000) + ($n - nonnull($rows; $k))) })
            | sort_by(.p)
            | .[0:6]
            | map(.k) ) as $cols
        | ($cols | join("\t")),
          ( $rows
            | map([ .[$cols[]] | cell ] | join("\t"))
            | .[] )' 2>/dev/null
}

# Exibe a tabela TSV (1ª linha = cabeçalho) em páginas com N linhas
# (padrão: 10). Em terminal interativo, Enter avança e q sai; só na
# última página não há pausa. Sem tty, imprime tudo de uma vez.
_az_render_list_page() {
    local table=$1 header rows page=1 start size=${AZ_PAGE_SIZE:-10} slice reply
    [[ "$size" =~ ^[0-9]+$ ]] || size=10
    (( size < 1 )) && size=10
    header=${table%%$'\n'*}
    rows=$(( $(printf '%s\n' "$table" | wc -l) - 1 ))
    if (( rows < 1 )); then
        printf '%s\n' "$table" | _az_print_tsv_table list
        return 0
    fi

    for (( start = 2; start <= rows + 1; start += size, page++ )); do
        slice=$(printf '%s\n' "$table" | sed -n "1p;${start},$((start + size - 1))p")
        if (( page > 1 )); then
            printf '\n  %b— página %s/%s —%b\n\n' "$CYBER_PURPLE" "$page" "$(( (rows + size - 1) / size ))" "$RESET"
        fi
        printf '%s\n' "$slice" | _az_print_tsv_table list
        if (( start + size <= rows )) && [ -t 1 ] && { [ -t 0 ] || [[ -r /dev/tty ]]; }; then
            reply=""
            read -e -r -p "$(printf '%b  mais %s itens — Enter continua, q sai: %b' "$CYBER_YELLOW" "$(( rows - start - size + 1 < size ? rows - start - size + 1 : size ))" "$RESET")" reply < /dev/tty 2>/dev/null
            local rc=$?
            if (( rc != 0 )); then
                break
            fi
            [[ "$reply" =~ ^[[:space:]]*[qQ][[:space:]]*$ ]] && break
        fi
    done
    printf '\n  %bTotal: %b%s item(ns)%b\n' "$CYBER_BLUE" "$CYBER_GREEN" "$rows" "$RESET"
}

_az_render() {
    local response=$1 text kind kv table
    local width=${COLUMNS:-80}
    [[ "$width" =~ ^[0-9]+$ ]] || width=80
    (( width < 40 )) && width=40
    (( width > 100 )) && width=100
    printf '\n%b%s%b\n' "$CYBER_PURPLE" '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' "$RESET"
    printf '  %bAZURE | RESULTADO%b\n\n' "$CYBER_YELLOW" "$RESET"
    if [[ -z "$response" ]]; then
        printf '  %bOperação concluída sem dados de resposta.%b\n' "$CYBER_GREEN" "$RESET"
    elif command -v jq >/dev/null 2>&1 && printf '%s' "$response" | jq -e . >/dev/null 2>&1; then
        kind=$(printf '%s' "$response" | jq -r 'if type == "object" then "kv"
            elif type == "array" and length > 0 and (.[0] | type) == "object" then "list"
            else "other" end')
        if [[ "$kind" == kv ]]; then
            if kv=$(_az_render_kv "$response") && [[ -n "$kv" ]]; then
                printf '%s\n' "$kv" | _az_print_tsv_table kv
            else
                printf '%s\n' "$response" | jq -C .
            fi
        elif [[ "$kind" == list ]]; then
            if table=$(_az_render_list "$response") && [[ -n "$table" ]]; then
                _az_render_list_page "$table"
            else
                printf '%s\n' "$response" | jq -C .
            fi
        else
            printf '%s\n' "$response" | jq -C .
        fi
    else
        while IFS= read -r text; do
            printf '  %b%s%b\n' "$CYBER_GREEN" "$text" "$RESET"
        done < <(printf '%s\n' "$response" | fold -s -w "$((width - 2))")
    fi
    printf '\n%b%s%b\n' "$CYBER_PURPLE" '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' "$RESET"
}

_az_run() {
    local argument response result
    local args=("$@")
    for argument in "$@"; do
        case "$argument" in
            --help|-h|--output|--output=*|-o|-o?*)
                az "$@"
                return $?
                ;;
        esac
    done
    args+=(--output json)
    if response=$(az "${args[@]}"); then
        _az_render "$response"
    else
        result=$?
        [[ -z "$response" ]] || _az_render "$response"
        printf '%bFalha na operação Azure (status %s).%b\n' "$CYBER_RED" "$result" "$RESET" >&2
        return "$result"
    fi
}
