# Web Servers

O módulo de servidores web do ByteBabe permite gerenciar instâncias Docker do Apache e Nginx de forma simplificada.

## Configuração Padrão

- Apache: porta 8080
- Nginx: porta 8081
- SSL: porta 4430

## Comandos Básicos

```bash
# Configuração inicial
bytebabe servers setup

# Iniciar servidores
bytebabe servers up [apache|nginx]

# Parar servidores
bytebabe servers down [apache|nginx]

# Ver status
bytebabe servers status
```

## Estrutura de Diretórios

```
docker/
├── apache/
│   └── index.html
├── nginx/
│   ├── nginx.conf
│   └── index.html
└── ssl/
```