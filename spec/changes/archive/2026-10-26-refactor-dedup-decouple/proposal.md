# Proposta — Refatoração incremental para eliminar duplicação e desacoplar o CLI

| Campo | Valor |
|-------|-------|
| ID | `2026-10-26-refactor-dedup-decouple` |
| Status | `archived` |
| Autor | ByteBabe CLI team |
| Data | `2026-10-26` |
| Módulos afetados | Core, Docker, Flux, Spring/Backend, Frontend, Git, DevTools, Database, testes e CI |
| Issues relacionadas | Plano de refatoração aprovado da Fase 0; sem issue externa vinculada |

## Problema

O CLI Bash acumulou duplicação e acoplamento que tornam cada correção arriscada e aumentam a chance de comportamento divergente entre comandos. Os casos concretos identificados no baseline são:

- `detect_pkg_manager` definido em 7 arquivos: `lib/core/helpers.sh`, `commands/backend.sh`, `lib/devtools/api_services.sh`, `lib/devtools/terminal_services.sh`, `lib/devtools/browser_services.sh`, `lib/devtools/database_services.sh` e `lib/pkg/upgrade/main.sh`.
- `choose_from_menu` definido em 3 arquivos: `commands/git/main.sh`, `lib/git/commit.sh` e `lib/docker/containers.sh`.
- `show_spinner` definido em 2 arquivos: `lib/core/helpers.sh` e `commands/git/main.sh`.
- `check_dependencies` definido em 2 arquivos: `lib/core/helpers.sh` e `lib/docker/containers.sh`.
- Cores, headers, mensagens de erro e animações repetidos em `bin/bytebabe`, `commands/flux.sh`, `lib/flux/request.sh`, `lib/docker/containers.sh`, `lib/docker/ui.sh` e `lib/utils/headers.sh`, inclusive com redefinição/exportação de `CYBER_*` fora de `lib/core/colors.sh`.
- Docker com UI duplicada e misturada à lógica de containers: `lib/docker/containers.sh` redefine header, menu, dependências e configuração já presentes em `lib/docker/ui.sh`, `lib/docker/utils.sh` e demais arquivos do domínio.
- Flux com sources inexistentes ou frágeis: `commands/flux.sh` carrega `lib/flux/verbs/postFeature/main.sh`, que não existe; `lib/flux/request.sh` resolve `history.sh` por `dirname "$0"`; os executores de GET, POST, PUT e DELETE repetem o mesmo fluxo de requisição.
- Spring com dois conjuntos de generators (`lib/backend/spring/generators/*.sh` e `*_generator.sh`), além de sources para arquivos ausentes no carregador de generators.
- Frontend com generators gerais e por framework duplicando dispatch e lógica em `lib/frontend/generators.sh`, `lib/frontend/react/generators.sh`, `lib/frontend/vue/generators.sh` e `lib/frontend/angular/generators.sh`.
- Comandos com contratos de dispatch inconsistentes: `bin/bytebabe` às vezes executa `main` depois do source, às vezes depende de o arquivo executar código ao ser carregado e às vezes passa argumentos ao próprio `source`.
- Bibliotecas com efeitos colaterais ao serem carregadas, incluindo `exit`, `clear`, menus e alteração de variáveis globais, o que impede testes isolados e reutilização segura.

## Motivação

Sem uma base compartilhada, cada novo comando copia helpers e UI, os testes precisam conhecer detalhes estruturais de cada arquivo e bugs de um módulo não são corrigidos nos demais. O Flux já apresenta falhas de carregamento e o Docker/Spring/Frontend dificultam manutenção por terem implementações concorrentes. Resolver agora reduz regressões, permite testes de caracterização confiáveis e cria condições para evoluir o CLI sem reescrita ampla.

## Baseline

Medições realizadas em `2026-10-26`, na branch `refactor/decouple-duplication`:

