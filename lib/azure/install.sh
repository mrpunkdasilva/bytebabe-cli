# ==================================================
# AZURE CLI INSTALLATION & SETUP
# ==================================================

_az_install_dnf() {
    local id version major
    id=$(. /etc/os-release 2>/dev/null; echo "${ID:-}")
    version=$(. /etc/os-release 2>/dev/null; echo "${VERSION_ID:-}")
    major=${version%%.*}

    case "$id:$major" in
        rhel:10|almalinux:10|rocky:10)
            sudo rpm --import https://packages.microsoft.com/keys/microsoft-2025.asc || return 1
            sudo dnf install -y https://packages.microsoft.com/config/rhel/10/packages-microsoft-prod.rpm || return 1
            ;;
        centos:10)
            sudo rpm --import https://packages.microsoft.com/keys/microsoft-2025.asc || return 1
            sudo dnf install -y https://packages.microsoft.com/config/centos/10/packages-microsoft-prod.rpm || return 1
            ;;
        rhel:9|centos:9|almalinux:9|rocky:9)
            sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc || return 1
            sudo dnf install -y https://packages.microsoft.com/config/rhel/9.0/packages-microsoft-prod.rpm || return 1
            ;;
        rhel:8|centos:8|almalinux:8|rocky:8)
            sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc || return 1
            sudo dnf install -y https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm || return 1
            ;;
        *)
            # Fedora e demais: repositório yum genérico do azure-cli
            sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc || return 1
            printf '%s\n' \
                '[azure-cli]' \
                'name=Azure CLI' \
                'baseurl=https://packages.microsoft.com/yumrepos/azure-cli' \
                'enabled=1' \
                'gpgcheck=1' \
                'gpgkey=https://packages.microsoft.com/keys/microsoft.asc' \
                | sudo tee /etc/yum.repos.d/azure-cli.repo >/dev/null || return 1
            ;;
    esac

    sudo dnf install -y azure-cli
}

_az_install_apt() {
    sudo apt-get update || return 1
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release || return 1

    sudo mkdir -p /etc/apt/keyrings || return 1
    curl -sLS https://packages.microsoft.com/keys/microsoft.asc \
        | gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg >/dev/null || return 1
    sudo chmod go+r /etc/apt/keyrings/microsoft.gpg || return 1

    # AZ_DIST permite forçar a suíte (ex: jammy, bookworm) em derivadas
    local dist=${AZ_DIST:-$(lsb_release -cs)}
    printf '%s\n' \
        'Types: deb' \
        'URIs: https://packages.microsoft.com/repos/azure-cli/' \
        "Suites: ${dist}" \
        'Components: main' \
        "Architectures: $(dpkg --print-architecture)" \
        'Signed-by: /etc/apt/keyrings/microsoft.gpg' \
        | sudo tee /etc/apt/sources.list.d/azure-cli.sources >/dev/null || return 1

    sudo apt-get update || return 1
    sudo apt-get install -y azure-cli
}

_az_install_zypper() {
    if sudo zypper install -y azure-cli; then
        return 0
    fi

    echo -e "${CYBER_YELLOW}Pacote do SUSE indisponível, usando repositório Microsoft...${RESET}"
    sudo zypper install -y curl || return 1
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc || return 1
    sudo zypper addrepo --name 'Azure CLI' --check https://packages.microsoft.com/yumrepos/azure-cli azure-cli || return 1
    sudo zypper refresh || return 1
    sudo zypper install --from azure-cli azure-cli
}

_az_install_tdnf() {
    sudo tdnf install -y ca-certificates || return 1
    sudo tdnf install -y azure-cli
}

# Extensões do az usam pip; pacotes de distro (ex: Fedora) rodam no python3 do sistema
_az_ensure_pip() {    python3 -m pip --version >/dev/null 2>&1 && return 0

    local pm
    pm=$(_az_detect_pkg_manager) || {
        echo -e "${CYBER_RED}pip não encontrado e nenhum gerenciador suportado para instalá-lo.${RESET}"
        return 1
    }

    echo -e "${CYBER_BLUE}Instalando python3-pip via ${pm} (necessário para extensões do az)...${RESET}"
    sudo "$pm" install -y python3-pip
}

