#!/bin/bash

# Gera a documentação
./unzip_writerside.sh

# Empacota o projeto
./package_release.sh

# Envia para o repositório remoto
./push_remote_repo.sh