# Comportamento (BDD)

Os arquivos `.feature` descrevem o comportamento observável do CLI em Gherkin, em português.

## Convenções

- Use `# language: pt` no topo.
- Um arquivo por área funcional.
- Cada cenário MUST ter um resultado verificável.
- Evite detalhes de implementação; descreva entrada, ação e saída.
- Cenários de instalação podem usar ambiente temporário, mas devem declarar pré-condições.
- Marque cenários ainda não implementados com a tag `@pendente`.

## Estrutura

```gherkin
# language: pt
Funcionalidade: Nome curto
  Como <papel>
  Quero <capacidade>
  Para <benefício>

  Contexto:
    Dado <pré-condição comum>

  Cenário: <resultado esperado>
    Dado <estado>
    Quando <ação>
    Então <resultado>
    E <resultado complementar>
```

## Execução

Os cenários são especificação viva. A automação atual está nos testes unitários em `tests/unit/commands/`; quando um runner BDD for adotado, ele MUST usar estes arquivos como fonte.
