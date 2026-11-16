#!/bin/bash

# ==================================================
# SONAR MODULE — configuração (JSON) e login
# Apenas funções; carregar este arquivo não lê rede nem grava nada.
#
# Formato do config (~/.config/bytebabe/sonar.json, permissão 600):
# {
#   "url": "",
#   "token": "",
#   "activeProject": "",
#   "defaultPullRequest": "",
#   "projects": [
#     { "key": "", "prs": [], "activePr": "" }
#   ]
# }
#
# As chaves achatadas antigas continuam aceitas pelos getters/setters
# como apelidos do esquema acima:
#   project            -> activeProject
#   projects           -> lista de .projects[].key (vírgulas)
#   pullRequest        -> defaultPullRequest (padrão global do login)
#   pullRequest.<p>    -> activePr do projeto <p>
#   pullRequests.<p>   -> lista .prs do projeto <p> (vírgulas)
# ==================================================

_SONAR_USER_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/bytebabe/sonar.json"
_SONAR_LEGACY_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/bytebabe/sonar.conf"
_SONAR_CONNECT_TIMEOUT="${SONAR_CONNECT_TIMEOUT:-10}"
_SONAR_TIMEOUT="${SONAR_TIMEOUT:-60}"
_SONAR_LEGACY_HINT_SHOWN=0

# Lê uma chave do config (com apelidos do esquema). Saída: valor ou vazio.
_sonar_config_get() {
    local key="$1"
    local current

    [[ -f "$_SONAR_USER_CONFIG" ]] || return 0
    current="$(cat "$_SONAR_USER_CONFIG" 2>/dev/null)" || return 0
    jq -e . >/dev/null 2>&1 <<<"$current" || return 0

    case "$key" in
        project)
            jq -r '.activeProject // ""' <<<"$current"
            ;;
        pullRequest)
            jq -r '.defaultPullRequest // ""' <<<"$current"
            ;;
        pullRequest.*)
            jq -r --arg k "${key#pullRequest.}" \
                '(.projects[]? | select(.key == $k) | .activePr) // ""' \
                <<<"$current"
            ;;
        pullRequests.*)
            jq -r --arg k "${key#pullRequests.}" \
                '(.projects[]? | select(.key == $k) | (.prs // [])) | join(",")' \
                <<<"$current"
            ;;
        projects)
            jq -r '[(.projects // [])[]?.key] | join(",")' <<<"$current"
            ;;
        *)
            jq -r --arg k "$key" '.[$k] // ""' <<<"$current"
            ;;
    esac
}

# Grava uma chave do config (com apelidos do esquema), preservando o resto.
# Arquivo mantido com permissão 600 e gravação atômica.
_sonar_config_set() {
    local key="$1"
    local value="$2"
    local dir
    local tmp
    local current
    local proj

    dir="$(dirname "$_SONAR_USER_CONFIG")"
    mkdir -p "$dir"
    current="{}"
    if [[ -f "$_SONAR_USER_CONFIG" ]]; then
        current="$(cat "$_SONAR_USER_CONFIG" 2>/dev/null)" || current="{}"
        jq -e . >/dev/null 2>&1 <<<"$current" || current="{}"
    fi

    tmp="$(mktemp "${TMPDIR:-/tmp}/bytebabe-sonar.XXXXXX")"
    (
        umask 077
        case "$key" in
            project)
                jq --arg v "$value" '.activeProject = $v' <<<"$current"
                ;;
            pullRequest)
                jq --arg v "$value" '.defaultPullRequest = $v' <<<"$current"
                ;;
            pullRequest.*)
                proj="${key#pullRequest.}"
                jq --arg k "$proj" --arg v "$value" \
                    '.projects = ((.projects // []) as $p |
                        [$p[] | select(.key != $k)] +
                        [(($p[] | select(.key == $k)) // {"key": $k, "prs": [], "activePr": ""}) | .activePr = $v])' \
                    <<<"$current"
                ;;
            pullRequests.*)
                proj="${key#pullRequests.}"
                jq --arg k "$proj" --arg v "$value" \
                    '.projects = ((.projects // []) as $p |
                        [$p[] | select(.key != $k)] +
                        [(($p[] | select(.key == $k)) // {"key": $k, "prs": [], "activePr": ""}) |
                            .prs = ($v | split(",") | map(select(length > 0)))])' \
                    <<<"$current"
                ;;
            projects)
                jq --arg raw "$value" \
                    '($raw | split(",") | map(select(length > 0))) as $keys |
                        .projects = [$keys[] as $k |
                            ((.projects // [])[] | select(.key == $k)) //
                                {"key": $k, "prs": [], "activePr": ""}]' \
                    <<<"$current"
                ;;
            *)
                jq --arg k "$key" --arg v "$value" '.[$k] = $v' <<<"$current"
                ;;
        esac >"$tmp"
    )
    mv "$tmp" "$_SONAR_USER_CONFIG"
    chmod 600 "$_SONAR_USER_CONFIG"
}

