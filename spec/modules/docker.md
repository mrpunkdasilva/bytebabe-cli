# Módulo Docker

## Objetivo

Gerenciar containers, imagens, volumes e stacks Docker com interface interativa e comandos diretos.

## Entry point

`commands/docker.sh`, com implementação em `lib/docker/`.

## Comandos

| Comando | Atalhos | Ação |
|---------|---------|------|
| `docker containers` | `c`, `cont` | Menu interativo de containers |
| `docker containers ls` | `list` | Lista containers sem menu (`-a` inclui parados) |
| `docker containers running` | `ps` | Lista containers em execução |
| `docker containers start/stop/restart` | — | Executa a ação em um ou mais containers |
| `docker containers rm` | `remove` | Remove containers com confirmação |
| `docker containers logs/inspect/shell` | `exec` | Acessa logs, inspeção ou shell |
| `docker containers stats` | — | Estatísticas sem pausa interativa |
| `docker images` | `image`, `i`, `img` | Menu ou opções de imagens |
| `docker volumes` | `volume`, `v`, `vol` | Menu ou comandos `ls/create/inspect/rm/prune` |
| `docker compose` | `co` | Gerencia compose |
| `docker clean` | — | Prune interativo de recursos |
| `docker stats` | — | Monitor de estatísticas |
| `docker help` | `--help`, `-h` | Ajuda sem exigir daemon |

## Arquitetura

- `lib/docker/helpers.sh`: configuração canônica (`configure_docker`, `configure_docker_compose`), dependências opcionais e seleção de `cmd_docker`/`cmd_docker_compose`.
- `lib/docker/ui.sh`: header, ajuda, menu principal e formatação visual.
- `lib/docker/containers.sh`: lógica e dispatch de containers, incluindo modo não interativo.
- `lib/docker/volumes.sh`: gerenciamento de volumes (`volume_commander`, `volume_bay`).
- `lib/docker/images.sh`, `compose.sh`, `utils.sh`: domínios específicos.
- `commands/docker.sh`: parsing de topo, ajuda sem daemon e configuração única antes do dispatch que exige Docker.

## Requisitos

- O módulo MUST verificar o daemon antes de comandos que exigem Docker.
- Ajuda de `docker`, `containers`, `images`, `volumes` e `compose` MUST funcionar sem daemon.
- `containers ls/list` MUST ser não interativo e aceitar `-a`/`--all` e `-r`/`--running`.
- `volumes ls/create/inspect/rm/prune` MUST funcionar sem menu; `rm` e `prune` MUST pedir confirmação ou aceitar `-f`.
- Comandos diretos MUST NOT abrir menu.
- Operações destrutivas MUST pedir confirmação.
- `docker compose` MUST usar o plugin moderno quando disponível e aceitar `docker-compose` legado.
- Libs Docker MUST NOT chamar `exit`; erros MUST retornar código não zero.
- Comando inválido MUST exibir ajuda e retornar `1`.

## Critérios de aceite

- `bytebabe docker containers list` lista containers.
- `bytebabe docker c ls -a` funciona como alias e inclui parados.
- `bytebabe docker images pull nginx` baixa a imagem.
- `bytebabe docker compose up -d` sobe o stack do diretório atual.
- `bytebabe docker volumes ls` lista volumes sem abrir menu.
- `bytebabe docker volumes create data` cria um volume; `rm data -f` remove.
- `bytebabe docker help` funciona sem Docker instalado.
- Sem Docker instalado, comandos operacionais exibem instrução de instalação e retornam `1`.

## Gaps conhecidos

- O módulo exige Docker ativo para operações reais; em WSL pode ser necessário iniciar o serviço.
- `docker` usa `sudo` em alguns fluxos, o que pode afetar permissões de arquivos.
- `images.sh` ainda concentra menus extensos; a criação de containers/imagens e as operações de volumes usam arrays, sem `eval`.
