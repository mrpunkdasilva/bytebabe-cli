# Tarefas — Refatoração incremental para eliminar duplicação e desacoplar o CLI

Convenção: todas as tarefas foram concluídas e verificadas. Nenhuma tarefa autoriza commit ou push sem solicitação explícita.

## Fase 0 — Baseline, testes e CI

- [x] Registrar baseline desta change: `bash -n` OK e suíte 91/91 em 9 arquivos.
- [x] Criar `tests/unit/lib/core_helpers.test.sh` com caracterização de `detect_pkg_manager`, `check_dependencies`, `show_spinner` e `choose_from_menu`.
- [x] Criar `tests/unit/lib/entrypoint.test.sh` para o contrato de source, `main` e ausência de `exit`/side effects ao carregar.
- [x] Criar `tests/unit/lib/flux_parser.test.sh` para parsing/validação de verbos e falhas de source.
- [x] Atualizar `tests/scripts/run_unit_tests.sh` para executar `tests/unit/lib/` além de `tests/unit/commands/`.
- [x] Criar `.github/workflows/validate.yml` com `bash -n` e `bash tests/scripts/run_unit_tests.sh` em push e pull request.
- [x] Garantir que o CI não exija rede, Docker ativo ou novas dependências de runtime.
- [x] Confirmar que a suíte continua em 100% com os testes de caracterização: 127/127 em 12 arquivos.
- [x] Portão da fase: baseline reproduzível e CI configurado.

## Fase 1 — Core: paths, package manager, UI, menu e feedback

- [x] Criar `lib/core/paths.sh` com resolução de symlinks, diretório de script e raiz do entrypoint.
- [x] Criar `lib/core/pkg.sh` e consolidar `detect_pkg_manager`, `_run_privileged`, `pkg_install`, `pkg_update` e `pkg_upgrade`.
- [x] Criar `lib/core/ui.sh` com headers/simples banner/seções; ícones permanecem em `colors.sh`.
- [x] Criar `lib/core/menu.sh` com uma única `choose_from_menu`.
- [x] Criar `lib/core/feedback.sh` com `show_spinner`/`show_loading` seguro para TTY e não TTY.
- [x] Manter `lib/core/helpers.sh` como fachada compatível e ampliar `lib/core/colors.sh` com a paleta legada.
- [x] Remover definições duplicadas de `detect_pkg_manager` de `commands/backend.sh`, `lib/devtools/api_services.sh`, `lib/devtools/terminal_services.sh`, `lib/devtools/browser_services.sh`, `lib/devtools/database_services.sh` e `lib/pkg/upgrade/main.sh`.
- [x] Remover definições duplicadas de `choose_from_menu` de `commands/git/main.sh`, `lib/git/commit.sh` e `lib/docker/containers.sh`.
- [x] Remover definições duplicadas de `show_spinner` de `commands/git/main.sh` e de `check_dependencies` de `lib/docker/containers.sh` (Docker usa `check_docker_dependencies`).
- [x] Remover redefinições/exportações de `CYBER_*` e headers locais em `bin/bytebabe`, `lib/docker/containers.sh`, `lib/git/ui.sh` e `lib/utils/headers.sh`, usando o core.
- [x] Adicionar/ajustar testes em `tests/unit/lib/{core_modules,core_helpers,pkg_consumers,ui_consumers}.test.sh`.
- [x] Rodar `bash -n` nos arquivos tocados e a suíte completa: 172/172 após o teste de brew; 177/177 após os testes da Fase 2.
- [x] Portão da fase: helpers canônicos únicos e nenhum chamador quebrado.
- [x] Mover deduplicação de cores/sources do Flux para a Fase 4 (`commands/flux.sh`, `lib/flux/request.sh` e `lib/flux/history.sh`).

## Fase 2 — Contrato de comandos e dispatch

- [x] Definir e documentar o contrato `main`/`<modulo>_main` em `spec/architecture/overview.md` e `spec/architecture/conventions.md`.
- [x] Padronizar `bin/bytebabe` para carregar o comando e chamar o entrypoint com `"$@"`, sem `source` que executa código por si só.
- [x] Ajustar `commands/*.sh` e `commands/git/main.sh`, `commands/backend/spring/main.sh` para não executar lógica principal no carregamento.
- [x] Garantir guarda de execução direta apenas quando necessária e sem duplicar dispatch.
- [x] Mover `check_docker_daemon` para dentro de `main` e corrigir o source de `templates.sh` do Spring.
- [x] Preservar aliases de topo, help/version e códigos `0`, `1` e `130`.
- [x] Ampliar `tests/unit/lib/entrypoint.test.sh` com carregamento sem efeitos colaterais e dispatch uniforme.
- [x] Ajustar testes estruturais de `tests/unit/commands/*.test.sh` quando o local de funções mudar.
- [x] Substituir `exit` remanescente em libs por `return` e retirar `clear`/`read`/menus de caminhos de source nos módulos das Fases 3–6 (Docker, Flux, Spring e Frontend).
- [x] Portão da fase: comandos não-Flux carregam e executam pelo mesmo contrato; `commands/flux.sh` permanece com correção de source na Fase 4.

