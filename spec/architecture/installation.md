# Instalação

## Objetivo

Instalar o ByteBabe CLI de forma idempotente, reproduzível e funcional a partir de qualquer diretório, incluindo ambientes WSL.

## Caminhos oficiais

| Caminho | Papel |
|---------|-------|
| `/opt/bytebabe` | Instalação completa |
| `/opt/bytebabe/bin/bytebabe` | Executável real |
| `/usr/local/bin/bytebabe` | Symlink global |
| `/tmp/bytebabe-install` | Diretório temporário do modo remoto |

## Modos de instalação

### Local (recomendado para desenvolvimento)

```bash
git clone https://github.com/mrpunkdasilva/bytebabe-cli.git
cd bytebabe-cli
./install.sh
```

Requisitos:

- `install.sh`, `bin/bytebabe` e `lib/` devem existir no diretório do script.
- O código local é copiado para `/opt/bytebabe`, sem baixar release.

### Remoto (release)

```bash
curl -fsSL https://raw.githubusercontent.com/mrpunkdasilva/bytebabe-cli/main/install.sh | bash
```

O script:

1. Baixa `https://github.com/mrpunkdasilva/bytebabe-cli/releases/download/v<versao>/bytebabe-<versao>.tar.gz`.
2. Extrai em `/tmp/bytebabe-install`.
3. Localiza `*/bin/bytebabe` para descobrir o diretório raiz.
4. Remove `/opt/bytebabe` anterior e copia a nova instalação.
5. Executa `chmod +x` no binário.
6. Cria/atualiza o symlink em `/usr/local/bin`.
7. Remove arquivos temporários.

## Requisitos

- Linux ou WSL
- Bash 4+
- `git`, `curl` ou `wget`
- `sudo` com permissão para escrever em `/opt` e `/usr/local/bin`
- Docker opcional

## Critérios de aceite

- `bytebabe --version` MUST exibir a versão instalada fora do repositório.
- `bytebabe help` MUST listar os comandos disponíveis.
- `bytebabe init` MUST iniciar o fluxo de configuração.
- O CLI MUST funcionar quando chamado por `/usr/local/bin/bytebabe` ou por qualquer symlink para o binário.
- Reexecutar `./install.sh` MUST substituir a instalação anterior sem duplicar symlinks.
- O asset remoto MUST ser baixável e conter `bin/`, `lib/`, `commands/` e `install.sh`.

## Falhas conhecidas e tratamento

| Falha | Comportamento esperado |
|-------|------------------------|
| Release/asset inexistente | Erro claro e saída `1` |
| Tarball sem `bin/bytebabe` | Erro claro e saída `1` |
| `/opt/bytebabe` sem permissão | Erro do `sudo` visível ao usuário |
| `BASE_DIR` resolvido como `/usr/local` | Corrigido pela resolução de symlink no `bin/bytebabe` |
| Flatpak ausente | Módulo IDE deve reportar pré-requisito, não declarar sucesso |

## Verificação pós-instalação

```bash
cd /tmp
hash -r
bytebabe --version
bytebabe help
bytebabe devtools h
```

## Rollback

Como a instalação é uma cópia versionada em `/opt/bytebabe`, o rollback consiste em reinstalar uma release anterior:

```bash
curl -fsSL https://raw.githubusercontent.com/mrpunkdasilva/bytebabe-cli/main/install.sh | bash
```

Para versão específica, ajuste o asset/tag no instalador ou reinstale a partir do clone correspondente.
