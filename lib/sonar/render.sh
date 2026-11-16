#!/bin/bash

# ==================================================
# SONAR MODULE — renderização e traduções
# Apenas funções; carregar este arquivo não imprime nada.
# ==================================================

# Prepara paleta (CYBER_*) respeitando --sem-cores e stdout não-TTY.
# As variáveis CYBER_* carregam sequências "\033" LITERAIS (o runtime as
# converte no printf %b/echo -e); aqui convertemos uma vez para bytes reais
# para poderem ser usadas em helpers com %s.
sonar_setup_colors() {
    if [[ -t 1 && "${_SONAR_NO_COLOR:-0}" != 1 ]]; then
        _SONAR_RESET="$(printf '%b' "$RESET")"
        _SONAR_BOLD="$(printf '%b' "$CYBER_BOLD")"
        _SONAR_CYAN="$(printf '%b' "$CYBER_CYAN")"
        _SONAR_RED="$(printf '%b' "$CYBER_RED")"
        _SONAR_YELLOW="$(printf '%b' "$CYBER_YELLOW")"
        _SONAR_MAGENTA="$(printf '%b' "$CYBER_MAGENTA")"
        _SONAR_GREEN="$(printf '%b' "$CYBER_GREEN")"
        _SONAR_BLUE="$(printf '%b' "$CYBER_BLUE")"
        _SONAR_WHITE="$(printf '%b' "$CYBER_WHITE")"
        _SONAR_PINK="$(printf '%b' "$CYBER_PINK")"
        _SONAR_DIM="$(printf '%b' "$CYBER_GRAY")"
    else
        _SONAR_RESET=''
        _SONAR_BOLD=''
        _SONAR_CYAN=''
        _SONAR_RED=''
        _SONAR_YELLOW=''
        _SONAR_MAGENTA=''
        _SONAR_GREEN=''
        _SONAR_BLUE=''
        _SONAR_WHITE=''
        _SONAR_PINK=''
        _SONAR_DIM=''
    fi

    _SONAR_OUTPUT_WIDTH="${COLUMNS:-100}"
    if [[ ! "$_SONAR_OUTPUT_WIDTH" =~ ^[0-9]+$ ]]; then
        _SONAR_OUTPUT_WIDTH=100
    fi
    if (( _SONAR_OUTPUT_WIDTH < 72 )); then
        _SONAR_OUTPUT_WIDTH=72
    elif (( _SONAR_OUTPUT_WIDTH > 120 )); then
        _SONAR_OUTPUT_WIDTH=120
    fi
    _SONAR_FIELD_WIDTH=$((_SONAR_OUTPUT_WIDTH - 14))
}

sonar_translate_type() {
    case "$1" in
        CODE_SMELL|MAINTAINABILITY) printf 'MANUTENÇÃO' ;;
        BUG|RELIABILITY) printf 'DEFEITO' ;;
        VULNERABILITY|SECURITY) printf 'SEGURANÇA' ;;
        *) printf '%s' "$1" ;;
    esac
}

sonar_translate_severity() {
    case "$1" in
        BLOCKER) printf 'BLOQUEADORA' ;;
        CRITICAL) printf 'CRÍTICA' ;;
        MAJOR) printf 'ALTA' ;;
        MINOR) printf 'BAIXA' ;;
        HIGH) printf 'ALTA' ;;
        MEDIUM) printf 'MÉDIA' ;;
        LOW) printf 'BAIXA' ;;
        INFO) printf 'INFORMATIVA' ;;
        *) printf '%s' "$1" ;;
    esac
}

sonar_translate_status() {
    case "$1" in
        OPEN) printf 'ABERTO' ;;
        CONFIRMED) printf 'CONFIRMADO' ;;
        REOPENED) printf 'REABERTO' ;;
        RESOLVED) printf 'RESOLVIDO' ;;
        CLOSED) printf 'FECHADO' ;;
        ACCEPTED) printf 'ACEITO' ;;
        FALSE-POSITIVE) printf 'FALSO POSITIVO' ;;
        TO_REVIEW) printf 'AGUARDANDO REVISÃO' ;;
        ACKNOWLEDGED) printf 'RECONHECIDO' ;;
        FIXED) printf 'CORRIGIDO' ;;
        SAFE) printf 'SEGURO' ;;
        *) printf '%s' "$1" ;;
    esac
}