## Fase 3 — Docker e archive da TUI legada

- [x] Inventariar `lib/docker/containers.sh`, `lib/docker/ui.sh`, `lib/docker/utils.sh`, `lib/docker/images.sh`, `lib/docker/volumes.sh` e `lib/docker/compose.sh`.
- [x] Consolidar header, menu, spinner, `check_docker_dependencies` e configuração de Docker em módulos únicos (`helpers.sh` e `ui.sh`).
- [x] Refatorar `lib/docker/containers.sh` para consumir a UI/config comum e conter apenas lógica de containers.
- [x] Garantir que comandos diretos de Docker funcionem sem menu e que ausência de Docker retorne erro sem `exit` na lib.
- [x] Substituir `exit` por `return` em `lib/docker/*` e usar `show_loading` do core em `utils.sh`.
- [x] Preservar confirmações de operações destrutivas (prune/remove).
- [x] Remover duplicatas de header/formatação/configuração; não restou UI legada isolada para arquivar.
- [x] Garantir que `archive/legacy/docker/` não seja referenciado por `bin/`, `commands/` ou `lib/`.
- [x] Atualizar `tests/unit/commands/docker.test.sh` e criar `tests/unit/lib/docker_modules.test.sh` para o novo contrato.
- [x] Atualizar `spec/modules/docker.md` e criar `spec/behavior/docker.feature`.
- [x] Portão da fase: uma única UI ativa e fluxos Docker testados (218/218).

## Fase 4 — Flux request engine

- [x] Corrigir `commands/flux.sh` para carregar `lib/flux/verbs/post/main.sh` em vez de `postFeature/main.sh`.
- [x] Remover/arquivar `lib/flux/verbs/postFeature/` em `archive/legacy/flux/postFeature/` com README.
- [x] Remover exportações/redefinições de `CYBER_*` em `commands/flux.sh`, `lib/flux/request.sh` e `lib/flux/history.sh`, usando o core.
- [x] Substituir `dirname "$0"` em `lib/flux/request.sh` por resolução via `BASE_DIR`.
- [x] Extrair pipeline único de parse, validação, execução, render e histórico para `lib/flux/engine.sh` (carregada por `request.sh`).
- [x] Transformar `lib/flux/verbs/{get,post,put,delete}/executor.sh` em adaptadores finos, sem repetir montagem/processamento de resposta.
- [x] Eliminar `eval` na montagem do `curl`; usar arrays e validação de URL/headers/body.
- [x] Garantir retorno `0` para HTTP 2xx/3xx, `1` para rede/validação/HTTP >= 400 e `130` para cancelamento.
- [x] Corrigir limpeza de arquivos temporários em sucesso, erro e cancelamento.
- [x] Eliminar validação/`exit` no carregamento de `lib/flux/request.sh` e dependências.
- [x] Criar/ampliar `tests/unit/lib/flux_parser.test.sh` (15 testes) e ajustar testes de comando.
- [x] Atualizar `spec/modules/flux.md` removendo gaps de source/histórico resolvidos.
- [x] Portão da fase: todos os verbos Flux funcionam sem erro de source e compartilham o mesmo engine (218/218).

## Fase 5 — Spring generators

- [x] Inventariar `lib/backend/spring/generators/*.sh` e `lib/backend/spring/generators/*_generator.sh` para mapear funções duplicadas.
- [x] Escolher o conjunto canônico já carregado por `lib/backend/spring/generators/main.sh` e eliminar implementações paralelas.
- [x] Corrigir sources ausentes no carregador de generators, incluindo a referência a `mapper.sh`.
- [x] Garantir que cada tipo (`entity`, `repository`, `service`, `controller`, `dto`, `mapper`, `exception-handler`, `security`) tenha uma única implementação ativa.
- [x] Substituir `exit` de validação em `lib/backend/spring/*` por retorno propagado ao comando.
- [x] Mover generators duplicados/substituídos para `archive/legacy/spring/generators/` com README.
- [x] Garantir que `archive/legacy/spring/` não seja carregado por `commands/backend/spring/main.sh`.
- [x] Atualizar `tests/unit/commands/backend.test.sh` e adicionar cobertura de geração quando viável sem projeto real.
- [x] Atualizar `spec/modules/backend.md`.
- [x] Portão da fase: nenhum source ausente e um generator por tipo (218/218).

## Fase 6 — Frontend generators

