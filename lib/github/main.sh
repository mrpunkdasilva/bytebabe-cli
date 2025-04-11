# ==================================================
# FUNÇÕES DE INTEGRAÇÃO COM GITHUB
# ==================================================

# Função para verificar se o git está instalado
check_git() {
    if ! command -v git &> /dev/null; then
        echo -e "${RED}Git não está instalado!${NC}"
        echo -e "${YELLOW}Deseja instalar o Git agora? (s/n)${NC}"
        read -r resposta

        if [[ "$resposta" =~ ^[Ss]$ ]]; then
            echo -e "${BLUE}Instalando Git...${NC}"

            # Detecta o sistema operacional
            if [[ "$(uname)" == "Linux" ]]; then
                # Detecta a distribuição Linux
                if command -v apt &> /dev/null; then
                    # Debian/Ubuntu
                    sudo apt update
                    sudo apt install git -y
                elif command -v dnf &> /dev/null; then
                    # Fedora/RHEL 8+
                    sudo dnf install git -y
                elif command -v yum &> /dev/null; then
                    # CentOS/RHEL 7
                    sudo yum install git -y
                else
                    echo -e "${RED}Não foi possível detectar o gerenciador de pacotes.${NC}"
                    echo -e "${YELLOW}Por favor, instale o Git manualmente.${NC}"
                    return 1
                fi
            elif [[ "$(uname)" == "Darwin" ]]; then
                # macOS
                if command -v brew &> /dev/null; then
                    brew install git
                else
                    echo -e "${RED}Homebrew não está instalado.${NC}"
                    echo -e "${YELLOW}Por favor, instale o Homebrew primeiro:${NC} https://brew.sh/"
                    return 1
                fi
            else
                echo -e "${RED}Sistema operacional não suportado para instalação automática.${NC}"
                echo -e "${YELLOW}Por favor, instale o Git manualmente.${NC}"
                return 1
            fi

            if command -v git &> /dev/null; then
                echo -e "${GREEN}Git instalado com sucesso!${NC}"
            else
                echo -e "${RED}Falha ao instalar Git.${NC}"
                echo -e "${YELLOW}Por favor, instale o Git manualmente.${NC}"
                return 1
            fi
        else
            echo -e "${YELLOW}Por favor, instale o Git manualmente:${NC}"
            echo -e "  sudo apt-get install git  # Debian/Ubuntu"
            echo -e "  sudo yum install git      # CentOS/RHEL"
            echo -e "  sudo dnf install git      # Fedora"
            return 1
        fi
    fi

    return 0
}

# Função para verificar se o repositório atual é um repositório git
check_git_repo() {
    if [ ! -d ".git" ]; then
        echo -e "${RED}Diretório atual não é um repositório Git!${NC}"
        echo -e "${YELLOW}Inicialize um repositório com:${NC} git init"
        return 1
    fi

    return 0
}

