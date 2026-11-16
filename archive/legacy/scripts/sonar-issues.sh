#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="${SONAR_CONFIG:-$ROOT_DIR/configs.yaml}"
DEFAULT_PROJECT_KEY=''
DEFAULT_PULL_REQUEST=''
DEFAULT_SONAR_URL=''
PAGE_SIZE=100
SONAR_CONNECT_TIMEOUT="${SONAR_CONNECT_TIMEOUT:-10}"
SONAR_TIMEOUT="${SONAR_TIMEOUT:-60}"
SUMMARY_ONLY=false
SHOW_HELP=false
POSITIONAL_ARGS=()
COMMAND='issues'

case "${1:-}" in
    issues|show|issue|rule|rules|metrics|gate|hotspots|branches|prs|analyses|task|source|component|login|help)
        COMMAND="$1"
        shift
        ;;
esac

while (( $# )); do
    case "$1" in
        --summary-only|--somente-resumo) SUMMARY_ONLY=true ;;
        --no-color|--sem-cores) NO_COLOR=1 ;;
        -h|--help) SHOW_HELP=true ;;
        --) shift; POSITIONAL_ARGS+=("$@"); break ;;
        *) POSITIONAL_ARGS+=("$1") ;;
    esac
    shift
done

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    COLOR_RESET=$'\033[0m'
    COLOR_BOLD=$'\033[1m'
    COLOR_CYAN=$'\033[36m'
    COLOR_RED=$'\033[31m'
    COLOR_YELLOW=$'\033[33m'
    COLOR_MAGENTA=$'\033[35m'
    COLOR_GREEN=$'\033[32m'
    COLOR_BLUE=$'\033[34m'
    COLOR_DIM=$'\033[2m'
else
    COLOR_RESET=''
    COLOR_BOLD=''
    COLOR_CYAN=''
    COLOR_RED=''
    COLOR_YELLOW=''
    COLOR_MAGENTA=''
    COLOR_GREEN=''
    COLOR_BLUE=''
    COLOR_DIM=''
fi

OUTPUT_WIDTH="${COLUMNS:-100}"
if [[ ! "$OUTPUT_WIDTH" =~ ^[0-9]+$ ]]; then
    OUTPUT_WIDTH=100
fi
if (( OUTPUT_WIDTH < 72 )); then
    OUTPUT_WIDTH=72
elif (( OUTPUT_WIDTH > 120 )); then
    OUTPUT_WIDTH=120
fi
FIELD_WIDTH=$((OUTPUT_WIDTH - 12))

help_section() {
    printf '\n%b%s%b\n' "$COLOR_BOLD$COLOR_CYAN" "$1" "$COLOR_RESET"
}

help_row() {
    printf '  %b%-11s%b%b%-26s%b %s\n' \
        "$COLOR_GREEN$COLOR_BOLD" "$1" "$COLOR_RESET" \
        "$COLOR_YELLOW" "$2" "$COLOR_RESET" "$3"
}

help_option() {
    printf '  %b%-34s%b %s\n' "$COLOR_GREEN$COLOR_BOLD" "$1" "$COLOR_RESET" "$2"
}

help_example() {
    printf '  %b$%b %s\n' "$COLOR_DIM" "$COLOR_RESET" "$1"
}

