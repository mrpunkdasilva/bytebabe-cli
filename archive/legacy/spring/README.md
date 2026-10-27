# Spring legado

Conteúdo arquivado na Fase 5 da refatoração.

## Arquivos

- `generators.sh`: carregador paralelo antigo, substituído por
  `lib/backend/spring/generators/main.sh`.
- `generators/controller_generator.sh`, `repository_generator.sh` e
  `service_generator.sh`: implementações duplicadas substituídas pelos
  generators canônicos por tipo.
- `documentation.sh` e `testing.sh`: módulos não carregados pelo entrypoint;
  suas funções ativas (`setup_swagger` e `generate_service_test`) já existem
  nos generators canônicos. As funções extras permanecem apenas como
  histórico.

## Substitutos canônicos

- `lib/backend/spring/generators/main.sh`: carrega e expõe um generator ativo
  por tipo.
- `lib/backend/spring/generators/{entity,dto,repository,service,controller,crud,mapper,exception_handler,security_config}.sh`:
  implementações canônicas.
- `lib/backend/spring/config.sh`: configuração e helpers de package.

Nenhum arquivo deste diretório é carregado por `commands/backend/spring/main.sh`.
