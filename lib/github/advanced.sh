#!/bin/bash

# ==================================================
# FUNÇÕES AVANÇADAS DE GITHUB
# ==================================================

# Função para criar um novo repositório e configurá-lo com template
gh_create_from_template() {
    if ! check_gh_cli; then
        return 1
    fi

    local repo_name=$1
    local template=$2
    local visibility=$3

    if [ -z "$repo_name" ]; then
        echo -e "${RED}Especifique o nome do repositório!${NC}"
        echo -e "Uso: bytebabe gh create-template <nome> <template> [public|private]"
        return 1
    fi

    if [ -z "$template" ]; then
        echo -e "${RED}Especifique o template!${NC}"
        echo -e "Uso: bytebabe gh create-template <nome> <template> [public|private]"
        echo -e "Exemplos de templates:"
        echo -e "  github/node-template"
        echo -e "  github/python-template"
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

    echo -e "${BLUE}Criando repositório $repo_name a partir do template $template...${NC}"

    gh repo create "$repo_name" --template="$template" --"$visibility" --clone

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Repositório criado com sucesso!${NC}"
        cd "$repo_name"
        echo -e "${GREEN}Diretório alterado para $(pwd)${NC}"
    else
        echo -e "${RED}Falha ao criar repositório!${NC}"
        return 1
    fi
}

# Função para configurar GitHub Actions
gh_setup_actions() {
    if ! check_git; then
        return 1
    fi

    if ! check_git_repo; then
        return 1
    fi

    if ! check_gh_cli; then
        return 1
    fi

    local workflow_type=$1

    if [ -z "$workflow_type" ]; then
        echo -e "${RED}Especifique o tipo de workflow!${NC}"
        echo -e "Uso: bytebabe gh setup-actions <tipo>"
        echo -e "Tipos disponíveis:"
        echo -e "  node       - Workflow para Node.js"
        echo -e "  python     - Workflow para Python"
        echo -e "  docker     - Workflow para Docker"
        echo -e "  static     - Workflow para sites estáticos"
        return 1
    fi

    # Cria diretório de workflows se não existir
    mkdir -p .github/workflows

    case "$workflow_type" in
        node)
            cat > .github/workflows/node.yml << EOF
name: Node.js CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [14.x, 16.x, 18.x]
    steps:
    - uses: actions/checkout@v3
    - name: Use Node.js \${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: \${{ matrix.node-version }}
        cache: 'npm'
    - run: npm ci
    - run: npm run build --if-present
    - run: npm test
EOF
            echo -e "${GREEN}Workflow para Node.js criado com sucesso!${NC}"
            ;;
        python)
            cat > .github/workflows/python.yml << EOF
name: Python CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: [3.8, 3.9, '3.10']
    steps:
    - uses: actions/checkout@v3
    - name: Set up Python \${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: \${{ matrix.python-version }}
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
        pip install pytest
    - name: Test with pytest
      run: |
        pytest
EOF
            echo -e "${GREEN}Workflow para Python criado com sucesso!${NC}"
            ;;
        docker)
            cat > .github/workflows/docker.yml << EOF
name: Docker CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Build the Docker image
      run: docker build . --file Dockerfile --tag my-image:latest
    - name: Run tests
      run: docker run my-image:latest test
EOF
            echo -e "${GREEN}Workflow para Docker criado com sucesso!${NC}"
            ;;
        static)
            cat > .github/workflows/static.yml << EOF
name: Deploy static site

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '16'
    - name: Install dependencies
      run: npm ci
    - name: Build
      run: npm run build
    - name: Deploy to GitHub Pages
      uses: JamesIves/github-pages-deploy-action@v4
      with:
        folder: build
EOF
            echo -e "${GREEN}Workflow para site estático criado com sucesso!${NC}"
            ;;
        *)
            echo -e "${RED}Tipo de workflow inválido: $workflow_type${NC}"
            return 1
            ;;
    esac

    # Adiciona e faz commit do workflow
    git add .github/workflows/
    git commit -m "Add GitHub Actions workflow for $workflow_type"

    echo -e "${GREEN}Workflow adicionado ao repositório!${NC}"
    echo -e "${YELLOW}Use 'bytebabe gh push' para enviar as alterações para o GitHub${NC}"
}