usage() {
    printf '\n%bSONARQUBE CLI%b  %b· consultas de qualidade sem sair do terminal%b\n' \
        "$COLOR_BOLD$COLOR_CYAN" "$COLOR_RESET" "$COLOR_DIM" "$COLOR_RESET"
    printf '%s\n' '======================================================================='

    help_section 'USO'
    printf '  bash scripts/sonar-issues.sh %b<comando>%b %b[argumentos]%b %b[opções]%b\n' \
        "$COLOR_GREEN$COLOR_BOLD" "$COLOR_RESET" "$COLOR_YELLOW" "$COLOR_RESET" "$COLOR_DIM" "$COLOR_RESET"

    help_section 'CONFIGURAÇÃO'
    help_row 'login' '' 'Configurar servidor e token de usuário'

    help_section 'CONSULTAS (SOMENTE LEITURA)'
    help_row 'issues' '[pr] [projeto]' 'Listar apontamentos e explicações das regras (padrão)'
    help_row 'show' '<chave>' 'Exibir localização, mensagem e regra do apontamento'
    help_row 'rule' '<chave>' 'Exibir metadados e descrição de uma regra'
    help_row 'rules' '[termo]' 'Pesquisar regras'
    help_row 'metrics' '[pr] [projeto]' 'Exibir métricas do projeto/PR'
    help_row 'gate' '[pr] [projeto]' 'Exibir situação do portão de qualidade e condições'
    help_row 'hotspots' '[pr] [projeto]' 'Listar alertas de segurança para um PR'
    help_row 'branches' '[projeto]' 'Listar branches analisadas'
    help_row 'prs' '[projeto]' 'Listar pull requests analisados'
    help_row 'analyses' '[projeto]' 'Exibir análises recentes'
    help_row 'task' '<id-ce>' 'Consultar tarefa do Compute Engine'
    help_row 'source' '<componente> <ini> <fim>' 'Exibir linhas de código analisadas'
    help_row 'component' '<chave>' 'Exibir metadados de um componente'

    help_section 'OPÇÕES'
    help_option '--somente-resumo, --summary-only' 'Exibir apenas o painel geral (issues)'
    help_option '--sem-cores, --no-color' 'Desativar cores e links na saída'
    help_option '-h, --help' 'Exibir esta ajuda'

    help_section 'VARIÁVEIS DE AMBIENTE'
    help_row 'SONAR_URL' '' 'URL base da instância'
    help_row 'SONAR_TOKEN' '' 'Token de usuário (prefira o comando login)'
    help_row 'SONAR_PROJECT_KEY' '' 'Chave do projeto padrão'
    help_row 'SONAR_PULL_REQUEST' '' 'Número do PR padrão'
    help_row 'SONAR_CONFIG' '' 'Arquivo de configuração alternativo'
    help_row 'SONAR_CONNECT_TIMEOUT' '' "Limite de conexão em segundos (atual: ${SONAR_CONNECT_TIMEOUT}s)"
    help_row 'SONAR_TIMEOUT' '' "Limite total da requisição em segundos (atual: ${SONAR_TIMEOUT}s)"

    help_section 'EXEMPLOS'
    help_example 'bash scripts/sonar-issues.sh login'
    help_example 'bash scripts/sonar-issues.sh issues 42 exemplo_front'
    help_example 'bash scripts/sonar-issues.sh --somente-resumo issues'
    help_example 'bash scripts/sonar-issues.sh source <componente> 10 30'

    printf '\n%bDica:%b execute %blogin%b uma vez; os demais comandos usam as credenciais salvas.\n\n' \
        "$COLOR_BOLD" "$COLOR_RESET" "$COLOR_GREEN" "$COLOR_RESET"
}

read_config_value() {
    local config_key="$1"

    if [[ ! -f "$CONFIG_FILE" ]]; then
        return 0
    fi

    awk -F: -v key="$config_key" '$1 == key { sub(/^[^:]*:[[:space:]]*/, ""); print; exit }' "$CONFIG_FILE"
}

SONAR_USER_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/sonar-cli/config"

read_user_config_value() {
    local config_key="$1"

    if [[ ! -f "$SONAR_USER_CONFIG" ]]; then
        return 0
    fi

    awk -F= -v key="$config_key" '$1 == key { sub(/^[^=]*=/, ""); print; exit }' "$SONAR_USER_CONFIG"
}

if [[ "$SHOW_HELP" == true ]]; then
    usage
    exit 0
fi

if [[ "$COMMAND" == 'help' ]]; then
    usage
    exit 0
fi

DEFAULT_PROJECT_KEY="${SONAR_PROJECT_KEY:-$(read_user_config_value project)}"
DEFAULT_PROJECT_KEY="${DEFAULT_PROJECT_KEY:-$(read_config_value sonar_project)}"
DEFAULT_PULL_REQUEST="${SONAR_PULL_REQUEST:-$(read_user_config_value pullRequest)}"
DEFAULT_PULL_REQUEST="${DEFAULT_PULL_REQUEST:-$(read_config_value sonar_pr)}"

PULL_REQUEST="${POSITIONAL_ARGS[0]:-$DEFAULT_PULL_REQUEST}"
PROJECT_KEY="${POSITIONAL_ARGS[1]:-$DEFAULT_PROJECT_KEY}"
SONAR_URL="${SONAR_URL:-$(read_user_config_value url)}"
SONAR_URL="${SONAR_URL:-$(read_config_value sonar_ur)}"
SONAR_URL="${SONAR_URL:-$DEFAULT_SONAR_URL}"
SONAR_TOKEN="${SONAR_TOKEN:-$(read_user_config_value token)}"
SONAR_TOKEN="${SONAR_TOKEN:-$(read_config_value sonar_key)}"
SONAR_URL="${SONAR_URL%/}"

if [[ ! "$SONAR_CONNECT_TIMEOUT" =~ ^[1-9][0-9]*$ || ! "$SONAR_TIMEOUT" =~ ^[1-9][0-9]*$ ]]; then
    printf 'Erro: SONAR_CONNECT_TIMEOUT e SONAR_TIMEOUT devem ser números inteiros positivos.\n' >&2
    exit 2
