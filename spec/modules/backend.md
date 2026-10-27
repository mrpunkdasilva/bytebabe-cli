# Módulo Backend

## Objetivo

Instalar runtimes e frameworks backend e criar projetos Spring Boot.

## Entry points

- `commands/backend.sh`: setup, install e list.
- `commands/backend/spring/main.sh`: comandos `spring`, sem `exit` e source-safe.
- `lib/backend/spring/generators/main.sh`: carregador canônico dos geradores.
- `lib/backend/spring/`: configuração, documentação, deploy e testes.

## Comandos

| Comando | Ação |
|---------|------|
| `backend setup` | Modo interativo de configuração |
| `backend install <runtime/framework> [...]` | Instala tecnologias |
| `backend list` | Lista runtimes e frameworks suportados |
| `backend help` | Ajuda |
| `spring new <nome>` | Cria projeto Spring Boot |
| `spring generate <tipo> <nome>` | Gera componente/recurso Spring |
| `spring generate crud <nome>` | Gera entity, DTO, repository, service e controller |
| `spring test service <nome>` | Gera teste unitário do service |
| `spring docs setup` | Configura Swagger/OpenAPI |
| `spring docker setup` | Gera Dockerfile, compose e dockerignore |
| `spring security audit run` | Executa auditoria de segurança |
| `spring security scan docker` | Escaneia o Dockerfile |
| `spring monitor setup prometheus` | Configura Prometheus |
| `spring monitor logs export` | Exporta logs da aplicação |
| `spring deploy k8s setup` | Gera manifestos Kubernetes |

## Geradores Spring

O carregador canônico é `lib/backend/spring/generators/main.sh`. Cada tipo tem
uma única implementação ativa:

| Tipo | Arquivo |
|------|---------|
| `entity` | `generators/entity.sh` |
| `dto` | `generators/dto.sh` |
| `repository` | `generators/repository.sh` |
| `service` | `generators/service.sh` |
| `controller` | `generators/controller.sh` |
| `crud` | `generators/crud.sh` |
| `mapper` | `generators/mapper.sh` |
| `exception-handler` | `generators/exception_handler.sh` |
| `security` | `generators/security_config.sh` |

Os geradores usam `get_package`/`get_default_package` e respeitam o
`.bytebabe/spring-config.json`. `mapper` gera uma interface MapStruct com
`toDto`, `toEntity` e `updateEntity`. Os generators duplicados
(`*_generator.sh`) e o carregador paralelo `lib/backend/spring/generators.sh`
foram movidos para `archive/legacy/spring/generators/`.

O entrypoint carrega `security.sh`, `monitoring.sh` e `deployment.sh`. As
funções de segurança geram relatório e escaneiam Dockerfile; monitoramento
exporta métricas/logs e analisa padrões; deploy cobre Kubernetes e provedores
cloud. `docs` e testes continuam usando os generators canônicos; os módulos
antigos `documentation.sh` e `testing.sh` foram movidos para
`archive/legacy/spring/`.

## Runtimes

`node`, `php`, `python`, `java`, `go`, `rust`, `elixir`.

## Frameworks

`express`, `django`, `flask`, `spring`, `nestjs`, `laravel`, `phoenix`.

## Requisitos

- `install` MUST aceitar múltiplas tecnologias.
- `install` MUST rejeitar tecnologia desconhecida com lista de opções.
- `setup` sem argumentos MUST abrir menu; com argumentos MUST executar direto.
- Detecção de gerenciador de pacotes MUST ser usada para dependências do sistema.
- Java SHOULD usar SDKMAN quando disponível.
- Node SHOULD usar NVM; o fallback para o gerenciador de pacotes existe no `init`, não no `backend install`.

## Critérios de aceite

- `bytebabe backend list` exibe runtimes e frameworks.
- `bytebabe backend install node` instala Node ou reporta que já existe.
- `bytebabe backend install tecnologia-invalida` retorna erro claro.
- `bytebabe spring new demo` cria o projeto Spring Boot.

## Gaps conhecidos

- `spring new` depende de rede para baixar do Spring Initializr.
- `security`, `monitor` e `deploy` dependem de ferramentas externas
  (`mvn`, `kubectl`, `aws`, `gcloud`, `az`) para as operações reais.
- `install_runtime node` não tem fallback para o gerenciador de pacotes se o NVM falhar.
- Alguns instaladores dependem de ferramentas externas (`sdk`, `composer`, `cargo`).
- O menu exibe "8) Todos" para runtimes/frameworks, mas o código testa a opção `7`.
- O teste unitário cobre estrutura e dispatch, não a instalação real de cada runtime.
