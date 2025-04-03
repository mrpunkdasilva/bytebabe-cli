#!/bin/bash

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configurações
REPO="https://github.com/mrpunkdasilva/bytebabe.git"
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
                echo -e "${RED}Não foi possível instalar o Git automaticamente.${NC}"
                echo -e "Por favor, instale o Git manualmente e execute este script novamente."
                echo -e "Visite: https://git-scm.com/downloads"
                exit 1
                ;;
        esac
    fi
}

# Baixa via curl se Git não estiver disponível
download_source() {
    if command -v git &>/dev/null; then
        git clone --depth 1 "${REPO}" "${INSTALL_DIR}/tmp"
        mv "${INSTALL_DIR}"/tmp/* "${INSTALL_DIR}"
        rm -rf "${INSTALL_DIR}/tmp"
    else
        echo -e "${YELLOW}Baixando via curl...${NC}"
        TARBALL_URL="https://github.com/yourusername/bytebabe/archive/refs/heads/main.tar.gz"
        curl -L "${TARBALL_URL}" | tar xz -C "${INSTALL_DIR}" --strip-components=1
    fi
}

# Início da instalação
echo -e "${BLUE}⚡ Instalando ByteBabe CLI...${NC}"

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

# Tenta instalar Git
install_git

# Baixa os arquivos
download_source

# Configura o executável
mkdir -p "${INSTALL_DIR}/bin"
cat > "${INSTALL_DIR}/bin/${EXECUTABLE}" << 'EOF'
#!/bin/bash
BYTEBABE_HOME="${HOME}/.bytebabe"
exec "${BYTEBABE_HOME}/src/main.sh" "$@"
EOF

chmod +x "${INSTALL_DIR}/bin/${EXECUTABLE}"

# Cria link simbólico
sudo ln -sf "${INSTALL_DIR}/bin/${EXECUTABLE}" "${BIN_DIR}/${EXECUTABLE}"

echo -e "${GREEN}✔ ByteBabe CLI instalada com sucesso!${NC}"
echo -e "${BLUE}➜ Execute 'bytebabe init' para começar${NC}"
