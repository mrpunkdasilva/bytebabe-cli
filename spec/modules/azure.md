# Módulo Azure DevOps

## Objetivo

Encapsular o Azure CLI (`az`) em comandos curtos com saída tabelada, cobrindo o
fluxo de pull requests (criar, listar, filtrar, categorizar, mergear) e
passthrough completo para os demais grupos do `az devops`.

## Entry points

- `commands/azure/main.sh`: dispatcher com banners por subcomando.
- `lib/azure/main.sh`: coordinator que carrega as bibliotecas do domínio.
- `lib/azure/prs.sh`: lógica de PR (`az_pr`, `az_prs`, `az_merge`), filtragem e query ao `az`.
- `lib/azure/pr_render.sh`: classificação de PRs e renderização (lista, agrupamentos, dashboard).
- `lib/azure/repos.sh`: projetos, branchs, tags e grupos de operação (`az_operations`).
- `lib/azure/render.sh`: render genérico de respostas `az` (JSON → tabela) e runner `_az_run`.
- `lib/azure/install.sh`: instalação da CLI e decisores por distro.
- `lib/azure/helpers.sh`: verificação de CLI/extensão, git helpers e utilitários.
- `lib/azure/help.sh`: central de comandos do módulo.

Ponto de final: prs (listar/filtrar), pr (criar), merge, projects, branches, tags.
Passthrough intencional: operations (project, repo, pr-manage, pipeline, boards, artifacts, devops) retornam pelo render genérico de az.

## Comandos

| Comando | Aliases | Ação |
|---------|---------|------|
| `install` | `i` | Instala o Azure CLI via dnf/apt/zypper/tdnf |
| `setup` | — | Instala CLI/extensão, faz login e salva organização/projeto |
| `pr <título> [base]` | — | Cria PR da branch atual para `main`/`master` ou base informada |
| `prs [termo] [opções]` | `pr-list`, `search-pr`, `pr-search`, `find-pr` | Lista, busca, filtra, agrupa e mostra dashboard de PRs |
| `merge [id] [merge|squash]` | — | Completa o PR; sem ID, usa o PR ativo da branch atual |
| `projects [org]` | `proj` | Lista projetos em tabela compacta |
| `project` | `repo`, `pr-manage`, `pipeline`, `boards`, `artifacts`, `devops`, `cli` | Passthrough do grupo `az` correspondente com render em tabela |
| `branches <repo>` | `br`, `refs` | Lista branchs ordenadas e paginadas |
| `tags <repo>` | `tag` | Lista tags ordenadas e paginadas |
| `help` | `--help`, `-h` | Central de comandos do módulo |

## Requisitos

- Comandos de PR MUST verificar `check_az_cli` (CLI + extensão azure-devops) e falhar com orientação.
- `pr` e `merge` sem ID MUST executar apenas dentro de um repositório Git.
- `prs --mine` MUST resolver o usuário via `git config`, `az account show` ou `whoami`.
- A renderização de PRs (classificação, badges, agrupamentos, dashboard) MUST permanecer em `lib/azure/pr_render.sh`; `prs.sh` chama a apresentação, mas não define os renderers.
- "Cada arquivo de lib/azure/*.sh deve ser seguro para source, sem ações em carga."
- Grupos passthrough MUST encaminhar argumentos extras ao `az` via array (sem `eval`).
- A saída de retorno de `az` em JSON precisa ser exibida em tabela (objetos como CAMPO/VALOR, listas como tabela colunar, nulos como —).
- Falhas de credenciais MUST produzir orientação específica (`az login`/`az devops login`/`bytebabe azure setup`) em vez de apenas a mensagem genérica, e MUST silenciar o `ERROR:` cru do `az`.

## Efeitos colaterais

- `install` executa instalações via gerenciador de pacotes (root/sudo).
- `setup` grava os defaults da CLI (`az devops configure`), entra em login interativo e executa a extensão azure-devops.
- `pr`/`merge`/`prs` chamam operações remotas do Azure DevOps (criar, completar, listar PRs) — merge é irreversível em repositórios sem política de branch.

## Critérios de aceite

- `bytebabe azure setup <org> [projeto]` aceita nome curto ou URL, inclusive org antiga `*.visualstudio.com` e projeto URL-encodado.
- `bytebabe az prs --stats` exibe total, distribuição por categoria, principais destinos e top contribuidores.
- `bytebabe az prs --group` agrupa por categoria; `--by-author` e `--by-target` agrupam por autor e branch de destino.
- `bytebabe az merge dados_id` mostra método inválido para valor diferente de merge/squash.
- `bytebabe az branches <repo>` mostra BRANCH/ID/AUTOR válido ordenado e "Total:"; sem repo, narra o uso.
- Sem `az` ou sem a extensão, cada comando informa como instalar (`bytebabe az install`/`setup`).
- Com sessão do `az` não autenticada, `az branches <repo>` orientando `az login` e `bytebabe azure setup`, sem vazar o stderr cru da CLI.

## Gaps conhecidos

- Ops passthrough (`pipeline`, `boards`, etc.) dependem do `az` local.
- Paginação de prs usa `--top`; sem cursor interativo.
- merge sem política: sem aprovações, conclui sem revisores.
