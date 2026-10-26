# Módulo Backend

## Objetivo

Instalar runtimes e frameworks backend e criar projetos Spring Boot.

## Entry points

- `commands/backend.sh`: setup, install e list.
- `commands/backend/spring/main.sh`: comandos `spring`.
- `lib/backend/spring/`: geradores e documentação.

## Comandos

| Comando | Ação |
|---------|------|
| `backend setup` | Modo interativo de configuração |
| `backend install <runtime/framework> [...]` | Instala tecnologias |
| `backend list` | Lista runtimes e frameworks suportados |
| `backend help` | Ajuda |
| `spring new <nome>` | Cria projeto Spring Boot |
| `spring generate <tipo> <nome>` | Gera componente/recurso Spring |

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

- `install_runtime node` não tem fallback para o gerenciador de pacotes se o NVM falhar.
- Alguns instaladores dependem de ferramentas externas (`sdk`, `composer`, `cargo`).
- O menu exibe "8) Todos" para runtimes/frameworks, mas o código testa a opção `7`.
- O teste unitário cobre estrutura e dispatch, não a instalação real de cada runtime.
