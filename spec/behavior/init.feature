# language: pt
Funcionalidade: Inicialização do ambiente
  Como desenvolvedor
  Quero configurar meu ambiente com o bytebabe init
  Para começar a desenvolver sem configurar cada ferramenta manualmente

  Cenário: Detecção de gerenciador de pacotes no Fedora
    Dado que o sistema possui dnf
    Quando executo bytebabe init
    Então o gerenciador dnf é detectado
    E a atualização do sistema usa dnf
    E a instalação de ferramentas essenciais usa dnf

  Cenário: Pacotes específicos por distribuição
    Dado que o sistema é Fedora
    Quando confirmo a instalação das ferramentas essenciais
    Então a lista de pacotes usa nomes disponíveis no dnf
    E gawk, git, curl e wget são incluídos quando necessário
    E pacotes indisponíveis são ignorados sem interromper toda a instalação

  Cenário: Node.js já instalado com NVM
    Dado que o NVM já está instalado
    E node e npm estão disponíveis no PATH
    Quando executo bytebabe init
    Então o NVM não é reinstalado
    E a versão atual do Node é reportada

  Cenário: Node.js ausente com NVM indisponível
    Dado que node não está instalado
    E a instalação via NVM falha
    Quando executo bytebabe init
    Então o Node é instalado pelo gerenciador de pacotes da distro
    E o comando informa a versão instalada

  Cenário: Docker opcional
    Dado que o Docker não está instalado
    Quando o init pergunta se desejo instalar o Docker
    E eu recuso
    Então a instalação do Docker é ignorada
    E o restante da configuração continua
