# Volume Management 💾

## Comandos Disponíveis

### Estilo Verboso {id="estilo-verboso_1"}
```bash
bytebabe docker volumes [comando] [opções]
```

### Estilo Curto
```bash
bytebabe docker v [cmd] [opts]
```

## Operações Básicas

| Operação | Verboso | Curto | Descrição |
|----------|---------|-------|-----------|
| Listar | `volumes list` | `v ls` | Lista volumes |
| Criar | `volumes create` | `v new` | Cria volume |
| Inspecionar | `volumes inspect` | `v i` | Detalhes do volume |
| Remove | `volumes remove` | `v rm` | Remove volume |
| Prune | `volumes prune` | `v p` | Limpa não usados |

## Tipos de Volume

- 🔧 Local
- 🌐 NFS
- ☁️ Cloud Storage
- 🔒 Encrypted
- 📦 Plugin Volumes

## Exemplos

### Estilo Verboso
```bash
# Criar volume
bytebabe docker volumes create --name dbdata

# Listar volumes
bytebabe docker volumes list

# Remover volume
bytebabe docker volumes remove dbdata
```

### Estilo Curto {id="estilo-curto_1"}
```bash
# Criar volume
bytebabe docker v new -n dbdata

# Listar volumes
bytebabe docker v ls

# Remover volume
bytebabe docker v rm dbdata
```

## Opções Comuns

| Opção | Verboso | Curto | Descrição |
|-------|---------|-------|-----------|
| Nome | `--name` | `-n` | Nome do volume |
| Driver | `--driver` | `-d` | Driver do volume |
| Force | `--force` | `-f` | Força operação |
| Quiet | `--quiet` | `-q` | Modo silencioso |