sonar_translate_gate() {
    case "$1" in
        OK) printf 'APROVADO' ;;
        ERROR) printf 'REPROVADO' ;;
        WARN) printf 'ATENÇÃO' ;;
        *) printf '%s' "$1" ;;
    esac
}

# Link clicável (OSC 8) para o apontamento na web, quando suportado.
sonar_issue_link() {
    local issue_key="$1"

    if [[ -t 1 && "${TERM:-dumb}" != 'dumb' && "${_SONAR_NO_COLOR:-0}" != 1 ]]; then
        local project_query
        local issue_query
        local pull_request_query
        project_query="$(jq -rn --arg value "$_SONAR_PROJECT" '$value | @uri')"
        issue_query="$(jq -rn --arg value "$issue_key" '$value | @uri')"
        pull_request_query="$(jq -rn --arg value "$_SONAR_PR" '$value | @uri')"
        printf '\033]8;;%s/project/issues?id=%s&open=%s&pullRequest=%s\033\\%s\033]8;;\033\\' \
            "$SONAR_URL" "$project_query" "$issue_query" "$pull_request_query" "$issue_key"
    else
        printf '%s' "$issue_key"
    fi
}

# sonar_field <rótulo> <valor> [cor-do-rótulo] — valor em branco.
sonar_field() {
    local label="$1"
    local value="$2"
    local color="${3:-$_SONAR_CYAN$_SONAR_BOLD}"

    printf '  %b%-10s%b %b' "$color" "$label" "$_SONAR_RESET" "$_SONAR_WHITE"
    printf '%s\n' "$value" | fold -s -w "$_SONAR_FIELD_WIDTH" | sed '2,$s/^/             /'
    printf '%b\n' "$_SONAR_RESET"
}

_sonar_error() {
    printf '%b✗ %s%b\n' "$_SONAR_RED$_SONAR_BOLD" "$1" "$_SONAR_RESET" >&2
}

_sonar_success() {
    printf '%b✔ %s%b\n' "$_SONAR_GREEN$_SONAR_BOLD" "$1" "$_SONAR_RESET"
}

_sonar_score_color() {
    if (( $1 >= 80 )); then
        printf '%s' "$_SONAR_GREEN"
    elif (( $1 >= 60 )); then
        printf '%s' "$_SONAR_YELLOW"
    else
        printf '%s' "$_SONAR_RED"
    fi
}

# Limpa o terminal no momento em que um dashboard vai ser renderizado,
# removendo banner e spinners de carregamento da tela.
_sonar_clear_screen() {
    if [[ -t 1 ]]; then
        printf '\033[H\033[2J'
    fi
}

# Comprimento visível de um texto (desconta sequências ANSI de bytes reais).
_sonar_visible_len() {
    local stripped
    stripped="$(printf '%s' "$1" | sed $'s/\x1b\\[[0-9;]*m//g')"
    printf '%s' "${#stripped}"
}

