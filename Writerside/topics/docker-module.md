# Docker Module

> "Onde Poseidon encontra o cyberpunk para domar seus containers"

## Visão Geral

O módulo Docker do ByteBabe oferece uma interface cyberpunk para gerenciar todos os aspectos do Docker, desde containers individuais até complexos stacks de serviços.

## Estilos de Comando

### Estilo Verboso (Explícito)
```bash
bytebabe docker containers list --all
bytebabe docker images pull nginx
```

### Estilo Curto (Cyberpunk)
```bash
bytebabe docker c ls -a
bytebabe docker i p nginx
```

## Subcomandos

| Comando | Alias | Descrição | Modo Cyberpunk |
|---------|-------|-----------|----------------|
| `containers` | `c` | Gerencia containers | Container Commander 🎮 |
| `images` | `i` | Controla imagens | Image Harbor 🏴‍☠️ |
| `volumes` | `v` | Administra volumes | Volume Bay 💾 |
| `compose` | `co` | Orquestra serviços | Compose Captain 🎭 |
| `stats` | `st` | Monitora recursos | System Watcher 📊 |

## Navegação

- [Container Management](container-management.md)
- [Image Management](image-management.md)
- [Volume Management](volume-management.md)
- [Compose Operations](compose-operations.md)
- [Docker Monitoring](docker-monitoring.md)