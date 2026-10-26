# Specs do ByteBabe CLI

Esta pasta é a fonte de verdade para produto, arquitetura, comportamento e mudanças do ByteBabe CLI.

## Estrutura

| Pasta | Conteúdo |
|-------|----------|
| `product/` | PRD, visão, personas, requisitos e roadmap |
| `architecture/` | Arquitetura, convenções e instalação |
| `modules/` | Especificação normativa de cada módulo/comando |
| `behavior/` | Cenários BDD em Gherkin |
| `changes/` | Propostas de mudança no fluxo SDD/OpenSpec |
| `templates/` | Modelos para novas specs e cenários |

## Status atual

| Área | Versão | Estado |
|------|--------|--------|
| CLI | `1.4.0` | Estável |
| Instalação local/remota | `1.4.0` | Estável |
| DevTools + Atuin | `1.4.0` | Estável |
| Frontend/Backend | `1.4.0` | Estável |
| Flux | `1.4.0` | Beta (dependências de verbos incompletas) |
| Docker volumes | `1.4.0` | Planejado |

## Fluxo de trabalho

1. **Entender o produto**: leia `product/prd.md`.
2. **Consultar a arquitetura**: leia `architecture/overview.md` e `architecture/conventions.md`.
3. **Verificar o módulo**: leia a spec em `modules/`.
4. **Propor mudanças**: crie `changes/<id>/` a partir de `changes/_template/`.
5. **Escrever cenários**: atualize ou crie arquivos em `behavior/`.
6. **Implementar e testar**: altere o código e rode `bash tests/scripts/run_unit_tests.sh`.
7. **Atualizar a spec**: a mudança só termina quando código, testes, docs e spec estão coerentes.
8. **Arquivar**: mova a mudança concluída para `changes/archive/`.

## Regras

- Use **MUST**, **SHOULD** e **MAY** para separar obrigação, recomendação e opção.
- Toda funcionalidade nova MUST ter critério de aceite e teste automatizado ou justificativa.
- Toda alteração de comportamento MUST atualizar a spec do módulo e, se aplicável, o cenário BDD.
- Não documente comportamento que o código não implementa como se já existisse; marque como **Planejado** ou **Gap conhecido**.
- Exemplos de comando devem ser executáveis na versão atual.

## Como adicionar um módulo

1. Copie `templates/module-spec.md` para `modules/<modulo>.md`.
2. Preencha objetivo, comandos, requisitos, efeitos colaterais, critérios de aceite e gaps.
3. Adicione o módulo em `modules/README.md`.
4. Crie ou atualize o arquivo `.feature` correspondente em `behavior/`.
5. Abra uma proposta em `changes/` se houver mudança de escopo.