# Função para verificar se o gh CLI está instalado
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}GitHub CLI (gh) não está instalado!${NC}"
        echo -e "${YELLOW}Deseja instalar o GitHub CLI agora? (s/n)${NC}"
        read -r resposta

        if [[ "$resposta" =~ ^[Ss]$ ]]; then
            echo -e "${BLUE}Instalando GitHub CLI...${NC}"

            # Detecta o sistema operacional
            if [[ "$(uname)" == "Linux" ]]; then
                # Detecta a distribuição Linux
                if command -v apt &> /dev/null; then
                    # Debian/Ubuntu
                    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
                    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
                    sudo apt update
                    sudo apt install gh -y
                elif command -v dnf &> /dev/null; then
                    # Fedora/RHEL 8+
                    sudo dnf install 'dnf-command(config-manager)' -y
                    sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
                    sudo dnf install gh -y
                elif command -v yum &> /dev/null; then
                    # CentOS/RHEL 7
                    sudo yum install yum-utils -y
                    sudo yum-config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
                    sudo yum install gh -y
                else
                    echo -e "${RED}Não foi possível detectar o gerenciador de pacotes.${NC}"
                    echo -e "${YELLOW}Por favor, instale manualmente:${NC} https://cli.github.com/manual/installation"
                    return 1
                fi
            elif [[ "$(uname)" == "Darwin" ]]; then
                # macOS
                if command -v brew &> /dev/null; then
                    brew install gh
                else
                    echo -e "${RED}Homebrew não está instalado.${NC}"
                    echo -e "${YELLOW}Por favor, instale o Homebrew primeiro:${NC} https://brew.sh/"
                    return 1
                fi
            else
                echo -e "${RED}Sistema operacional não suportado para instalação automática.${NC}"
                echo -e "${YELLOW}Por favor, instale manualmente:${NC} https://cli.github.com/manual/installation"
                return 1
            fi

            if command -v gh &> /dev/null; then
                echo -e "${GREEN}GitHub CLI instalado com sucesso!${NC}"
            else
                echo -e "${RED}Falha ao instalar GitHub CLI.${NC}"
                echo -e "${YELLOW}Por favor, instale manualmente:${NC} https://cli.github.com/manual/installation"
                return 1
            fi
        else
            echo -e "${YELLOW}Por favor, instale o GitHub CLI manualmente:${NC} https://cli.github.com/manual/installation"
            return 1
        fi
    fi

    # Verifica se o usuário está autenticado
    if ! gh auth status &> /dev/null; then
        echo -e "${RED}Você não está autenticado no GitHub CLI!${NC}"
        echo -e "${YELLOW}Deseja fazer login agora? (s/n)${NC}"
        read -r resposta

        if [[ "$resposta" =~ ^[Ss]$ ]]; then
            echo -e "${BLUE}Iniciando processo de login...${NC}"
            gh auth login

            if ! gh auth status &> /dev/null; then
                echo -e "${RED}Falha ao autenticar.${NC}"
                return 1
            else
                echo -e "${GREEN}Autenticado com sucesso!${NC}"
            fi
        else
            echo -e "${YELLOW}Por favor, autentique-se mais tarde com:${NC} gh auth login"
            return 1
        fi
    fi

    return 0
}

