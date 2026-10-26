# language: pt
Funcionalidade: Instalação do ByteBabe CLI
  Como desenvolvedor
  Quero instalar o CLI globalmente
  Para usar o comando bytebabe em qualquer diretório

  Cenário: Instalação a partir do clone local
    Dado que estou no diretório raiz do repositório
    E existem install.sh, bin/bytebabe e lib/
    Quando executo ./install.sh
    Então /opt/bytebabe contém bin/bytebabe e lib/
    E /usr/local/bin/bytebabe aponta para /opt/bytebabe/bin/bytebabe
    E bytebabe --version exibe a versão instalada

  Cenário: Instalação a partir da release
    Dado que a release v1.4.0 possui o asset bytebabe-1.4.0.tar.gz
    Quando executo o install.sh remoto
    Então o tarball é baixado e extraído
    E o diretório raiz do tarball é detectado corretamente
    E o CLI é instalado em /opt/bytebabe

  Cenário: Execução via symlink fora do repositório
    Dado que o CLI está instalado em /opt/bytebabe
    E /usr/local/bin/bytebabe é um symlink para o binário
    Quando executo bytebabe devtools h a partir de /tmp
    Então BASE_DIR é resolvido para /opt/bytebabe
    E a ajuda do módulo é exibida sem erro de arquivo não encontrado

  Cenário: Reinstalação idempotente
    Dado que o CLI já está instalado
    Quando executo ./install.sh novamente
    Então a instalação anterior é substituída
    E existe apenas um symlink em /usr/local/bin/bytebabe
    E bytebabe --version continua funcionando

  @pendente
  Cenário: Asset ausente
    Dado que o asset da release não existe
    Quando executo o install.sh remoto
    Então o script exibe uma mensagem de erro clara
    E retorna código de saída 1
