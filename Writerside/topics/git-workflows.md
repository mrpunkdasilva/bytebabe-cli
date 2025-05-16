# Git Workflows

## Workflows Suportados

> Em desenvolvimento

### GitFlow
```bash
# Iniciar GitFlow
bytebabe git flow init

# Nova feature
bytebabe git flow feature start
```

### Trunk-Based
```bash
# Setup inicial
bytebabe git trunk setup

# Nova branch curta
bytebabe git trunk feature
```

## Commit Patterns

### Commits Semânticos

```bash
# Commit guiado
bytebabe git commit

Tipos disponíveis:
- feat: Nova feature
- fix: Correção de bug
- docs: Documentação
- style: Formatação
- refactor: Refatoração
- test: Testes
- chore: Tarefas
```

## Automações

> Em desenvolvimento


### Auto-Branch
```bash
# Branch por ticket
bytebabe git auto-branch TICKET-123

# Branch por tipo
bytebabe git auto-branch feature/descricao
```

### Auto-Merge
```bash
# Merge automático
bytebabe git auto-merge develop

# Com testes
bytebabe git auto-merge --with-tests
```

## Boas Práticas

1. Use commits semânticos
2. Mantenha branches atualizadas
3. Faça merge frequente
4. Revise antes do push