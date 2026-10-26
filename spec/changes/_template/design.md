# Design — <título>

## Visão técnica

<Como a solução será implementada?>

## Arquivos afetados

| Arquivo | Mudança |
|---------|---------|
| `<caminho>` | <descrição> |

## Contratos

### Entrada

```text
<comando, argumentos, flags e pré-condições>
```

### Saída

```text
<saída esperada, código de saída e efeitos colaterais>
```

## Fluxo

```text
<entrada> → <processamento> → <saída>
```

## Dependências

- <ferramenta/pacote e fallback>

## Compatibilidade

- Linux/WSL: <impacto>
- Distros: <apt/dnf/pacman/...>
- Versão anterior: <breaking change?>

## Segurança

- [ ] Nenhum segredo exposto
- [ ] Comandos destrutivos pedem confirmação
- [ ] Downloads usam HTTPS
- [ ] Privilégios mínimos

## Testes

| Tipo | Cenário |
|------|---------|
| Unitário | <teste> |
| BDD | `<arquivo>.feature` |
| Manual | <passos> |
