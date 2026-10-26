# Módulo IDE

## Objetivo

Instalar, executar, listar e verificar IDEs e editores.

## Entry point

`commands/ide.sh`, com serviços em `lib/ide/ide_services.sh`.

## Comandos

| Comando | Ação |
|---------|------|
| `ide vscode` | Instala VS Code |
| `ide zed` | Instala Zed |
| `ide sublime` | Instala Sublime Text |
| `ide toolbox` | Instala JetBrains Toolbox |
| `ide intellij` | Instala IntelliJ IDEA Community |
| `ide pycharm` | Instala PyCharm Community |
| `ide clion` | Instala CLion |
| `ide all` | Instala todas as IDEs |
| `ide install <ide>` | Instala IDE específica |
| `ide run <ide>` | Executa IDE |
| `ide status <ide>` | Verifica instalação/execução |
| `ide list` | Lista IDEs instaladas |

Sem argumentos, abre menu interativo.

## Requisitos

- `install` MUST verificar se a IDE já está instalada.
- `install` MUST reportar falha real e não declarar sucesso incondicional.
- VS Code MUST preferir binário `code` existente (incluindo WSL/Windows) antes de instalar.
- Flatpak MUST ser detectado e instalado/configurado antes do uso.
- `run` MUST usar o comando correto da IDE (`code`, `zed`, `flatpak run ...`).
- `status` MUST distinguir instalado, em execução e ausente.

## Critérios de aceite

- `bytebabe ide list` lista apenas IDEs presentes via Flatpak.
- `bytebabe ide status vscode` identifica a instalação Flatpak.
- `bytebabe ide help` exibe todos os comandos.
- `bytebabe ide vscode` deve reportar erro claro quando Flatpak estiver ausente (critério ainda não atendido).

## Gaps conhecidos

- `install_vscode` chama `flatpak` sem `ensure_flatpak` e suprime erros com `>/dev/null`, podendo declarar sucesso falsamente.
- `ensure_flatpak` assume `apt` e não funciona em Fedora sem ajuste.
- Em WSL, o VS Code do Windows é acessível via `code`, mas `install`/`run`/`status` não o detectam.
- `run` e `status` também dependem exclusivamente do Flatpak.
- `install_toolbox` baixa tarball fixo e pode ficar desatualizado.
