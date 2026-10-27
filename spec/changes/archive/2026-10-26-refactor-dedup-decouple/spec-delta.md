# Delta de especificação — Refatoração incremental para eliminar duplicação e desacoplar o CLI

Este delta descreve o estado final implementado da change. Todos os arquivos citados existem no repositório e foram validados na Fase 7.

## Adicionado

### Requisitos

- `R-DEDUP-01`: o projeto MUST ter uma única definição canônica de `detect_pkg_manager`, `_run_privileged`, `pkg_install`, `pkg_update` e `pkg_upgrade` em `lib/core/`; módulos MUST consumir essa implementação.
- `R-DEDUP-02`: o projeto MUST ter uma única implementação canônica de `choose_from_menu`, `show_spinner`, `check_dependencies`, headers e feedback em `lib/core/`; duplicatas locais MUST ser removidas ou convertidas em wrappers documentados.
- `R-ARCH-01`: código substituído MUST ser movido para `archive/legacy/<area>/` com README de origem, motivo e substituto, e MUST NOT ser carregado pelo CLI nem incluído no runtime.
- `R-CMD-01`: todo comando de topo MUST seguir o mesmo contrato de source/dispatch, expondo `main` ou `<modulo>_main` e recebendo argumentos pela chamada do dispatch.
- `R-LIB-01`: nos módulos refatorados, carregar uma biblioteca MUST NOT executar `main`, `exit`, `clear`, `read`, menu ou spinner; funções de lib MUST retornar status ao chamador.
- `R-PATH-01`: caminhos internos MUST derivar de `BASE_DIR`, sem depender do diretório atual nem de `dirname "$0"`.
- `R-CORE-01`: cores, headers, mensagens e ícones MUST vir de `lib/core/`, sem redefinição/exportação de `CYBER_*` nos módulos.
- `R-DOCKER-01`: o módulo Docker MUST ter uma única UI para header, menu, feedback, dependências e configuração; containers, imagens, volumes e compose MUST compartilhar helpers comuns.
- `R-FLUX-01`: o Flux MUST carregar apenas sources existentes, localizar histórico via `BASE_DIR` e usar um pipeline comum de requisição para GET, POST, PUT e DELETE.
- `R-FLUX-02`: o Flux MUST NOT usar `eval` para montar comandos, MUST limpar arquivos temporários em todos os caminhos e MUST retornar `0` para 2xx, `1` para falha/HTTP >= 400 e `130` para cancelamento.
- `R-SPRING-01`: o Spring MUST ter um único conjunto ativo de generators por tipo, sem sources ausentes e sem implementações paralelas.
- `R-FRONT-01`: o Frontend MUST ter um dispatcher canônico de generators e adaptadores por framework sem duplicar validação/dispatch.
- `R-TEST-01`: a refatoração MUST ser protegida por testes de caracterização para core, entrypoint e Flux, além da suíte existente.
- `R-CI-01`: o repositório MUST ter CI que execute `bash -n` e a suíte de testes em push e pull request.
- `R-COMPAT-01`: comandos, subcomandos, aliases, flags de help/version e códigos `0`, `1` e `130` MUST permanecer compatíveis; mudanças observáveis MUST ser documentadas.
- `R-SEC-01`: a refatoração MUST preservar confirmações destrutivas, não expor segredos, usar HTTPS em downloads e aplicar privilégios mínimos.
- `R-DOC-01`: specs de arquitetura, módulos, BDD, testes e delta MUST refletir o estado final após a Fase 7.

### Comandos

Nenhum comando novo de topo é adicionado. Comportamentos existentes (`docker`, `flux`, `spring`, `frontend`, `backend`, `git`, `devtools`, `db`, `alias`, `init`, help/version) MUST continuar disponíveis.

### Arquivos e contratos internos

- `lib/core/paths.sh`, `lib/core/pkg.sh`, `lib/core/ui.sh`, `lib/core/menu.sh`, `lib/core/feedback.sh`: módulos centrais sem side effects.
- `tests/unit/lib/core_helpers.test.sh`, `entrypoint.test.sh`, `flux_parser.test.sh`, `docker_modules.test.sh`, `spring_generators.test.sh`, `frontend_generators.test.sh`: caracterização e regressão.
- `.github/workflows/validate.yml`: CI de sintaxe e suíte.
- `archive/legacy/{flux,spring,frontend}/`: armazenamento rastreável de código substituído, fora do source path.

