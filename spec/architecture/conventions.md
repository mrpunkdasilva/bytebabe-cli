# Convenções de código e contribuição

## Normativos

- **MUST**: obrigatório; violação bloqueia release.
- **SHOULD**: recomendado; desvio exige justificativa.
- **MAY**: opcional.

## Bash

- Shebang MUST ser `#!/bin/bash`.
- Variáveis MUST ser citadas: `"$var"`, `"${array[@]}"`.
- Variáveis locais MUST usar `local` dentro de funções.
- Caminhos MUST ser derivados de `BASE_DIR`, nunca do diretório atual.
- Comandos MUST usar `command -v` para detectar dependências.
- Comparações numéricas MUST usar `(( ))`; strings MUST usar `[[ ]]`.
- Arrays MUST usar `mapfile`/`read -ra` em vez de `$(...)` sem controle.
- Funções MUST ter nomes em `snake_case` e prefixo de domínio quando necessário (`install_atuin`, `db_setup`).

## Estrutura de arquivos

- `commands/<modulo>.sh`: parsing de argumentos e dispatch do módulo.
- Todo comando MUST ser seguro para `source`, expor `main` e executá-lo apenas sob guarda `[[ "${BASH_SOURCE[0]}" == "$0" ]]`.
- `lib/<dominio>/*.sh`: implementação, instalação e UI específica.
- `bin/bytebabe`: somente resolução de caminho, bootstrap, help/version e tabela de dispatch.
- Novas dependências de um módulo MUST ser carregadas no próprio módulo, não no `bin/bytebabe`.

## Saída no terminal

- Cores MUST vir de `lib/core/colors.sh`.
- Informação: azul/verde; aviso: amarelo/laranja; erro: vermelho.
- Toda mensagem de erro SHOULD incluir causa e próximo passo.
- Modo não interativo MUST evitar `clear`, animações e `read` quando possível.
- ENTER de confirmação SHOULD ser omitido em execução direta.

## Retorno e source

- Bibliotecas MUST usar `return` para erros recuperáveis; `exit` MUST ficar restrito a entrypoints de topo.
- Bibliotecas MUST NOT executar menus, `clear` ou `read` no carregamento; interação pertence ao comando.
- `bin/bytebabe` MUST carregar comandos sem argumentos e chamar o entrypoint com `"$@"`.
- Dispatchers de domínio MUST validar e detectar contexto uma única vez; adaptadores MUST NOT duplicar essa lógica.
- Código em `archive/legacy/` MUST NOT ser carregado nem incluído no runtime.

## Códigos de saída

| Código | Uso |
|--------|-----|
| `0` | sucesso |
| `1` | erro de validação ou dependência ausente |
| `130` | cancelamento pelo usuário |

## Gerenciamento de pacotes

- Detectar com `detect_pkg_manager`.
- Para projetos JavaScript, detectar com `detect_node_pkg_manager` (npm, pnpm, yarn, bun; fallback npm).
- Instalar com `pkg_install`, atualizar com `pkg_update`/`pkg_upgrade`.
- Privilegios MUST ser aplicados por `_run_privileged`.
- `sudo` MUST NOT ser usado se o processo já roda como root.
- Falhas de pacotes opcionais SHOULD ser reportadas sem abortar o fluxo inteiro.

## Segurança

- Nunca imprimir tokens, senhas ou chaves.
- Nunca commitar `.env`, credenciais, `hosts.yml` ou arquivos de token.
- Comandos destrutivos MUST pedir confirmação explícita.
- Downloads MUST usar HTTPS e `curl -fsSL`/`wget -qO-`.
- Scripts remotos MUST ser piped apenas de URLs oficiais documentadas.

## Testes

- Todo novo comando SHOULD ter teste em `tests/unit/commands/<nome>.test.sh`.
- Testes MUST ser isolados e limpar diretórios temporários.
- Testes MUST funcionar sem rede quando possível.
- A suíte completa MUST rodar com `bash tests/scripts/run_unit_tests.sh`.
- Release MUST ter 100% dos testes passando.

## Documentação e spec

- Mudança de comportamento MUST atualizar a spec do módulo.
- Comando novo MUST aparecer em `bytebabe help` e em `spec/modules/`.
- Instalação ou release MUST atualizar `spec/architecture/installation.md`, README e CHANGELOG.
- Exemplos MUST ser testados antes do release.

## Commits

Seguir Conventional Commits:

- `feat:` nova funcionalidade
- `fix:` correção
- `test:` testes
- `docs:` documentação
- `refactor:` refatoração
- `chore:` manutenção/release
