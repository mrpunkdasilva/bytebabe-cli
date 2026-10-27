# Módulo Prime

## Objetivo

Centralizar gerenciamento de pacotes, segurança, serviços e utilitários do sistema.

## Entry point

`commands/prime.sh`, com implementação em `lib/pkg/`.

## Comandos

| Comando | Aliases | Ação |
|---------|---------|------|
| `prime upgrade` | `up` | Atualiza pacotes |
| `prime install <pkg>` | `in`, `i` | Instala pacotes |
| `prime remove <pkg>` | `rm`, `purge` | Remove pacotes |
| `prime scan` | | Scanner de segurança |
| `prime firewall` | `fw` | Firewall |
| `prime quarantine` | `q` | Quarentena |
| `prime clean` | | Limpeza do sistema |
| `prime backup` | | Backup |
| `prime network` | `net` | Rede |
| `prime log` | | Logs |
| `prime service` | `svc` | Serviços |
| `prime list` | `ls` | Lista pacotes |
| `prime info` | | Informações do sistema |
| `prime stats` | | Estatísticas |
| `prime neo` | | Easter egg |
| `prime help` | | Ajuda |

## Requisitos

- Detectar o gerenciador de pacotes e usar comandos nativos.
- `install`/`remove` MUST validar o nome do pacote.
- Operações destrutivas MUST pedir confirmação.
- Comandos de segurança MUST avisar sobre escopo e riscos.
- Comando inválido MUST exibir ajuda e sair com código `1`.

## Critérios de aceite

- `bytebabe prime upgrade` executa atualização no gerenciador detectado.
- `bytebabe prime install jq` instala o pacote.
- `bytebabe prime list` lista pacotes instalados.
- `bytebabe prime info` exibe informações do sistema.
- `bytebabe prime help` lista todos os subcomandos.

## Gaps conhecidos

- Alguns subcomandos dependem de ferramentas externas e privilégios de root.
- Cobertura de testes atual valida estrutura/dispatch e source-safety, não operações reais no sistema.
