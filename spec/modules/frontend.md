# Módulo Frontend

## Objetivo

Configurar ambiente frontend, criar projetos e gerar artefatos para frameworks modernos.

## Entry point

- `commands/frontend.sh`: parsing, criação de projeto, scripts e features.
- `lib/frontend/main.sh`: requisitos, detecção de package manager e helpers de execução.
- `lib/frontend/generators.sh`: dispatcher canônico de geração.
- `lib/frontend/{react,vue,angular}/generators.sh`: adaptadores por framework.
- `lib/frontend/templates.sh`, `config.sh`, `help.sh`, `features/`.

## Comandos

| Comando | Ação |
|---------|------|
| `frontend setup` | Instala/configura ambiente frontend |
| `frontend new <framework> <nome> [template]` | Cria projeto |
| `frontend create ...` | Alias de `new` |
| `frontend generate`, `g` | Gera componente, service, store, hook ou guard |
| `frontend add <feature>` | Adiciona Tailwind, Redux, Router ou i18n |
| `frontend install`, `i` | Instala dependências |
| `frontend test`, `t` | Executa testes |
| `frontend build`, `b` | Compila o projeto |
| `frontend serve`, `s` | Inicia servidor de desenvolvimento |
| `frontend help` | Ajuda do módulo |

## Frameworks

`react`, `vue`, `angular`, `next`, `svelte`.

## Geração

`lib/frontend/generators.sh` é o único ponto que detecta o framework e valida
nomes. Os adaptadores apenas escrevem os arquivos específicos.

| Comando | Escopo |
|---------|--------|
| `g component <nome>` | React/Vue/Angular/Next/Svelte |
| `g service <nome>` | React API service, Vue store ou Angular service |
| `g store <nome>` | React Context ou Vue store |
| `g hook <nome>` | React |
| `g guard <nome>` | Angular |

## Requisitos

- `new` MUST validar framework e nome do projeto.
- `new` SHOULD usar o package manager disponível (`npm`, `yarn`, `pnpm`, `bun`) com fallback para `npm`.
- A detecção de package manager JS MUST vir de `detect_node_pkg_manager` no core.
- `g component` MUST detectar o framework pelo projeto atual.
- `install`/`test`/`build`/`serve` MUST delegar aos scripts do `package.json`.
- `setup` MUST exigir Node.js e um package manager e instalar os gerenciadores/frameworks selecionados.
- Comando desconhecido MUST exibir ajuda e sair com código `1`.

## Critérios de aceite

- `bytebabe frontend new react my-app` cria o projeto React.
- `bytebabe frontend g component UserProfile` cria arquivo no diretório correto.
- `bytebabe frontend setup` funciona sem erros de `source` quando Node.js está disponível.
- `bytebabe frontend help` lista `new`, `generate`, `install`, `test`, `build` e `serve`.

## Gaps conhecidos

- `setup` não instala Node.js: retorna erro e orienta `bytebabe backend install node`.
- Detecção de framework depende da estrutura do projeto e pode falhar em monorepos.
- `add` cobre apenas Tailwind, Redux, Router e i18n.
- Criação remota ainda depende de rede e do CLI de cada framework.
