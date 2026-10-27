# Design — Refatoração incremental para eliminar duplicação e desacoplar o CLI

## Visão técnica

A refatoração é organizada em camadas com dependência unidirecional:

```text
bin/bytebabe
  └─ commands/*.sh            parsing e dispatch do módulo
       └─ lib/<dominio>/*.sh  regras do domínio
            └─ lib/core/*.sh  paths, pacotes, UI, menu, feedback, aliases
```

Princípios vinculantes:

- `lib/core/` é a única fonte de detecção de gerenciador de pacotes, cores, headers, menus, spinners e verificação de dependências.
- Carregar uma lib MUST NOT executar fluxo principal, abrir menu, limpar tela, ler entrada ou encerrar o processo.
- `commands/*.sh` expõem um entrypoint único e previsível; `bin/bytebabe` apenas resolve caminhos, carrega dependências, faz dispatch e trata help/version.
- Funções de lib retornam código de saída; apenas entrypoints de topo convertem erro/cancelamento em `exit`.
- Todo caminho interno deriva de `BASE_DIR`; nenhuma lib depende do diretório atual ou de `dirname "$0"` para localizar módulos.
- Código substituído é arquivado em `archive/legacy/<area>/`, fora do source path de produção e sem ser carregado pelo CLI.
- A compatibilidade pública (comandos, subcomandos, aliases, flags e códigos de saída) é preservada, salvo correção documentada no delta.

Durante a transição, wrappers de compatibilidade MAY existir para nomes antigos, mas MUST delegar para a implementação canônica e MUST ser removidos ou marcados como legado até a Fase 7.

## Arquivos afetados

| Arquivo | Mudança |
|---------|---------|
| `bin/bytebabe` | Dispatch uniforme, carregamento sem side effects e uso exclusivo de helpers de core |
| `lib/core/colors.sh` | Fonte única de cores; remover redefinições/exportações dos módulos |
| `lib/core/helpers.sh` | Manter helpers de pacote compatíveis e delegar para os módulos centrais |
| `lib/core/paths.sh` | **Previsto**: resolução/validação de `BASE_DIR` e caminhos internos |
| `lib/core/pkg.sh` | **Previsto**: `detect_pkg_manager`, `_run_privileged`, `pkg_install`, `pkg_update`, `pkg_upgrade` |
| `lib/core/ui.sh` | **Previsto**: headers, seções, mensagens e ícones padronizados |
| `lib/core/menu.sh` | **Previsto**: `choose_from_menu` único e retorno seguro |
| `lib/core/feedback.sh` | **Previsto**: `show_spinner`, loading e comportamento não interativo |
| `commands/backend.sh`, `lib/devtools/*.sh`, `lib/pkg/upgrade/main.sh`, `lib/utils/nvm.sh` | Remover definições locais de pacote e consumir o core |
| `commands/git/main.sh`, `lib/git/commit.sh`, `lib/docker/containers.sh` | Remover definições locais de menu/spinner/dependências e consumir o core |
| `commands/flux.sh` | Corrigir sources, remover cores locais e delegar ao request engine |
| `lib/flux/request.sh` | Resolver `history.sh` por `BASE_DIR` e abrigar o pipeline comum de requisição |
| `lib/flux/verbs/*/` | Adaptadores finos de método, parsing, validação e help sobre o engine comum |
| `lib/flux/verbs/postFeature/` | Arquivar conteúdo incompleto em `archive/legacy/flux/postFeature/`; não carregar |
| `lib/docker/containers.sh`, `lib/docker/ui.sh`, `lib/docker/utils.sh` | Consolidar header, menu, feedback, dependências e configuração em uma única UI |
| `lib/backend/spring/generators/main.sh` e generators | Um conjunto canônico por tipo; corrigir sources ausentes; arquivar duplicatas |
| `lib/frontend/generators.sh`, `lib/frontend/{react,vue,angular}/generators.sh` | Dispatch único com adaptadores por framework; arquivar duplicatas |
| `tests/unit/lib/core_helpers.test.sh` | Caracterização e regressão dos helpers de core |
| `tests/unit/lib/entrypoint.test.sh` | Contrato de source/dispatch e ausência de side effects |
| `tests/unit/lib/flux_parser.test.sh` | Parsing e validação do request engine |
| `tests/scripts/run_unit_tests.sh` | Executar também `tests/unit/lib/` e manter o resumo atual |
| `.github/workflows/validate.yml` | CI de `bash -n` e suíte em push/pull request |
| `archive/legacy/<area>/` | **Previsto**: código substituído, com README de origem, motivo e substituto |

## Contratos

### Source de bibliotecas

