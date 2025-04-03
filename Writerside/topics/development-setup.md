# Development Setup 🛠️

## Requisitos

### Sistema
- Linux/macOS
- Bash 4+
- Git
- curl ou wget

### Ferramentas Recomendadas
- shellcheck (para linting)
- shfmt (para formatação)
- VSCode ou Neovim

## Setup do Ambiente

### 1. Dependências Básicas
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install git curl wget shellcheck

# macOS
brew install git curl wget shellcheck
```

### 2. Projeto Setup
```bash
# Clone o repositório
git clone https://github.com/mrpunkdasilva/bytebabe.git
cd bytebabe

# Dê permissão de execução
chmod +x bin/bytebabe

# Teste a instalação
./bin/bytebabe --version
```

## Comandos de Desenvolvimento

### Testes Manuais
```bash
# Teste um comando específico
./bin/bytebabe hello
./bin/bytebabe init

# Teste o modo interativo
./bin/bytebabe
```

### Lint (com shellcheck)
```bash
# Verificar um arquivo
shellcheck bin/bytebabe

# Verificar todos os scripts
find . -type f -name "*.sh" -exec shellcheck {} \;
```

## IDEs e Editores

### VSCode
Extensões recomendadas:
- Shell-format
- ShellCheck
- Bash Debug

### Neovim
Plugins recomendados:
- ale (para shellcheck)
- vim-shell-format
