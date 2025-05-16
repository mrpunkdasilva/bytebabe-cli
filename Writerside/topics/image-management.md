# Image Management

## Comandos Disponíveis

### Estilo Verboso
```bash
bytebabe docker images [comando] [opções]
```

### Estilo Curto {id="estilo-curto_1"}
```bash
bytebabe docker i [cmd] [opts]
```

## Operações Básicas

| Operação | Verboso | Curto | Descrição |
|----------|---------|-------|-----------|
| Listar | `images list` | `i ls` | Lista imagens |
| Pull | `images pull` | `i p` | Baixa imagens |
| Push | `images push` | `i ps` | Envia imagens |
| Build | `images build` | `i b` | Constrói imagens |
| Remove | `images remove` | `i rm` | Remove imagens |

## Categorias de Imagens

- 🌐 Web Servers: nginx, apache, httpd
- 🛢️ Databases: mysql, postgres, mongo
- 💻 OS Base: ubuntu, alpine, debian
- 🛠️ Dev Tools: node, python, golang
- 📊 Monitoring: grafana, prometheus
- 🔒 Security: vault, owasp/zap

## Exemplos

### Estilo Verboso {id="estilo-verboso_1"}
```bash
# Listar todas as imagens
bytebabe docker images list --all

# Pull de imagem específica
bytebabe docker images pull nginx:latest

# Build com tag
bytebabe docker images build --tag myapp:1.0 .
```

### Estilo Curto
```bash
# Listar todas as imagens
bytebabe docker i ls -a

# Pull de imagem específica
bytebabe docker i p nginx:latest

# Build com tag
bytebabe docker i b -t myapp:1.0 .
```

## Opções Comuns

| Opção | Verboso | Curto | Descrição |
|-------|---------|-------|-----------|
| Todos | `--all` | `-a` | Mostra intermediárias |
| Tag | `--tag` | `-t` | Define tag |
| Force | `--force` | `-f` | Força operação |
| Quiet | `--quiet` | `-q` | Só IDs |