fi

for required_command in curl jq; do
    if ! command -v "$required_command" >/dev/null 2>&1; then
        printf 'Erro: comando necessário não encontrado: %s\n' "$required_command" >&2
        exit 2
    fi
done

curl_with_loading() {
    local label="$1"
    local request_url="$2"
    local auth_token="$3"
    shift 3
    local response
    local curl_status=0
    local error_file
    local response_file
    local started_at="$SECONDS"
    local frame_index=0
    local elapsed=0
    local -a frames=('|' '/' '-' '\')

    error_file="$(mktemp)"
    response_file="$(mktemp)"

    curl --fail --silent --show-error \
        --connect-timeout "$SONAR_CONNECT_TIMEOUT" \
        --max-time "$SONAR_TIMEOUT" \
        --config <(printf 'user = "%s:"\n' "$auth_token") \
        --get "$request_url" \
        "$@" >"$response_file" 2>"$error_file" &
    local curl_pid=$!

    if [[ -t 2 ]]; then
        while kill -0 "$curl_pid" 2>/dev/null; do
            elapsed=$((SECONDS - started_at))
            printf '\r\033[K%b%s%b %s (%02ds)' \
                "$COLOR_CYAN$COLOR_BOLD" "${frames[$frame_index]}" "$COLOR_RESET" "$label" "$elapsed" >&2
            frame_index=$(((frame_index + 1) % ${#frames[@]}))
            sleep 0.1
        done
    fi

    if wait "$curl_pid"; then
        elapsed=$((SECONDS - started_at))
        if [[ -s "$error_file" ]]; then
            cat "$error_file" >&2
        fi
        if [[ -t 2 ]]; then
            printf '\r\033[K%bOK%b %s concluído em %02ds\n' \
                "$COLOR_GREEN$COLOR_BOLD" "$COLOR_RESET" "$label" "$elapsed" >&2
        fi
        rm -f "$error_file"
        cat "$response_file"
        rm -f "$response_file"
    else
        curl_status=$?
        elapsed=$((SECONDS - started_at))
        if [[ -t 2 ]]; then
            printf '\r\033[K%bERRO%b %s após %02ds\n' \
                "$COLOR_RED$COLOR_BOLD" "$COLOR_RESET" "$label" "$elapsed" >&2
        fi
        if [[ "$curl_status" == '28' ]]; then
            printf 'Tempo limite excedido (%ss). Confira a conexão e tente novamente.\n' "$SONAR_TIMEOUT" >&2
        elif [[ -s "$error_file" ]]; then
            cat "$error_file" >&2
        fi
        rm -f "$error_file"
        rm -f "$response_file"
        return "$curl_status"
    fi
}

sonar_get() {
    local endpoint="$1"
    shift
    local label='Consultando o SonarQube'

    case "$endpoint" in
        /api/issues/search) label='Buscando apontamentos' ;;
        /api/rules/show) label='Carregando detalhes da regra' ;;
        /api/rules/search) label='Pesquisando regras' ;;
        /api/measures/component) label='Buscando métricas' ;;
        /api/qualitygates/project_status) label='Verificando portão de qualidade' ;;
        /api/hotspots/search) label='Buscando alertas de segurança' ;;
        /api/project_branches/list) label='Buscando branches' ;;
        /api/project_pull_requests/list) label='Buscando pull requests' ;;
        /api/project_analyses/search) label='Buscando histórico de análises' ;;
        /api/ce/task) label='Consultando tarefa de análise' ;;
        /api/sources/lines) label='Carregando linhas de código' ;;
        /api/components/show) label='Carregando componente' ;;
    esac

    curl_with_loading "$label" "$SONAR_URL$endpoint" "$SONAR_TOKEN" "$@"
}

traduz_tipo() {
    case "$1" in
        CODE_SMELL|MAINTAINABILITY) printf 'MANUTENÇÃO' ;;
        BUG|RELIABILITY) printf 'DEFEITO' ;;
        VULNERABILITY|SECURITY) printf 'SEGURANÇA' ;;
        *) printf '%s' "$1" ;;
    esac
}

traduz_severidade() {
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

traduz_status() {
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

traduz_quality_gate() {
    case "$1" in
        OK) printf 'APROVADO' ;;
        ERROR) printf 'REPROVADO' ;;
        WARN) printf 'ATENÇÃO' ;;
        *) printf '%s' "$1" ;;
    esac
}

