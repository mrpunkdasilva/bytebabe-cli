# ==================================================
# AZURE DEVOPS HELPERS & UTILS
# ==================================================

check_az_cli() {
    if ! command -v az >/dev/null 2>&1; then
        echo -e "${CYBER_RED}Azure CLI (az) não está instalado!${RESET}"
        echo -e "${CYBER_YELLOW}Rode: bytebabe azure install${RESET}"
        return 1
    fi

    if ! az extension show --name azure-devops >/dev/null 2>&1; then
        echo -e "${CYBER_RED}Extensão azure-devops não encontrada!${RESET}"
        echo -e "${CYBER_YELLOW}Rode: bytebabe azure setup${RESET}"
        return 1
    fi
}

# A partir do stderr de uma chamada az, imprime orientação específica.
# Reconhece falhas de autenticação (sessão expirada ou sem az login).
_az_guidance() {
    local err=$1
    case "$err" in
        *"az login"*|*"devops login"*|*"not logged in"*|*"Login command"*)
            echo -e "${CYBER_YELLOW}Credenciais ausentes ou inválidas para a organização.${RESET}"
            echo -e "Se ${CYBER_GREEN}az account show${RESET} responde mas os comandos devops falham:"
            echo -e "  AAD/MSA: ${CYBER_GREEN}az login --allow-no-subscriptions${RESET}"
            echo -e "           (orgs em tenant sem assinatura precisam dessa flag)"
            echo -e "  PAT:     ${CYBER_GREEN}az devops login --organization https://dev.azure.com/<org>${RESET}"
            echo -e "Ou refaça: ${CYBER_GREEN}bytebabe azure setup${RESET} (salva org/projeto após o login)."
            ;;
    esac
}

_az_check_repo() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo -e "${CYBER_RED}Não está em um repositório Git!${RESET}"
        return 1
    fi
}

_az_current_branch() {
    git symbolic-ref --short HEAD 2>/dev/null
}

_az_default_base() {
    if git show-ref --verify --quiet refs/heads/main; then
        echo "main"
    elif git show-ref --verify --quiet refs/heads/master; then
        echo "master"
    fi
}

# Detecta o gerenciador de pacotes suportado pela doc do Azure CLI
_az_detect_pkg_manager() {
    local pm
    for pm in tdnf dnf apt-get zypper; do
        if command -v "$pm" >/dev/null 2>&1; then
            echo "$pm"
            return 0
        fi
    done
    return 1
}

# Aceita nome curto da org ou qualquer URL do Azure DevOps e devolve só a URL da organização
_az_org_url() {
    local org=$1 rest
    case "$org" in
        https://dev.azure.com/*|http://dev.azure.com/*)
            rest=${org#*://dev.azure.com/}
            echo "https://dev.azure.com/${rest%%/*}"
            ;;
        https://*|http://*)
            # Formato antigo (org.visualstudio.com): a organização é o host
            rest=${org#*://}
            echo "https://${rest%%/*}"
            ;;
        *) echo "https://dev.azure.com/${org}" ;;
    esac
}

# Decodifica %XX de URLs (ex.: %20 vira espaço)
_az_url_decode() {
    printf '%b' "${1//%/\\x}"
}

# Extrai o projeto de uma URL dev.azure.com/<org>/<projeto>[/...]
_az_project_from_url() {
    local url=$1 rest
    case "$url" in
        https://dev.azure.com/*|http://dev.azure.com/*)
            rest=${url#*://dev.azure.com/}
            [[ "$rest" == */* ]] || return 0
            rest=${rest#*/}
            _az_url_decode "${rest%%/*}"
            ;;
    esac
}
