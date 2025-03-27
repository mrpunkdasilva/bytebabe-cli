#!/bin/bash

# Diretório de origem
SOURCE_DIR="$HOME/Área de Trabalho/Linux Configs"

# Diretório de instalação global
TARGET_DIR="/usr/local/lib/bytebabe"

# Criar estrutura de diretórios
sudo mkdir -p "$TARGET_DIR"/{lib/core,lib/utils,commands}

# Copiar arquivos
sudo cp -r "$SOURCE_DIR"/lib/* "$TARGET_DIR"/lib/
sudo cp -r "$SOURCE_DIR"/commands/* "$TARGET_DIR"/commands/
sudo cp "$SOURCE_DIR"/bin/bytebabe /usr/local/bin/

# Corrigir permissões
sudo chmod +x /usr/local/bin/bytebabe
sudo chmod -R +r "$TARGET_DIR"

echo "ByteBabe CLI instalada com sucesso em $TARGET_DIR"