login() {
    local entered_url
    local entered_token
    local entered_project
    local entered_pull_request
    local validation
    local validation_status=0

    if [[ ! -t 0 ]]; then
        printf 'Erro: o comando login precisa de um terminal interativo.\n' >&2
        return 2
    fi

    printf '\nConfiguração de acesso ao SonarQube\n\n'
    printf '1. Abra a instância no navegador e entre pelo login corporativo, se solicitado.\n'
    printf '2. No menu do usuário, acesse Minha conta > Segurança > Gerar tokens.\n'
    printf '3. Crie um token de usuário. Para consultar o projeto, sua conta precisa de permissão de leitura (Browse).\n\n'
    printf 'URL base do SonarQube (ex.: https://sonar.exemplo.invalid): '
    IFS= read -r entered_url
    entered_url="${entered_url:-$SONAR_URL}"
    entered_url="${entered_url%/}"
    entered_url="${entered_url%/api}"

    if [[ "$entered_url" == http://* ]]; then
        printf 'Aviso: esta URL usa HTTP; o token não fica protegido por TLS durante o envio. Prefira HTTPS, se disponível.\n' >&2
    fi

    printf 'Token de usuário (entrada oculta): '
    IFS= read -r -s entered_token
    printf '\n'

    printf 'Chave do projeto padrão (opcional, ex.: exemplo_front): '
    IFS= read -r entered_project
    entered_project="${entered_project:-$PROJECT_KEY}"

    printf 'PR padrão (opcional): '
    IFS= read -r entered_pull_request
    entered_pull_request="${entered_pull_request:-$PULL_REQUEST}"

    if [[ -z "$entered_url" || -z "$entered_token" ]]; then
        printf 'Erro: a URL base e o token são obrigatórios.\n' >&2
        return 2
    fi

    if validation="$(curl_with_loading 'Validando token' \
        "$entered_url/api/authentication/validate" "$entered_token")"; then
        :
    else
        validation_status=$?
        if [[ -t 2 ]]; then
            printf 'falhou\n' >&2
        fi
        unset entered_token
        if [[ "$validation_status" == '28' ]]; then
            printf 'Tempo limite excedido ao validar o token (limite: %ss). Nada foi salvo.\n' "$SONAR_TIMEOUT" >&2
        else
            printf 'Falha na autenticação. Confira a URL e o token. Nada foi salvo.\n' >&2
        fi
        return 1
    fi

    if ! jq -e '.valid == true' >/dev/null 2>&1 <<<"$validation"; then
        unset entered_token
        printf 'Token inválido para esta instância. Nada foi salvo.\n' >&2
        return 1
    fi

    mkdir -p "$(dirname "$SONAR_USER_CONFIG")"
    (
        umask 077
        printf 'url=%s\ntoken=%s\nproject=%s\npullRequest=%s\n' \
            "$entered_url" "$entered_token" "$entered_project" "$entered_pull_request" \
            >"$SONAR_USER_CONFIG"
    )
    chmod 600 "$SONAR_USER_CONFIG"
    unset entered_token

    printf 'Acesso validado. Credenciais salvas em %s com permissão somente para seu usuário.\n' "$SONAR_USER_CONFIG"
    printf 'O token não foi exibido. Se ele for exposto, revogue-o em Minha conta > Segurança.\n'
}

if [[ "$COMMAND" == 'login' ]]; then
    login
    exit $?
fi

if [[ -z "$SONAR_TOKEN" ]]; then
    printf 'Nenhum token configurado. Execute: bash scripts/sonar-issues.sh login\n' >&2
    exit 2
fi

for required_command in column; do
    if ! command -v "$required_command" >/dev/null 2>&1; then
        printf 'Erro: comando necessário não encontrado: %s\n' "$required_command" >&2
        exit 2
    fi
done

print_description() {
    local label="$1"
    local description="$2"
    local is_html="$3"
    local formatted
    local first_line=1

    if [[ "$is_html" == 'true' ]] && command -v python3 >/dev/null 2>&1; then
        formatted="$(SONAR_COLOR_RESET="$COLOR_RESET" \
            SONAR_COLOR_BOLD="$COLOR_BOLD" \
            SONAR_COLOR_CYAN="$COLOR_CYAN" \
            SONAR_COLOR_GREEN="$COLOR_GREEN" \
            SONAR_COLOR_BLUE="$COLOR_BLUE" \
            SONAR_COLOR_DIM="$COLOR_DIM" \
            SONAR_TEXT_WIDTH="$FIELD_WIDTH" \
            python3 -c '
import html
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
        formatted="$(printf '%s' "$description" | sed -E 's/<br[[:space:]]*\/?[[:space:]]*>/\n/gI; s#</(p|div|li|h[1-6])>#\n#gI; s/<li[^>]*>/- /Ig; s/<[^>]*>//g; s/&nbsp;/ /gI; s/&amp;/\&/gI; s/&lt;/</gI; s/&gt;/>/gI' | fold -s -w "$FIELD_WIDTH")"
    fi

    while IFS= read -r line; do
        if (( first_line )); then
            printf '  %-8s%s\n' "$label" "$line"
            first_line=0
        else
            printf '           %s\n' "$line"
        fi
    done <<<"$formatted"
    printf '\n'
}

print_field() {
    local label="$1"
    local value="$2"
    local color="${3:-$COLOR_CYAN$COLOR_BOLD}"

    printf '  %b%-8s%b ' "$color" "$label" "$COLOR_RESET"
    printf '%s\n' "$value" | fold -s -w "$FIELD_WIDTH" | sed '2,$s/^/           /'
    printf '\n'
}

format_issue_key() {
    local issue_key="$1"

    if [[ -t 1 && "${TERM:-dumb}" != 'dumb' ]]; then
        local project_query
        local issue_query
        local pull_request_query
        project_query="$(jq -rn --arg value "$PROJECT_KEY" '$value | @uri')"
        issue_query="$(jq -rn --arg value "$issue_key" '$value | @uri')"
        pull_request_query="$(jq -rn --arg value "$PULL_REQUEST" '$value | @uri')"
        printf '\033]8;;%s/project/issues?id=%s&open=%s&pullRequest=%s\033\\%s\033]8;;\033\\' \
            "$SONAR_URL" "$project_query" "$issue_query" "$pull_request_query" "$issue_key"
    else
        printf '%s' "$issue_key"
    fi
}

print_json() {
    if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
        jq -C .
    else
        jq .
    fi
}

print_rule() {
    local rule_key="$1"
    local response
    local description
    local is_html=false

    response="$(sonar_get '/api/rules/show' --data-urlencode "key=$rule_key")"
    description="$(jq -r '.rule.htmlDesc // .rule.mdDesc // .rule.description // "Descrição indisponível"' <<<"$response")"
    [[ "$(jq -r '.rule.htmlDesc // empty' <<<"$response")" ]] && is_html=true

    printf '\n%bREGRA%b  %s\n' "$COLOR_BOLD$COLOR_CYAN" "$COLOR_RESET" \
        "$(jq -r '.rule.name // .rule.key' <<<"$response")"
    printf '%s\n' '-----------------------------------------------------------------------'
    print_field 'CHAVE' "$(jq -r '.rule.key' <<<"$response")"
    print_field 'LINGUAGEM' "$(jq -r '.rule.langName // .rule.lang // "-"' <<<"$response")"
    print_field 'TIPO' "$(traduz_tipo "$(jq -r '.rule.type // "-"' <<<"$response")")"
    print_field 'SEVERIDADE' "$(traduz_severidade "$(jq -r '.rule.severity // "-"' <<<"$response")")"
    print_field 'TAGS' "$(jq -r '(.rule.tags // []) | join(", ")' <<<"$response")"
    print_description 'POR QUE:' "$description" "$is_html"
}

show_issue() {
    local issue_key="$1"
    local response
    local issue
    local component
    local rule_key

    response="$(sonar_get '/api/issues/search' \
        --data-urlencode "issues=$issue_key" \
        --data-urlencode "componentKeys=$PROJECT_KEY" \
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

    printf '\n%bDETALHES DO APONTAMENTO%b\n' "$COLOR_BOLD$COLOR_CYAN" "$COLOR_RESET"
    printf '%s\n' '======================================================================='
    print_field 'CHAVE' "$(format_issue_key "$issue_key")"
    print_field 'TIPO' "$(traduz_tipo "$(jq -r '.type // (.impacts[0].softwareQuality // "-" )' <<<"$issue")")"
    print_field 'SEVERIDADE' "$(traduz_severidade "$(jq -r '.severity // (.impacts[0].severity // "-")' <<<"$issue")")"
    print_field 'SITUAÇÃO' "$(traduz_status "$(jq -r '.status // "-"' <<<"$issue")")"
    print_field 'LOCAL' "$component:$(jq -r '.line // .textRange.startLine // "-"' <<<"$issue")"
    print_field 'MENSAGEM' "$(jq -r '.message // "-"' <<<"$issue")"
    print_field 'ESFORCO' "$(jq -r '.effort // "-"' <<<"$issue")"
    print_field 'REGRA' "$rule_key"
    print_rule "$rule_key"
}

run_command() {
    local command="$1"
    local first="${POSITIONAL_ARGS[0]:-}"
    local second="${POSITIONAL_ARGS[1]:-$DEFAULT_PROJECT_KEY}"
    local response
    local page

    case "$command" in
        show|issue)
            [[ -n "$first" ]] || { usage >&2; return 2; }
            show_issue "$first"
            ;;
        rule)
            [[ -n "$first" ]] || { usage >&2; return 2; }
            print_rule "$first"
            ;;
        rules)
            if [[ -n "$first" ]]; then
                response="$(sonar_get '/api/rules/search' \
                    --data-urlencode "q=$first" \
                    --data-urlencode 'p=1' --data-urlencode 'ps=100')"
            else
                response="$(sonar_get '/api/rules/search' \
                    --data-urlencode 'p=1' --data-urlencode 'ps=100')"
            fi
            jq -r '.rules[]? | [.key, .langName, .type, .severity, .name] | @tsv' <<<"$response" \
                | awk -F '\t' 'BEGIN { printf "%-34s %-14s %-18s %-12s %s\\n", "REGRA", "LINGUAGEM", "TIPO", "SEVERIDADE", "NOME"; for (i=0;i<100;i++) printf "-"; printf "\\n" } { printf "%-34s %-14s %-18s %-12s %s\\n", $1, $2, $3, $4, $5 }'
            ;;
        metrics)
            local pr="${first:-$DEFAULT_PULL_REQUEST}"
            local project="${second:-$DEFAULT_PROJECT_KEY}"
            sonar_get '/api/measures/component' \
                --data-urlencode "component=$project" \
                --data-urlencode "pullRequest=$pr" \
                --data-urlencode 'metricKeys=code_smells,bugs,vulnerabilities,coverage,duplicated_lines_density,ncloc,complexity,cognitive_complexity,sqale_index,new_code_smells,new_bugs,new_vulnerabilities,new_coverage' \
                | jq -r '"MÉTRICA\tVALOR", (.component.measures[]? | [(.metric | if . == "code_smells" then "problemas de manutenção" elif . == "bugs" then "defeitos" elif . == "vulnerabilities" then "vulnerabilidades" elif . == "coverage" then "cobertura" elif . == "duplicated_lines_density" then "duplicação percentual" elif . == "ncloc" then "linhas de código" elif . == "complexity" then "complexidade" elif . == "cognitive_complexity" then "complexidade cognitiva" elif . == "new_code_smells" then "novos problemas de manutenção" elif . == "new_bugs" then "novos defeitos" elif . == "new_vulnerabilities" then "novas vulnerabilidades" elif . == "new_coverage" then "cobertura do código novo" else . end), .value] | @tsv)' \
                | column -t -s $'\t'
            ;;
        gate)
            local pr="${first:-$DEFAULT_PULL_REQUEST}"
            local project="${second:-$DEFAULT_PROJECT_KEY}"
            response="$(sonar_get '/api/qualitygates/project_status' \
                --data-urlencode "projectKey=$project" --data-urlencode "pullRequest=$pr")"
            printf '%s\n' "$response" | jq -r '
                "Portão de qualidade: \((.projectStatus.status // "N/A") | if . == "OK" then "APROVADO" elif . == "ERROR" then "REPROVADO" elif . == "WARN" then "ATENÇÃO" else . end)",
                "CONDIÇÃO  MÉTRICA  VALOR  LIMITE",
                (.projectStatus.conditions[]? | "  \(.status)  \(.metricKey)  \(.actualValue // "-")  \(.comparator // "")\(.errorThreshold // "")")'
            ;;
        hotspots)
            local pr="${first:-$DEFAULT_PULL_REQUEST}"
            local project="${second:-$DEFAULT_PROJECT_KEY}"
            page=1
            while :; do
                response="$(sonar_get '/api/hotspots/search' \
                    --data-urlencode "projectKey=$project" \
                    --data-urlencode "pullRequest=$pr" \
                    --data-urlencode "p=$page" --data-urlencode "ps=$PAGE_SIZE")"
                jq -r '"CHAVE\tSITUAÇÃO\tRISCO\tCOMPONENTE\tLINHA\tMENSAGEM", (.hotspots[]? | [.key, (.status | if . == "TO_REVIEW" then "AGUARDANDO REVISÃO" elif . == "ACKNOWLEDGED" then "RECONHECIDO" elif . == "FIXED" then "CORRIGIDO" elif . == "SAFE" then "SEGURO" else . end), .vulnerabilityProbability, .component, (.line // "-"), .message] | @tsv)' <<<"$response" \
                    | column -t -s $'\t'
                local hotspot_total
                hotspot_total="$(jq -r '.paging.total // 0' <<<"$response")"
                (( page * PAGE_SIZE >= hotspot_total )) && break
                page=$((page + 1))
            done
            ;;
        branches)
            local project="${first:-$DEFAULT_PROJECT_KEY}"
            sonar_get '/api/project_branches/list' --data-urlencode "project=$project" \
                | jq -r '"NOME\tPRINCIPAL\tTIPO\tÚLTIMA ANÁLISE", (.branches[]? | [.name, (if .isMain then "SIM" else "NÃO" end), (.type // "-"), (.status.lastAnalysis.date // "-")] | @tsv)' \
                | column -t -s $'\t'
            ;;
        prs)
            local project="${first:-$DEFAULT_PROJECT_KEY}"
            sonar_get '/api/project_pull_requests/list' --data-urlencode "project=$project" \
                | jq -r '"CHAVE\tTÍTULO\tBRANCH\tBASE\tSITUAÇÃO", (.pullRequests[]? | [.key, .title, .branch, .base, (.status // "-")] | @tsv)' \
                | column -t -s $'\t'
            ;;
        analyses)
            local project="${first:-$DEFAULT_PROJECT_KEY}"
            sonar_get '/api/project_analyses/search' \
                --data-urlencode "project=$project" --data-urlencode 'p=1' --data-urlencode 'ps=20' \
                | jq -r '"CHAVE\tDATA\tVERSAO\tEVENTO", (.analyses[]? | [.key, .date, (.projectVersion // "-"), (.events[0].name // "-")] | @tsv)' \
                | column -t -s $'\t'
            ;;
        task)
            [[ -n "$first" ]] || { usage >&2; return 2; }
            sonar_get '/api/ce/task' --data-urlencode "id=$first" | print_json
            ;;
        source)
            [[ -n "$first" && -n "${POSITIONAL_ARGS[1]:-}" && -n "${POSITIONAL_ARGS[2]:-}" ]] || { usage >&2; return 2; }
            sonar_get '/api/sources/lines' \
                --data-urlencode "key=$first" \
                --data-urlencode "from=${POSITIONAL_ARGS[1]}" \
                --data-urlencode "to=${POSITIONAL_ARGS[2]}" \
                | jq -r '"LINHA\tCÓDIGO", (.sources[]? | [.line, (.code // "")] | @tsv)' \
                | while IFS=$'\t' read -r source_line source_code; do
                    printf '%5s  %s\n' "$source_line" "$source_code"
                done
            ;;
        component)
            [[ -n "$first" ]] || { usage >&2; return 2; }
            sonar_get '/api/components/show' --data-urlencode "component=$first" \
                | jq '.component | {chave: .key, nome: .name, nomeCompleto: .longName, tipo: .qualifier, caminho: .path}'
            ;;
        issues) return 3 ;;
        *) usage >&2; return 2 ;;
    esac
}

