# Delta de especificação — <título>

## Adicionado

### Requisitos

- `R-<id>`: <novo requisito>

### Comandos

- `bytebabe <novo-comando>`: <comportamento>

## Modificado

### Requisitos

- `R-<id>`: <antes> → <depois>

### Comportamento

- <mudança observável>

## Removido

- `R-<id>`: <requisito removido e motivo>

## Impacto em specs existentes

| Spec | Mudança |
|------|---------|
| `spec/modules/<modulo>.md` | <adição/remoção/ajuste> |
| `spec/behavior/<arquivo>.feature` | <cenário adicionado/alterado> |
| `spec/product/prd.md` | <requisito/roadmap> |

## Rastreabilidade

| Requisito | Teste | Cenário BDD |
|-----------|-------|-------------|
| `R-<id>` | `tests/unit/commands/<arquivo>.test.sh` | `<arquivo>.feature` |
