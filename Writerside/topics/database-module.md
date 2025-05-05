# Database Module

> "Gerenciamento de bancos de dados com estilo cyberpunk"

## Visão Geral

O módulo Database do ByteBabe oferece uma interface unificada para gerenciar diferentes bancos de dados através de containers Docker, com suporte a operações comuns e monitoramento.

## Comandos Principais

```bash
# Configuração inicial
bytebabe db setup

# Iniciar banco específico
bytebabe db start mysql

# Parar todos os bancos
bytebabe db stop

# Ver status
bytebabe db status

# Acompanhar logs
bytebabe db log mongodb
```

## Recursos Principais

- Suporte a múltiplos bancos de dados
- Backup e restore automatizados
- Ferramentas de migração integradas
- Monitoramento em tempo real
- Interface visual para gestão

## Subcomandos

| Comando | Descrição |
|---------|-----------|
| `setup` | Configuração inicial |
| `start` | Inicia banco(s) |
| `stop` | Para banco(s) |
| `status` | Mostra status atual |
| `log` | Exibe logs |

## Próximos Passos

- [📚 Bancos Suportados](supported-databases.md)
- [💾 Backup e Restore](backup-restore.md)
- [🔄 Ferramentas de Migração](migration-tools.md)
- [📊 Monitoramento](database-monitoring.md)