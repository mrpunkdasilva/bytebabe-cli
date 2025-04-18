#!/bin/bash

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configurações
VERSION=$(node -p "require('../package.json').version")
PACKAGE_NAME="bytebabe-${VERSION}"
TEMP_DIR="/tmp/${PACKAGE_NAME}"
DIST_DIR="../dist"

echo -e "${BLUE}📦 Empacotando ByteBabe v${VERSION}...${NC}"

# Cria diretórios temporários
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
mkdir -p "$DIST_DIR"

# Lista de diretórios e arquivos para incluir
INCLUDES=(
    "bin"
    "lib"
    "commands"
    "scripts"
    "install.sh"
    "package.json"
    "README.md"
    "LICENSE"
)

# Copia arquivos necessários
for item in "${INCLUDES[@]}"; do
    if [ -e "../$item" ]; then
        cp -r "../$item" "$TEMP_DIR/"
        echo -e "${GREEN}✔ Copiado: $item${NC}"
    else
        echo -e "${RED}✘ Não encontrado: $item${NC}"
    fi
done

# Garante permissões corretas
chmod +x "$TEMP_DIR/bin/bytebabe"
chmod +x "$TEMP_DIR/install.sh"

# Cria o arquivo tar.gz
cd /tmp
tar -czf "${DIST_DIR}/${PACKAGE_NAME}.tar.gz" "${PACKAGE_NAME}"

# Limpa diretório temporário
rm -rf "$TEMP_DIR"

echo -e "${GREEN}✔ Pacote criado: ${DIST_DIR}/${PACKAGE_NAME}.tar.gz${NC}"
echo -e "${BLUE}📊 Tamanho: $(du -h ${DIST_DIR}/${PACKAGE_NAME}.tar.gz | cut -f1)${NC}"