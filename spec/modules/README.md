# Módulos

| Módulo | Entry point | Spec | Estado |
|--------|-------------|------|--------|
| Core | `bin/bytebabe` | [core.md](core.md) | Estável |
| DevTools | `commands/devtools.sh` | [devtools.md](devtools.md) | Estável |
| Frontend | `commands/frontend.sh` | [frontend.md](frontend.md) | Estável |
| Backend | `commands/backend.sh` | [backend.md](backend.md) | Estável |
| IDE | `commands/ide.sh` | [ide.md](ide.md) | Beta |
| Docker | `commands/docker.sh` | [docker.md](docker.md) | Beta |
| Database | `commands/db.sh`, `lib/database/datavision.sh` | [database.md](database.md) | Beta |
| Git/GitHub | `commands/git/main.sh`, `commands/gh.sh` | [git-github.md](git-github.md) | Estável |
| Servers | `commands/servers.sh` | [servers.md](servers.md) | Beta |
| Flux | `commands/flux.sh` | [flux.md](flux.md) | Beta |
| Prime | `commands/prime.sh` | [prime.md](prime.md) | Estável |

## Como interpretar

- **Estável**: comando documentado, testado e usado no fluxo principal.
- **Beta**: funcional, mas com gaps conhecidos ou dependências externas frágeis.
- **Planejado**: ainda não implementado.

## Regra de atualização

Sempre que um comando mudar, atualize:

1. A spec do módulo.
2. `bytebabe help` (se for comando de topo).
3. README e CHANGELOG (se afetar instalação/uso).
4. Testes em `tests/unit/commands/`.
5. Cenário em `spec/behavior/` quando o comportamento for observável.
