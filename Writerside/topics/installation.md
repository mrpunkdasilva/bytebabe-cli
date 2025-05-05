# Instalação

## Requisitos

- Linux, macOS ou WSL (Windows Subsystem for Linux)
- Bash 4.0+ ou Zsh
- Git
- Docker (opcional, necessário para módulos Docker e Servers)

## Instalação Rápida

```bash
# Instalação via curl
curl -fsSL https://raw.githubusercontent.com/mrpunkdasilva/bytebabe/main/install.sh | bash

# Verificar instalação
bytebabe --version
```

## Instalação Manual

```bash
# Clone o repositório
git clone https://github.com/mrpunkdasilva/bytebabe.git

# Entre no diretório
cd bytebabe

# Instale o ByteBabe
./install.sh

# Adicione ao PATH (se não for feito automaticamente)
echo 'export PATH="$HOME/.bytebabe/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## Configuração Inicial

Após a instalação, execute o comando de inicialização:

```bash
bytebabe init
```

Este comando irá:
1. Verificar dependências
2. Configurar diretórios necessários
3. Criar arquivos de configuração padrão
4. Oferecer configuração guiada dos módulos

## Próximos Passos

- [Quick Start](quick-start.md) - Primeiros comandos
- [Core Modules](core-modules.md) - Visão geral dos módulos
