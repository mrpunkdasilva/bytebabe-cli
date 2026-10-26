# Módulo Database

## Objetivo

Configurar bancos de dados via Docker Compose e gerenciar conexões com o DataVision.

## Entry points

- `commands/db.sh`: ciclo de vida dos bancos.
- `lib/database/db_services.sh`: implementação.
- `lib/database/datavision.sh`: gerenciador de conexões via `bytebabe datavision`/`dv`.

## Comandos DB

| Comando | Ação |
|---------|------|
| `db setup` | Cria diretórios, config e `docker-compose-db.yml` |
| `db install <banco>` | Adiciona banco ao compose |
| `db start [banco]` | Inicia bancos |
| `db stop [banco]` | Para bancos |
| `db status` | Mostra status de todos os bancos |
| `db log [banco] [follow] [linhas]` | Exibe logs |

Bancos suportados: MySQL, PostgreSQL, MongoDB, Redis.

## Comandos DataVision

`connect`, `add`, `list`, `remove`, `edit`, `import`, `export`, `show`, `search`, `schema`, `stats`, `query`, `backup`.

## Armazenamento

| Caminho | Uso |
|---------|-----|
| `$HOME/.bytebabe/datavision/connections.json` | Conexões |
| `$HOME/.bytebabe/datavision/query_history.json` | Histórico |
| `$HOME/.bytebabe/datavision/exports/` | Exportações |
| `$BASE_DIR/docker-compose-db.yml` | Serviços gerados |
| `$BASE_DIR/docker/databases/config.json` | Bancos habilitados |
| `$BASE_DIR/docker/databases/<banco>/data/` | Dados persistentes |

`$BASE_DIR` é o diretório de instalação (`/opt/bytebabe` no uso normal).

## Requisitos

- `setup` MUST criar `docker-compose-db.yml` válido e perguntar quais bancos configurar.
- `install` MUST adicionar o serviço sem sobrescrever outros bancos.
- `start`/`stop`/`status` MUST usar Docker Compose.
- DataVision MUST validar `jq` e criar o diretório de configuração.
- Operações de escrita SHOULD usar escrita atômica.
- Nenhuma senha MUST ser exibida em logs.

## Critérios de aceite

- `bytebabe db setup` gera `docker-compose-db.yml`.
- `bytebabe db start postgres` sobe o serviço.
- `bytebabe db status` lista serviços e portas.
- `bytebabe datavision add` salva a conexão em `connections.json`.
- `bytebabe dv list` lista conexões salvas.

## Gaps conhecidos

- `generate_db_compose` imprime o compose no terminal, incluindo as senhas padrão.
- `db_stop` e `db_status` usam `sudo docker compose` fixo, sem a detecção de `docker-compose` v1.
- Alguns fluxos assumem `sudo docker` em vez de `docker` no grupo do usuário.
- DataVision depende de `jq` e clientes nativos para conectar de fato.
- Senhas padrão de desenvolvimento precisam ser explicitamente marcadas como inseguras.
