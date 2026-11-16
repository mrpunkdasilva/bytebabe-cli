# Backup Strategies 💾

## Configuração de Backup

```bash
# Configurar backup
bytebabe servers backup config

# Agendar backup
bytebabe servers backup schedule

# Backup manual
bytebabe servers backup now
```

## Tipos de Backup

### Completo
```bash
# Backup completo
bytebabe servers backup full
```

### Incremental
```bash
# Backup incremental
bytebabe servers backup incremental
```

## Destinos Suportados

- Local Storage
- Remote Server
- Cloud Storage (S3, GCS)
- FTP/SFTP

## Restauração

```bash
# Listar backups
bytebabe servers backup list

# Restaurar backup
bytebabe servers backup restore <id>

# Verificar backup
bytebabe servers backup verify <id>
```