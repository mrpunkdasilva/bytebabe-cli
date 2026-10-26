# Módulo Flux

## Objetivo

Oferecer um cliente HTTP de terminal e um servidor JSON para testes de API.

## Entry point

`commands/flux.sh`, com implementação em `lib/flux/`.

## Comandos

| Comando | Ação |
|---------|------|
| `flux get <url>` | Requisição GET |
| `flux post <url> -d '<json>'` | Requisição POST |
| `flux put <url> -d '<json>'` | Requisição PUT |
| `flux delete <url>` | Requisição DELETE |
| `flux history` | Histórico de requisições |
| `flux server [porta]` | Inicia JSON Server (padrão 3000) |
| `flux help` | Ajuda |

## Requisitos

- Comandos MUST aceitar URL completa e headers/body.
- `history` MUST listar e permitir reexecutar/limpar requisições.
- `server` MUST iniciar `commands/json-server.sh` e respeitar a porta informada.
- O módulo MUST validar `jq` e `curl`.
- Erros de rede MUST ser exibidos sem encerrar o shell.
- Respostas MUST ser formatadas de forma legível.

## Critérios de aceite

- `bytebabe flux get https://api.github.com` exibe a resposta formatada.
- `bytebabe flux post <url> -d '{"name":"John"}'` envia JSON.
- `bytebabe flux history` lista requisições anteriores.
- `bytebabe flux server 8080` inicia o servidor na porta 8080.
- `bytebabe flux help` exibe os comandos disponíveis.

## Gaps conhecidos

- O arquivo `lib/flux/verbs/postFeature/main.sh` não existe, causando erro no carregamento do módulo.
- O fallback de `lib/flux/request.sh` usa `$(dirname "$0")/history.sh`; quando chamado pelo entrypoint, `$0` aponta para `bin/bytebabe`, não para `lib/flux/`.
- O módulo precisa de correção antes de ser considerado estável.
