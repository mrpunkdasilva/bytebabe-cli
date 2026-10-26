# language: pt
Funcionalidade: Ferramentas de desenvolvimento
  Como desenvolvedor
  Quero instalar e configurar ferramentas de terminal, banco, navegador e API
  Para padronizar meu ambiente de trabalho

  Cenário: Instalar Atuin
    Dado que o Atuin não está instalado
    Quando executo bytebabe devtools terminal atuin
    Então o instalador oficial é executado ou o pacote é instalado
    E o PATH do Atuin é configurado em .zshrc e .bashrc
    E a linha de init do Atuin não é duplicada

  Cenário: Atuin já instalado
    Dado que o comando atuin já está disponível
    Quando executo bytebabe devtools t at
    Então o módulo informa que o Atuin já está instalado
    E a configuração do shell é verificada novamente

  Cenário: Alias global de Atuin
    Dado que o alias global atuin está configurado
    Quando executo bytebabe atuin
    Então o comando é expandido para devtools terminal atuin

  Cenário: Listar navegadores instalados
    Dado que pelo menos um navegador está instalado
    Quando executo bytebabe devtools b list
    Então os navegadores detectados são exibidos
    E nenhum navegador é instalado

  Cenário: Ajuda do módulo
    Quando executo bytebabe devtools h
    Então os comandos terminal, database, browser, api e help são exibidos
    E os aliases t, d, b, a e h são mostrados
