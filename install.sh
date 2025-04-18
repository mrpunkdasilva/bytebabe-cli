#!/bin/bash

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configurações
VERSION="1.0.0"
REPO_URL="https://github.com/mrpunkdasilva/bytebabe"
TARBALL_URL="${REPO_URL}/releases/download/v${VERSION}/bytebabe-${VERSION}.tar.gz"
TEMP_DIR="/tmp/bytebabe-install"
INSTALL_DIR="/opt/bytebabe"
BIN_DIR="/usr/local/bin"
EXECUTABLE="bytebabe"

echo -e "${BLUE}⚡ Instalando ByteBabe CLI v${VERSION}...${NC}"

# Cria diretório temporário
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

# Download do pacote
echo -e "${BLUE}📥 Baixando pacote...${NC}"
if ! curl -L "$TARBALL_URL" -o "${TEMP_DIR}/bytebabe.tar.gz"; then
    echo -e "${RED}Erro: Falha ao baixar o pacote${NC}"
    exit 1
fi

# Extrai o pacote
echo -e "${BLUE}📦 Extraindo arquivos...${NC}"
tar -xzf "${TEMP_DIR}/bytebabe.tar.gz" -C "$TEMP_DIR"

# Cria diretório de instalação
sudo mkdir -p "$INSTALL_DIR"
sudo cp -r "${TEMP_DIR}"/bytebabe-*/* "$INSTALL_DIR/"

# Configura permissões
sudo chmod +x "${INSTALL_DIR}/bin/bytebabe"

# Cria link simbólico
echo -e "${BLUE}🔗 Criando link simbólico...${NC}"
sudo ln -sf "${INSTALL_DIR}/bin/bytebabe" "${BIN_DIR}/${EXECUTABLE}"

# Limpa arquivos temporários
rm -rf "$TEMP_DIR"

echo -e "${GREEN}✔ ByteBabe CLI instalado com sucesso!${NC}"
echo -e "${BLUE}➜ Execute 'bytebabe --version' para testar${NC}"
echo -e "${BLUE}➜ Execute 'bytebabe init' para começar${NC}"