# Instala o Azure CLI nativamente conforme o gerenciador de pacotes
az_install() {
    if command -v az >/dev/null 2>&1; then
        echo -e "${CYBER_GREEN}Azure CLI já instalado: $(az version --query '"azure-cli"' -o tsv 2>/dev/null)${RESET}"
        return 0
    fi

    local pm
    if ! pm=$(_az_detect_pkg_manager); then
        echo -e "${CYBER_RED}Nenhum gerenciador suportado encontrado (dnf, apt, zypper, tdnf).${RESET}"
        echo -e "${CYBER_YELLOW}Veja: https://learn.microsoft.com/cli/azure/install-azure-cli-linux${RESET}"
        return 1
    fi

    echo -e "${CYBER_BLUE}Instalando Azure CLI via ${pm}...${RESET}"
    case "$pm" in
        dnf) _az_install_dnf ;;
        apt-get) _az_install_apt ;;
        zypper) _az_install_zypper ;;
        tdnf) _az_install_tdnf ;;
    esac || {
        echo -e "${CYBER_RED}Falha ao instalar o Azure CLI.${RESET}"
        return 1
    }

    hash -r
    if ! command -v az >/dev/null 2>&1; then
        echo -e "${CYBER_RED}Instalação terminou, mas o comando az não foi encontrado no PATH.${RESET}"
        return 1
    fi
    echo -e "${CYBER_GREEN}Azure CLI instalado com sucesso!${RESET}"
}

# Login AAD cobrindo orgs em tenant sem assinatura Azure
_az_login_aad() {
    echo -e "${CYBER_BLUE}Fazendo login Azure (siga as instruções do navegador/código)...${RESET}"
    echo -e "${CYBER_GRAY}  (az login --allow-no-subscriptions: cobre orgs em tenant sem assinatura)${RESET}"
    az login --allow-no-subscriptions
}

# Salva organização/projeto como defaults do az devops
_az_save_org() {
    local org=$1 project=${2:-}

    if [ -z "$project" ]; then
        project=$(_az_project_from_url "$org")
    else
        project=$(_az_url_decode "$project")
    fi
    local defaults=("organization=$(_az_org_url "$org")")
    [ -n "$project" ] && defaults+=("project=$project")
    az devops configure --defaults "${defaults[@]}" || return 1
    echo -e "${CYBER_GREEN}Padrão salvo: ${defaults[*]}${RESET}"
}

# bytebabe azure login [org]
# bytebabe azure login --pat [org]
az_login() {
    local org=${1:-}
    local mode=aad
    if [ "${org:-}" = "--pat" ]; then
        mode=pat
        org=${2:-}
    fi

    if ! command -v az >/dev/null 2>&1; then
        echo -e "${CYBER_RED}Azure CLI (az) não está instalado!${RESET}"
        echo -e "${CYBER_YELLOW}Rode: bytebabe azure setup${RESET}"
        return 1
    fi

    if [ "$mode" = pat ]; then
        if [ -n "$org" ]; then
            echo -e "${CYBER_BLUE}Login por PAT na organização $(_az_org_url "$org") (o token não é ecoado)...${RESET}"
            az devops login --organization "$(_az_org_url "$org")"
        else
            echo -e "${CYBER_BLUE}Login por PAT (o token não é ecoado no terminal)...${RESET}"
            az devops login
        fi
        return $?
    fi

    if ! _az_login_aad; then
        echo -e "${CYBER_RED}Falha no login Azure (AAD).${RESET}"
        echo -e "${CYBER_YELLOW}Alternativa por PAT: bytebabe azure login --pat${RESET}"
        return 1
    fi
    echo -e "${CYBER_GREEN}Login Azure concluído!${RESET}"

    if [ -n "$org" ]; then
        _az_save_org "$org" || return 1
    else
        echo -e "${CYBER_YELLOW}Dica: bytebabe azure login <organização|URL> também salva a organização padrão.${RESET}"
    fi
}

