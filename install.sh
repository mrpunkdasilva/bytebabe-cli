#!/bin/bash

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configurações
VERSION="v1.0.0"
REPO="https://github.com/mrpunkdasilva/bytebabe"
REPO_GIT="${REPO}.git"
REPO_TAR="${REPO}/archive/refs/tags/${VERSION}.tar.gz"
INSTALL_DIR="${HOME}/.bytebabe"
BIN_DIR="/usr/local/bin"
EXECUTABLE="bytebabe"

# Detecta o gerenciador de pacotes
detect_package_manager() {
    if command -v apt-get &>/dev/null; then
        echo "apt"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v yum &>/dev/null; then
        echo "yum"
    elif command -v pacman &>/dev/null; then
        echo "pacman"
    elif command -v brew &>/dev/null; then
        echo "brew"
    else
        echo "unknown"
    fi
}

# Instala o Git se necessário
install_git() {
    if ! command -v git &>/dev/null; then
        echo -e "${YELLOW}Git não encontrado. Instalando...${NC}"
        
        PKG_MANAGER=$(detect_package_manager)
        case $PKG_MANAGER in
            "apt")
                sudo apt-get update
                sudo apt-get install -y git
                ;;
            "dnf")
                sudo dnf install -y git
                ;;
            "yum")
                sudo yum install -y git
                ;;
            "pacman")
                sudo pacman -Sy git --noconfirm
                ;;
            "brew")
                brew install git
                ;;
            *)
                echo -e "${YELLOW}Não foi possível instalar o Git. Usando método alternativo...${NC}"
                return 1
                ;;
        esac
    fi
    return 0
}

# Baixa e instala os arquivos
download_source() {
    # Tenta usar Git primeiro
    if install_git; then
        echo -e "${BLUE}Clonando via Git...${NC}"
        if git clone --depth 1 --branch ${VERSION} "${REPO_GIT}" "${INSTALL_DIR}/tmp"; then
            mv "${INSTALL_DIR}"/tmp/* "${INSTALL_DIR}/"
            rm -rf "${INSTALL_DIR}/tmp"
            return 0
        fi
    fi

    # Fallback para download via tar
    echo -e "${YELLOW}Baixando via arquivo tar...${NC}"
    
    # Verifica se curl ou wget está disponível
    if command -v curl &>/dev/null; then
        DOWNLOAD_CMD="curl -L"
    elif command -v wget &>/dev/null; then
        DOWNLOAD_CMD="wget -qO-"
    else
        echo -e "${RED}Erro: Necessário curl ou wget para download${NC}"
        exit 1
    fi

    # Tenta baixar e extrair
    if $DOWNLOAD_CMD "${REPO_TAR}" | tar xz -C "${INSTALL_DIR}" --strip-components=1; then
        return 0
    else
        echo -e "${RED}Erro ao baixar ou extrair os arquivos${NC}"
        exit 1
    fi
}

# Início da instalação
echo -e "${BLUE}⚡ Instalando ByteBabe CLI ${VERSION}...${NC}"

# Verifica permissões do diretório bin
if [ ! -w "${BIN_DIR}" ]; then
    echo -e "${YELLOW}Necessário sudo para criar link simbólico em ${BIN_DIR}${NC}"
    if ! sudo -v; then
        echo -e "${RED}Erro: Necessário privilégios sudo para instalação${NC}"
        exit 1
    fi
fi

# Cria diretório de instalação
mkdir -p "${INSTALL_DIR}"

# Baixa os arquivos
download_source

# Configura o executável
mkdir -p "${INSTALL_DIR}/bin"

# Agora vamos criar um wrapper que aponta para o executável correto
cat > "${INSTALL_DIR}/bin/${EXECUTABLE}" << EOF
#!/bin/bash
BYTEBABE_HOME="${HOME}/.bytebabe"
exec "\${BYTEBABE_HOME}/bin/bytebabe" "\$@"
EOF

chmod +x "${INSTALL_DIR}/bin/${EXECUTABLE}"

# Cria link simbólico
sudo ln -sf "${INSTALL_DIR}/bin/${EXECUTABLE}" "${BIN_DIR}/${EXECUTABLE}"

# Garante que o executável principal também tem permissões corretas
chmod +x "${INSTALL_DIR}/bin/bytebabe"

echo -e "${GREEN}✔ ByteBabe CLI instalada com sucesso!${NC}"
echo -e "${BLUE}➜ Execute 'bytebabe init' para começar${NC}"