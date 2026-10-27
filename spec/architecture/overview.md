# Arquitetura

## Visão geral

```text
/usr/local/bin/bytebabe
        │ symlink
        ▼
/opt/bytebabe/bin/bytebabe
        │ resolve BASE_DIR
        ├── lib/core/*.sh        cores, helpers, aliases, completion
        ├── commands/*.sh        dispatch de comandos
        ├── lib/<dominio>/*.sh   implementação por domínio
        └── config/dados         ~/.bytebabe e ~/.config/bytebabe
```

## Entrada e resolução de caminho

`bin/bytebabe` MUST resolver symlinks antes de calcular `BASE_DIR`:

1. Lê `BASH_SOURCE[0]` ou `$0`.
2. Enquanto o caminho for symlink, resolve com `readlink`.
3. Converte caminhos relativos usando o diretório do link.
4. Define `BASE_DIR` como o pai de `bin/`.

Isso permite executar o CLI a partir de `/usr/local/bin/bytebabe` sem depender do diretório atual.

## Dispatch principal

O `case "$1"` em `bin/bytebabe` é a tabela de roteamento de topo:

| Comando | Destino | Estilo |
|---------|---------|--------|
| `alias` | `lib/core/alias_manager.sh` | `main` |
| `hello` | `commands/hello.sh` | `main` |
| `init` | `commands/init.sh` | `main` |
| `git` | `commands/git/main.sh` | `main` |
| `frontend` | `commands/frontend.sh` | `main` |
| `backend` | `commands/backend.sh` | `main` |
| `spring` | `commands/backend/spring/main.sh` | `main` |
| `servers` | `commands/servers.sh` | `main` |
| `db` | `commands/db.sh` | `main` |
| `datavision`, `dv` | `lib/database/datavision.sh` | `datavision_main` |
| `edit`, `byteedit` | `commands/byteedit.sh` | `main` |
| `ide` | `commands/ide.sh` | `main` |
| `devtools` | `commands/devtools.sh` | `main` |
| `docker` | `commands/docker.sh` | `main` |
| `prime`, `pm` | `commands/prime.sh` | `main` |
| `gh`, `github` | `commands/gh.sh` | `main` |
| `flux` | `commands/flux.sh` | `main` |
| `help`, `--help`, `-h`, `h` | `show_help` | função interna |
| `--version`, `-v` | `show_version` | função interna |

## Contrato de comandos

Todo arquivo em `commands/` MUST:

1. Ser seguro para `source`, sem executar lógica principal, menus ou validações no carregamento.
2. Expor uma função `main` que receba `"$@"`.
3. Executar `main` somente sob guarda:
   `if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then main "$@"; fi`.
4. Retornar os códigos `0` (sucesso), `1` (validação/dependência) e `130` (cancelamento).

`bin/bytebabe` carrega o arquivo sem argumentos e chama `run_command <arquivo> main "$@"`.
O entrypoint `datavision` é a exceção documentada e usa `datavision_main`.

### Dispatch interno

Comandos com muitos subcomandos delegam para um único dispatcher de domínio:

| Domínio | Dispatcher | Adaptadores |
|---------|------------|-------------|
| Docker | `commands/docker.sh` | `lib/docker/*` com UI e helpers únicos |
| Flux | `lib/flux/engine.sh` | `lib/flux/verbs/{get,post,put,delete}` finos |
| Spring | `lib/backend/spring/generators/main.sh` | um generator por tipo |
| Frontend | `lib/frontend/generators.sh` | `lib/frontend/{react,vue,angular}/generators.sh` |

Validadores de domínio não repetem detecção, parsing ou dispatch; adaptadores
apenas executam a parte específica do framework ou verbo.

## Camadas

### 1. Core