# Instala az + extensão, faz login e define organização/projeto padrão
az_setup() {
    local org=${1:-}
    local project=${2:-}
    local force_login=false
    if [ "$org" = "--login" ]; then
        force_login=true
        org=${2:-}
        project=${3:-}
    elif [ "$project" = "--login" ]; then
        force_login=true
        project=""
    fi

    echo -e "${CYBER_YELLOW}O que o setup faz:${RESET}"
    echo -e "  1. Instala o Azure CLI (az), se ainda não existir"
    echo -e "  2. Instala a extensão azure-devops (necessária para PRs e projetos)"
    echo -e "  3. Faz login na sua conta Microsoft (bytebabe azure login)"
    echo -e "  4. Salva a organização/projeto padrão, para não repetir nos comandos"
    echo
    echo -e "${CYBER_YELLOW}Organização:${RESET} é o nome que aparece na URL do seu Azure DevOps:"
    echo -e "  https://dev.azure.com/${CYBER_CYAN}<organização>${RESET}/<projeto>"
    echo -e "Pode informar só o nome ou colar a URL (com projeto, se quiser): o bytebabe separa os dois."
    echo -e "Uso: bytebabe azure setup [--login] <organização|URL> [projeto]"
    echo

    if ! command -v az >/dev/null 2>&1; then
        echo -e "${CYBER_BLUE}[1/4] Azure CLI não encontrado, instalando...${RESET}"
        az_install || return 1
    else
        echo -e "${CYBER_GREEN}[1/4] Azure CLI já instalado.${RESET}"
    fi

    if ! az extension show --name azure-devops >/dev/null 2>&1; then
        echo -e "${CYBER_BLUE}[2/4] Instalando extensão azure-devops...${RESET}"
        _az_ensure_pip || return 1
        az extension add --name azure-devops || return 1
    else
        echo -e "${CYBER_GREEN}[2/4] Extensão azure-devops já instalada.${RESET}"
    fi

    if [ "$force_login" = true ]; then
        echo -e "${CYBER_BLUE}[3/4] Refazendo o login (--login)...${RESET}"
        _az_login_aad || return 1
    elif ! az account show >/dev/null 2>&1; then
        echo -e "${CYBER_BLUE}[3/4] Fazendo login na Azure...${RESET}"
        _az_login_aad || return 1
    else
        echo -e "${CYBER_GREEN}[3/4] Login já realizado.${RESET}"
        echo -e "${CYBER_YELLOW}      Se a organização recusar o login: bytebabe azure setup --login${RESET}"
    fi

    if [ -z "$org" ] && [ -t 0 ]; then
        echo -e "${CYBER_BLUE}[4/4] Organização padrão${RESET} (nome ou URL; Enter para pular):"
        read -r -p "  > " org
    fi

    if [ -n "$org" ]; then
        if [ -z "$project" ]; then
            project=$(_az_project_from_url "$org")
        else
            project=$(_az_url_decode "$project")
        fi
        local defaults=("organization=$(_az_org_url "$org")")
        [ -n "$project" ] && defaults+=("project=$project")
        az devops configure --defaults "${defaults[@]}" || return 1
        echo -e "${CYBER_GREEN}[4/4] Padrão salvo: ${defaults[*]}${RESET}"
    else
        echo -e "${CYBER_YELLOW}[4/4] Nenhuma organização padrão definida.${RESET}"
        echo -e "  Ela será detectada pelo remote do repositório ou informada em cada comando."
        echo -e "  Para definir depois: bytebabe azure setup <organização> [projeto]"
    fi

    echo -e "\n${CYBER_GREEN}Azure DevOps configurado!${RESET}"
    echo -e "Próximos passos: ${CYBER_CYAN}bytebabe azure projects${RESET} | ${CYBER_CYAN}bytebabe azure pr \"título\"${RESET}"
}
