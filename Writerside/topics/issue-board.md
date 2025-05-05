# Issue Board

Este quadro Scrum mostra o status atual das tarefas de desenvolvimento do ByteBabe CLI.

## Sprint Atual: Sprint 12 (15/05 - 29/05)

### Meta do Sprint
Finalizar o módulo Flux e iniciar o desenvolvimento do módulo de segurança.

## Backlog

| ID | Título | Prioridade | Estimativa | Responsável |
|----|--------|------------|------------|-------------|
| BB-145 | Implementar autenticação OAuth no Flux | Alta | 5 | - |
| BB-146 | Adicionar suporte a GraphQL no Flux | Média | 8 | - |
| BB-147 | Criar interface para gerenciamento de certificados SSL | Média | 5 | - |
| BB-148 | Implementar detecção automática de formato de resposta | Baixa | 3 | - |
| BB-149 | Adicionar suporte a WebSockets no Flux | Baixa | 8 | - |

## To Do

| ID | Título | Prioridade | Estimativa | Responsável |
|----|--------|------------|------------|-------------|
| BB-138 | Implementar salvamento de histórico de requisições | Alta | 5 | Maria |
| BB-139 | Adicionar suporte a variáveis de ambiente no Flux | Alta | 3 | João |
| BB-140 | Criar sistema de templates para requisições | Média | 5 | - |
| BB-141 | Implementar validação de esquema JSON | Média | 3 | - |

## Em Progresso

| ID | Título | Prioridade | Estimativa | Responsável |
|----|--------|------------|------------|-------------|
| BB-135 | Implementar formatação avançada de JSON | Alta | 5 | Pedro |
| BB-136 | Adicionar suporte a upload de arquivos | Alta | 8 | Ana |
| BB-137 | Criar sistema de coleções de requisições | Média | 8 | Carlos |

## Em Revisão

| ID | Título | Prioridade | Estimativa | Responsável | Revisor |
|----|--------|------------|------------|-------------|---------|
| BB-132 | Implementar highlight de sintaxe para respostas | Média | 3 | Maria | João |
| BB-133 | Adicionar suporte a múltiplos profiles de configuração | Alta | 5 | Pedro | Ana |
| BB-134 | Criar documentação interativa para o Flux | Alta | 5 | Carlos | Pedro |

## Concluído

| ID | Título | Prioridade | Estimativa | Responsável | Data |
|----|--------|------------|------------|-------------|------|
| BB-128 | Implementar verbos HTTP básicos (GET, POST, PUT, DELETE) | Alta | 8 | João | 18/05 |
| BB-129 | Criar interface visual para exibição de respostas | Alta | 5 | Ana | 19/05 |
| BB-130 | Adicionar suporte a headers customizados | Média | 3 | Pedro | 20/05 |
| BB-131 | Implementar exibição de tempo de resposta | Baixa | 2 | Maria | 21/05 |

## Impedimentos

| ID | Título | Descrição | Responsável | Data |
|----|--------|-----------|-------------|------|
| IMP-12 | Problema com formatação de respostas XML | A biblioteca atual não suporta formatação adequada de XML | Pedro | 22/05 |
| IMP-13 | Conflito de dependências com a biblioteca de UI | A nova versão da biblioteca de UI está causando conflitos | Ana | 23/05 |

## Métricas do Sprint

### Burndown Chart
```ascii
Pontos |
  40   |  *
       |     *
  30   |        *
       |           *
  20   |              *
       |                 *
  10   |                    *
       |                       *
   0   |                          *
       +---------------------------
           1  2  3  4  5  6  7  8  9  10
                      Dias
```

### Velocidade da Equipe
- Sprint 10: 42 pontos
- Sprint 11: 45 pontos
- Sprint 12 (atual): 18/40 pontos (45%)

## Retrospectiva do Sprint Anterior

### O que foi bem
- Implementação dos verbos HTTP básicos concluída antes do prazo
- Boa colaboração entre equipes de front-end e back-end
- Documentação sendo atualizada em paralelo com o desenvolvimento

### O que pode melhorar
- Estimativas de tarefas complexas ainda estão imprecisas
- Alguns testes automatizados estão falhando intermitentemente
- Comunicação sobre dependências entre tarefas

### Ações para o próximo Sprint
- Revisar processo de estimativa para tarefas complexas
- Melhorar a estabilidade dos testes automatizados
- Implementar reuniões diárias mais focadas em dependências