- [x] Inventariar `lib/frontend/generators.sh`, `lib/frontend/react/generators.sh`, `lib/frontend/vue/generators.sh` e `lib/frontend/angular/generators.sh`.
- [x] Consolidar `lib/frontend/generators.sh` como dispatcher canônico.
- [x] Manter adaptadores por framework sem repetir validação, detecção e dispatch.
- [x] Substituir `exit` de validação em `lib/frontend/main.sh` por retorno propagado ao comando.
- [x] Consumir detecção de package manager do core em criação/instalação de projetos.
- [x] Mover duplicatas substituídas para `archive/legacy/frontend/generators/` com README.
- [x] Garantir que `archive/legacy/frontend/` não seja carregado por `commands/frontend.sh`.
- [x] Atualizar `tests/unit/commands/frontend.test.sh`.
- [x] Atualizar `spec/modules/frontend.md` e `spec/behavior/frontend.feature` quando houver mudança observável.
- [x] Portão da fase: dispatch único e adaptadores por framework testados (218/218).

## Fase 7 — Validação, documentação e arquivamento da change

- [x] Atualizar `spec/architecture/overview.md` com camadas finais, dispatch, archive e cobertura de testes.
- [x] Atualizar `spec/architecture/conventions.md` com contratos de source, retorno em vez de `exit` e uso do core.
- [x] Atualizar `spec/modules/core.md`, `spec/modules/docker.md`, `spec/modules/flux.md`, `spec/modules/backend.md` e `spec/modules/frontend.md`.
- [x] Revisar `spec/behavior/init.feature` (sem mudança de contrato) e atualizar `frontend.feature`; `docker.feature` criado na Fase 3.
- [x] Atualizar `tests/README.md` para refletir `tests/unit/lib/`, o runner e o CI.
- [x] Atualizar README/CHANGELOG para a suíte de 218 testes e a refatoração; help global preservado.
- [x] Revisar `spec-delta.md` contra o estado final e ajustar rastreabilidade.
- [x] Revisar segurança: segredos, confirmações destrutivas, HTTPS, privilégios e ausência de `eval` no Flux.
- [x] Rodar suíte completa, `bash -n` e smoke tests manuais em `/tmp`.
- [x] Verificar que `archive/legacy/` não é carregado nem empacotado no runtime.
- [x] Mover a change para `spec/changes/archive/` com status `archived` somente após o Definition of Done.

## Testes

- [x] Criar/ampliar `tests/unit/lib/core_helpers.test.sh`.
- [x] Criar/ampliar `tests/unit/lib/entrypoint.test.sh`.
- [x] Criar/ampliar `tests/unit/lib/flux_parser.test.sh`.
- [x] Atualizar `tests/unit/lib/entrypoint.test.sh` para guardas, dispatch, source sem efeitos, `main` e `git`.
- [x] Atualizar `tests/unit/commands/docker.test.sh` e criar `tests/unit/lib/docker_modules.test.sh`.
- [x] Atualizar `tests/unit/commands/backend.test.sh` e `frontend.test.sh` quando o contrato mudar.
- [x] Adicionar testes de contrato para consumidores de pacotes e de UI (`pkg_consumers.test.sh`, `ui_consumers.test.sh`).
- [x] Manter todos os testes existentes passando (218/218).
- [x] Garantir que os testes sejam isolados, usem `mktemp` e não dependam de rede/Docker real quando possível.
- [x] Atingir cobertura igual ou superior ao baseline de 91 testes.

## Documentação

- [x] Atualizar `spec/architecture/overview.md` e `spec/architecture/conventions.md` com o contrato de comandos.
- [x] Atualizar specs dos módulos tocados.
- [x] Atualizar cenários BDD aplicáveis.
- [x] Atualizar README/help quando o comportamento público mudar.
- [x] Atualizar CHANGELOG quando a mudança for observável ao usuário.
- [x] Atualizar `tests/README.md`.
- [x] Revisar `spec-delta.md`.

## Verificação

Executar a partir da raiz do repositório:

```bash
find bin commands lib tests -type f -name '*.sh' -print0 | xargs -0 -n1 bash -n
bash tests/scripts/run_unit_tests.sh
bash tests/unit/lib/core_helpers.test.sh
bash tests/unit/lib/entrypoint.test.sh
bash tests/unit/lib/flux_parser.test.sh
```

Verificar definições duplicadas (esperado: apenas `lib/core/`):

```bash
grep -RInE '^[[:space:]]*(detect_pkg_manager|choose_from_menu|show_spinner|check_dependencies)[[:space:]]*\(\)' bin commands lib
```

Verificar sources inválidos/legados do Flux (esperado: nenhuma saída):

```bash
grep -RIn 'postFeature/main.sh' commands lib
grep -RIn 'dirname "\$0"' lib/flux
```

Verificar que o archive não é carregado (esperado: nenhuma saída):

```bash
grep -RIn 'archive/legacy' bin commands lib tests .github
```

Verificação manual:

```bash
cd /tmp
bytebabe --version
bytebabe help
bytebabe docker help
bytebabe flux help
bytebabe spring --help
bytebabe frontend help
```

- [x] `bash -n` sem erros.
- [x] Suíte 100% e sem regressão de contagem.
- [x] `bytebabe <comando>` funciona fora do repositório.
- [x] Nenhum segredo no diff.
- [x] `spec-delta.md` revisado.
- [x] Archive inacessível ao runtime.