- `bash -n` em `bin/`, `commands/`, `lib/` e `tests/`: OK, sem erros de sintaxe.
- `bash tests/scripts/run_unit_tests.sh`: 91/91 testes passando, em 9 arquivos.
- Os testes atuais são majoritariamente estruturais, baseados em `grep` por funções, imports e strings; há pouca verificação comportamental.
- Não existe workflow de CI dedicado a executar `bash -n` e a suíte de testes. Os workflows existentes cobrem changelog, publicação NPM e documentação.

Após a Fase 0, em `2026-10-26`:

- `bash -n` em `bin/`, `commands/`, `lib/` e `tests/`: OK.
- `bash tests/scripts/run_unit_tests.sh`: 127/127 testes passando, em 12 arquivos.
- Testes de caracterização adicionados em `tests/unit/lib/` para core, entrypoint e Flux.
- Runner ampliado para `tests/unit/commands/` e `tests/unit/lib/`.
- `.github/workflows/validate.yml` adicionado para `bash -n` e suíte em push/pull request.

Após a Fase 7, em `2026-10-26`:

- `bash -n` em `bin/`, `commands/`, `lib/` e `tests/`: OK.
- `bash tests/scripts/run_unit_tests.sh`: 218/218 testes passando, em 18 arquivos (101 estruturais e 117 de caracterização).
- Smoke tests de `help`, `--version`, Docker, Flux, Frontend e Spring: OK sem daemon de Docker.
- `archive/legacy/` sem referências no runtime e removido do destino pelo instalador local.

## Escopo

### Incluído

- **Fase 0 — Baseline, testes e CI**: registrar o baseline, criar testes de caracterização para core, entrypoint e Flux, ajustar o runner e adicionar CI de `bash -n` + suíte.
- **Fase 1 — Core**: unificar caminhos, detecção de gerenciador de pacotes, UI, menus e feedback em `lib/core/`.
- **Fase 2 — Contrato de comandos e dispatch**: padronizar entrypoints e `bin/bytebabe`, remover side effects ao carregar e substituir `exit` em libs por retorno.
- **Fase 3 — Docker e archive da TUI legada**: consolidar UI de Docker e remover duplicatas de containers; não restou UI legada isolada para arquivar.
- **Fase 4 — Flux request engine**: corrigir sources inexistentes, centralizar parsing/validação/execução/histórico e transformar verbos em adaptadores finos.
- **Fase 5 — Spring generators**: consolidar um único conjunto de generators, corrigir sources ausentes e arquivar duplicatas em `archive/legacy/spring/`.
- **Fase 6 — Frontend generators**: consolidar dispatch e generators, manter adaptadores por framework e arquivar duplicatas em `archive/legacy/frontend/`.
- **Fase 7 — Validação e documentação**: atualizar specs, README/CHANGELOG quando houver mudança observável, ampliar testes e validar o fluxo completo.

### Não incluído

- Tradução geral do projeto para inglês.
- Reescrita completa da suíte para Bats.
- Novas dependências de runtime.
- Refatoração ampla de módulos não tocados pelo plano.
- Mudança de identidade visual cyberpunk ou redesenho de comandos fora do escopo de desacoplamento.
- Remoção definitiva de código legado; o plano usa arquivamento rastreável.

## Solução proposta

Executar a refatoração de forma incremental por camadas: primeiro congelar o comportamento com testes de caracterização e CI; depois criar helpers centrais sem side effects; em seguida padronizar o contrato de source/dispatch e migrar Docker, Flux, Spring e Frontend um domínio por vez. Código substituído é movido para `archive/legacy/<area>/` com referência de origem e substituto, nunca removido sem rastro. Bugs acoplados encontrados durante a migração MUST ser corrigidos na mesma fase e cobertos por teste, desde que não ampliem o escopo para módulos não tocados.

## Alternativas consideradas

