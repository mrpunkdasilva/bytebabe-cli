# ByteBabe CLI

CLI em Bash 5 com tema cyberpunk. O runtime principal é `bin/bytebabe`, os comandos ficam em `commands/` e as bibliotecas em `lib/`.

## Validação obrigatória

```bash
bash -n bin/bytebabe install.sh
find commands lib tests -type f -name '*.sh' -print0 | xargs -0 -n1 bash -n
bash tests/scripts/run_unit_tests.sh
git diff --check
```

A suíte atual tem 236 testes em 19 arquivos. Atualize as contagens em `README.md`, `CHANGELOG.md`, `tests/README.md` e `spec/architecture/overview.md` quando adicionar ou remover testes.

## Contratos do projeto

- `commands/*.sh` MUST ser source-safe, expor `main` e só executar sob guard de `BASH_SOURCE`.
- Bibliotecas não devem produzir saída, pedir input, executar instalações ou chamar `exit` durante o source.
- `bin/bytebabe` carrega o comando e chama a função de entrada via `run_command`.
- Não usar `exit` em funções reutilizáveis; propague status com `return`.
- Evitar `eval`; usar arrays para argumentos.
- Código substituído vai para `archive/legacy/<area>/` com README, fora do runtime e do pacote.
- Não commitar, criar PR ou fazer push sem pedido explícito.

## Estilo

- Preserve a saída cyberpunk e o comportamento interativo existente.
- Mensagens de usuário e documentação em português; nomes de funções podem seguir o padrão já existente.
- Antes de editar, procure helpers canônicos no `lib/core/` e consumidores existentes.
- Mudanças de comportamento devem vir com teste de caracterização em `tests/unit/lib/` ou teste estrutural em `tests/unit/commands/`.

## Restrições

- Sem dependências de runtime novas.
- Docker, instalações e operações privilegiadas devem ser validadas com stubs quando possível.
- `lib/utils/get_docker.sh` é um instalador upstream executado intencionalmente, não uma biblioteca source-safe.