# Função para clonar um repositório
gh_clone() {
    if ! check_git; then
        return 1
    fi

    local repo=$1
    local dir=$2

    if [ -z "$repo" ]; then
        echo -e "${RED}Especifique o repositório para clonar!${NC}"
        echo -e "Uso: bytebabe gh clone <repositório> [diretório]"
        echo -e "Exemplos:"
        echo -e "  bytebabe gh clone username/repo"
        echo -e "  bytebabe gh clone https://github.com/username/repo.git"
        return 1
    fi

    # Adiciona prefixo github.com se for apenas username/repo
    if [[ "$repo" != http* ]] && [[ "$repo" == */* ]]; then
        repo="https://github.com/$repo.git"
    fi

    echo -e "${BLUE}Clonando repositório $repo...${NC}"

    if [ -n "$dir" ]; then
        git clone "$repo" "$dir"
    else
        git clone "$repo"
    fi

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Repositório clonado com sucesso!${NC}"
    else
        echo -e "${RED}Falha ao clonar repositório!${NC}"
        return 1
    fi
}

# Função para criar um novo repositório no GitHub
gh_create() {
    if ! check_git; then
        return 1
    fi

    if ! check_gh_cli; then
        return 1
    fi

    local repo_name=$1
    local visibility=$2

    if [ -z "$repo_name" ]; then
        echo -e "${RED}Especifique o nome do repositório!${NC}"
        echo -e "Uso: bytebabe gh create <nome> [public|private]"
        return 1
    fi

    # Define visibilidade padrão como privada
    if [ -z "$visibility" ]; then
        visibility="private"
    fi

    # Verifica se a visibilidade é válida
    if [ "$visibility" != "public" ] && [ "$visibility" != "private" ]; then
        echo -e "${RED}Visibilidade inválida: $visibility${NC}"
        echo -e "Use 'public' ou 'private'"
        return 1
    fi

    echo -e "${BLUE}Criando repositório $repo_name ($visibility)...${NC}"

    gh repo create "$repo_name" --"$visibility" --confirm

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Repositório criado com sucesso!${NC}"
    else
        echo -e "${RED}Falha ao criar repositório!${NC}"
        return 1
    fi
}

# Função para fazer commit e push
gh_commit() {
    if ! check_git; then
        return 1
    fi

    if ! check_git_repo; then
        return 1
    fi

    local message=$1
    local branch=$2

    if [ -z "$message" ]; then
        echo -e "${RED}Especifique a mensagem do commit!${NC}"
        echo -e "Uso: bytebabe gh commit <mensagem> [branch]"
        return 1
    fi

    # Verifica se há alterações para commit
    if git diff --quiet && git diff --staged --quiet; then
        echo -e "${YELLOW}Não há alterações para commit!${NC}"
        return 0
    fi

    # Adiciona todas as alterações
    echo -e "${BLUE}Adicionando alterações...${NC}"
    git add .

    # Faz o commit
    echo -e "${BLUE}Fazendo commit: $message${NC}"
    git commit -m "$message"

    # Se a branch for especificada, faz push
    if [ -n "$branch" ]; then
        echo -e "${BLUE}Fazendo push para $branch...${NC}"
        git push origin "$branch"

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Push realizado com sucesso!${NC}"
        else
            echo -e "${RED}Falha ao fazer push!${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}Para fazer push, especifique a branch:${NC} bytebabe gh push <branch>"
    fi
}

# Função para fazer push
gh_push() {
    if ! check_git; then
        return 1
    fi

    if ! check_git_repo; then
        return 1
    fi

    local branch=$1

    # Se a branch não for especificada, usa a branch atual
    if [ -z "$branch" ]; then
        branch=$(git symbolic-ref --short HEAD 2>/dev/null)
        if [ -z "$branch" ]; then
            echo -e "${RED}Não foi possível determinar a branch atual!${NC}"
            echo -e "Especifique a branch: bytebabe gh push <branch>"
            return 1
        fi
    fi

    echo -e "${BLUE}Fazendo push para $branch...${NC}"
    git push origin "$branch"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Push realizado com sucesso!${NC}"
    else
        echo -e "${RED}Falha ao fazer push!${NC}"
        return 1
    fi
}

# Função para fazer pull
gh_pull() {
    if ! check_git; then
        return 1
    fi

    if ! check_git_repo; then
        return 1
    fi

    local branch=$1

    # Se a branch não for especificada, usa a branch atual
    if [ -z "$branch" ]; then
        branch=$(git symbolic-ref --short HEAD 2>/dev/null)
        if [ -z "$branch" ]; then
            echo -e "${RED}Não foi possível determinar a branch atual!${NC}"
            echo -e "Especifique a branch: bytebabe gh pull <branch>"
            return 1
        fi
    fi

    echo -e "${BLUE}Fazendo pull de $branch...${NC}"
    git pull origin "$branch"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Pull realizado com sucesso!${NC}"
    else
        echo -e "${RED}Falha ao fazer pull!${NC}"
        return 1
    fi
}

# Função para criar uma nova branch
gh_branch() {
    if ! check_git; then
        return 1
    fi

    if ! check_git_repo; then
        return 1
    fi

    local branch=$1
    local base=$2

    if [ -z "$branch" ]; then
        echo -e "${RED}Especifique o nome da branch!${NC}"
        echo -e "Uso: bytebabe gh branch <nome> [base]"
        return 1
    fi

    # Se a base não for especificada, usa a branch atual
    if [ -z "$base" ]; then
        base=$(git symbolic-ref --short HEAD 2>/dev/null)
        if [ -z "$base" ]; then
            echo -e "${RED}Não foi possível determinar a branch atual!${NC}"
            echo -e "Especifique a branch base: bytebabe gh branch $branch <base>"
            return 1
        fi
    fi

    echo -e "${BLUE}Criando branch $branch a partir de $base...${NC}"
    git checkout -b "$branch" "$base"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Branch $branch criada com sucesso!${NC}"
    else
        echo -e "${RED}Falha ao criar branch!${NC}"
        return 1
    fi
}

# Função para listar branches
gh_branches() {
    if ! check_git; then
        return 1
    fi

    if ! check_git_repo; then
        return 1
    fi

    echo -e "${BLUE}Branches locais:${NC}"
    git branch

    echo -e "\n${BLUE}Branches remotas:${NC}"
    git branch -r
}

# Função para trocar de branch
gh_checkout() {
    if ! check_git; then
        return 1
    fi

    if ! check_git_repo; then
        return 1
    fi

    local branch=$1

    if [ -z "$branch" ]; then
        echo -e "${RED}Especifique a branch para checkout!${NC}"
        echo -e "Uso: bytebabe gh checkout <branch>"
        return 1
    fi

    echo -e "${BLUE}Fazendo checkout para $branch...${NC}"
    git checkout "$branch"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Checkout para $branch realizado com sucesso!${NC}"
    else
        echo -e "${RED}Falha ao fazer checkout!${NC}"
        return 1
    fi
}

# Função para criar um pull request
gh_pr() {
    if ! check_git; then
        return 1
    fi

    if ! check_git_repo; then
        return 1
    fi

    if ! check_gh_cli; then
        return 1
    fi

    local title=$1
    local base=$2

    if [ -z "$title" ]; then
        echo -e "${RED}Especifique o título do pull request!${NC}"
        echo -e "Uso: bytebabe gh pr <título> [base]"
        return 1
    fi

    # Se a base não for especificada, usa main ou master
    if [ -z "$base" ]; then
        if git show-ref --verify --quiet refs/heads/main; then
            base="main"
        elif git show-ref --verify --quiet refs/heads/master; then
            base="master"
        else
            echo -e "${RED}Não foi possível determinar a branch base!${NC}"
            echo -e "Especifique a branch base: bytebabe gh pr \"$title\" <base>"
            return 1
        fi
    fi

    # Obtém a branch atual
    local current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    if [ -z "$current_branch" ]; then
        echo -e "${RED}Não foi possível determinar a branch atual!${NC}"
        return 1
    fi

    echo -e "${BLUE}Criando pull request de $current_branch para $base...${NC}"
    gh pr create --title "$title" --base "$base"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Pull request criado com sucesso!${NC}"
    else
        echo -e "${RED}Falha ao criar pull request!${NC}"
        return 1
    fi
}

# Função para listar pull requests
gh_prs() {
    if ! check_gh_cli; then
        return 1
    fi

    echo -e "${BLUE}Pull requests abertos:${NC}"
    gh pr list
}

# Função para ver o status do repositório
gh_status() {
    if ! check_git; then
        return 1
    fi

    if ! check_git_repo; then
        return 1
    fi

    echo -e "${BLUE}Status do repositório:${NC}"
    git status

    echo -e "\n${BLUE}Branch atual:${NC}"
    git branch --show-current

    echo -e "\n${BLUE}Últimos commits:${NC}"
    git log --oneline -n 5
}

# Função para mostrar ajuda do GitHub
gh_help() {
    echo -e "${BLUE}Comandos GitHub disponíveis:${NC}"
    echo -e "  ${GREEN}clone${NC}     - Clona um repositório (ex: bytebabe gh clone username/repo)"
    echo -e "  ${GREEN}create${NC}    - Cria um novo repositório (ex: bytebabe gh create repo-name [public|private])"
    echo -e "  ${GREEN}commit${NC}    - Adiciona e faz commit de alterações (ex: bytebabe gh commit \"mensagem\")"
    echo -e "  ${GREEN}push${NC}      - Faz push para o repositório remoto (ex: bytebabe gh push [branch])"
    echo -e "  ${GREEN}pull${NC}      - Faz pull do repositório remoto (ex: bytebabe gh pull [branch])"
    echo -e "  ${GREEN}branch${NC}    - Cria uma nova branch (ex: bytebabe gh branch nova-branch [base])"
    echo -e "  ${GREEN}branches${NC}  - Lista todas as branches"
    echo -e "  ${GREEN}checkout${NC}  - Troca para outra branch (ex: bytebabe gh checkout branch)"
    echo -e "  ${GREEN}pr${NC}        - Cria um pull request (ex: bytebabe gh pr \"título\" [base])"
    echo -e "  ${GREEN}prs${NC}       - Lista pull requests abertos"
    echo -e "  ${GREEN}status${NC}    - Mostra o status do repositório"
}
