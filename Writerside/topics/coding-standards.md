# Coding Standards

## Estilo de Código

### Shell Script Guidelines
```bash
# ✅ Bom
function install_package() {
    local package_name="$1"
    if ! command -v "$package_name" &> /dev/null; then
        echo "Instalando $package_name..."
    fi
}

# ❌ Evitar
function installPackage {
    packageName=$1
    which $packageName > /dev/null
    if [ $? -ne 0 ]; then
        echo "Instalando $packageName..."
    fi
}
```

### Nomenclatura
- Funções: `snake_case`
- Variáveis: `snake_case`
- Constantes: `SCREAMING_SNAKE_CASE`
- Arquivos: `kebab-case.sh`

## Organização de Código

### Estrutura de Arquivos
```bash
# Módulos separados por funcionalidade
commands/
  ├── hello.sh
  ├── init.sh
  └── git/
      ├── main.sh
      └── utils.sh
```

### Imports
```bash
# Carregar dependências
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$BASE_DIR/lib/common.sh"
source "$BASE_DIR/lib/utils.sh"
```

## Documentação

### Headers
```bash
#!/bin/bash
#
# Nome do Script: hello.sh
# Descrição: Implementa o comando hello do ByteBabe
# Uso: bytebabe hello [nome]
#
# Argumentos:
#   $1 - Nome do usuário (opcional)
```

## Boas Práticas

### Error Handling
```bash
# ✅ Bom
if ! command -v docker &> /dev/null; then
    echo "Erro: Docker não encontrado"
    exit 1
fi

# ❌ Evitar
docker ps
if [ $? -ne 0 ]; then
    echo "Erro"
    exit 1
fi
```

### Variáveis
```bash
# ✅ Bom
local user_name="${1:-}"
readonly MAX_RETRIES=3

# ❌ Evitar
name=$1
MAXRETRIES=3
```