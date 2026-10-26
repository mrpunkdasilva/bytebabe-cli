#!/bin/bash

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configurações
VERSION="1.4.0"
REPO_URL="https://github.com/mrpunkdasilva/bytebabe-cli"
TARBALL_URL="${REPO_URL}/releases/download/v${VERSION}/bytebabe-${VERSION}.tar.gz"
TEMP_DIR="/tmp/bytebabe-install"
INSTALL_DIR="/opt/bytebabe"
BIN_DIR="/usr/local/bin"
EXECUTABLE="bytebabe"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)"

echo -e "${BLUE}⚡ Instalando ByteBabe CLI v${VERSION}...${NC}"

SOURCE_DIR=""

# Modo local: instalando a partir de um clone do repositório
if [ -f "${SCRIPT_DIR}/install.sh" ] && [ -f "${SCRIPT_DIR}/bin/bytebabe" ] && [ -d "${SCRIPT_DIR}/lib" ]; then
    echo -e "${BLUE}📂 Instalando a partir do repositório local: ${SCRIPT_DIR}${NC}"
    SOURCE_DIR="$SCRIPT_DIR"
else
    # Cria diretório temporário
    rm -rf "$TEMP_DIR"
    mkdir -p "$TEMP_DIR"

    # Download do pacote
    echo -e "${BLUE}📥 Baixando pacote...${NC}"
    if ! curl -fsSL "$TARBALL_URL" -o "${TEMP_DIR}/bytebabe.tar.gz"; then
        echo -e "${RED}Erro: Falha ao baixar o pacote${NC}"
        exit 1
    fi

    # Extrai o pacote
    echo -e "${BLUE}📦 Extraindo arquivos...${NC}"
    if ! tar -xzf "${TEMP_DIR}/bytebabe.tar.gz" -C "$TEMP_DIR"; then
        echo -e "${RED}Erro: Falha ao extrair o pacote${NC}"
        exit 1
    fi

    # O tarball pode conter um diretório raiz (ex: bytebabe-1.4.0/)
    EXEC_PATH=$(find "$TEMP_DIR" -type f -path '*/bin/bytebabe' | head -n 1)
    if [ -z "$EXEC_PATH" ]; then
        echo -e "${RED}Erro: executável bin/bytebabe não encontrado no pacote${NC}"
        exit 1
    fi
    SOURCE_DIR=$(dirname "$(dirname "$EXEC_PATH")")
fi

if [ ! -f "${SOURCE_DIR}/bin/bytebabe" ] || [ ! -d "${SOURCE_DIR}/lib" ]; then
    echo -e "${RED}Erro: instalação inválida, bin/bytebabe ou lib/ não encontrados em ${SOURCE_DIR}${NC}"
    exit 1
fi

# Substitui instalação anterior
echo -e "${BLUE}📂 Copiando arquivos para ${INSTALL_DIR}...${NC}"
sudo rm -rf "$INSTALL_DIR"
sudo mkdir -p "$INSTALL_DIR"
sudo cp -a "${SOURCE_DIR}/." "$INSTALL_DIR/"
sudo chmod +x "${INSTALL_DIR}/bin/bytebabe"

# Cria link simbólico
echo -e "${BLUE}🔗 Criando link simbólico...${NC}"
sudo ln -sf "${INSTALL_DIR}/bin/bytebabe" "${BIN_DIR}/${EXECUTABLE}"
hash -r 2>/dev/null || true

# Limpa arquivos temporários
[ -d "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"

echo -e "${GREEN}✔ ByteBabe CLI instalado com sucesso!${NC}"
echo -e "${BLUE}➜ Execute 'bytebabe --version' para testar${NC}"
echo -e "${BLUE}➜ Execute 'bytebabe init' para começar${NC}"
