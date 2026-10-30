# 🧪 Testes ByteBabe CLI

Esta pasta contém todos os testes automatizados para o ByteBabe CLI.

## Estrutura Atual

```text
tests/
├── lib/                   # Helpers compartilhados
│   └── test_helpers.sh
├── scripts/
│   └── run_unit_tests.sh  # Runner de todos os testes
└── unit/
    ├── commands/          # Testes estruturais dos comandos
    └── lib/               # Testes de caracterização de lib/entrypoint
        ├── core_helpers.test.sh
        ├── core_modules.test.sh
        ├── docker_modules.test.sh
        ├── entrypoint.test.sh
        ├── flux_parser.test.sh
        ├── frontend_generators.test.sh
        ├── pkg_consumers.test.sh
        ├── source_safety.test.sh
        ├── spring_generators.test.sh
        └── ui_consumers.test.sh
```

## Como Executar

### Suíte completa

```bash
bash tests/scripts/run_unit_tests.sh
```

### Opções do runner

```bash
bash tests/scripts/run_unit_tests.sh --list
bash tests/scripts/run_unit_tests.sh --test hello
bash tests/scripts/run_unit_tests.sh --test core_helpers
bash tests/scripts/run_unit_tests.sh --verbose
```

### Testes individuais

```bash
bash tests/unit/lib/core_helpers.test.sh
bash tests/unit/lib/entrypoint.test.sh
bash tests/unit/lib/flux_parser.test.sh
bash tests/unit/commands/hello.test.sh
```

## Status dos Testes

Estado em 2026-10-26:

- 19 arquivos de teste.
- 240 testes, todos passando.
- 101 testes estruturais em `tests/unit/commands/`.
- 139 testes de caracterização em `tests/unit/lib/`.

Cobertura atual por arquivo:

- **commands**: backend, byteedit, db, docker, frontend, git, hello, init, prime.
- **lib**: core helpers, módulos de core, Docker não interativo, entrypoint, parser/validador Flux, geradores Spring/Frontend, consumidores de pacotes, consumidores de UI e source-safety.
- **CI**: `.github/workflows/validate.yml` executa `bash -n` e a suíte em push e pull request.

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

### Testes de Caracterização

Os testes em `tests/unit/lib/` usam `tests/lib/test_helpers.sh`:

```bash
source "$TEST_DIR/../../lib/test_helpers.sh"

run_test_case "descrição" minha_funcao_de_teste
show_test_summary
```

Helpers disponíveis: `setup_test_env`, `cleanup_test_env`, `stub_command`,
`assert_eq`, `assert_contains`, `assert_not_contains`, `assert_matches`,
`assert_success`, `assert_failure`, `run_test_case` e `show_test_summary`.

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

## Ferramentas Utilizadas

- **Bash**: Scripts de teste nativos.
- **grep**: Busca de padrões nos arquivos.
- **test**: Verificações de arquivos e permissões.
- **mktemp**: Criação de diretórios temporários.
- **timeout**: Limite de execução para smoke tests do entrypoint.
- **GitHub Actions**: CI de sintaxe e suíte completa.

## Convenções

### Nomenclatura
- Arquivos de teste: `[comando].test.sh`.
- Funções de teste: `test_[comando]_structure()` ou `test_[comportamento]()`.
- Variáveis: `TOTAL_TESTS`, `PASSED_TESTS`, `FAILED_TESTS`.
- Helpers compartilhados ficam em `tests/lib/`; testes de lib em `tests/unit/lib/`.

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
test -f commands/hello/main.sh

# Verificar se é executável
test -x commands/hello/main.sh

# Verificar conteúdo
grep -q "main()" commands/hello/main.sh
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

## Próximos Passos

1. Ampliar testes de caracterização durante a refatoração de core, Docker, Flux, Spring e Frontend.
2. Adicionar testes de integração para fluxos completos sem depender de rede, Docker ou Flatpak.
3. Avaliar cobertura por módulo e relatório de testes.
4. Manter o CI de sintaxe e suíte como portão obrigatório em pull requests.