# language: pt
Funcionalidade: Desenvolvimento frontend
  Como desenvolvedor frontend
  Quero criar projetos e gerar artefatos pelo terminal
  Para acelerar o início e a evolução de aplicações

  Cenário: Criar projeto React
    Dado que estou em um diretório de trabalho
    E o Node.js e um package manager estão disponíveis
    Quando executo bytebabe frontend new react my-app
    Então o projeto my-app é criado com React
    E as dependências são instaladas

  Cenário: Gerar componente
    Dado que estou dentro de um projeto React
    Quando executo bytebabe frontend g component UserProfile
    Então o arquivo do componente UserProfile é criado no diretório correto
    E o framework é detectado automaticamente pelo dispatcher canônico
    E apenas o adaptador React é usado

  Cenário: Gerar componente sem nome
    Dado que estou dentro de um projeto React
    Quando executo bytebabe frontend g component
    Então o comando informa que o nome é obrigatório
    E retorna código de saída 1

  Cenário: Framework não suportado
    Quando executo bytebabe frontend new flutter my-app
    Então o comando exibe os frameworks suportados
    E retorna código de saída 1

  Cenário: Comando desconhecido
    Quando executo bytebabe frontend comando-invalido
    Então a ajuda do módulo é exibida
    E o comando retorna código de saída 1

  Cenário: Setup do ambiente
    Quando executo bytebabe frontend setup
    Então as dependências de frontend são verificadas
    E o comando conclui sem erro de carregamento de módulo

  Cenário: Usar package manager disponível
    Dado que o projeto tem pnpm disponível
    Quando executo um comando de instalação
    Então o pnpm é usado em vez de npm