# Molduras de caixa do painel do overview. width = largura do interior.
_sonar_box_top() {
    local width="$1"
    local title="${2:-}"
    local pad
    local dashes

    if [[ -n "$title" ]]; then
        pad=$(( width - ${#title} - 2 ))
        (( pad < 0 )) && pad=0
        dashes=''
        (( pad > 0 )) && dashes="$(printf '─%.0s' $(seq "$pad"))"
        printf '╭─%b%s%b%s╮\n' "$_SONAR_CYAN$_SONAR_BOLD" "$title" "$_SONAR_RESET" "$dashes"
    else
        dashes="$(printf '─%.0s' $(seq "$width"))"
        printf '╭%s╮\n' "$dashes"
    fi
}

_sonar_box_bottom() {
    printf '╰%s╯\n' "$(printf '─%.0s' $(seq "$1"))"
}

_sonar_box_line() {
    local width="$1"
    local content="${2:-}"
    local len
    local pad=''

    len="$(_sonar_visible_len "$content")"
    if (( width - len - 2 > 0 )); then
        pad="$(printf '%*s' $(( width - len - 2 )) '')"
    fi
    printf '│ %s%s │\n' "$content" "$pad"
}

# Banner temático por subcomando (padrão do módulo azure).
_sonar_banner() {
    printf '%b╔══════════════════════════════════════════════════╗%b\n' "$_SONAR_PINK" "$_SONAR_RESET"
    printf '%b║%b %b%-46s%b %b║%b\n' \
        "$_SONAR_PINK" "$_SONAR_RESET" \
        "$_SONAR_BOLD$_SONAR_CYAN" "$1" "$_SONAR_RESET" \
        "$_SONAR_PINK" "$_SONAR_RESET"
    printf '%b╚══════════════════════════════════════════════════╝%b\n' "$_SONAR_PINK" "$_SONAR_RESET"
}

# Separador de painel.
_sonar_rule_line() {
    printf '%b%s%b\n' "$_SONAR_DIM" "$1" "$_SONAR_RESET"
}

_sonar_severity_color() {
    case "$1" in
        BLOCKER|CRITICAL|HIGH|ALTA|CRÍTICA|BLOQUEADORA) printf '%s' "$_SONAR_RED" ;;
        MAJOR|MEDIUM|MÉDIA) printf '%s' "$_SONAR_YELLOW" ;;
        MINOR|LOW|BAIXA) printf '%s' "$_SONAR_CYAN" ;;
        *) printf '%s' "$_SONAR_DIM" ;;
    esac
}

_sonar_type_color() {
    case "$1" in
        BUG|RELIABILITY|DEFEITO) printf '%s' "$_SONAR_RED" ;;
        VULNERABILITY|SECURITY|SEGURANÇA) printf '%s' "$_SONAR_MAGENTA" ;;
        CODE_SMELL|MAINTAINABILITY|MANUTENÇÃO) printf '%s' "$_SONAR_YELLOW" ;;
        *) printf '%s' "$_SONAR_CYAN" ;;
    esac
}

_sonar_status_color() {
    case "$1" in
        OPEN|REOPENED|ABERTO|REABERTO) printf '%s' "$_SONAR_YELLOW" ;;
        CONFIRMED|CONFIRMADO) printf '%s' "$_SONAR_RED" ;;
        TO_REVIEW|AGUARDANDO*) printf '%s' "$_SONAR_YELLOW" ;;
        RESOLVED|FIXED|ACCEPTED|RESOLVIDO|CORRIGIDO|ACEITO) printf '%s' "$_SONAR_GREEN" ;;
        ACKNOWLEDGED|RECONHECIDO) printf '%s' "$_SONAR_CYAN" ;;
        SAFE|SEGURO) printf '%s' "$_SONAR_DIM" ;;
        *) printf '%s' "$_SONAR_DIM" ;;
    esac
}

_sonar_gate_color() {
    case "$1" in
        OK|APROVADO|LOW) printf '%s' "$_SONAR_GREEN" ;;
        ERROR|REPROVADO|HIGH) printf '%s' "$_SONAR_RED" ;;
        WARN|ATENÇÃO|MEDIUM) printf '%s' "$_SONAR_YELLOW" ;;
        *) printf '%s' "$_SONAR_DIM" ;;
    esac
}

