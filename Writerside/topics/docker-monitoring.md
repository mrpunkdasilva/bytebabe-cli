# Docker Monitoring 📊

## Comandos Disponíveis

### Estilo Verboso
```bash
bytebabe docker stats [comando] [opções]
```

### Estilo Curto
```bash
bytebabe docker st [cmd] [opts]
```

## Métricas Disponíveis

| Métrica | Verboso | Curto | Descrição |
|---------|---------|-------|-----------|
| CPU | `stats cpu` | `st cpu` | Uso de CPU |
| Memory | `stats mem` | `st mem` | Uso de memória |
| Network | `stats net` | `st net` | I/O de rede |
| Disk | `stats disk` | `st disk` | I/O de disco |
| All | `stats all` | `st all` | Todas métricas |

## Visualizações

- 📈 Gráficos em tempo real
- 📊 Tabelas de recursos
- 🎯 Alertas configuráveis
- 📱 Dashboard móvel
- 📥 Export de dados

## Exemplos

### Estilo Verboso
```bash
# Ver todas as métricas
bytebabe docker stats show --all

# Monitorar container específico
bytebabe docker stats watch --container webapp

# Exportar métricas
bytebabe docker stats export --format json
```

### Estilo Curto
```bash
# Ver todas as métricas
bytebabe docker st show -a

# Monitorar container específico
bytebabe docker st watch -c webapp

# Exportar métricas
bytebabe docker st exp -f json
```

## Opções de Visualização

| Opção | Verboso | Curto | Descrição |
|-------|---------|-------|-----------|
| Live | `--live` | `-l` | Atualização ao vivo |
| Format | `--format` | `-f` | Formato de saída |
| Interval | `--interval` | `-i` | Intervalo de update |
| NoColor | `--no-color` | `-nc` | Sem cores |