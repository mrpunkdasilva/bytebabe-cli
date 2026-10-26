# Módulo Docker

## Objetivo

Gerenciar containers, imagens, volumes e stacks Docker com interface verbose e atalhos curtos.

## Entry point

`commands/docker.sh`, com implementação em `lib/docker/`.

## Comandos

| Comando | Atalhos | Ação |
|---------|---------|------|
| `docker containers` | `c`, `cont` | Gerencia containers |
| `docker images` | `image`, `i`, `img` | Gerencia imagens |
| `docker volumes` | `volume`, `v`, `vol` | Gerencia volumes (planejado) |
| `docker compose` | `co` | Gerencia compose |

## Requisitos

- O módulo MUST verificar o daemon Docker antes de executar comandos.
- `containers` MUST listar, iniciar, parar, remover e inspecionar containers.
- `images` MUST listar, baixar, remover e inspecionar imagens.
- `compose` MUST executar `docker compose` com o arquivo do diretório atual.
- Comando inválido MUST exibir ajuda e sair com código `1`.
- O módulo MUST suportar estilo verbose e curto sem ambiguidade.

## Critérios de aceite

- `bytebabe docker containers list` lista containers.
- `bytebabe docker c ls -a` funciona como alias.
- `bytebabe docker images pull nginx` baixa a imagem.
- `bytebabe docker compose up -d` sobe o stack do diretório atual.
- Sem Docker instalado, o módulo exibe instrução de instalação.

## Gaps conhecidos

- `volumes` ainda não implementado.
- O módulo exige Docker ativo; em WSL pode ser necessário iniciar o serviço.
- `docker` usa `sudo` em alguns fluxos, o que pode afetar permissões de arquivos.
