# Agent

## Objetivo

Instalar, manter e remover o knowledge pack de IA do ByteBabe (`.bytebabe/`) em qualquer projeto, para que assistentes de código (Claude Code, opencode, etc.) conheçam a CLI e seus contratos.

## Comandos

| Comando | Comportamento |
|---------|---------------|
| `bytebabe agent init` | Gera `.bytebabe/SKILL.md` + `.bytebabe/README.md` |
| `bytebabe agent update` | Regenera os arquivos do pack |
| `bytebabe agent status` | Verifica presença de `.bytebabe/SKILL.md`; status `1` se ausente |
| `bytebabe agent remove` | Pede confirmação explícita (s/Sim) e remove `.bytebabe/` |
| `bytebabe agent help` | Ajuda do módulo |

## Contratos

- O conteúdo do pack é inglês, formato de skill universal (frontmatter `name`/`description`).
- O pack é criado apenas em `.bytebabe/`; nada mais no projeto é criado ou alterado.
- A fonte de verdade do conteúdo é `lib/agent/skill.sh`; comandos citados no pack devem refletir `bin/bytebabe help` e `spec/modules/`.
- `lib/agent/skill.sh` é source-safe: sem saída, sem input, sem `exit`.

## Status

`1.6.0` (não-release) - Estável.