if [[ "$COMMAND" != 'issues' ]]; then
    run_command "$COMMAND"
    exit $?
fi

quality_gate_response="$(sonar_get '/api/qualitygates/project_status' \
    --data-urlencode "projectKey=$PROJECT_KEY" \
    --data-urlencode "pullRequest=$PULL_REQUEST" 2>/dev/null || printf '{}')"
measures_response="$(sonar_get '/api/measures/component' \
    --data-urlencode "component=$PROJECT_KEY" \
    --data-urlencode "pullRequest=$PULL_REQUEST" \
    --data-urlencode 'metricKeys=coverage,duplicated_lines_density,ncloc' 2>/dev/null || printf '{}')"

quality_gate="$(jq -r '.projectStatus.status // "N/A"' <<<"$quality_gate_response")"
coverage="$(jq -r '([.component.measures[]? | select(.metric == "coverage") | .value] | first) // "N/A"' <<<"$measures_response")"
duplication="$(jq -r '([.component.measures[]? | select(.metric == "duplicated_lines_density") | .value] | first) // "N/A"' <<<"$measures_response")"
lines_of_code="$(jq -r '([.component.measures[]? | select(.metric == "ncloc") | .value] | first) // "N/A"' <<<"$measures_response")"

issues='[]'
components='[]'
total=0
page=1

