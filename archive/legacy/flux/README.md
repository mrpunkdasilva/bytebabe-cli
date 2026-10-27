# Flux legado

Conteúdo arquivado na Fase 4 da refatoração.

## Arquivos

- `verbs-main.sh`: dispatcher antigo dos verbos, substituído por
  `lib/flux/engine.sh` e pelos adaptadores em `lib/flux/verbs/`.
- `postFeature/`: implementação incompleta que era carregada por engano por
  `commands/flux.sh`; substituída por `lib/flux/verbs/post/`.

## Substitutos canônicos

- `lib/flux/engine.sh`: pipeline único de parse, validação, execução, render e
  histórico.
- `lib/flux/args.sh` e `lib/flux/validation.sh`: parser e validação compartilhados.
- `lib/flux/verbs/{get,post,put,delete}/`: adaptadores finos por verbo.

Nenhum arquivo deste diretório é carregado por `commands/flux.sh`.
