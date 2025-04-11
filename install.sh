#!/bin/bash

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configurações
REPO_DIR="$(pwd)"
BIN_DIR="/usr/local/bin"
EXECUTABLE="bytebabe"

echo -e "${BLUE}⚡ Criando link para ByteBabe CLI...${NC}"

# Verifica permissões do diretório bin
if [ ! -w "${BIN_DIR}" ]; then
    echo -e "${YELLOW}Necessário sudo para criar link em ${BIN_DIR}${NC}"
    if ! sudo -v; then
        echo -e "${RED}Erro: Necessário privilégios sudo para instalação${NC}"
        exit 1
    fi
fi

# Garante que o executável tem permissões corretas
chmod +x "${REPO_DIR}/bin/bytebabe"

# Modifica o script principal para usar o caminho absoluto
echo -e "${BLUE}Configurando script principal...${NC}"
sed -i "s|BASE_DIR=.*|BASE_DIR=\"${REPO_DIR}\"|" "${REPO_DIR}/bin/bytebabe"

# Cria link direto para o executável
echo -e "${BLUE}Criando link para o executável...${NC}"
sudo ln -sf "${REPO_DIR}/bin/bytebabe" "${BIN_DIR}/${EXECUTABLE}"

echo -e "${GREEN}✔ Link criado com sucesso!${NC}"
echo -e "${BLUE}➜ Execute 'bytebabe --version' para testar${NC}"
echo -e "${BLUE}➜ Execute 'bytebabe init' para começar${NC}"