while :; do
    response="$(sonar_get '/api/issues/search' \
        --data-urlencode "componentKeys=$PROJECT_KEY" \
        --data-urlencode "pullRequest=$PULL_REQUEST" \
        --data-urlencode 'types=CODE_SMELL,BUG,VULNERABILITY' \
        --data-urlencode 'resolved=false' \
        --data-urlencode "p=$page" \
        --data-urlencode "ps=$PAGE_SIZE")"

    total="$(jq -r '.paging.total // 0' <<<"$response")"
    issues="$(jq -cn --argjson current "$issues" --argjson response "$response" '$current + ($response.issues // [])')"
    components="$(jq -cn --argjson current "$components" --argjson response "$response" '($current + ($response.components // [])) | unique_by(.key)')"

    if (( page * PAGE_SIZE >= total )); then
        break
    fi

    page=$((page + 1))
done

code_smell_count="$(jq '[.[] | select(.type == "CODE_SMELL" or any(.impacts[]?; .softwareQuality == "MAINTAINABILITY"))] | length' <<<"$issues")"
bug_count="$(jq '[.[] | select(.type == "BUG" or any(.impacts[]?; .softwareQuality == "RELIABILITY"))] | length' <<<"$issues")"
vulnerability_count="$(jq '[.[] | select(.type == "VULNERABILITY" or any(.impacts[]?; .softwareQuality == "SECURITY"))] | length' <<<"$issues")"