| Alternativa | Prós | Contras | Decisão |
|-------------|------|---------|---------|
| Refatoração big bang em uma única entrega | Consistência imediata; menos adaptadores temporários | Alto risco de regressão; difícil revisar; bloqueia correções urgentes | Rejeitada |
| Manter a duplicação e corrigir apenas bugs pontuais | Menor esforço inicial | Custo recorrente; bugs divergentes; testes frágeis | Rejeitada |
| Reescrever toda a suíte em Bats antes da refatoração | Assertivas melhores; isolamento | Introduz dependência/escopo novo e atrasa a redução de duplicação | Adiada; testes de caracterização em Bash cobrem a migração |
| Remover imediatamente todo código duplicado/morto | Base menor rapidamente | Perda de referência e maior risco em fluxos pouco testados | Rejeitada; usar `archive/legacy/` |
| Refatoração incremental por camadas com testes primeiro | Risco controlado; revisão por fase; compatibilidade preservada | Trabalho temporário de adaptadores e documentação | **Aprovada** |

## Riscos

| Risco | Impacto | Mitigação |
|-------|---------|-----------|
| Regressão em menus e fluxos interativos | Alto | Testes de caracterização, execução não interativa, checklist manual em `/tmp` e comparação de saída |
| Ordem de carregamento e variáveis globais quebrarem comandos | Alto | Contrato explícito de source, `BASE_DIR` resolvido uma vez, testes de entrypoint e wrappers temporários |
| Testes estruturais atuais ficarem obsoletos após mover arquivos | Médio | Atualizar testes junto de cada fase; manter cobertura igual ou superior a 91 testes |
| Chamadores ocultos de funções duplicadas | Médio | Inventário com `grep`, aliases de compatibilidade documentados e remoção só após uso zerado |
| Código arquivado voltar a ser carregado ou confundir manutenção | Médio | `archive/legacy/` fora do source path, README por área e CI que verifica ausência de referências |
| Escopo crescer para módulos não planejados | Alto | Portões por fase; corrigir apenas bugs acoplados e registrar desvios na change |
| Perda de confirmação em comandos destrutivos | Alto | Revisão de segurança por fase, preservação de confirmações e testes de caminhos negativos |
| CI novo falhar por diferenças de ambiente | Médio | Workflow mínimo com `bash`, `bash -n` e a suíte existente; sem novas dependências de runtime |

## Critérios de aceite

- [x] `bash -n` passa em todos os arquivos shell de `bin/`, `commands/`, `lib/` e `tests/`.
- [x] `bash tests/scripts/run_unit_tests.sh` passa com 100%, com 218 testes finais (101 estruturais e 117 de caracterização).
- [x] `detect_pkg_manager`, `choose_from_menu`, `show_spinner` e `check_dependencies` têm uma única definição canônica em `lib/core/`; ocorrências fora disso são apenas chamadas ou wrappers de compatibilidade documentados.
- [x] Bibliotecas dos módulos refatorados não executam `main`, `exit`, `clear`, `read` ou menu no momento do `source`; entrypoints têm contrato uniforme e documentado.
- [x] Caminhos internos derivam de `BASE_DIR`; Flux não usa `dirname "$0"` para localizar `history.sh` e não referencia `postFeature/main.sh`.
- [x] Docker, Flux, Spring e Frontend não mantêm duas implementações ativas para o mesmo comportamento; duplicatas estão em `archive/legacy/<area>/` e não são carregadas.
- [x] `.github/workflows/validate.yml` executa `bash -n` e a suíte em push e pull request.
- [x] Specs de arquitetura, módulos e delta refletem o estado final; comandos e códigos de saída públicos permanecem compatíveis ou a mudança está explicitamente documentada.
- [x] Revisão de segurança confirma ausência de segredos, preservação de confirmações destrutivas, downloads HTTPS e privilégios mínimos.
- [x] A change é arquivada em `spec/changes/archive/` somente após todos os critérios acima e o Definition of Done de [spec/changes/README.md](../README.md).
