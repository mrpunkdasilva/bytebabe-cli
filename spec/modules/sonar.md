# Módulo Sonar

## Objetivo

Expor consultas somente leitura ao SonarQube a partir do terminal, com saída
cyberpunk traduzida (tipo, severidade, situação, portão) e explicação das
regras no próprio relatório, sem sair da CLI.

## Entry points

- `commands/sonar/main.sh`: dispatcher com guard de `BASH_SOURCE`, banner,
  `sonar_usage` e parsing de flags/posicionais.
- `lib/sonar/main.sh`: coordenador que carrega as bibliotecas do domínio.
- `lib/sonar/config.sh`: resolução de credenciais (env > `~/.config/bytebabe/sonar.json`),
  validação de timeouts, guarda de token/projeto e `sonar_login` interativo.
- `lib/sonar/client.sh`: `sonar_get` (curl com token via `--config`), spinner
  no stderr, degradação sem TTY e `sonar_print_json`.
- `lib/sonar/render.sh`: paleta `CYBER_*` com `--sem-cores`/não-TTY, campos
  alinhados (padding por caracteres), HTML→ANSI (python3 opcional com fallback
  sed), traduções, cores por severidade/tipo/status/gate, barras de percentual,
  truncamento e links OSC 8 para a web.
- `lib/sonar/queries.sh`: subcomandos do núcleo e dashboard de issues; tabelas
  de rules/hotspots com cabeçalho, linhas coloridas e total; metrics com barras
  de cobertura/duplicação; gate com painel de status e condições.

## Comandos

| Comando | Aliases | Ação |
|---------|---------|------|
| `overview [pr] [projeto]` | `resumo`, `painel`, `ov` | TUI de painel geral: molduras com seções (qualidade com barras e score de saúde, apontamentos por tipo/severidade via facets, hotspots por risco); interativa quando stdin/stdout são TTY (`[1]` apontamentos, `[2]` hotspots, `[3]` métricas, `r` atualizar, `q`/ESC sair), render estático caso contrário |
| `issues [pr] [projeto]` | — | Dashboard de qualidade (portão, cobertura, duplicação, LOC) + apontamentos abertos com regra explicada; padrão do módulo |
| `show <chave>` | `issue` | Localização, mensagem, regra e "por quê" de um apontamento |
| `rule <chave>` | — | Metadados e descrição completa de uma regra |
| `rules [termo]` | — | Pesquisa de regras em tabela |
| `metrics [pr] [projeto]` | — | Métricas do projeto/PR (coverage, duplicação, complexidade, código novo) |
| `gate [pr] [projeto]` | — | Situação do portão de qualidade e condições |
| `hotspots [pr] [projeto]` | — | Alertas de segurança paginados |
| `login` | — | Configura URL/token/projeto/PR de forma interativa e segura |
| `project <sub> [args]` | `proj` | Gestão multi-projeto em lista: `projects[]` (chaves) e `activeProject` (ativo) no `sonar.json`; subs `list`, `next`/`prev` (alternância circular do ativo), `current`, `search [termo]` (seleção interativa), `add <chave>` (só insere na lista), `remove <chave>` (se era o ativo, ativa o primeiro restante), `use <chave>`/`set [chave]` (troca o ativo; sem chave usa autodetecção do diretório) e `validate <chave>`; sem subcomando exibe o help |
| `pr <sub> [args]` | `pull` | Pull requests do projeto ativo: lista em `projects[].prs` e PR ativo em `projects[].activePr` do `sonar.json`, com fallback para `defaultPullRequest` (login); subs `list`, `add <numero>` (só insere na lista), `remove <numero>` (se era o ativo, ativa o primeiro restante), `search [termo]` (seleção interativa) e `use <numero>` (define o ativo; números novos entram na lista); sem subcomando exibe o help |
| `help` | (sem argumentos), `-h`, `--help` | Ajuda estilizada do módulo, com versão e aviso de login obrigatório |
| `version` | `-v`, `--version` | Versão do módulo (`bytebabe sonar v1.0.0`) |

Opções globais: `--somente-resumo`/`--summary-only` (issues) e
`-p/--projeto <chave>`.
`--sem-cores`/`--no-color`.

## Requisitos