printf '\n%bRELATÓRIO DE QUALIDADE DO SONARQUBE%b\n' "$COLOR_BOLD$COLOR_CYAN" "$COLOR_RESET"
printf '%s\n' '======================================================================='
print_field 'PROJETO' "$PROJECT_KEY"
print_field 'PR' "${PULL_REQUEST:-todos}"
print_field 'ABERTOS' "$total apontamentos"
printf '\n  %bRESUMO%b  %bProblemas de manutenção: %s%b  |  %bDefeitos: %s%b  |  %bVulnerabilidades: %s%b\n' \
    "$COLOR_CYAN$COLOR_BOLD" "$COLOR_RESET" \
    "$COLOR_YELLOW$COLOR_BOLD" "$code_smell_count" "$COLOR_RESET" \
    "$COLOR_RED$COLOR_BOLD" "$bug_count" "$COLOR_RESET" \
    "$COLOR_MAGENTA$COLOR_BOLD" "$vulnerability_count" "$COLOR_RESET"
printf '\n  %bPORTÃO%b  %b%s%b     Cobertura: %s%%     Duplicação: %s%%     Linhas de código: %s\n' \
    "$COLOR_CYAN$COLOR_BOLD" "$COLOR_RESET" "$COLOR_BOLD" "$(traduz_quality_gate "$quality_gate")" "$COLOR_RESET" \
    "$coverage" "$duplication" "$lines_of_code"
