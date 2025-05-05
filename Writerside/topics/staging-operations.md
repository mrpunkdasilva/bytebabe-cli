# Staging Operations

## Smart Staging

Interface interativa para staging de arquivos:

```bash
bytebabe git stage
```

### Características

- Seleção múltipla
- Preview de mudanças
- Filtros por tipo
- Staging parcial
- Undo/Redo

## Comandos Principais

```bash
# Staging interativo
bytebabe git stage

# Staging rápido
bytebabe git stage all

# Unstage
bytebabe git unstage
```

## Modos de Visualização

| Modo | Descrição | Atalho |
|------|-----------|--------|
| List | Lista simples | `l` |
| Tree | Visualização em árvore | `t` |
| Detail | Detalhes completos | `d` |

## Operações Avançadas

### Staging Parcial

```bash
# Selecionar hunks
bytebabe git stage --partial

# Review de mudanças
bytebabe git stage --review
```

### Filtros

```bash
# Por extensão
bytebabe git stage "*.js"

# Por diretório
bytebabe git stage src/
```

## Dicas Pro

1. Use espaço para selecionar
2. Enter para confirmar
3. Tab para navegação
4. ? para ajuda