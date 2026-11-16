#!/bin/bash

# ==================================================
# MODULE SONAR — consultas de qualidade do SonarQube
# ==================================================

BASE_DIR="${BASE_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
source "${BASE_DIR}/lib/core/colors.sh"
source "${BASE_DIR}/lib/core/helpers.sh"
source "${BASE_DIR}/lib/sonar/main.sh"

SONAR_MODULE_VERSION="1.0.0"

sonar_module_version() {
    printf 'bytebabe sonar v%s\n' "$SONAR_MODULE_VERSION"
}

show_sonar_header() {
    echo -e "${CYBER_CYAN}"
    cat << "EOF"
███████╗ ██████╗ ███╗   ██╗ █████╗ ██████╗
██╔════╝██╔═══██╗████╗  ██║██╔══██╗██╔══██╗
███████╗██║   ██║██╔██╗ ██║███████║██████╔╝
╚════██║██║   ██║██║╚██╗██║██╔══██║██╔══██╗
███████║╚██████╔╝██║ ╚████║██║  ██║██║  ██║
╚══════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝
EOF
    echo -e "${RESET}"
    echo -e "${CYBER_GRAY}  módulo sonar v${SONAR_MODULE_VERSION}${RESET}"
    cyber_divider
}

sonar_usage() {
    echo -e "${CYBER_CYAN}Uso: bytebabe sonar <comando> [argumentos] [opções]${RESET}"
    echo ""
    echo -e "${CYBER_YELLOW}Configuração:${RESET}"
    echo -e "${CYBER_GREEN}  login${RESET}    Configura servidor e token de usuário (interativo)"
    echo -e "${CYBER_GREEN}  project${RESET}  Gestão multi-projeto: project [list/next/prev/search/add/remove/use/set/validate]"
    echo -e "${CYBER_GREEN}  pr${RESET}       Pull requests do projeto ativo: pr [list/add/remove/search/use <numero>]"
    echo ""
    echo -e "${CYBER_YELLOW}Projetos (${CYBER_GREEN}bytebabe sonar project${CYBER_YELLOW}):${RESET}"
    echo -e "  ${CYBER_GREEN}list${RESET}              Lista os projetos e marca o ativo"
    echo -e "  ${CYBER_GREEN}next/prev${RESET}          Alterna o ativo para o próximo/anterior da lista"
    echo -e "  ${CYBER_GREEN}current${RESET}           Exibe o projeto ativo"
    echo -e "  ${CYBER_GREEN}search${RESET} [termo]    Pesquisa e seleciona um projeto interativamente"
    echo -e "  ${CYBER_GREEN}add${RESET} <chave>       Adiciona à lista (não muda o ativo)"
    echo -e "  ${CYBER_GREEN}remove${RESET} <chave>    Remove da lista"
    echo -e "  ${CYBER_GREEN}use${RESET} <chave>       Define o projeto ativo"
    echo -e "  ${CYBER_GREEN}set${RESET} [chave]       Atalho para use; sem chave usa a autodetecção do diretório"
    echo -e "  ${CYBER_GREEN}validate${RESET} <chave>  Confere se o projeto existe na instância"
    echo ""
    echo -e "${CYBER_YELLOW}Pull Requests (${CYBER_GREEN}bytebabe sonar pr${CYBER_YELLOW}) — escopo do projeto ativo:${RESET}"
    echo -e "  ${CYBER_GREEN}list${RESET}              Lista os PRs do projeto ativo e marca o ativo"
    echo -e "  ${CYBER_GREEN}add${RESET} <numero>      Adiciona à lista do projeto ativo (não muda o ativo)"
    echo -e "  ${CYBER_GREEN}remove${RESET} <numero>   Remove da lista; se era o ativo, ativa o primeiro restante"
    echo -e "  ${CYBER_GREEN}search${RESET} [termo]    Pesquisa e seleciona um PR interativamente"
    echo -e "  ${CYBER_GREEN}use${RESET} <numero>      Define o PR ativo deste projeto; números novos entram na lista"
    echo ""
    echo -e "${CYBER_YELLOW}Consultas (somente leitura):${RESET}"
    echo -e "${CYBER_GREEN}  overview${RESET} Painel geral do dia a dia: portão, cobertura, duplicação, apontamentos e hotspots"
    echo -e "${CYBER_GREEN}  issues${RESET}   Dashboard de qualidade + apontamentos abertos (padrão)"
    echo -e "${CYBER_GREEN}  show${RESET}     Detalhes de um apontamento: show <chave>"
    echo -e "${CYBER_GREEN}  rule${RESET}     Metadados e descrição de uma regra: rule <chave>"
    echo -e "${CYBER_GREEN}  rules${RESET}    Pesquisa regras: rules [termo]"
    echo -e "${CYBER_GREEN}  metrics${RESET}  Métricas do projeto/PR: metrics [pr] [projeto]"
    echo -e "${CYBER_GREEN}  gate${RESET}     Portão de qualidade e condições: gate [pr] [projeto]"
    echo -e "${CYBER_GREEN}  hotspots${RESET} Alertas de segurança: hotspots [pr] [projeto]"
    echo ""
    echo -e "${CYBER_YELLOW}Opções:${RESET}"
    echo -e "  ${CYBER_GREEN}--somente-resumo${RESET}, ${CYBER_GREEN}--summary-only${RESET}  Apenas o painel geral (issues)"
    echo -e "  ${CYBER_GREEN}-p${RESET}, ${CYBER_GREEN}--projeto${RESET} <chave>            Projeto (sobrepõe defaults e posicionais)"
    echo -e "  ${CYBER_GREEN}--sem-cores${RESET}, ${CYBER_GREEN}--no-color${RESET}          Desativa cores e links"
    echo -e "  ${CYBER_GREEN}-h${RESET}, ${CYBER_GREEN}--help${RESET}                      Mostra esta ajuda"
    echo -e "  ${CYBER_GREEN}-v${RESET}, ${CYBER_GREEN}--version${RESET}                   Mostra a versão do módulo"
    echo ""
    echo -e "${CYBER_YELLOW}⚡ Primeiro acesso:${RESET}"
    echo -e "  ${CYBER_RED}Configure o acesso antes das consultas:${RESET} ${CYBER_GREEN}bytebabe sonar login${RESET}"
    echo ""
    echo -e "${CYBER_GRAY}Configuração global em ~/.config/bytebabe/sonar.json (JSON, permissão 600) ou variáveis${RESET}"
    echo -e "${CYBER_GRAY}SONAR_URL / SONAR_TOKEN / SONAR_PROJECT_KEY / SONAR_PULL_REQUEST${RESET}"
}

