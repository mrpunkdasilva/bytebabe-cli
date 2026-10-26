# Mudanças (SDD/OpenSpec)

Cada mudança relevante deve ter uma pasta própria em `spec/changes/`, descrevendo o problema, o design, as tarefas e o delta de especificação.

## Nome da pasta

```text
spec/changes/YYYY-MM-DD-slug-curto/
```

Exemplo: `spec/changes/2026-10-26-ide-code-detection/`.

## Arquivos obrigatórios

| Arquivo | Conteúdo |
|---------|----------|
| `proposal.md` | Problema, motivação, escopo, alternativas e riscos |
| `design.md` | Solução técnica, contratos e impacto |
| `tasks.md` | Checklist de implementação e testes |
| `spec-delta.md` | O que muda nas specs existentes |

## Ciclo de vida

```text
draft → proposed → accepted → implementing → verifying → archived
```

1. **Draft**: ideia em rascunho.
2. **Proposed**: proposta pronta para revisão.
3. **Accepted**: escopo aprovado.
4. **Implementing**: código em andamento.
5. **Verifying**: testes e validação.
6. **Archived**: concluída e documentada.

## Definition of Done

- [ ] Código implementado
- [ ] Testes unitários passando
- [ ] `bash tests/scripts/run_unit_tests.sh` com 100% de aprovação
- [ ] Spec do módulo atualizada
- [ ] Cenário BDD criado/atualizado
- [ ] README/help/CHANGELOG atualizados quando aplicável
- [ ] `spec-delta.md` refletindo o estado final
- [ ] Revisão de segurança (segredos, comandos destrutivos)
- [ ] Pasta movida para `spec/changes/archive/` com status `archived`

## Exemplo de fluxo

```bash
mkdir -p spec/changes/2026-10-26-ide-code-detection
cp spec/changes/_template/*.md spec/changes/2026-10-26-ide-code-detection/
```

Depois edite os arquivos, implemente, valide e arquive.