## Modificado

### Requisitos

- `R-CORE-HELPERS` (atual em [spec/modules/core.md](../../../modules/core.md)): helpers de pacote e UI deixam de ser definidos por cada módulo e passam a ser canônicos em `lib/core/`.
- `R-DOCKER-UI` (atual em [spec/modules/docker.md](../../../modules/docker.md)): uma UI única substitui as implementações concorrentes de `containers.sh`, `ui.sh` e `utils.sh`.
- `R-FLUX-SOURCES` (atual em [spec/modules/flux.md](../../../modules/flux.md)): o gap de `postFeature/main.sh` e o fallback por `dirname "$0"` deixam de existir.
- `R-SPRING-GENERATORS` (atual em [spec/modules/backend.md](../../../modules/backend.md)): generators passam a ter uma única implementação ativa por tipo.
- `R-FRONTEND-GENERATORS` (atual em [spec/modules/frontend.md](../../../modules/frontend.md)): dispatch e lógica compartilhada passam a ser únicos, com adaptadores por framework.
- `R-ARCH-DISPATCH` (atual em [spec/architecture/overview.md](../../../architecture/overview.md)): a tabela de dispatch passa a declarar explicitamente o entrypoint e o contrato de chamada de cada comando.
- `R-CONV-SOURCE` (atual em [spec/architecture/conventions.md](../../../architecture/conventions.md)): novas regras normativas para source sem side effects, retorno em vez de `exit` e uso de `BASE_DIR`.

### Comportamento

- Carregar `commands/*.sh` ou `lib/**/*.sh` deixa de abrir menu, limpar tela, ler entrada ou encerrar o processo.
- Comandos de topo passam a ser carregados e chamados de forma uniforme por `bin/bytebabe`.
- Falhas recuperáveis em libs retornam código ao chamador; apenas entrypoints de topo encerram o processo.
- Flux passa a compartilhar execução/render/histórico e a retornar código consistente com o resultado HTTP/rede.
- Docker deixa de duplicar header, menu, spinner e verificação de dependências.
- Código duplicado substituído deixa de estar ativo e passa a residir em `archive/legacy/`.
- A suíte passa a cobrir helpers de core, entrypoint e parser do Flux, além dos testes estruturais existentes.

## Removido

- `R-FLUX-POSTFEATURE`: referência a `lib/flux/verbs/postFeature/main.sh` como source ativo; o conteúdo incompleto é arquivado em `archive/legacy/flux/postFeature/`.
- `R-DOCKER-DUP`: definições duplicadas de header, menu, spinner, `check_dependencies` e configuração dentro de `lib/docker/containers.sh`; a implementação canônica permanece uma só.
- `R-GENERATOR-DUP`: implementações paralelas de generators Spring e Frontend; as substituídas são arquivadas, não mantidas ativas.
- `R-EVAL-FLUX`: montagem de comando por `eval` no Flux; substituída por invocação segura com arrays.
- `R-SOURCE-SIDEEFFECT`: execução automática de `main`/`exit`/`clear`/`read` ao carregar bibliotecas.

## Impacto em specs existentes

| Spec | Mudança |
|------|---------|
| [spec/architecture/overview.md](../../../architecture/overview.md) | Atualizar camadas, tabela de dispatch, contrato de entrypoint, archive e cobertura de testes |
| [spec/architecture/conventions.md](../../../architecture/conventions.md) | Adicionar regras de source sem side effects, retorno em vez de `exit`, `BASE_DIR` e uso do core |
| [spec/modules/core.md](../../../modules/core.md) | Documentar helpers canônicos de paths, pacotes, UI, menu e feedback |
| [spec/modules/docker.md](../../../modules/docker.md) | Documentar UI única, fluxos não interativos e remoção de duplicatas |
| [spec/modules/flux.md](../../../modules/flux.md) | Remover gaps de source/histórico, documentar request engine e códigos de retorno |
| [spec/modules/backend.md](../../../modules/backend.md) | Documentar conjunto canônico de generators Spring e correção de sources |
| [spec/modules/frontend.md](../../../modules/frontend.md) | Documentar dispatcher canônico e adaptadores por framework |
| [spec/behavior/init.feature](../../../behavior/init.feature) | Ajustar cenário apenas se o contrato de init ou helpers mudar |
| [spec/behavior/docker.feature](../../../behavior/docker.feature) | Cenários de ajuda sem daemon, listagem não interativa e dependências ausentes |
| [spec/behavior/frontend.feature](../../../behavior/frontend.feature) | Atualizar cenário de geração se o dispatch mudar |
| [tests/README.md](../../../../tests/README.md) | Documentar `tests/unit/lib/` e o runner ampliado |
| [tests/scripts/run_unit_tests.sh](../../../../tests/scripts/run_unit_tests.sh) | Incluir `tests/unit/lib/` na execução e no resumo |
| `spec/product/prd.md` | Sem mudança de produto prevista; atualizar somente se algum critério de aceite de produto for afetado |