printf '%s\n' '======================================================================='

if [[ "$SUMMARY_ONLY" == true ]]; then
    exit 0
fi

if [[ "$total" == '0' ]]; then
    printf 'Nenhum apontamento aberto foi encontrado.\n'
    exit 0
fi

declare -A RULE_NAMES=()
declare -A RULE_DESCRIPTIONS=()
declare -A RULE_DESCRIPTION_IS_HTML=()

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
        RULE_DESCRIPTIONS["$rule_key"]='Detalhes da regra indisponiveis; confira o acesso a instancia.'
        RULE_DESCRIPTION_IS_HTML["$rule_key"]='false'
    fi
done < <(jq -r '[.[] | .rule] | unique | .[]' <<<"$issues")

index=0
while IFS=$'\t' read -r issue_key issue_type severity status effort component line rule_key message; do
    index=$((index + 1))
    file_path="$(jq -r --arg key "$component" '([.[] | select(.key == $key) | (.path // .longName // .name)] | first) // $key' <<<"$components")"
    rule_name="${RULE_NAMES[$rule_key]:-$rule_key}"
    rule_description="${RULE_DESCRIPTIONS[$rule_key]:-Descrição da regra indisponível.}"

    case "$issue_type" in
        BUG|RELIABILITY) issue_color="$COLOR_RED" ;;
        VULNERABILITY|SECURITY) issue_color="$COLOR_MAGENTA" ;;
        CODE_SMELL|MAINTAINABILITY) issue_color="$COLOR_YELLOW" ;;
        *) issue_color="$COLOR_CYAN" ;;
    esac

    case "$severity" in
        BLOCKER|CRITICAL|HIGH) severity_color="$COLOR_RED" ;;
        MAJOR|MEDIUM) severity_color="$COLOR_YELLOW" ;;
        MINOR|LOW) severity_color="$COLOR_CYAN" ;;
        *) severity_color="$COLOR_DIM" ;;
    esac

    printf '\n%b[%02d/%02d] %s%b  |  %b%s%b\n' \
        "$COLOR_BOLD$issue_color" "$index" "$total" "$(traduz_tipo "$issue_type")" "$COLOR_RESET" \
        "$severity_color$COLOR_BOLD" "$(traduz_severidade "$severity")" "$COLOR_RESET"
    print_field 'CHAVE' "$(format_issue_key "$issue_key")"
    print_field 'SITUAÇÃO' "$(traduz_status "$status")"
    print_field 'LOCAL' "$file_path:$line"
    print_field 'REGRA' "$rule_name ($rule_key)"
    print_field 'MENSAGEM' "$message"
    print_field 'ESFORCO' "$effort"
    print_description 'POR QUE:' "$rule_description" "${RULE_DESCRIPTION_IS_HTML[$rule_key]:-false}"
    printf '%s\n' '-----------------------------------------------------------------------'
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
