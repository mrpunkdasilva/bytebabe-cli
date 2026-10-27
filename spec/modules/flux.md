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

## Opções

| Opção | Verbos | Ação |
|-------|--------|------|
| `-H, --header <valor>` | todos | Adiciona header (repetível) |
| `--json` | todos | Adiciona `Accept: application/json` |
| `--loading-style <estilo>` / `--loading` | todos | Aceita o estilo por compatibilidade; animação atual é única |
| `-i, --include` | todos | Mantém headers na resposta (curl já usa `-i`) |
| `-v, --verbose` | todos | Exibe detalhes do curl |
| `-q, --query <k=v>` | GET | Adiciona query string (repetível) |
| `-o, --output <arquivo>` | GET | Salva o corpo em arquivo |
| `-d, --data <corpo>` | POST, PUT | Corpo da requisição |
| `-f, --force` | DELETE | Aceito para compatibilidade; não há confirmação interativa |
| `-h, --help` | todos | Ajuda do verbo |

## Arquitetura

- `lib/flux/engine.sh`: pipeline único de parse, validação, execução, render e histórico.
- `lib/flux/args.sh`: parser compartilhado de opções.
- `lib/flux/validation.sh`: validação de URL.
- `lib/flux/display.sh`: header, request, resposta e ajuda geral.
- `lib/flux/history.sh`: persistência e consulta do histórico.
- `lib/flux/request.sh`: menu de histórico e ponte `process_request_for_history`.
- `lib/flux/verbs/{get,post,put,delete}/`: adaptadores finos, parser, validador e ajuda.
- `archive/legacy/flux/postFeature/`: conteúdo incompleto arquivado; não é carregado.

## Requisitos

- Comandos MUST aceitar URL completa e headers/body.
- `history` MUST listar e permitir visualizar, filtrar, limpar e exportar requisições.
- `server` MUST iniciar `commands/json-server.sh` e respeitar a porta informada.
- O módulo MUST validar `curl` e usar `jq` quando disponível para formatar/histórico.
- Erros de rede MUST ser exibidos sem encerrar o shell.
- Respostas MUST ser formatadas de forma legível.
- Todo arquivo de `lib/flux/` MUST ser seguro para `source`, sem efeitos, menus ou `exit` no carregamento.
- A montagem do `curl` MUST usar arrays Bash, sem `eval`.
- Arquivos temporários MUST ser removidos em sucesso e erro.

## Códigos de retorno

- `0`: resposta HTTP 2xx/3xx ou ajuda.
- `1`: uso inválido, URL inválida, falha de rede ou resposta HTTP >= 400.
- `130`: requisição cancelada por `SIGINT`.

## Critérios de aceite

- `bytebabe flux get https://api.github.com` exibe a resposta formatada.
- `bytebabe flux post <url> -d '{"name":"John"}'` envia JSON.
- `bytebabe flux history` lista requisições anteriores.
- `bytebabe flux server 8080` inicia o servidor na porta 8080.
- `bytebabe flux help` exibe os comandos disponíveis.
- `bytebabe flux <verbo> --help` retorna `0` sem exigir rede.

## Gaps conhecidos

- O menu de histórico é interativo; a automação cobre source, persistência e comandos não interativos.
- O histórico fica em `$HOME/bytebabe/flux/request_history.json` e depende de `jq`; os caminhos são resolvidos no uso (após `HOME` estar definido), não no source.
- `--loading-style` é aceito, mas todos os estilos usam a animação canônica de `lib/core/feedback.sh`.
- Não há cenário BDD dedicado ao Flux; a cobertura está em `tests/unit/lib/flux_parser.test.sh`.