```text
Pré-condições:
  BASE_DIR definido e apontando para a raiz da instalação/repositório.
  Dependências de core carregadas antes das libs de domínio.

Regras:
  source lib/**/*.sh MUST apenas declarar variáveis e funções.
  source MUST NOT chamar main, exit, clear, read, choose_from_menu ou show_spinner.
  Variáveis globais MUST ser evitadas; quando necessárias, MUST ter nome de domínio.
  Constantes MUST usar readonly ou guarda de idempotência.
  Cores MUST vir de lib/core/colors.sh; nenhum módulo redefine CYBER_* ou RESET.
  Caminhos MUST derivar de BASE_DIR, nunca de "$0" ou do cwd.

Saída:
  Código 0 quando o source é válido.
  Código diferente de 0 somente para falha de dependência crítica, sem encerrar o shell chamador.
```

### Dispatch de comandos

```text
Entrada:
  bin/bytebabe <comando> [args...]

Fluxo:
  1. Resolver symlinks e BASE_DIR.
  2. Carregar core e aliases.
  3. Expandir alias de topo, se aplicável.
  4. Selecionar o comando na tabela case.
  5. Fazer source do entrypoint do comando.
  6. Invocar o entrypoint de forma uniforme com "$@".

Contrato dos entrypoints:
  commands/<modulo>.sh MUST definir main() ou <modulo>_main().
  O entrypoint MUST receber argumentos somente pela chamada do dispatch.
  O arquivo MUST NOT executar main ao ser carregado.
  Execução direta MAY ser suportada por guarda explícita, sem alterar o contrato do dispatch.
  Comando desconhecido MUST exibir ajuda do módulo e retornar 1; topo MUST preservar help global.

Saída:
  0    sucesso
  1    validação, dependência ausente ou comando inválido
  130  cancelamento pelo usuário
  Demais códigos somente quando o comando externo os definir e a spec documentar.
```

### Retorno em vez de exit

```text
Funções de lib MUST retornar o status ao chamador.
Funções de lib MUST NOT chamar exit, exceto guards de execução direta fora do fluxo de source.
Entrypoints de topo MAY converter o retorno em exit.
Fluxos destrutivos MUST preservar confirmação explícita antes da ação.
```

### Core de pacotes, UI, menu e feedback

```text
detect_pkg_manager()
  Saída: apt|dnf|yum|pacman|zypper|apk|unknown
  Sem efeitos colaterais; não instala nem atualiza.

pkg_install/pkg_update/pkg_upgrade
  Consomem _run_privileged; sudo apenas quando não root.
  Falha de pacote opcional MUST ser retornada, não encerrar o processo.

choose_from_menu <prompt> <outvar> <opções...>
  Retorno 0 em seleção, 1 em cancelamento/lista vazia.
  Seleção entregue via outvar; não deve depender de variável global oculta.
  Em modo não interativo MUST retornar 1 sem bloquear.

show_spinner <pid> <mensagem>
  MUST degradar para mensagem simples quando stdout não é TTY.
  MUST NOT mascarar o código de saída do processo observado.
```

### Flux request engine

```text
Entrada:
  flux get|post|put|delete <url> [params]
  flux history
  flux server [porta]

Pipeline único:
  parse → validate → build curl args (array, sem eval) → execute → parse response
  → render → save history → retorno

Contratos:
  commands/flux.sh MUST carregar apenas arquivos existentes.
  History MUST ser localizado via BASE_DIR.
  Cada verbo MUST fornecer método, regras de body/headers e help; execução e render são compartilhados.
  Saída: 0 para HTTP 2xx; 1 para erro de rede/validação ou HTTP >= 400; 130 para cancelamento.
  Nenhum token/header sensível MUST ser impresso ou persistido sem necessidade.
  Arquivo temporário MUST ser removido mesmo em erro.
```

### Docker TUI

```text
Entrada:
  docker containers|images|volumes|compose [subcomando] [flags]

Contratos:
  Uma única implementação de header, menu, spinner e check_dependencies.
  containers/images/volumes/compose MUST delegar a helpers comuns.
  Comandos diretos MUST funcionar sem menu.
  Sem Docker MUST exibir instrução e retornar 1, sem exit dentro da lib.
  UI legada substituída MUST ir para archive/legacy/docker/ e não ser carregada.
```

### Spring e Frontend generators

```text
Spring:
  Um único conjunto canônico em lib/backend/spring/generators/.
  O dispatcher MUST mapear tipo → função sem duplicar implementação.
  Sources MUST apontar apenas para arquivos existentes.
  Duplicatas *_generator.sh substituídas vão para archive/legacy/spring/generators/.

Frontend:
  lib/frontend/generators.sh MUST ser o dispatcher canônico.
  react|vue|angular/generators.sh MUST ser adaptadores específicos, sem repetir validação/dispatch.
  Detecção de package manager MUST usar o core.
  Duplicatas substituídas vão para archive/legacy/frontend/.
```

### Archive

