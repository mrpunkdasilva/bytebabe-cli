# 🧪 Testes ByteBabe CLI

Esta pasta contém todos os testes automatizados e manuais para o ByteBabe CLI.

## 📁 Estrutura

```
tests/
├── unit/                 # Testes unitários
│   ├── commands/        # Testes dos comandos
│   ├── lib/            # Testes das bibliotecas
│   └── utils/          # Testes utilitários
├── integration/         # Testes de integração
│   ├── docker/         # Testes Docker
│   ├── database/       # Testes de banco
│   └── api/           # Testes de API
├── e2e/               # Testes end-to-end
│   ├── workflows/     # Fluxos completos
│   └── scenarios/     # Cenários específicos
├── fixtures/          # Dados de teste
│   ├── configs/       # Configurações
│   ├── data/          # Dados mock
│   └── responses/     # Respostas esperadas
├── scripts/           # Scripts de teste
│   ├── setup.sh       # Setup do ambiente
│   ├── teardown.sh    # Limpeza do ambiente
│   └── helpers.sh     # Funções auxiliares
└── reports/           # Relatórios de teste
    ├── coverage/      # Cobertura de código
    ├── junit/         # Relatórios JUnit
    └── html/          # Relatórios HTML
```

## 🚀 Como Executar

### Testes Unitários
```bash
# Executar todos os testes unitários
./tests/scripts/run_unit_tests.sh

# Executar testes específicos
./tests/scripts/run_unit_tests.sh commands/hello
```

### Testes de Integração
```bash
# Executar testes de integração
./tests/scripts/run_integration_tests.sh

# Executar com Docker
./tests/scripts/run_integration_tests.sh --docker
```

### Testes E2E
```bash
# Executar testes end-to-end
./tests/scripts/run_e2e_tests.sh

# Executar cenário específico
./tests/scripts/run_e2e_tests.sh --scenario=init
```

### Todos os Testes
```bash
# Setup inicial (uma vez)
./tests/scripts/setup.sh

# Executar todos os testes
./tests/scripts/run_all_tests.sh

# Executar com relatórios
./tests/scripts/run_all_tests.sh --reports --verbose

# Apenas linting
./tests/scripts/run_all_tests.sh --lint

# Testes específicos
./tests/scripts/run_all_tests.sh --skip-e2e
```

## 🛠️ Ferramentas Utilizadas

- **BATS**: Framework de testes para Bash
- **ShellCheck**: Linting de código Shell
- **Docker**: Containers para testes isolados
- **GitHub Actions**: CI/CD automatizado

## 📊 Relatórios

Os relatórios são gerados automaticamente em:
- `tests/reports/coverage/` - Cobertura de código
- `tests/reports/junit/` - Relatórios JUnit XML
- `tests/reports/html/` - Relatórios HTML interativos

## 🔧 Configuração

### Variáveis de Ambiente
```bash
# Configurar ambiente de teste
export BYTEBABE_TEST_MODE=true
export BYTEBABE_TEST_DATA_DIR=tests/fixtures/data
export BYTEBABE_TEST_REPORTS_DIR=tests/reports
```

### Arquivo de Configuração
```bash
# tests/config/test.env
BYTEBABE_TEST_TIMEOUT=30
BYTEBABE_TEST_RETRIES=3
BYTEBABE_TEST_VERBOSE=true
```

## 📝 Convenções

### Nomenclatura
- Arquivos de teste: `*.test.sh`
- Arquivos de fixture: `*.fixture.json`
- Scripts auxiliares: `*.helper.sh`

### Estrutura de Teste
```bash
#!/usr/bin/env bats

setup() {
    # Setup do teste
}

teardown() {
    # Limpeza do teste
}

@test "descrição do teste" {
    # Implementação do teste
}
```

## 🐛 Debugging

### Modo Verboso
```bash
./tests/scripts/run_unit_tests.sh --verbose
```

### Debug Individual
```bash
# Executar teste específico com debug
bats --verbose-run tests/unit/commands/hello.test.sh
```

### Logs de Teste
```bash
# Ver logs detalhados
tail -f tests/reports/test.log
```

## 🤝 Contribuindo

1. Escreva testes para novas funcionalidades
2. Mantenha cobertura de código > 80%
3. Execute testes antes de fazer commit
4. Atualize documentação quando necessário

## 📚 Recursos

- [BATS Documentation](https://github.com/bats-core/bats-core)
- [ShellCheck Documentation](https://www.shellcheck.net/)
- [Testing Guidelines](../docs/testing-guidelines.html) 