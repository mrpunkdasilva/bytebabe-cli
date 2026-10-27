# language: pt
Funcionalidade: Docker
  Como usuário do ByteBabe
  Quero gerenciar recursos Docker com ou sem interface interativa
  Para operar containers, imagens e compose de forma previsível

  Cenário: Ajuda sem daemon
    Dado que o Docker não está disponível
    Quando executo "bytebabe docker help"
    Então o comando retorna sucesso
    E exibe "TRIDENTE DE COMANDOS"

  Cenário: Ajuda de containers sem daemon
    Dado que o Docker não está disponível
    Quando executo "bytebabe docker containers help"
    Então o comando retorna sucesso
    E exibe as ações de containers

  Cenário: Ajuda de volumes sem daemon
    Dado que o Docker não está disponível
    Quando executo "bytebabe docker volumes help"
    Então o comando retorna sucesso
    E exibe as ações de volumes

  Cenário: Listar volumes sem menu
    Dado que o Docker está acessível
    Quando executo "bytebabe docker volumes ls"
    Então o comando retorna sucesso
    E lista os volumes
    E não abre menu interativo

  Cenário: Listar containers sem menu
    Dado que o Docker está acessível
    Quando executo "bytebabe docker containers ls -a"
    Então o comando retorna sucesso
    E lista containers parados e em execução
    E não abre menu interativo

  Cenário: Listar apenas containers em execução
    Dado que o Docker está acessível
    Quando executo "bytebabe docker containers running"
    Então o comando retorna sucesso
    E lista apenas containers em execução

  Cenário: Docker ausente em comando operacional
    Dado que o Docker não está instalado
    Quando executo "bytebabe docker containers ls"
    Então o comando retorna código 1
    E exibe instrução de instalação

  Cenário: Compose sem plugin
    Dado que o Docker está acessível
    E o Docker Compose não está instalado
    Quando executo "bytebabe docker compose up"
    Então o comando retorna código 1
    E exibe instrução de instalação do Compose