# Ajuda específica de um subcomando. Chamada por <comando> --help/-h.
sonar_command_help() {
    local cmd="$1"
    local foot="${CYBER_GRAY}Ajuda geral: bytebabe sonar help  |  versão: bytebabe sonar --version${RESET}"

    echo -e "${CYBER_CYAN}━━━ bytebabe sonar ${CYBER_BOLD}${cmd}${RESET}${CYBER_CYAN} ━━━${RESET}"
    echo ""

    case "$cmd" in
        overview|resumo|painel|ov)
            echo -e "${CYBER_YELLOW}Painel geral do dia a dia — portão, cobertura, duplicação, linhas,${RESET}"
            echo -e "${CYBER_YELLOW}apontamentos por tipo/severidade e hotspots por risco.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe sonar overview ${CYBER_GRAY}[pr] [projeto]${RESET} ${CYBER_GRAY}[-p chave]${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Argumentos:${RESET}"
            echo -e "  ${CYBER_GREEN}pr${RESET}        Número do pull request para escopo de código novo (opcional)"
            echo -e "  ${CYBER_GREEN}projeto${RESET}   Chave do projeto (opcional; sobrepõe o default)"
            echo ""
            echo -e "${CYBER_YELLOW}Atalhos interativos (em terminal):${RESET}"
            echo -e "  ${CYBER_GREEN}[1]${RESET} apontamentos   ${CYBER_GREEN}[2]${RESET} hotspots   ${CYBER_GREEN}[3]${RESET} métricas"
            echo -e "  ${CYBER_GREEN}[r]${RESET} atualizar dados   ${CYBER_GREEN}[q]${RESET} sair"
            echo ""
            echo -e "${CYBER_YELLOW}Opções:${RESET}"
            echo -e "  ${CYBER_GREEN}-p${RESET}, ${CYBER_GREEN}--projeto${RESET} <chave>   Sobrepõe projeto (posição, autodetecção e defaults)"
            echo -e "  ${CYBER_GREEN}--sem-cores${RESET}         Render estático sem cores"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe sonar overview${RESET}                    ${CYBER_GRAY}# projeto autodetectado/default${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe sonar overview 42${RESET}                 ${CYBER_GRAY}# escopo do PR 42${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe sonar overview -p proj_backend${RESET}    ${CYBER_GRAY}# projeto explícito${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        issues)
            echo -e "${CYBER_YELLOW}Dashboard de qualidade + lista de apontamentos abertos com a regra explicada.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe sonar issues ${CYBER_GRAY}[pr] [projeto]${RESET} ${CYBER_GRAY}[-p chave]${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Argumentos:${RESET}"
            echo -e "  ${CYBER_GREEN}pr${RESET}        Número do pull request (opcional)"
            echo -e "  ${CYBER_GREEN}projeto${RESET}   Chave do projeto (opcional; sobrepõe o default)"
            echo ""
            echo -e "${CYBER_YELLOW}Opções:${RESET}"
            echo -e "  ${CYBER_GREEN}--somente-resumo${RESET}, ${CYBER_GREEN}--summary-only${RESET}  Apenas o painel geral, sem a lista de apontamentos"
            echo -e "  ${CYBER_GREEN}-p${RESET}, ${CYBER_GREEN}--projeto${RESET} <chave>            Sobrepõe projeto"
            echo -e "  ${CYBER_GREEN}--sem-cores${RESET}                        Sem cores e links"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe sonar issues${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe sonar issues 42${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe sonar issues --somente-resumo${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        show|issue)
            echo -e "${CYBER_YELLOW}Detalhes de um apontamento: local, mensagem, esforço e a explicação da regra.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe sonar show ${CYBER_BOLD}<chave>${RESET} ${CYBER_GRAY}[-p chave]${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Argumentos:${RESET}"
            echo -e "  ${CYBER_GREEN}chave${RESET}    Chave do apontamento (obrigatória; use ${CYBER_GREEN}issues${RESET} para listar)"
            echo ""
            echo -e "${CYBER_YELLOW}Opções:${RESET}"
            echo -e "  ${CYBER_GREEN}-p${RESET}, ${CYBER_GREEN}--projeto${RESET} <chave>   Sobrepõe projeto"
            echo -e "  ${CYBER_GREEN}--sem-cores${RESET}         Sem cores"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe sonar show AXb1c2D3e4F5g6H7${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe sonar show AXb1c2D3e4F5g6H7 -p proj_backend${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        rule)
            echo -e "${CYBER_YELLOW}Metadados de uma regra: nome, tipo, severidade, remediation e descrição completa.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe sonar rule ${CYBER_BOLD}<chave>${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Argumentos:${RESET}"
            echo -e "  ${CYBER_GREEN}chave${RESET}    Chave da regra (obrigatória)"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe sonar rule java:S1106${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe sonar rule js:S125${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        rules)
            echo -e "${CYBER_YELLOW}Pesquisa na base de regras do SonarQube, com filtro por termo.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe sonar rules ${CYBER_GRAY}[termo]${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Argumentos:${RESET}"
            echo -e "  ${CYBER_GREEN}termo${RESET}    Filtro por nome ou tipo (opcional; ex.: security, bug)"
            echo ""
            echo -e "${CYBER_YELLOW}Opções:${RESET}"
            echo -e "  ${CYBER_GREEN}--sem-cores${RESET}   Sem cores"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe sonar rules${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe sonar rules security${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        metrics)
            echo -e "${CYBER_YELLOW}Métricas do projeto/PR: bugs, code smells, vulnerabilidades, cobertura,${RESET}"
            echo -e "${CYBER_YELLOW}duplicação, linhas, complexidade e métricas de código novo — com barras.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe sonar metrics ${CYBER_GRAY}[pr] [projeto]${RESET} ${CYBER_GRAY}[-p chave]${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Argumentos:${RESET}"
            echo -e "  ${CYBER_GREEN}pr${RESET}        Número do pull request (opcional)"
            echo -e "  ${CYBER_GREEN}projeto${RESET}   Chave do projeto (opcional)"
            echo ""
            echo -e "${CYBER_YELLOW}Opções:${RESET}"
            echo -e "  ${CYBER_GREEN}-p${RESET}, ${CYBER_GREEN}--projeto${RESET} <chave>   Sobrepõe projeto"
            echo -e "  ${CYBER_GREEN}--sem-cores${RESET}         Sem cores"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe sonar metrics${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe sonar metrics 42${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        gate)
            echo -e "${CYBER_YELLOW}Portão de qualidade: status geral e cada condição (métrica, valor e limite).${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe sonar gate ${CYBER_GRAY}[pr] [projeto]${RESET} ${CYBER_GRAY}[-p chave]${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Argumentos:${RESET}"
            echo -e "  ${CYBER_GREEN}pr${RESET}        Número do pull request (opcional)"
            echo -e "  ${CYBER_GREEN}projeto${RESET}   Chave do projeto (opcional)"
            echo ""
            echo -e "${CYBER_YELLOW}Opções:${RESET}"
            echo -e "  ${CYBER_GREEN}-p${RESET}, ${CYBER_GREEN}--projeto${RESET} <chave>   Sobrepõe projeto"
            echo -e "  ${CYBER_GREEN}--sem-cores${RESET}         Sem cores"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe sonar gate${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe sonar gate -p proj_backend${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        hotspots)
            echo -e "${CYBER_YELLOW}Alertas de segurança (Security Hotspots) com status, risco e componente.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe sonar hotspots ${CYBER_GRAY}[pr] [projeto]${RESET} ${CYBER_GRAY}[-p chave]${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Argumentos:${RESET}"
            echo -e "  ${CYBER_GREEN}pr${RESET}        Número do pull request (opcional)"
            echo -e "  ${CYBER_GREEN}projeto${RESET}   Chave do projeto (opcional)"
            echo ""
            echo -e "${CYBER_YELLOW}Opções:${RESET}"
            echo -e "  ${CYBER_GREEN}-p${RESET}, ${CYBER_GREEN}--projeto${RESET} <chave>   Sobrepõe projeto"
            echo -e "  ${CYBER_GREEN}--sem-cores${RESET}         Sem cores"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe sonar hotspots${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe sonar hotspots 42${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        login)
            echo -e "${CYBER_YELLOW}Configura o acesso ao SonarQube de forma interativa.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe sonar login"
            echo ""
            echo -e "${CYBER_YELLOW}O que é salvo em ~/.config/bytebabe/sonar.json (JSON, permissão 600):${RESET}"
            echo -e "  ${CYBER_GREEN}url${RESET}              Endereço do SonarQube/SonarCloud"
            echo -e "  ${CYBER_GREEN}token${RESET}            Token validado via /api/authentication/validate (nunca exibido)"
            echo -e "  ${CYBER_GREEN}activeProject${RESET}    Projeto ativo (opcional)"
            echo -e "  ${CYBER_GREEN}defaultPullRequest${RESET}  Pull request padrão (opcional)"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe sonar login${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        project|proj)
            echo -e "${CYBER_YELLOW}Gestão multi-projeto: lista em projects[] e ativo em activeProject (sonar.json).${RESET}"
            echo -e "${CYBER_GRAY}As consultas usam: -p > posicional > autodetecção do diretório > projeto ativo.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe sonar project <subcomando> ${CYBER_GRAY}[argumentos]${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Subcomandos:${RESET}"
            echo -e "  ${CYBER_GREEN}list${RESET}              Lista os projetos e marca o ativo"
            echo -e "  ${CYBER_GREEN}next${RESET}, ${CYBER_GREEN}prev${RESET}      Alterna o ativo para o próximo/anterior da lista (circular)"
            echo -e "  ${CYBER_GREEN}current${RESET}           Exibe o projeto ativo no momento"
            echo -e "  ${CYBER_GREEN}search${RESET} [termo]    Pesquisa e seleciona um projeto da lista interativamente"
            echo -e "  ${CYBER_GREEN}add${RESET} <chave>       Adiciona um projeto à lista (não muda o ativo)"
            echo -e "  ${CYBER_GREEN}remove${RESET} <chave>    Remove da lista; se era o ativo, ativa o primeiro restante"
            echo -e "  ${CYBER_GREEN}use${RESET} <chave>       Define o projeto ativo"
            echo -e "  ${CYBER_GREEN}set${RESET} [chave]       Atalho para use; sem chave usa a autodetecção do diretório"
            echo -e "  ${CYBER_GREEN}validate${RESET} <chave>  Confere se o projeto existe na instância"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe sonar project add proj_front${RESET}         ${CYBER_GRAY}# só entra na lista${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe sonar project next${RESET}                   ${CYBER_GRAY}# troca o ativo${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe sonar project set${RESET}                    ${CYBER_GRAY}# usa sonar-project.properties daqui${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe sonar proj use proj_back${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        pr|pull)
            echo -e "${CYBER_YELLOW}Pull requests no escopo do projeto ativo:${RESET}"
            echo -e "${CYBER_GRAY}Cada projeto tem sua lista (prs) e seu PR ativo (activePr) em sonar.json.${RESET}"
            echo -e "${CYBER_GRAY}As consultas (gate/metrics/issues) usam o PR ativo automaticamente.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe sonar pr <subcomando> ${CYBER_GRAY}[argumentos]${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Subcomandos:${RESET}"
            echo -e "  ${CYBER_GREEN}list${RESET}              Lista os PRs do projeto ativo e marca o ativo"
            echo -e "  ${CYBER_GREEN}add${RESET} <numero>      Adiciona à lista do projeto ativo (não muda o ativo)"
            echo -e "  ${CYBER_GREEN}remove${RESET} <numero>   Remove da lista; se era o ativo, ativa o primeiro restante"
            echo -e "  ${CYBER_GREEN}search${RESET} [termo]    Pesquisa e seleciona um PR da lista interativamente"
            echo -e "  ${CYBER_GREEN}use${RESET} <numero>      Define o PR ativo; números novos entram na lista"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe sonar pr add 42${RESET}                      ${CYBER_GRAY}# só entra na lista${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe sonar pr use 42${RESET}                      ${CYBER_GRAY}# define e entra na lista${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe sonar pr search${RESET}                      ${CYBER_GRAY}# menu com os PRs da lista${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe sonar gate${RESET}                           ${CYBER_GRAY}# analisa o PR ativo${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        *)
            echo -e "${CYBER_YELLOW}Sem ajuda específica para este comando.${RESET}"
            echo ""
            echo -e "$foot"
            ;;
    esac
}

_sonar_parse_args() {
    SONAR_POSITIONAL_ARGS=()
    _SONAR_SUMMARY_ONLY=0
    _SONAR_NO_COLOR="${_SONAR_NO_COLOR:-0}"
    _SONAR_SHOW_HELP=0
    _SONAR_PROJECT_FLAG=''

    while (( $# )); do
        case "$1" in
            --summary-only|--somente-resumo) _SONAR_SUMMARY_ONLY=1 ;;
            --no-color|--sem-cores) _SONAR_NO_COLOR=1 ;;
            -p|--projeto|--project)
                if (( $# < 2 )); then
                    printf 'Opção %s exige uma chave de projeto.\n' "$1" >&2
                    return 2
                fi
                _SONAR_PROJECT_FLAG="$2"
                shift
                ;;
            -h|--help) _SONAR_SHOW_HELP=1 ;;
            --) shift; SONAR_POSITIONAL_ARGS+=("$@"); break ;;
            -*) printf 'Opção inválida: %s\n' "$1" >&2; return 2 ;;
            *) SONAR_POSITIONAL_ARGS+=("$1") ;;
        esac
        shift
    done
}

_sonar_command_banner() {
    case "$1" in
        login) _sonar_banner 'CONFIGURANDO ACESSO AO SONARQUBE...' ;;
        project|proj) _sonar_banner 'GERENCIANDO PROJETOS — SONARQUBE' ;;
        pr|pull) _sonar_banner 'GERENCIANDO PULL REQUESTS — SONARQUBE' ;;
        overview|resumo|painel|ov) _sonar_banner 'PAINEL GERAL DE QUALIDADE — SONARQUBE' ;;
        issues) _sonar_banner 'RELATÓRIO DE QUALIDADE — SONARQUBE' ;;
        show|issue) _sonar_banner 'INSPECIONANDO APONTAMENTO...' ;;
        rule) _sonar_banner 'DECODIFICANDO REGRA...' ;;
        rules) _sonar_banner 'VARRENDO BASE DE REGRAS...' ;;
        metrics) _sonar_banner 'COLETANDO MÉTRICAS...' ;;
        gate) _sonar_banner 'VERIFICANDO PORTÃO DE QUALIDADE...' ;;
        hotspots) _sonar_banner 'RASTREANDO ALERTAS DE SEGURANÇA...' ;;
    esac
}

