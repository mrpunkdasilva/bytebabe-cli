# Debugging Guide 🔍

## Ferramentas de Debug

### CLI Debug Mode
```bash
# Ativar debug
bytebabe --debug

# Níveis de log
bytebabe --log-level=trace
bytebabe --log-level=debug
bytebabe --log-level=info
```

### Log Viewer
```bash
# Ver logs
bytebabe logs show

# Filtrar logs
bytebabe logs filter --level error
bytebabe logs filter --module docker
```

## Técnicas de Debug

### 1. Isolamento de Problema
```bash
# Testar componente específico
bytebabe test docker
bytebabe test network
bytebabe test database
```

### 2. Verificação de Estado
```bash
# Estado do sistema
bytebabe status

# Componentes específicos
bytebabe docker status
bytebabe network status
```

### 3. Diagnóstico
```bash
# Verificação completa
bytebabe doctor

# Verificações específicas
bytebabe doctor docker
bytebabe doctor network
```

## Debug por Módulo

### Docker Debug
```bash
# Logs do container
bytebabe docker logs <container>

# Inspeção
bytebabe docker inspect <container>

# Network debug
bytebabe docker network debug
```

### Database Debug
```bash
# Teste de conexão
bytebabe db test-connection

# Query log
bytebabe db log-queries

# Performance
bytebabe db analyze-performance
```

### Network Debug
```bash
# Teste de conectividade
bytebabe network test

# Trace de rota
bytebabe network trace

# Port scanning
bytebabe network scan
```

## Análise de Performance

### Profiling
```bash
# CPU profiling
bytebabe profile cpu

# Memory profiling
bytebabe profile memory

# I/O profiling
bytebabe profile io
```

### Benchmarking
```bash
# Benchmark comando
bytebabe benchmark <command>

# Comparação
bytebabe benchmark compare
```