# System Monitoring 📊

## Monitoramento em Tempo Real

```bash
# Dashboard completo
bytebabe servers monitor

# Monitorar serviço específico
bytebabe servers monitor <nome>

# Métricas específicas
bytebabe servers monitor --metrics=cpu,mem
```

## Métricas Disponíveis

### Recursos do Sistema
- CPU Usage
- Memory Usage
- Disk Space
- Network I/O

### Métricas de Serviço
- Response Time
- Error Rate
- Request Count
- Active Users

## Alertas

```bash
# Configurar alertas
bytebabe servers alerts set

# Listar alertas
bytebabe servers alerts list

# Remover alerta
bytebabe servers alerts remove
```