main() {
    local cmd="${1:-help}"
    local status=0

    case "$cmd" in
        -h|--help) cmd="help" ;;
        -v|--version) cmd="version" ;;
    esac

    case "$cmd" in
        overview|resumo|painel|ov|issues|show|issue|rule|rules|metrics|gate|hotspots|login|help|version|project|proj|pr|pull) ;;
        *)
            printf 'Comando sonar inválido: %s\n' "$cmd" >&2
            sonar_usage >&2
            return 2
            ;;
    esac
    [[ $# -gt 0 ]] && shift

    if ! _sonar_parse_args "$@"; then
        sonar_usage >&2
        return 2
    fi

    if [[ "$_SONAR_SHOW_HELP" == 1 ]]; then
        sonar_command_help "$cmd"
        return 0
    fi

    if [[ "$cmd" == "help" ]]; then
        show_sonar_header
        sonar_usage
        return 0
    fi

    if [[ "$cmd" == "version" ]]; then
        show_sonar_header
        sonar_module_version
        return 0
    fi

    sonar_setup_colors
    _sonar_command_banner "$cmd"

    case "$cmd" in
        login)
            sonar_require_deps curl jq || return $?
            _sonar_validate_timeouts || return $?
            sonar_login
            ;;
        project|proj)
            sonar_require_deps curl jq || return $?
            _sonar_validate_timeouts || return $?
            sonar_resolve_credentials
            sonar_project_cmd "${SONAR_POSITIONAL_ARGS[@]}"
            ;;
        pr|pull)
            sonar_require_deps curl jq || return $?
            _sonar_validate_timeouts || return $?
            sonar_resolve_credentials
            sonar_pull_cmd "${SONAR_POSITIONAL_ARGS[@]}"
            ;;
        overview|resumo|painel|ov|issues|metrics|gate|hotspots)
            sonar_require_deps curl jq || return $?
            _sonar_validate_timeouts || return $?
            sonar_require_credentials || return $?
            sonar_resolve_credentials
            sonar_resolve_context pr_project
            sonar_run_query "$cmd"
            ;;
        show|issue)
            sonar_require_deps curl jq || return $?
            _sonar_validate_timeouts || return $?
            sonar_require_credentials || return $?
            sonar_resolve_credentials
            sonar_resolve_context
            sonar_run_query "$cmd"
            ;;
        rule|rules)
            sonar_require_deps curl jq || return $?
            _sonar_validate_timeouts || return $?
            sonar_require_credentials || return $?
            sonar_resolve_credentials
            sonar_resolve_context
            sonar_run_query "$cmd"
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