- Dependências: `curl`, `jq`; `python3` é opcional (renderização de HTML de
  regras degrada para fallback sed) — sem dependências novas.
- Credenciais e listas em `$XDG_CONFIG_HOME/bytebabe/sonar.json` (ou
  `~/.config/bytebabe/sonar.json`), formato JSON manipulado com `jq`,
  gravado com `umask 077`, `chmod 600` e escrita atômica; variáveis
  `SONAR_URL`, `SONAR_TOKEN`, `SONAR_PROJECT_KEY` e
  `SONAR_PULL_REQUEST` vencem o arquivo. Esquema: `url`, `token`,
  `activeProject`, `defaultPullRequest` e `projects[]` com
  `{key, prs[], activePr}`. Config antigo em key=value (`sonar.conf`)
  é ignorado, com aviso único apontando para o `login`.
- Projeto efetivo, por prioridade: `-p/--projeto <chave>` > posicional
  `<projeto>` > `SONAR_PROJECT_KEY` (env / `sonar.json`).
- O token nunca é exibido; falhas de validação descartam o valor lido.
- A paleta local `_SONAR_*` converte as sequências `\033` literais das
  variáveis `CYBER_*` para bytes reais no `sonar_setup_colors` (fonte de
  verdade única); helpers de cor usam `printf '%s'` e são seguros em
  composições com `%s`.
- Sem token, todo comando de consulta falha com orientação
  (`bytebabe sonar login`); sem chave de projeto, idem.
- Todos os subcomandos são somente leitura: nenhuma mutação na instância.
- `commands/*.sh` e `lib/sonar/*.sh` são source-safe (sem `exit`, sem saída no
  load); erros propagam via `return` (2 = uso inválido/sem credencial,
  1 = falha da consulta, 28 propagado do curl).
- Sem `eval`; argumentos extras ao curl via array de posicionais.

## Efeitos colaterais

- `login` grava `~/.config/bytebabe/sonar.json` e executa uma requisição de
  validação (`/api/authentication/validate`).
- Consultas leem a API do SonarQube configurada; nada é escrito na instância.

## Critérios de aceite

- `bytebabe sonar help` retorna 0; subcomando ou opção inválida retorna 2 com a ajuda no stderr.
- `bytebabe sonar` sem argumentos (e `sonar --help`) exibe o banner, a versão do módulo e a orientação de executar `bytebabe sonar login`.
- `bytebabe sonar --version` exibe `bytebabe sonar v1.0.0`.
- `bytebabe sonar issues --somente-resumo` mostra apenas o painel geral.
- `bytebabe sonar overview` reúne em um painel: portão, cobertura/duplicação (barras), LOC, score de saúde (0–100 = 50% cobertura + 30% ausência de duplicação + até 20% pelo portão), contagem de apontamentos por tipo e severidade e hotspots por risco de segurança.
- `overview` em terminal entra em loop interativo com atalhos; sem TTY (pipes/testes) renderiza o painel estático uma vez.
- `bytebabe sonar issues 42` usa PR 42 e mantém o projeto ativo do `sonar.json`; `42 proj` sobrescreve ambos; `-p proj` sobrepõe posicionais e defaults.
- Sem token configurado, `bytebabe sonar gate` retorna 2 orientando `bytebabe sonar login`.
- Todos os subcomandos exibem banner temático próprio (padrão do módulo azure)
- Dashboards (`issues`, `metrics`, `gate`, `hotspots`, `overview`) limpam o terminal no momento da renderização (`_sonar_clear_screen`, apenas em TTY), sem resíduo de banner/spinners acima do conteúdo
  e tabelas com cabeçalho, cores semânticas e linha de total.
- Apontamentos aparecem numerados com tipo/severidade traduzidos e o campo `POR QUE:` preenchido com a descrição da regra.
- `metrics` exibe barras de progresso para percentuais (cobertura/duplicação) coloridas por faixa.
- `--sem-cores` desativa cores, spinner decorativo e links OSC 8.

## Gaps conhecidos

- Subcomandos do script original ainda não portados: `branches`, `prs`,
  `analyses`, `task`, `source`, `component` (roadmap).
- Paginação do dashboard de issues é automática (sem cursor interativo).
- Config legado (`~/.config/sonar-cli/config` e `configs.yaml`) não é lido.
