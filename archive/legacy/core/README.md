# Core legado

Conteúdo arquivado na limpeza pós-refatoração.

## Arquivos

- `tui.sh`: menu principal em `dialog` e `show_cyberpunk_header` duplicado,
  sem chamadores no runtime.
- `tui/database_dialogs.sh`, `tui/docker_dialogs.sh` e
  `tui/spring_dialogs.sh`: diálogos auxiliares da mesma TUI não utilizada.

## Substitutos canônicos

- `lib/core/ui.sh`: headers, banners e seções.
- `lib/core/menu.sh`: menu único com navegação por teclado.
- `lib/core/feedback.sh`: spinners e carregamento.
- `lib/core/pkg.sh` e `lib/core/paths.sh`: pacotes, privilégios e caminhos.

Nenhum arquivo deste diretório é carregado por `bin/`, `commands/` ou `lib/`.
