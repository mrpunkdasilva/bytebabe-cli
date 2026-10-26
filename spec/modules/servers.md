# Módulo Servers

## Objetivo

Orquestrar servidores Apache e Nginx baseados em Docker Compose.

## Entry point

`commands/servers.sh`, com serviços em `lib/server/servers_services.sh`.

## Comandos

Serviços aceitos: `apache` e `nginx`.

| Comando | Ação |
|---------|------|
| `servers up [serviço]` / `start` | Inicia servidores |
| `servers down [serviço]` / `stop` | Para servidores |
| `servers status [serviço]` | Mostra status |
| `servers setup` / `init` | Gera configuração Docker Compose |

## Requisitos

- `setup` MUST gerar `docker-compose.yml` com Apache e Nginx.
- `setup` MUST gerar configurações de servidor e página inicial.
- `up`/`down`/`status` MUST usar `docker compose` quando disponível.
- O módulo MUST verificar se Docker e Compose estão instalados.
- Sem `docker-compose.yml`, o comando MUST exibir instrução para rodar `setup`.
- `up`/`down`/`status` com serviço MUST validar que ele é `apache` ou `nginx`.

## Critérios de aceite

- `bytebabe servers setup` cria `docker-compose.yml` e `docker/`.
- `bytebabe servers up apache` sobe o container Apache.
- `bytebabe servers status` mostra o estado.
- `bytebabe servers down` para os containers.
- `bytebabe servers` sem argumentos exibe a ajuda.

## Gaps conhecidos

- `servers up` sem serviço passa uma string vazia ao Docker Compose e pode falhar.
- Usa `sudo docker compose`, o que pode criar arquivos com dono `root`.
- As portas 8080/8081/4430 e volumes gerados precisam ser documentados por projeto.
- Não há suporte a outros servidores além de Apache e Nginx.
