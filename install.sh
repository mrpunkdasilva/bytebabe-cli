#!/bin/bash

# Define o diretório de instalação
INSTALL_DIR="/usr/local/bin"

# Nome do executável
EXECUTABLE="bytebabe"

# Caminho completo do script
SCRIPT_PATH="$(pwd)/bin/$EXECUTABLE"

# Verifica se o script existe
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "Erro: O script $EXECUTABLE não foi encontrado em $SCRIPT_PATH."
    exit 1
fi

# Copia o script para o diretório de instalação
echo "Instalando $EXECUTABLE em $INSTALL_DIR..."
sudo cp "$SCRIPT_PATH" "$INSTALL_DIR"

# Verifica se a cópia foi bem-sucedida
if [ $? -eq 0 ]; then
    echo "$EXECUTABLE foi instalado com sucesso em $INSTALL_DIR."
else
    echo "Erro: Falha ao instalar $EXECUTABLE."
    exit 1
fi