- `lib/core/paths.sh`: resolução de symlinks, diretório do script e raiz do entrypoint.
- `lib/core/pkg.sh`: detecção de gerenciador, execução privilegiada, update/upgrade e instalação.
- `lib/core/feedback.sh`: spinners e loading seguros para TTY e não TTY.
- `lib/core/menu.sh`: menu único com navegação por teclado.
- `lib/core/ui.sh`: headers, banner, seções e cabeçalhos customizados.
- `lib/core/colors.sh`: variáveis de cor, ícones e estilos.
- `lib/core/helpers.sh`: fachada compatível e helpers de root/erro.
- `lib/core/alias_manager.sh`: aliases padrão, do usuário, templates e backups.
- `lib/core/completion.sh`: autocomplete para Bash/Zsh.
- `lib/core/logger.sh`, `i18n.sh`, `plugins.sh`: suporte e extensões.
- `lib/core/tui.sh` e `lib/core/tui/`: TUI antiga em `dialog`, arquivada por não ter chamadores.

### 2. Commands

Arquivos em `commands/` fazem parsing de argumentos e delegam para `lib/<dominio>/`. Devem evitar lógica de instalação pesada e seguir o contrato de `main`/guarda acima.

### 3. Domain libraries

Implementação real por domínio:

- `lib/devtools/`: terminal, bancos, navegadores e APIs.
- `lib/frontend/`: dispatcher, adaptadores por framework, templates, configuração e ajuda.
- `lib/backend/`: runtimes, frameworks e Spring, com um generator ativo por tipo.
- `lib/ide/`, `lib/docker/`, `lib/database/`, `lib/server/`, `lib/flux/`, `lib/pkg/`.
- `lib/git/`, `lib/github/`: operações assistidas de versionamento.

## Archive legado

- Código substituído reside em `archive/legacy/<area>/` com README de origem,
  motivo e substituto.
- `archive/legacy/` MUST NOT ser carregado por `bin/`, `commands/` ou `lib/`.
- O diretório não faz parte de `files` no `package.json`; o instalador local
  remove `archive/` do destino.
- Áreas arquivadas: `core/`, `flux/`, `spring/` e `frontend/`. No Docker as duplicatas foram removidas diretamente, sem UI legada isolada.

## Configuração e dados

| Caminho | Uso |
|---------|-----|
| `~/.bytebabe/` | Aliases do usuário, backups e dados do DataVision |
| `~/.config/bytebabe/` | Configuração, temas e plugins |
| `~/.nvm/` | Node Version Manager |
| `~/.atuin/` | Binário e configuração do Atuin |
| `$BASE_DIR/docker-compose.yml` | Servidores Apache/Nginx gerados |
| `$BASE_DIR/docker-compose-db.yml` | Bancos de dados gerados |
| `$BASE_DIR/docker/databases/` | Configuração e dados dos bancos |
| `/opt/bytebabe/` | Instalação do CLI (`$BASE_DIR` no uso normal) |
| `/usr/local/bin/bytebabe` | Symlink global |

## Instalação e release

- `install.sh` opera em dois modos: local (clone) e remoto (tarball do GitHub Releases).
- O asset remoto MUST se chamar `bytebabe-<versao>.tar.gz`.
- O tarball MUST conter um diretório raiz `bytebabe-<versao>/` com `bin/` e `lib/`.
- A instalação substitui `/opt/bytebabe`, cria o symlink e limpa arquivos temporários.
- A versão deve ser consistente em `bin/bytebabe`, `install.sh`, `package.json` e CHANGELOG.

## Testes

- Runner: `tests/scripts/run_unit_tests.sh`.
- Testes por comando em `tests/unit/commands/*.test.sh`.
- Estrutura: setup, testes estruturais, testes funcionais, cleanup e relatório.
- Cobertura atual: 19 arquivos, 240 testes (101 estruturais e 139 de caracterização).

## Restrições e riscos arquiteturais

- Dependência de Bash e ferramentas externas (`jq`, `curl`, `docker`, `flatpak`, `npm`).
- Menus interativos podem bloquear automação; comandos diretos SHOULD existir.
- Módulos com caminhos absolutos/relativos frágeis devem ser migrados para `BASE_DIR`.
- Flatpak no WSL pode não abrir interface gráfica; preferir detectar binário nativo ou integração com Windows.
