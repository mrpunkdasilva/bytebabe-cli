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

### 🐳 Docker
```bash
# Iniciar containers
bytebabe docker up

# Ver status
bytebabe docker ps

# Parar tudo
bytebabe docker down
```

### 🔧 Git
```bash
# Status estiloso
bytebabe git status

# Commit interativo
bytebabe git commit

# Push com proteção
bytebabe git push
```

### 🌐 Servers
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

## Dicas Pro

```ascii
    /\___/\
   (  o o  )
   (  =^=  ) 
    (______)
```

1. Use TAB para autocompletar
2. Setas ↑↓ para histórico
3. `--help` em qualquer comando
4. `Ctrl+C` sempre funciona

## Atalhos do Teclado

| Atalho | Ação |
|--------|------|
| `Ctrl+C` | Cancelar operação |
| `Ctrl+D` | Sair do modo interativo |
| `Tab` | Autocompletar |
| `↑↓` | Navegar histórico |

## Próximos Passos

- [🔧 Core Modules](core-modules.md)
- [🛠️ Dev Tools](dev-tools.md)