# Trunca texto para caber na largura disponível.
_sonar_truncate() {
    local text="$1"
    local width="${2:-40}"

    if (( ${#text} > width )); then
        printf '%s...' "${text:0:$((width - 3))}"
    else
        printf '%s' "$text"
    fi
}

# Preenche por caracteres (não bytes) para alinhar textos com acentos.
_sonar_pad() {
    local text="$1"
    local width="$2"
    local len=${#text}

    if (( len < width )); then
        printf '%s%*s' "$text" $((width - len)) ''
    else
        printf '%s' "$text"
    fi
}

# Barra de progresso ANSI a partir de um percentual (aceita "85" ou "85.0").
_sonar_bar() {
    local value="$1"
    local width="${2:-20}"
    local filled=0
    local i

    if [[ "$value" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        filled=$(( ${value%.*} * width / 100 ))
    fi
    (( filled > width )) && filled=$width
    (( filled < 0 )) && filled=0

    printf '['
    for ((i = 0; i < filled; i++)); do printf '█'; done
    for ((i = filled; i < width; i++)); do printf '░'; done
    printf ']'
}

# Cor contextual para percentuais de cobertura/duplicação.
_sonar_percent_color() {
    local value="$1"
    local good_high="${2:-true}"
    local num=0

    [[ "$value" =~ ^[0-9]+(\.[0-9]+)?$ ]] && num="${value%.*}"
    if [[ "$good_high" == "true" ]]; then
        if (( num >= 80 )); then printf '%s' "$_SONAR_GREEN"
        elif (( num >= 50 )); then printf '%s' "$_SONAR_YELLOW"
        else printf '%s' "$_SONAR_RED"; fi
    else
        if (( num <= 3 )); then printf '%s' "$_SONAR_GREEN"
        elif (( num <= 10 )); then printf '%s' "$_SONAR_YELLOW"
        else printf '%s' "$_SONAR_RED"; fi
    fi
}

_sonar_metric_name() {
    case "$1" in
        code_smells) printf 'problemas de manutenção' ;;
        bugs) printf 'defeitos' ;;
        vulnerabilities) printf 'vulnerabilidades' ;;
        coverage) printf 'cobertura' ;;
        duplicated_lines_density) printf 'duplicação' ;;
        ncloc) printf 'linhas de código' ;;
        complexity) printf 'complexidade' ;;
        cognitive_complexity) printf 'complexidade cognitiva' ;;
        sqale_index) printf 'dívida técnica' ;;
        new_code_smells) printf 'novos problemas de manutenção' ;;
        new_bugs) printf 'novos defeitos' ;;
        new_vulnerabilities) printf 'novas vulnerabilidades' ;;
        new_coverage) printf 'cobertura (código novo)' ;;
        new_duplicated_lines_density) printf 'duplicação (código novo)' ;;
        *) printf '%s' "$1" ;;
    esac
}

_sonar_metric_is_percent() {
    case "$1" in
        coverage|new_coverage|duplicated_lines_density|new_duplicated_lines_density) return 0 ;;
        *) return 1 ;;
    esac
}

