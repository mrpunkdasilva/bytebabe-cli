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
| `hello` | `commands/hello.sh` | source direto |
| `init` | `commands/init.sh` | `main` |
| `git` | `commands/git/main.sh` | interativo |
| `frontend` | `commands/frontend.sh` | `main` |
| `backend` | `commands/backend.sh` | source direto |
| `spring` | `commands/backend/spring/main.sh` | source direto |
| `servers` | `commands/servers.sh` | source direto |
| `db` | `commands/db.sh` | source direto |
| `datavision`, `dv` | `lib/database/datavision.sh` | `datavision_main` |
| `edit`, `byteedit` | `commands/byteedit.sh` | source direto |
| `ide` | `commands/ide.sh` | source direto |
| `devtools` | `commands/devtools.sh` | `main` |
| `docker` | `commands/docker.sh` | `main` |
| `prime`, `pm` | `commands/prime.sh` | source direto |
| `gh`, `github` | `commands/gh.sh` | source direto |
| `flux` | `commands/flux.sh` | source direto |
| `help`, `--help`, `-h`, `h` | `show_help` | função interna |
| `--version`, `-v` | `show_version` | função interna |

## Camadas

### 1. Core

- `lib/core/colors.sh`: variáveis de cor e funções visuais.
- `lib/core/helpers.sh`: detecção de gerenciador de pacotes, execução privilegiada e instalação.
- `lib/core/alias_manager.sh`: aliases padrão, do usuário, templates e backups.
- `lib/core/completion.sh`: autocomplete para Bash/Zsh.
- `lib/core/logger.sh`, `i18n.sh`, `plugins.sh`, `tui.sh`: suporte e extensões.

### 2. Commands

Arquivos em `commands/` fazem parsing de argumentos e delegam para `lib/<dominio>/`. Devem evitar lógica de instalação pesada.

### 3. Domain libraries

Implementação real por domínio:

- `lib/devtools/`: terminal, bancos, navegadores e APIs.
- `lib/frontend/`: templates, geradores, configuração e ajuda.
- `lib/backend/`: runtimes, frameworks e Spring.
- `lib/ide/`, `lib/docker/`, `lib/database/`, `lib/server/`, `lib/flux/`, `lib/pkg/`.
- `lib/git/`, `lib/github/`: operações assistidas de versionamento.

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
- A versão deve ser consistente em `bin/bytebabe`, `install.sh`, `package.json`, `lib/core/tui.sh` e CHANGELOG.

## Testes

- Runner: `tests/scripts/run_unit_tests.sh`.
- Testes por comando em `tests/unit/commands/*.test.sh`.
- Estrutura: setup, testes estruturais, testes funcionais, cleanup e relatório.
- Cobertura atual: 9 arquivos, 91 testes.

## Restrições e riscos arquiteturais

- Dependência de Bash e ferramentas externas (`jq`, `curl`, `docker`, `flatpak`, `npm`).
- Menus interativos podem bloquear automação; comandos diretos SHOULD existir.
- Alguns módulos ainda chamam `source` com argumentos, o que depende de `$@` no arquivo carregado.
- Módulos com caminhos absolutos/relativos frágeis devem ser migrados para `BASE_DIR`.
- Flatpak no WSL pode não abrir interface gráfica; preferir detectar binário nativo ou integração com Windows.