# Aviso único quando só existe o config antigo em key=value (sonar.conf).
_sonar_cfg_legacy_hint() {
    if [[ "${_SONAR_LEGACY_HINT_SHOWN:-0}" == 0 && -f "$_SONAR_LEGACY_CONFIG" && ! -f "$_SONAR_USER_CONFIG" ]]; then
        _SONAR_LEGACY_HINT_SHOWN=1
        printf '%bℹ Config antigo detectado (%s); formato novo é %s.%b\n' \
            "$_SONAR_YELLOW" "$_SONAR_LEGACY_CONFIG" "$_SONAR_USER_CONFIG" "$_SONAR_RESET" >&2
        printf '%bRode %b para gerar o config novo.%b\n' \
            "$_SONAR_DIM" "bytebabe sonar login" "$_SONAR_RESET" >&2
    fi
}

# Resolve credenciais: variáveis de ambiente vencem o arquivo de config.
sonar_resolve_credentials() {
    _sonar_cfg_legacy_hint
    SONAR_URL="${SONAR_URL:-$(_sonar_config_get url)}"
    SONAR_TOKEN="${SONAR_TOKEN:-$(_sonar_config_get token)}"
    SONAR_PROJECT_KEY="${SONAR_PROJECT_KEY:-$(_sonar_config_get project)}"
    SONAR_URL="${SONAR_URL%/}"
}

_sonar_validate_timeouts() {
    if [[ ! "$_SONAR_CONNECT_TIMEOUT" =~ ^[1-9][0-9]*$ || ! "$_SONAR_TIMEOUT" =~ ^[1-9][0-9]*$ ]]; then
        printf 'Erro: SONAR_CONNECT_TIMEOUT e SONAR_TIMEOUT devem ser números inteiros positivos.\n' >&2
        return 2
    fi
}

sonar_require_credentials() {
    sonar_resolve_credentials
    if [[ -z "$SONAR_TOKEN" ]]; then
        printf '%b✗ Nenhum token configurado. Execute:%b %bbytebabe sonar login%b\n' \
            "$_SONAR_RED$_SONAR_BOLD" "$_SONAR_RESET" \
            "$_SONAR_GREEN$_SONAR_BOLD" "$_SONAR_RESET" >&2
        return 2
    fi
    return 0
}

# Detecta a chave do projeto a partir do diretório atual (subindo os pais).
# Suporta sonar-project.properties e .sonarcloud.properties.
_sonar_detect_project() {
    local dir="$PWD"
    local prop_file
    local key

    while :; do
        for prop_file in sonar-project.properties .sonarcloud.properties; do
            if [[ -f "$dir/$prop_file" ]]; then
                key="$(awk -F= '$1 == "sonar.projectKey" { sub(/^[[:space:]]*/, "", $2); sub(/[[:space:]]+$/, "", $2); print $2; exit }' "$dir/$prop_file")"
                if [[ -n "$key" ]]; then
                    printf '%s' "$key"
                    return 0
                fi
            fi
        done
        [[ "$dir" == "/" ]] && return 0
        dir="$(dirname "$dir")"
    done
}

