# Quick Start

> "A vida é curta demais para CLIs complicadas"

## Primeiros Comandos

### Hello World!
```bash
bytebabe hello
```

### Ver todos os comandos
```bash
bytebabe --help
```

## Módulos Principais

### Docker
```bash
# Iniciar containers
bytebabe docker up

# Ver status
bytebabe docker ps

# Parar tudo
bytebabe docker down
```

### Git
```bash
# Status estiloso
bytebabe git status

# Commit interativo
bytebabe git commit

# Push com proteção
bytebabe git push
```

### Servers
```bash
# Iniciar servidor de desenvolvimento
bytebabe servers dev

# Configurar proxy reverso
bytebabe servers proxy
```

## Exemplos Práticos

### Configurar Ambiente de Desenvolvimento
```bash
# Configurar ambiente
bytebabe init

# Configurar ambiente Docker
bytebabe docker init

# Iniciar serviços
bytebabe docker up
```

### Workflow Git
```bash
# Ver status do repo
bytebabe git status

# Staging interativo
bytebabe git stage

# Commit com mensagem formatada
bytebabe git commit
```

## Próximos Passos

- [Docker Module](docker-module.md)
- [Git Module](git-module.md)
- [Servers](servers.md)
- [Database Module](database-module.md)
