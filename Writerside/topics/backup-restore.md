# Backup e Restore

## Backup Automático

### Configuração
```yaml
backup:
  schedule: "0 0 * * *"  # Todo dia à meia-noite
  retention: 7           # Manter últimos 7 backups
  compress: true        # Compactar automaticamente
```

### Comandos

```bash
# Backup manual
bytebabe db backup mysql

# Backup de todos os bancos
bytebabe db backup all

# Backup com timestamp customizado
bytebabe db backup postgres --timestamp "pre-deploy"
```

## Restore

### Restauração Simples
```bash
# Restaurar último backup
bytebabe db restore mysql

# Restaurar backup específico
bytebabe db restore postgres --file backup-20231225.sql
```

### Restauração Seletiva
```bash
# Restaurar apenas uma database
bytebabe db restore mysql --database users_db

# Restaurar tabelas específicas
bytebabe db restore postgres --tables "users,orders"
```

## Boas Práticas

1. Configure backups automáticos
2. Teste seus backups regularmente
3. Mantenha cópias em locais diferentes
4. Documente procedimentos de restore