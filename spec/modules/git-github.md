# Módulo Git/GitHub

## Objetivo

Oferecer operações Git assistidas e atalhos para o GitHub CLI.

## Entry points

- `commands/git/main.sh`: interface interativa Git Nexus.
- `commands/gh.sh`: comandos GitHub.
- `lib/git/*`: implementação das operações Git.
- `lib/github/*`: implementação das operações GitHub.

## Git

`bytebabe git` abre o menu interativo:

| Opção | Ação |
|-------|------|
| Profile Dashboard | Identidade e estatísticas |
| Smart Staging | Seleção interativa de arquivos |
| Commit Wizard | Commits semânticos guiados |
| Branch Navigator | Gerenciamento visual de branches |
| Push Controller | Push avançado |
| Time Machine | Histórico interativo de commits |
| Repository Settings | Configuração do repositório |

Quick actions: `s` status, `c` commit, `b` branches, `p` push, `q` sair.

## GitHub

Comandos: `clone`, `create`, `commit`, `push`, `pull`, `branch`, `branches`, `checkout`, `pr`, `prs`, `status`, `create-template`, `setup-actions`, `protect-branch`, `release`, `issues`, `issue-create`, `pages`, `clone-all`, `help`.

## Requisitos

- `git` MUST detectar se está dentro de um repositório antes de operar.
- Operações destrutivas (`reset`, `force push`, remoção de branch) MUST pedir confirmação.
- `gh` MUST verificar se o GitHub CLI está instalado e autenticado.
- Comandos GitHub MUST repassar argumentos para `gh`.
- Saída MUST indicar o próximo passo em caso de erro de autenticação.

## Critérios de aceite

- `bytebabe git` abre o menu sem erro.
- `bytebabe gh status` mostra o estado do repositório.
- `bytebabe gh clone usuario/repo` clona o repositório.
- `bytebabe gh pr create` inicia a criação de PR.
- Sem `gh` instalado, o comando informa como instalar/autenticar.

## Gaps conhecidos

- O menu Git é totalmente interativo; não há subcomandos diretos.
- Algumas mensagens usam `bc` e `sleep` sem fallback quando `bc` não está instalado.
- Operações GitHub dependem de autenticação prévia do `gh`.
