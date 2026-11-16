# Log Management

## Visualização de Logs

```bash
# Ver logs em tempo real
bytebabe servers logs --follow

# Filtrar por serviço
bytebabe servers logs <nome>

# Filtrar por nível
bytebabe servers logs --level=error
```

## Configuração de Logs

```bash
# Configurar rotação
bytebabe servers logs config

# Limpar logs antigos
bytebabe servers logs clean

# Exportar logs
bytebabe servers logs export
```

## Níveis de Log

| Nível | Descrição | Flag |
|-------|-----------|------|
| ERROR | Erros críticos | `--level=error` |
| WARN | Alertas | `--level=warn` |
| INFO | Informações | `--level=info` |
| DEBUG | Depuração | `--level=debug` |