# Resolve PR/projeto efetivos. Prioridade do projeto:
#   -p/--projeto > posicionais > autodetecção (sonar-project.properties)
#   > SONAR_PROJECT_KEY (env) > projeto ativo (activeProject do sonar.json,
#   sincronizado pelos comandos project use/set/next/prev).
# Prioridade do PR: posicionais > activePr do projeto (pr use) >
#   SONAR_PULL_REQUEST (env) > defaultPullRequest (padrão do login).
# Modo "pr_project" aceita posicionais: <pr> <projeto>.
sonar_resolve_context() {
    local mode="${1:-default}"
    local detected
    detected="$(_sonar_detect_project)"

    if [[ -n "${_SONAR_PROJECT_FLAG:-}" ]]; then
        _SONAR_PROJECT="$_SONAR_PROJECT_FLAG"
    elif [[ "$mode" == "pr_project" && -n "${SONAR_POSITIONAL_ARGS[1]:-}" ]]; then
        _SONAR_PROJECT="${SONAR_POSITIONAL_ARGS[1]}"
    elif [[ -n "$detected" ]]; then
        _SONAR_PROJECT="$detected"
    else
        _SONAR_PROJECT="${SONAR_PROJECT_KEY:-}"
    fi

    _SONAR_PR="$(_sonar_config_get "pullRequest.${_SONAR_PROJECT:-_sem_projeto_}")"
    if [[ -z "$_SONAR_PR" ]]; then
        _SONAR_PR="${SONAR_PULL_REQUEST:-}"
    fi
    if [[ -z "$_SONAR_PR" ]]; then
        _SONAR_PR="$(_sonar_config_get pullRequest)"
    fi

    if [[ "$mode" == "pr_project" && -z "${_SONAR_PR:-}" ]]; then
        _SONAR_PR="${SONAR_POSITIONAL_ARGS[0]:-}"
    fi
}

sonar_require_project() {
    if [[ -z "${1:-}" ]]; then
        printf '%b✗ Nenhuma chave de projeto configurada. Execute:%b %bbytebabe sonar login%b\n' \
            "$_SONAR_RED$_SONAR_BOLD" "$_SONAR_RESET" \
            "$_SONAR_GREEN$_SONAR_BOLD" "$_SONAR_RESET" >&2
        return 2
    fi
    return 0
}

