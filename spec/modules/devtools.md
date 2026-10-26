# Módulo DevTools

## Objetivo

Instalar e configurar ferramentas de terminal, bancos, navegadores e APIs.

## Entry point

`commands/devtools.sh`, com implementações em `lib/devtools/`.

## Comandos

| Comando | Aliases | Ação |
|---------|---------|------|
| `bytebabe devtools terminal` | `term`, `t` | Zsh, Oh My Zsh, Spaceship, Atuin, plugins |
| `bytebabe devtools database` | `db`, `d` | TablePlus, DBeaver, MongoDB Compass, pgAdmin, MySQL Workbench |
| `bytebabe devtools browser` | `bwsr`, `b` | Chrome, Firefox, Brave, Edge, Vivaldi |
| `bytebabe devtools api` | `api-tools`, `a` | curl, httpie, jq, yq, grpcurl, websocat e ferramentas de docs/proxy |
| `bytebabe devtools help` | `h` | Ajuda do módulo |

Sem argumentos, abre menu interativo.

## Terminal

| Comando | Ação |
|---------|------|
| `terminal zsh`, `z` | Instala Zsh e opcionalmente define como padrão |
| `terminal ohmyzsh`, `omz`, `oh-my-zsh` | Instala Oh My Zsh |
| `terminal spaceship`, `sp`, `space` | Instala Spaceship Prompt |
| `terminal atuin`, `at` | Instala e configura Atuin |
| `terminal plugins`, `p` | Configura plugins do Zsh |
| `terminal all`, `a` | Instala Zsh, Oh My Zsh, Spaceship, Atuin e plugins |

## Database

`tableplus`, `dbeaver`, `compass`, `pgadmin`, `mysql`, `all`, `list`.

## Browser

`chrome`, `firefox`, `brave`, `edge`, `vivaldi`, `all`, `list`.

## API

- `--test [ferramentas...]`: instala ferramentas de teste.
- `--docs [all]`: instala Swagger/OpenAPI/Redoc/Spectral.
- `--proxy [ferramentas...]`: instala ferramentas de proxy/debug.
- `--gui [ferramentas...]`: instala ferramentas GUI.
- Sem argumentos: menu interativo.

## Aliases globais

| Alias | Expansão |
|-------|----------|
| `bytebabe dev` | `devtools` |
| `bytebabe dt` | `devtools terminal` |
| `bytebabe term` | `devtools terminal` |
| `bytebabe atuin` | `devtools terminal atuin` |

## Requisitos

- Detectar o gerenciador de pacotes antes de instalar.
- Atuin MUST ser instalado via pacote ou instalador oficial e configurado em `.zshrc`/`.bashrc`.
- A configuração do Atuin MUST ser idempotente (não duplicar `atuin init`).
- Navegadores e ferramentas GUI SHOULD usar o gerenciador nativo, com fallback para Snap ou AUR quando aplicável.
- `list` MUST reportar ferramentas instaladas sem instalar nada.
- Falha de uma ferramenta MUST ser exibida sem derrubar o menu inteiro.

## Critérios de aceite

- `bytebabe devtools t at` instala o Atuin e adiciona `eval "$(atuin init zsh)"` uma única vez.
- `bytebabe atuin` funciona como atalho global.
- `bytebabe devtools b list` lista navegadores sem erro.
- `bytebabe devtools h` exibe todos os aliases.

## Gaps conhecidos

- `install_vscode` em `lib/ide` usa Flatpak sem verificar se ele existe (ver módulo IDE).
- Instaladores de navegadores usam `apt`/`dnf`/`rpm`/Snap/AUR, não Flatpak.
- Instaladores de navegadores precisam de validação em todas as distros.
- O Atuin requer reinício do shell para ativar `Ctrl+R`.