## Rastreabilidade

| Requisito | Teste | Cenário BDD |
|-----------|-------|-------------|
| `R-DEDUP-01` | `tests/unit/lib/core_helpers.test.sh`; `tests/unit/commands/init.test.sh`; `tests/unit/commands/backend.test.sh` | [spec/behavior/init.feature](../../../behavior/init.feature) |
| `R-DEDUP-02` | `tests/unit/lib/core_helpers.test.sh`; `tests/unit/commands/docker.test.sh`; `tests/unit/commands/git.test.sh` | — |
| `R-ARCH-01` | Verificação `grep -RIn 'archive/legacy' bin commands lib tests .github`; `tests/unit/lib/entrypoint.test.sh`; remoção de `archive/` no `install.sh` | — |
| `R-CMD-01` | `tests/unit/lib/entrypoint.test.sh`; `tests/unit/commands/*.test.sh` | — |
| `R-LIB-01` | `tests/unit/lib/entrypoint.test.sh`; `tests/unit/lib/core_helpers.test.sh` | — |
| `R-PATH-01` | `tests/unit/lib/entrypoint.test.sh`; `tests/unit/lib/flux_parser.test.sh` | — |
| `R-CORE-01` | `tests/unit/lib/core_helpers.test.sh` | — |
| `R-DOCKER-01` | `tests/unit/commands/docker.test.sh`; `tests/unit/lib/docker_modules.test.sh` | [spec/behavior/docker.feature](../../../behavior/docker.feature) |
| `R-FLUX-01` | `tests/unit/lib/flux_parser.test.sh` | — |
| `R-FLUX-02` | `tests/unit/lib/flux_parser.test.sh` | — |
| `R-SPRING-01` | `tests/unit/commands/backend.test.sh`; `tests/unit/lib/spring_generators.test.sh` | — |
| `R-FRONT-01` | `tests/unit/commands/frontend.test.sh`; `tests/unit/lib/frontend_generators.test.sh` | [spec/behavior/frontend.feature](../../../behavior/frontend.feature) |
| `R-TEST-01` | `tests/scripts/run_unit_tests.sh` com 18 arquivos e 218 testes | — |
| `R-CI-01` | `.github/workflows/validate.yml` | — |
| `R-COMPAT-01` | `tests/unit/lib/entrypoint.test.sh`; `tests/unit/commands/*.test.sh`; verificação manual de help/version | — |
| `R-SEC-01` | Revisão de segurança da Fase 7; `tests/unit/lib/flux_parser.test.sh` para ausência de `eval` | — |
| `R-DOC-01` | Revisão de `spec-delta.md`; atualização das specs listadas acima | — |

## Observações de consistência

- `tests/unit/commands/git.test.sh` já existe e cobre o módulo Git de forma estrutural; ele é mantido como regressão, não como substituto dos testes de contrato.
- `spec/behavior/flux.feature` não existe hoje; por isso os requisitos de Flux são rastreados pelo teste de caracterização, sem criar link para arquivo inexistente nesta change.
- Os caminhos em `archive/legacy/` estão especializados por área: `flux`, `spring` e `frontend`. No Docker não restou UI legada isolada para arquivar.
- O baseline de 91 testes foi ampliado para 218 testes em 18 arquivos (101 estruturais e 117 de caracterização); a suíte completa é o portão de regressão.
