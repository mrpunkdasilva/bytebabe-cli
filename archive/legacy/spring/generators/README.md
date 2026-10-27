# Spring generators legados

Conteúdo arquivado na Fase 5 da refatoração.

## Arquivos

- `controller_generator.sh`, `repository_generator.sh`, `service_generator.sh`:
  implementações paralelas de `generate_controller`, `generate_repository` e
  `generate_service`. Dependiam de helpers (`find_package_path`,
  `get_package_name`) que não existiam e geravam pacotes em layout diferente do
  restante do CLI.
- `../generators.sh`: carregador paralelo que duplicava o conjunto carregado por
  `lib/backend/spring/generators/main.sh`.

## Substitutos canônicos

- `lib/backend/spring/generators/controller.sh`
- `lib/backend/spring/generators/repository.sh`
- `lib/backend/spring/generators/service.sh`
- `lib/backend/spring/generators/main.sh`

Nenhum arquivo deste diretório é carregado por `commands/backend/spring/main.sh`.