# Descrição de regra: HTML -> texto ANSI (python3 opcional, fallback sed).
sonar_description() {
    local label="$1"
    local description="$2"
    local is_html="$3"
    local formatted
    local first_line=1

    if [[ "$is_html" == 'true' ]] && command -v python3 >/dev/null 2>&1; then
        formatted="$(SONAR_COLOR_RESET="$_SONAR_RESET" \
            SONAR_COLOR_BOLD="$_SONAR_BOLD" \
            SONAR_COLOR_CYAN="$_SONAR_CYAN" \
            SONAR_COLOR_GREEN="$_SONAR_GREEN" \
            SONAR_COLOR_BLUE="$_SONAR_BLUE" \
            SONAR_COLOR_DIM="$_SONAR_DIM" \
            SONAR_TEXT_WIDTH="$_SONAR_FIELD_WIDTH" \
            python3 -c '
import re
import sys
import textwrap
import os
from html.parser import HTMLParser

class TerminalHTMLParser(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.parts = []
        self.lines = []
        self.links = []
        self.list_stack = []
        self.quote_depth = 0
        self.preformatted = False
        self.style = "plain"
        self.previous_styles = []

    def flush(self):
        raw = "".join(self.parts)
        self.parts = []
        if not raw:
            return
        if self.preformatted:
            code_lines = raw.splitlines() or [raw]
            while code_lines and not code_lines[0].strip():
                code_lines.pop(0)
            while code_lines and not code_lines[-1].strip():
                code_lines.pop()
            for line in code_lines:
                self.lines.append(("    " + line.rstrip(), self.style))
            return
        text = re.sub(r"\\s+", " ", raw).strip()
        if not text:
            return
        if self.list_stack and self.style == "plain":
            depth = len(self.list_stack) - 1
            entry = self.list_stack[-1]
            if entry[0] == "ol":
                entry[1] += 1
                marker = str(entry[1]) + ". "
            else:
                marker = "- "
            initial = "  " * depth + marker
            continuation = "  " * depth + " " * len(marker)
        elif self.quote_depth:
            initial = "  " * (self.quote_depth - 1) + "| "
            continuation = initial
        else:
            initial = ""
            continuation = ""
        width = max(20, int(os.environ.get("SONAR_TEXT_WIDTH", "76")) - len(initial))
        wrapped = textwrap.wrap(
            text,
            width=width,
            initial_indent=initial,
            subsequent_indent=continuation,
            break_long_words=False,
            break_on_hyphens=False,
        ) or [initial]
        self.lines.extend((line, self.style) for line in wrapped)

    def separate(self):
        if self.lines and self.lines[-1][0]:
            self.lines.append(("", "plain"))

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag in ("p", "div", "section", "ul", "ol", "blockquote") or re.fullmatch(r"h[1-6]", tag):
            self.flush()
            if tag in ("ul", "ol", "blockquote") or re.fullmatch(r"h[1-6]", tag):
                self.separate()
        if tag in ("ul", "ol"):
            self.list_stack.append([tag, 0])
        elif tag == "blockquote":
            self.quote_depth += 1
            self.previous_styles.append((tag, self.style))
            self.style = "quote"
        elif re.fullmatch(r"h[1-6]", tag):
            self.previous_styles.append((tag, self.style))
            self.style = "heading"
        elif tag == "pre":
            if self.lines and not self.lines[-1][0]:
                self.lines.pop()
            self.preformatted = True
            self.previous_styles.append((tag, self.style))
            self.style = "code"
        elif tag == "li":
            self.flush()
        elif tag == "br":
            self.flush()
        elif tag == "code" and not self.preformatted:
            self.parts.append("`")
        elif tag == "a":
            self.links.append(attrs.get("href", ""))

    def handle_endtag(self, tag):
        if tag == "code" and not self.preformatted:
            self.parts.append("`")
        elif tag == "a" and self.links:
            href = self.links.pop()
            if href:
                self.parts.append(" [" + href + "]")
        elif tag == "li":
            self.flush()
        elif tag in ("p", "div", "section", "ul", "ol", "pre") or re.fullmatch(r"h[1-6]", tag):
            self.flush()
            if tag in ("ul", "ol", "pre") or re.fullmatch(r"h[1-6]", tag):
                self.separate()
            if tag in ("ul", "ol") and self.list_stack:
                self.list_stack.pop()
            if tag == "pre":
                self.preformatted = False
            if tag in ("pre", "blockquote") or re.fullmatch(r"h[1-6]", tag):
                for index in range(len(self.previous_styles) - 1, -1, -1):
                    saved_tag, saved_style = self.previous_styles[index]
                    if saved_tag == tag:
                        self.style = saved_style
                        del self.previous_styles[index]
                        break
            if tag == "blockquote":
                self.quote_depth = max(0, self.quote_depth - 1)

    def handle_data(self, data):
        self.parts.append(data)

parser = TerminalHTMLParser()
parser.feed(sys.stdin.read())
parser.flush()
colors = {
    "heading": os.environ.get("SONAR_COLOR_BOLD", "") + os.environ.get("SONAR_COLOR_CYAN", ""),
    "code": os.environ.get("SONAR_COLOR_GREEN", ""),
    "quote": os.environ.get("SONAR_COLOR_DIM", "") + os.environ.get("SONAR_COLOR_CYAN", ""),
}
reset = os.environ.get("SONAR_COLOR_RESET", "")
for line, style in parser.lines:
    color = colors.get(style, "")
    print(color + line + (reset if color else ""))
' <<<"$description")"
    else
        formatted="$(printf '%s' "$description" | sed -E 's/<br[[:space:]]*\/?[[:space:]]*>/\n/gI; s#</(p|div|li|h[1-6])>#\n#gI; s/<li[^>]*>/- /Ig; s/<[^>]*>//g; s/&nbsp;/ /gI; s/&amp;/\&/gI; s/&lt;/</gI; s/&gt;/>/gI' | fold -s -w "$_SONAR_FIELD_WIDTH")"
    fi

    while IFS= read -r line; do
        if (( first_line )); then
            printf '  %b%-10s%b %b%s%b\n' "$_SONAR_GREEN$_SONAR_BOLD" "$label" "$_SONAR_RESET" "$_SONAR_WHITE" "$line" "$_SONAR_RESET"
            first_line=0
        else
            printf '%b             %s%b\n' "$_SONAR_WHITE" "$line" "$_SONAR_RESET"
        fi
    done <<<"$formatted"
    printf '\n'
}
