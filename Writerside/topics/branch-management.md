# Branch Management 🌿

## Branch Navigator

Interface visual para gerenciar branches:

```bash
bytebabe git branch
```

### Ações Disponíveis

| Ação | Descrição | Comando Rápido |
|------|-----------|----------------|
| Switch Branch | Mudar de branch | `switch` |
| Create Branch | Nova feature branch | `new` |
| Merge Branch | Combinar branches | `merge` |
| Delete Branch | Remover branch local | `delete` |

## Operações Comuns

### Criar Branch

```bash
# Interativo
bytebabe git branch new

# Direto
bytebabe git branch new feature/nome
```

### Merge de Branches

```bash
# Merge interativo
bytebabe git branch merge

# Com confirmação visual
bytebabe git branch merge develop --visual
```

### Deletar Branches

```bash
# Com validação
bytebabe git branch delete feature/old

# Força deleção
bytebabe git branch delete feature/old --force
```

## Proteções

- Validação antes de deletar
- Verificação de merges
- Proteção de branches principais
- Detecção de conflitos