# Função para configurar proteção de branch
gh_protect_branch() {
    if ! check_git; then
        return 1
    fi

    if ! check_git_repo; then
        return 1
    fi

    if ! check_gh_cli; then
        return 1
    fi

    local branch=$1
    local level=$2

    if [ -z "$branch" ]; then
        echo -e "${RED}Especifique a branch para proteger!${NC}"
        echo -e "Uso: bytebabe gh protect-branch <branch> [basic|strict]"
        return 1
    fi

    # Define nível padrão como basic
    if [ -z "$level" ]; then
        level="basic"
    fi

    # Verifica se o nível é válido
    if [ "$level" != "basic" ] && [ "$level" != "strict" ]; then
        echo -e "${RED}Nível de proteção inválido: $level${NC}"
        echo -e "Use 'basic' ou 'strict'"
        return 1
    fi

    echo -e "${BLUE}Configurando proteção para a branch $branch (nível: $level)...${NC}"

    if [ "$level" = "basic" ]; then
        gh api repos/:owner/:repo/branches/$branch/protection -X PUT -F required_status_checks='{"strict":false,"contexts":[]}' -F enforce_admins=false -F required_pull_request_reviews='{"dismissal_restrictions":{},"dismiss_stale_reviews":false,"require_code_owner_reviews":false,"required_approving_review_count":1}' -F restrictions='{"users":[],"teams":[],"apps":[]}'
    else
        gh api repos/:owner/:repo/branches/$branch/protection -X PUT -F required_status_checks='{"strict":true,"contexts":["continuous-integration"]}' -F enforce_admins=true -F required_pull_request_reviews='{"dismissal_restrictions":{},"dismiss_stale_reviews":true,"require_code_owner_reviews":true,"required_approving_review_count":2}' -F restrictions='{"users":[],"teams":[],"apps":[]}'
    fi

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Proteção configurada com sucesso para a branch $branch!${NC}"
    else
        echo -e "${RED}Falha ao configurar proteção!${NC}"
        return 1
    fi
}

# Função para criar um novo release
gh_release() {
    if ! check_git; then
        return 1
    fi

    if ! check_git_repo; then
        return 1
    fi

    if ! check_gh_cli; then
        return 1
    fi

    local tag=$1
    local title=$2
    local notes=$3

    if [ -z "$tag" ]; then
        echo -e "${RED}Especifique a tag do release!${NC}"
        echo -e "Uso: bytebabe gh release <tag> [título] [notas]"
        return 1
    fi

    # Se o título não for especificado, usa a tag
    if [ -z "$title" ]; then
        title="Release $tag"
    fi

    # Se as notas não forem especificadas, gera automaticamente
    if [ -z "$notes" ]; then
        notes=$(git log --pretty=format:"- %s" $(git describe --tags --abbrev=0 2>/dev/null || echo HEAD^)..HEAD)
        if [ -z "$notes" ]; then
            notes="Release $tag"
        fi
    fi

    echo -e "${BLUE}Criando release $tag...${NC}"

    # Cria o release
    echo "$notes" | gh release create "$tag" --title "$title" --notes-file -

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Release $tag criado com sucesso!${NC}"
    else
        echo -e "${RED}Falha ao criar release!${NC}"
        return 1
    fi
}

# Função para listar issues
gh_issues() {
    if ! check_gh_cli; then
        return 1
    fi

    local state=$1
    local limit=$2

    # Define estado padrão como open
    if [ -z "$state" ]; then
        state="open"
    fi

    # Define limite padrão como 10
    if [ -z "$limit" ]; then
        limit=10
    fi

    # Verifica se o estado é válido
    if [ "$state" != "open" ] && [ "$state" != "closed" ] && [ "$state" != "all" ]; then
        echo -e "${RED}Estado inválido: $state${NC}"
        echo -e "Use 'open', 'closed' ou 'all'"
        return 1
    fi

    echo -e "${BLUE}Issues $state:${NC}"
    gh issue list --state "$state" --limit "$limit"
}

# Função para criar uma nova issue
gh_issue_create() {
    if ! check_gh_cli; then
        return 1
    fi

    local title=$1
    local body=$2

    if [ -z "$title" ]; then
        echo -e "${RED}Especifique o título da issue!${NC}"
        echo -e "Uso: bytebabe gh issue-create <título> [corpo]"
        return 1
    fi

    echo -e "${BLUE}Criando issue: $title${NC}"

    if [ -z "$body" ]; then
        gh issue create --title "$title"
    else
        echo "$body" | gh issue create --title "$title" --body-file -
    fi

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Issue criada com sucesso!${NC}"
    else
        echo -e "${RED}Falha ao criar issue!${NC}"
        return 1
    fi
}

