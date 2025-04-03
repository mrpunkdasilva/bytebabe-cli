# Container Management 🎮

## Comandos Disponíveis

### Estilo Verboso
```bash
bytebabe docker containers [comando] [opções]
```

### Estilo Curto
```bash
bytebabe docker c [cmd] [opts]
```

## Operações Básicas

| Operação | Verboso | Curto | Descrição |
|----------|---------|-------|-----------|
| Listar | `containers list` | `c ls` | Lista containers |
| Iniciar | `containers start` | `c up` | Inicia containers |
| Parar | `containers stop` | `c down` | Para containers |
| Reiniciar | `containers restart` | `c rs` | Reinicia containers |
| Remover | `containers remove` | `c rm` | Remove containers |

## Menu Interativo

O Container Commander oferece:
- 📋 Listagem de containers
- 🟢 Containers em execução
- 🔍 Pesquisa de containers
- 🆕 Criação de containers
- 📊 Estatísticas do sistema

## Exemplos

### Estilo Verboso
```bash
# Listar todos os containers
bytebabe docker containers list --all

# Iniciar container específico
bytebabe docker containers start my-container

# Remover container com volumes
bytebabe docker containers remove --volumes my-container
```

### Estilo Curto
```bash
# Listar todos os containers
bytebabe docker c ls -a

# Iniciar container específico
bytebabe docker c up my-container

# Remover container com volumes
bytebabe docker c rm -v my-container
```

## Opções Comuns

| Opção | Verboso | Curto | Descrição |
|-------|---------|-------|-----------|
| Todos | `--all` | `-a` | Inclui parados |
| Detach | `--detach` | `-d` | Roda em background |
| Force | `--force` | `-f` | Força operação |
| Volumes | `--volumes` | `-v` | Include volumes |