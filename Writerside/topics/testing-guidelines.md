# Testing Guidelines 🧪

## Testes Manuais

### 1. Comandos Básicos
```bash
# Testar versão
./bin/bytebabe --version

# Testar ajuda
./bin/bytebabe --help

# Testar comando hello
./bin/bytebabe hello
```

### 2. Fluxos Completos
```bash
# Testar inicialização
./bin/bytebabe init

# Testar configuração git
./bin/bytebabe git config

# Testar instalação de ferramentas
./bin/bytebabe devtools
```

## Checklist de Testes

### Pré-commit
- [ ] Verificar sintaxe (shellcheck)
- [ ] Testar comandos básicos
- [ ] Verificar mensagens de erro
- [ ] Testar modo interativo

### Pós-commit
- [ ] Testar em ambiente limpo
- [ ] Verificar dependências
- [ ] Testar instalação completa

## Ferramentas

### ShellCheck
```bash
# Verificar um arquivo
shellcheck commands/hello.sh

# Verificar diretório
shellcheck commands/*.sh

# Ignorar warnings específicos
# shellcheck disable=SC2034
```

### Debug Mode
```bash
# Ativar debug
set -x
./bin/bytebabe comando
set +x

# Ou usar flag -x
bash -x ./bin/bytebabe comando
```

## Best Practices

### 1. Ambiente de Testes
```bash
# Criar ambiente isolado
mkdir -p /tmp/bytebabe-test
cd /tmp/bytebabe-test

# Clonar repositório fresco
git clone https://github.com/mrpunkdasilva/bytebabe.git
```

### 2. Logs de Teste
```bash
# Registrar saída
./bin/bytebabe comando 2>&1 | tee test.log

# Analisar erros
grep "ERROR" test.log
```

### 3. Verificações
```bash
# Verificar permissões
test -x bin/bytebabe || echo "Erro: bytebabe não é executável"

# Verificar arquivos críticos
test -f commands/init.sh || echo "Erro: init.sh não encontrado"
```