# Service Management

## Comandos Disponíveis

### Controle de Serviços
```bash
# Status dos serviços
bytebabe servers status

# Iniciar serviço
bytebabe servers start <nome>

# Parar serviço
bytebabe servers stop <nome>

# Reiniciar serviço
bytebabe servers restart <nome>
```

### Configuração
```bash
# Editar configuração
bytebabe servers config <nome>

# Aplicar alterações
bytebabe servers reload <nome>
```

## Serviços Suportados

| Serviço | Descrição | Comando |
|---------|-----------|---------|
| API | Backend API | `api` |
| Web | Frontend | `web` |
| DB | Database | `db` |
| Cache | Redis/Memcached | `cache` |