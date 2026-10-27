# Frontend generators legados

Conteúdo arquivado na Fase 6 da refatoração.

## Arquivos

- `duplicated-generators.sh`: versão antiga de `lib/frontend/generators.sh`
  que duplicava `generate_react_component`, `generate_react_hook` e
  `generate_api_service` já definidos nos adaptadores por framework.
- `duplicated-main.sh`: versão antiga de `lib/frontend/main.sh` que repetia
  `detect_framework`, `generate_component` e `generate_service`, além de usar
  `exit` nas validações.

## Substitutos canônicos

- `lib/frontend/generators.sh`: dispatcher único, detecção de framework e
  validação compartilhada.
- `lib/frontend/react/generators.sh`, `lib/frontend/vue/generators.sh` e
  `lib/frontend/angular/generators.sh`: adaptadores específicos.
- `lib/frontend/main.sh`: requisitos, detecção de package manager via core e
  helpers de instalação/execução.

Nenhum arquivo deste diretório é carregado por `commands/frontend.sh`.
