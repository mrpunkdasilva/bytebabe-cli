# 🧪 Testes ByteBabe CLI

Esta pasta contém todos os testes automatizados para o ByteBabe CLI.

## 📁 Estrutura Atual

```
tests/
├── unit/                 # Testes unitários
│   └── commands/        # Testes dos comandos principais
│       ├── hello.test.sh
│       ├── init.test.sh
│       ├── backend.test.sh
│       ├── frontend.test.sh
│       ├── byteedit.test.sh
│       ├── db.test.sh
│       └── docker.test.sh
├── integration/         # Testes de integração (planejado)
├── e2e/               # Testes end-to-end (planejado)
├── fixtures/          # Dados de teste (planejado)
├── scripts/           # Scripts de teste (planejado)
└── reports/           # Relatórios de teste (planejado)
```

## 🚀 Como Executar

### Testes Unitários Individuais
```bash
# Executar testes específicos
bash tests/unit/commands/hello.test.sh
bash tests/unit/commands/init.test.sh
bash tests/unit/commands/backend.test.sh
bash tests/unit/commands/frontend.test.sh
bash tests/unit/commands/byteedit.test.sh
bash tests/unit/commands/db.test.sh
bash tests/unit/commands/docker.test.sh
```

### Executar Todos os Testes
```bash
# Executar todos os testes unitários
for test_file in tests/unit/commands/*.test.sh; do
    echo "Executando: $test_file"
    bash "$test_file"
    echo "---"
done
```

## 📊 Status dos Testes

### ✅ Testes Implementados
- **hello** - 10/10 testes passando
- **init** - 10/10 testes passando
- **backend** - 9/10 testes passando
- **frontend** - 10/10 testes passando
- **byteedit** - 10/10 testes passando
- **db** - 10/10 testes passando
- **docker** - 10/10 testes passando

### 🔄 Testes Pendentes
- **git** - Testes de controle de versão
- **gh** - Testes do GitHub CLI
- **devtools** - Testes de ferramentas de desenvolvimento
- **prime** - Testes de gerenciamento de sistema
- **flux** - Testes de API
- **ide** - Testes de gerenciamento de IDE
- **servers** - Testes de gerenciamento de servidores

## 🏗️ Estrutura dos Testes

Cada teste segue um padrão consistente:

### Setup
```bash
# Configuração do ambiente de teste
readonly BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
readonly TEST_TEMP_DIR="$(mktemp -d)"
readonly HOME="$TEST_TEMP_DIR"
```

### Testes Estruturais
- Verificação de existência do arquivo
- Verificação de permissões de execução
- Verificação de funções principais
- Verificação de imports necessários
- Verificação de estilo cyberpunk

### Testes Funcionais
- Verificação de funcionalidades específicas do comando
- Verificação de comandos e subcomandos
- Verificação de ajuda integrada

### Cleanup
```bash
# Limpeza após cada teste
rm -rf "$TEST_TEMP_DIR"
```

### Relatório
```bash
# Mostra resumo dos testes
echo "Total: $TOTAL_TESTS"
echo "Passou: $PASSED_TESTS"
echo "Falhou: $FAILED_TESTS"
```

## 🛠️ Ferramentas Utilizadas

- **Bash**: Scripts de teste nativos
- **grep**: Busca de padrões nos arquivos
- **test**: Verificações de arquivos e permissões
- **mktemp**: Criação de diretórios temporários

## 📝 Convenções

### Nomenclatura
- Arquivos de teste: `[comando].test.sh`
- Funções de teste: `test_[comando]_structure()`
- Variáveis: `TOTAL_TESTS`, `PASSED_TESTS`, `FAILED_TESTS`

### Estrutura de Teste
```bash
#!/bin/bash

# Configuração
set -euo pipefail

# Setup
setup() {
    mkdir -p "$HOME/.bytebabe"
}

# Testes
test_command_structure() {
    # Testes estruturais e funcionais
}

# Cleanup
cleanup() {
    rm -rf "$TEST_TEMP_DIR"
}

# Execução
main() {
    setup
    test_command_structure
    cleanup
    show_summary
}
```

## 🐛 Debugging

### Modo Verboso
```bash
# Executar com saída detalhada
bash -x tests/unit/commands/hello.test.sh
```

### Debug Individual
```bash
# Executar teste específico
bash tests/unit/commands/hello.test.sh
```

### Verificar Estrutura
```bash
# Verificar se arquivo existe
test -f commands/hello.sh

# Verificar se é executável
test -x commands/hello.sh

# Verificar conteúdo
grep -q "main()" commands/hello.sh
```

## 🤝 Contribuindo

### Criando Novos Testes
1. Crie arquivo `tests/unit/commands/[comando].test.sh`
2. Siga o padrão dos testes existentes
3. Inclua pelo menos 10 testes estruturais
4. Teste funcionalidades específicas do comando
5. Execute o teste para verificar funcionamento

### Padrão de Commit
```bash
git commit -m "test: add unit test for [comando] command

- Add structural unit test for [comando].sh
- Checks for file existence, executability, functions, imports and features
- Follows the same pattern as other command tests"
```

### Requisitos
- Todos os novos comandos devem ter testes unitários
- Manter padrão consistente entre todos os testes
- Incluir setup, cleanup e relatório
- Seguir Conventional Commits

## 📚 Recursos

- [Bash Testing Best Practices](https://github.com/kward/shunit2)
- [Shell Script Testing](https://www.shellscript.sh/test.html)
- [Conventional Commits](https://www.conventionalcommits.org/)

## 🎯 Próximos Passos

1. **Completar testes pendentes** para todos os comandos
2. **Criar script runner** para executar todos os testes
3. **Adicionar testes de integração** para fluxos completos
4. **Implementar relatórios** de cobertura
5. **Configurar CI/CD** com GitHub Actions 