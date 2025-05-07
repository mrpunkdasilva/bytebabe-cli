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

# Lista o conteúdo extraído para debug
echo -e "${BLUE}📋 Verificando arquivos extraídos...${NC}"
ls -la "$TEMP_DIR"

# Cria diretório de instalação
sudo mkdir -p "$INSTALL_DIR"

# Copia todos os arquivos extraídos diretamente
echo -e "${BLUE}📂 Copiando arquivos...${NC}"
sudo cp -r "$TEMP_DIR"/* "$INSTALL_DIR/" 2>/dev/null || true

# Verifica se há arquivos bin/ no diretório temporário
if [ -d "$TEMP_DIR/bin" ]; then
    sudo mkdir -p "$INSTALL_DIR/bin"
    sudo cp -r "$TEMP_DIR/bin"/* "$INSTALL_DIR/bin/" 2>/dev/null || true
fi

# Procura pelo executável bytebabe em qualquer lugar
EXEC_PATH=$(find "$TEMP_DIR" -type f -name "bytebabe" | head -n 1)
if [ -n "$EXEC_PATH" ]; then
    echo -e "${BLUE}🔍 Executável encontrado em: $EXEC_PATH${NC}"
    sudo mkdir -p "$INSTALL_DIR/bin"
    sudo cp "$EXEC_PATH" "$INSTALL_DIR/bin/"
    sudo chmod +x "$INSTALL_DIR/bin/bytebabe"
else
    echo -e "${YELLOW}⚠️ Executável 'bytebabe' não encontrado no pacote${NC}"
    
    # Cria um script básico como fallback
    echo -e "${BLUE}🔧 Criando script básico...${NC}"
    sudo mkdir -p "$INSTALL_DIR/bin"
    cat << 'EOF' | sudo tee "$INSTALL_DIR/bin/bytebabe" > /dev/null
#!/bin/bash
echo "ByteBabe CLI v${VERSION}"
echo "Esta é uma instalação básica. Execute 'bytebabe update' para atualizar."
EOF
    sudo chmod +x "$INSTALL_DIR/bin/bytebabe"
fi

# Cria link simbólico
echo -e "${BLUE}🔗 Criando link simbólico...${NC}"
sudo ln -sf "${INSTALL_DIR}/bin/bytebabe" "${BIN_DIR}/${EXECUTABLE}"

# Limpa arquivos temporários
rm -rf "$TEMP_DIR"

echo -e "${GREEN}✔ ByteBabe CLI instalado com sucesso!${NC}"
echo -e "${BLUE}➜ Execute 'bytebabe --version' para testar${NC}"
echo -e "${BLUE}➜ Execute 'bytebabe init' para começar${NC}"