# Função para configurar GitHub Pages
gh_pages() {
    if ! check_git; then
        return 1
    fi

    if ! check_git_repo; then
        return 1
    fi

    if ! check_gh_cli; then
        return 1
    fi

    local branch=$1
    local path=$2

    if [ -z "$branch" ]; then
        echo -e "${RED}Especifique a branch para GitHub Pages!${NC}"
        echo -e "Uso: bytebabe gh pages <branch> [path]"
        echo -e "Exemplos:"
        echo -e "  bytebabe gh pages main"
        echo -e "  bytebabe gh pages gh-pages"
        echo -e "  bytebabe gh pages main /docs"
        return 1
    fi

    # Define path padrão como /
    if [ -z "$path" ]; then
        path="/"
    fi

    echo -e "${BLUE}Configurando GitHub Pages na branch $branch, path $path...${NC}"

    gh api repos/:owner/:repo/pages -X PUT -F source='{"branch":"'$branch'","path":"'$path'"}'

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}GitHub Pages configurado com sucesso!${NC}"
        echo -e "${YELLOW}Acesse em: https://$(gh repo view --json nameWithOwner -q .nameWithOwner | tr '[:upper:]' '[:lower:]').github.io${NC}"
    else
        echo -e "${RED}Falha ao configurar GitHub Pages!${NC}"
        return 1
    fi
}

# Função para clonar todos os repositórios de um usuário ou organização
gh_clone_all() {
    if ! check_git; then
        return 1
    fi

    if ! check_gh_cli; then
        return 1
    fi

    local owner=$1
    local type=$2
    local dest_dir=$3

    if [ -z "$owner" ]; then
        echo -e "${RED}Especifique o usuário ou organização!${NC}"
        echo -e "Uso: bytebabe gh clone-all <owner> [user|org] [diretório]"
        return 1
    fi

    # Define tipo padrão como user
    if [ -z "$type" ]; then
        type="user"
    fi

    # Verifica se o tipo é válido
    if [ "$type" != "user" ] && [ "$type" != "org" ]; then
        echo -e "${RED}Tipo inválido: $type${NC}"
        echo -e "Use 'user' ou 'org'"
        return 1
    fi

    # Define diretório padrão como o nome do owner
    if [ -z "$dest_dir" ]; then
        dest_dir="$owner-repos"
    fi

    # Cria diretório de destino
    mkdir -p "$dest_dir"
    cd "$dest_dir"

    echo -e "${BLUE}Clonando todos os repositórios de $owner ($type)...${NC}"

    if [ "$type" = "user" ]; then
        gh repo list "$owner" --limit 1000 --json nameWithOwner --jq '.[].nameWithOwner' | xargs -L1 gh repo clone
    else
        gh repo list "$owner" --limit 1000 --json nameWithOwner --jq '.[].nameWithOwner' | xargs -L1 gh repo clone
    fi

    echo -e "${GREEN}Repositórios clonados em $(pwd)${NC}"
    echo -e "${BLUE}Total de repositórios: $(ls -l | grep "^d" | wc -l)${NC}"
}

# Função para mostrar ajuda das funções avançadas
gh_advanced_help() {
    echo -e "${BLUE}Comandos GitHub Avançados:${NC}"
    echo -e "  ${GREEN}create-template${NC}  - Cria um repositório a partir de um template"
    echo -e "  ${GREEN}setup-actions${NC}    - Configura GitHub Actions (node, python, docker, static)"
    echo -e "  ${GREEN}protect-branch${NC}   - Configura proteção de branch (basic, strict)"
    echo -e "  ${GREEN}release${NC}          - Cria um novo release"
    echo -e "  ${GREEN}issues${NC}           - Lista issues (open, closed, all)"
    echo -e "  ${GREEN}issue-create${NC}     - Cria uma nova issue"
    echo -e "  ${GREEN}pages${NC}            - Configura GitHub Pages"
    echo -e "  ${GREEN}clone-all${NC}        - Clona todos os repositórios de um usuário ou organização"
}