# bytebabe sonar login: configura URL/token de forma interativa e segura.
sonar_login() {
    local entered_url
    local entered_token
    local entered_project
    local entered_pull_request
    local validation
    local validation_status=0
    local old_list

    if [[ ! -t 0 ]]; then
        printf '%b✗ O comando login precisa de um terminal interativo.%b\n' \
            "$_SONAR_RED$_SONAR_BOLD" "$_SONAR_RESET" >&2
        return 2
    fi

    sonar_resolve_credentials

    printf '\n%b⚡ CONFIGURAÇÃO DE ACESSO AO SONARQUBE%b\n' "$_SONAR_BOLD$_SONAR_CYAN" "$_SONAR_RESET"
    printf '%b─────────────────────────────────────────────────────────────%b\n\n' "$_SONAR_DIM" "$_SONAR_RESET"
    printf '  %b[1]%b %bAbra a instância no navegador e entre pelo login corporativo, se solicitado.%b\n' \
        "$_SONAR_GREEN$_SONAR_BOLD" "$_SONAR_RESET" "$_SONAR_WHITE" "$_SONAR_RESET"
    printf '  %b[2]%b %bNo menu do usuário, acesse Minha conta > Segurança > Gerar tokens.%b\n' \
        "$_SONAR_GREEN$_SONAR_BOLD" "$_SONAR_RESET" "$_SONAR_WHITE" "$_SONAR_RESET"
    printf '  %b[3]%b %bCrie um token de usuário. Para consultar o projeto, sua conta%b\n' \
        "$_SONAR_GREEN$_SONAR_BOLD" "$_SONAR_RESET" "$_SONAR_WHITE" "$_SONAR_RESET"
    printf '      %bprecisa de permissão de leitura (Browse).%b\n\n' "$_SONAR_WHITE" "$_SONAR_RESET"

    printf '  %b➜ URL base do SonarQube%b %b(ex.: https://sonar.exemplo.invalid)%b: ' \
        "$_SONAR_GREEN$_SONAR_BOLD" "$_SONAR_RESET" "$_SONAR_DIM" "$_SONAR_RESET"
    IFS= read -r entered_url
    entered_url="${entered_url:-$SONAR_URL}"
    entered_url="${entered_url%/}"
    entered_url="${entered_url%/api}"

    printf '  %b➜ Token de usuário%b %b(entrada oculta)%b: ' \
        "$_SONAR_GREEN$_SONAR_BOLD" "$_SONAR_RESET" "$_SONAR_DIM" "$_SONAR_RESET"
    IFS= read -r -s entered_token
    printf '\n'

    printf '  %b➜ Chave do projeto padrão%b %b(opcional, ex.: exemplo_front)%b: ' \
        "$_SONAR_GREEN$_SONAR_BOLD" "$_SONAR_RESET" "$_SONAR_DIM" "$_SONAR_RESET"
    IFS= read -r entered_project
    entered_project="${entered_project:-$SONAR_PROJECT_KEY}"

    printf '  %b➜ PR padrão%b %b(opcional, aplica a projetos sem PR ativo próprio)%b: ' \
        "$_SONAR_GREEN$_SONAR_BOLD" "$_SONAR_RESET" "$_SONAR_DIM" "$_SONAR_RESET"
    IFS= read -r entered_pull_request
    entered_pull_request="${entered_pull_request:-$SONAR_PULL_REQUEST}"

    if [[ -z "$entered_url" || -z "$entered_token" ]]; then
        _sonar_error 'A URL base e o token são obrigatórios. Nada foi salvo.'
        return 2
    fi

    printf '\n'
    if ! validation="$(_sonar_curl 'Validando token' \
        "$entered_url/api/authentication/validate" "$entered_token")"; then
        validation_status=$?
        unset entered_token
        if [[ "$validation_status" == '28' ]]; then
            _sonar_error "Tempo limite excedido ao validar o token (limite: ${_SONAR_TIMEOUT}s). Nada foi salvo."
        else
            _sonar_error 'Falha na autenticação. Confira a URL e o token. Nada foi salvo.'
        fi
        return 1
    fi

    if ! jq -e '.valid == true' >/dev/null 2>&1 <<<"$validation"; then
        unset entered_token
        _sonar_error 'Token inválido para esta instância. Nada foi salvo.'
        return 1
    fi

    _sonar_config_set url "$entered_url"
    _sonar_config_set token "$entered_token"
    _sonar_config_set project "$entered_project"
    _sonar_config_set pullRequest "$entered_pull_request"
    unset entered_token

    # Projeto informado entra na lista de projetos (entrada criada aqui,
    # antes de qualquer uso de project add/use).
    if [[ -n "$entered_project" ]]; then
        old_list="$(_sonar_config_get projects)"
        case ",${old_list}," in
            *",${entered_project},"*) ;;
            *) old_list="${old_list:+${old_list},}${entered_project}" ;;
        esac
        _sonar_config_set projects "$old_list"

        # PR padrão informado é vinculado ao projeto (entra na lista dele
        # e vira o ativo), mantendo a correlação projeto/PR coerente.
        if [[ -n "$entered_pull_request" ]]; then
            local proj_prs
            proj_prs="$(_sonar_config_get "pullRequests.$entered_project")"
            case ",${proj_prs}," in
                *",${entered_pull_request},"*) ;;
                *) proj_prs="${proj_prs:+${proj_prs},}${entered_pull_request}" ;;
            esac
            _sonar_config_set "pullRequests.$entered_project" "$proj_prs"
            _sonar_config_set "pullRequest.$entered_project" "$entered_pull_request"
        fi
    fi

    _sonar_success "Acesso validado. Credenciais salvas em $_SONAR_USER_CONFIG (permissão somente para seu usuário)."
    printf '%bℹ O token não foi exibido. Se ele for exposto, revogue-o em Minha conta > Segurança.%b\n' \
        "$_SONAR_CYAN" "$_SONAR_RESET"
}