```text
Caminho: archive/legacy/<area>/
Exemplos: archive/legacy/core/, archive/legacy/docker/, archive/legacy/flux/,
          archive/legacy/spring/, archive/legacy/frontend/

Cada área MUST ter README com:
  - caminho original;
  - motivo do arquivamento;
  - substituto canônico;
  - data e change de origem;
  - confirmação de que não é carregado pelo CLI.

archive/legacy/ MUST NOT estar no source path, no tarball de runtime ou no dispatch.
```

## Fluxo

```text
bin/bytebabe
  → resolve BASE_DIR
  → carrega core sem side effects
  → case de dispatch
  → source do command entrypoint
  → main "$@"
  → lib de domínio
  → core helpers
  → retorno 0/1/130
```

Migração por fase:

```text
Fase 0 baseline/testes/CI
  → Fase 1 core compartilhado
  → Fase 2 contrato de commands/dispatch
  → Fase 3 Docker + archive TUI
  → Fase 4 Flux request engine
  → Fase 5 Spring generators
  → Fase 6 Frontend generators
  → Fase 7 validação/docs/archive da change
```

Estado em `2026-10-26`: Fase 0 concluída. As fases 1 a 7 permanecem pendentes.

## Dependências

- Bash 4+ e utilitários já usados pelo projeto (`grep`, `sed`, `awk`, `mktemp`).
- `jq`/`curl` para Flux, preservando validação e mensagens atuais.
- Docker/Compose apenas nos fluxos Docker; ausência MUST ser tratada sem quebrar o shell.
- Nenhuma dependência nova de runtime.
- Bats não é adotado nesta change; a suíte Bash existente é ampliada.

## Compatibilidade

- Linux/WSL: manter comportamento atual; menus devem degradar ou ser evitados em execução não interativa.
- Distros: `apt`, `dnf`, `yum`, `pacman`, `zypper` e `apk` continuam suportados por um único detector.
- Comandos de topo, aliases (`dv`, `pm`, `gh`, `edit`, etc.), flags de help/version e códigos `0/1/130` MUST permanecer.
- Mudanças observáveis de saída ou de código de saída MUST ser registradas em `spec-delta.md` e, se afetarem uso, em README/CHANGELOG.
- A refatoração é interna; não há breaking change planejado. Wrappers temporários cobrem nomes internos ainda usados durante a migração.

## Segurança

- [x] Nenhum segredo exposto; tokens, headers sensíveis e credenciais não são logados nem persistidos desnecessariamente.
- [x] Comandos destrutivos preservam confirmação explícita (Docker prune/remove, Git force push, remoção de pacotes).
- [x] Downloads e scripts remotos continuam usando HTTPS e `curl -fsSL`/`wget -qO-` quando aplicável.
- [x] Privilégios mínimos: `_run_privileged` só usa `sudo` quando não root.
- [x] Flux não usa `eval` para montar comandos; argumentos são passados em array.
- [x] `archive/legacy/` não é carregado pelo CLI nem incluído no runtime.
- [x] Testes usam diretórios temporários e não dependem de rede quando possível.

## Testes

| Tipo | Cenário |
|------|---------|
| Unitário | `tests/unit/lib/core_helpers.test.sh` valida detecção de pacote, menu, spinner, dependências e ausência de side effects |
| Unitário | `tests/unit/lib/entrypoint.test.sh` valida contrato de source/dispatch, `main` sem execução no load e retorno em vez de `exit` |
| Unitário | `tests/unit/lib/flux_parser.test.sh` valida verbos, URL, headers/body, falhas de source e localização do histórico |
| Unitário | Testes de comando existentes em `tests/unit/commands/*.test.sh` continuam passando e são ajustados apenas quando o contrato mudar |
| Regressão | `bash tests/scripts/run_unit_tests.sh` mantém 100% com 218 testes em 18 arquivos |
| CI | `.github/workflows/validate.yml` executa `bash -n` e a suíte em push/pull request |
| BDD | `spec/behavior/init.feature` e `spec/behavior/frontend.feature` atualizados quando houver comportamento observável; `spec/behavior/docker.feature` cobre ajuda sem daemon, listagem não interativa e dependências ausentes |
| Manual | Executar `bytebabe help`, `--version`, `docker help`, `flux help`, `spring --help`, `frontend help` em `/tmp` e revisar menus interativos |

## Estratégia de migração

1. Congelar comportamento com testes e CI antes de mover código.
2. Introduzir core compartilhado mantendo wrappers locais temporários para não quebrar chamadores.
3. Migrar chamadores por domínio e verificar com `grep` que definições duplicadas sumiram.
4. Mover implementações substituídas para `archive/legacy/<area>/` no mesmo commit da migração.
5. Rodar `bash -n`, suíte e smoke tests manuais a cada fase.
6. Atualizar specs e delta ao final de cada fase para evitar documentação divergente.
