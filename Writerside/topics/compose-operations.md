# Compose Operations 🎭

## Comandos Disponíveis

### Estilo Verboso
```bash
bytebabe docker compose [comando] [opções]
```

### Estilo Curto {id="estilo-curto_1"}
```bash
bytebabe docker co [cmd] [opts]
```

## Operações Básicas

| Operação | Verboso | Curto | Descrição |
|----------|---------|-------|-----------|
| Up | `compose up` | `co up` | Inicia serviços |
| Down | `compose down` | `co down` | Para serviços |
| Logs | `compose logs` | `co logs` | Mostra logs |
| PS | `compose ps` | `co ps` | Lista serviços |
| Build | `compose build` | `co b` | Build serviços |

## Recursos Avançados

- 🔄 Auto-restart policies
- 🌐 Network management
- 📊 Resource limits
- 🔒 Secrets handling
- 🎯 Health checks

## Exemplos

### Estilo Verboso {id="estilo-verboso_1"}
```bash
# Iniciar todos os serviços
bytebabe docker compose up --detach

# Ver logs
bytebabe docker compose logs --follow

# Parar e remover
bytebabe docker compose down --volumes
```

### Estilo Curto
```bash
# Iniciar todos os serviços
bytebabe docker co up -d

# Ver logs
bytebabe docker co logs -f

# Parar e remover
bytebabe docker co down -v
```

## Opções Comuns

| Opção | Verboso | Curto | Descrição |
|-------|---------|-------|-----------|
| Detach | `--detach` | `-d` | Background |
| Follow | `--follow` | `-f` | Follow logs |
| Build | `--build` | `-b` | Force build |
| Volumes | `--volumes` | `-v` | With volumes |