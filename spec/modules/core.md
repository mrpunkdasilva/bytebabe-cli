# Módulo Core

## Objetivo

Fornecer bootstrap, ajuda, versão, editor simples, saudação e configuração inicial do ambiente.

## Entry points

- `bin/bytebabe`: resolução de `BASE_DIR`, dispatch, `show_help`, `show_version`.
- `commands/hello.sh`: saudação cyberpunk.
- `commands/init.sh`: configuração inicial.
- `commands/byteedit.sh`: editor de texto simples.
- `lib/core/alias_manager.sh`: aliases.
- `lib/core/completion.sh`: autocomplete.

## Comandos

| Comando | Comportamento |
|---------|---------------|
| `bytebabe hello` | Exibe header e frase cyberpunk aleatória |
| `bytebabe init` | Executa configuração inicial guiada |
| `bytebabe edit <arquivo>` / `bytebabe byteedit <arquivo>` | Abre editor de terminal |
| `bytebabe alias ...` | Gerencia aliases padrão e do usuário |
| `bytebabe help`, `h`, `--help`, `-h` | Exibe help global |
| `bytebabe --version`, `-v` | Exibe versão, sistema, shell e uptime |

## Requisitos

- `bin/bytebabe` MUST resolver symlinks antes de definir `BASE_DIR`.
- `help` MUST listar comandos de topo, subcomandos principais, aliases e sistema.
- `--version` MUST exibir a versão de `VERSION`.
- `init` MUST detectar o gerenciador de pacotes e oferecer atualização/instalação.
- `init` MUST configurar identidade Git, NVM/Node e Docker de forma opcional.
- `alias` MUST validar nomes/comandos e manter backups dos aliases do usuário.
- `edit` MUST criar o arquivo se ele não existir e permitir salvar/sair.

## Efeitos colaterais

- `init` pode instalar pacotes, alterar `~/.gitconfig`, instalar NVM/Node e Docker.
- `alias` grava em `~/.bytebabe/aliases.json` e em `~/.bytebabe/backups/aliases/`.
- `edit` cria/alterar o arquivo informado.

## Critérios de aceite

- `cd /tmp && bytebabe --version` funciona após instalação.
- `bytebabe help` não retorna `command not found`.
- `bytebabe init` não falha em Fedora quando `neofetch` não existe.
- `bytebabe alias add -n gp -c 'git push'` cria o alias.
- `bytebabe edit arquivo.txt` cria o arquivo e abre o editor.

## Gaps conhecidos

- O help global é estático; novos comandos precisam ser adicionados manualmente.
- `alias` depende de `jq`.
- O autocomplete cobre apenas parte dos comandos de topo.
