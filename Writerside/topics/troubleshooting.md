# Troubleshooting

> "Quando as coisas dão errado, há sempre um caminho cyberpunk para consertar 🔧"

## Problemas Comuns

### Docker

#### 🔴 Docker não está respondendo
```bash
# Erro: Cannot connect to the Docker daemon
```

**Soluções:**
1. Verifique se o daemon está rodando:
   ```bash
   sudo systemctl status docker
   ```
2. Verifique permissões:
   ```bash
   sudo usermod -aG docker $USER
   # Faça logout e login novamente
   ```
3. Reinicie o serviço:
   ```bash
   sudo systemctl restart docker
   ```

#### 🔴 Permissão negada no Docker
```bash
# Erro: Permission denied while trying to connect to the Docker daemon socket
```

**Soluções:**
1. Adicione seu usuário ao grupo docker
2. Use `sudo` temporariamente
3. Verifique permissões do socket:
   ```bash
   sudo chmod 666 /var/run/docker.sock
   ```

### Configuração

#### 🔴 Arquivo de configuração não encontrado
```bash
# Erro: Config file not found in ~/.config/bytebabe/settings.conf
```

**Soluções:**
1. Execute o comando de inicialização:
   ```bash
   bytebabe init
   ```
2. Verifique permissões do diretório:
   ```bash
   chmod 700 ~/.config/bytebabe
   chmod 600 ~/.config/bytebabe/settings.conf
   ```

#### 🔴 Variáveis de ambiente não carregadas
```bash
# Erro: Environment variables not set
```

**Soluções:**
1. Recarregue seu shell:
   ```bash
   source ~/.bashrc
   ```
2. Verifique o arquivo de configuração:
   ```bash
   cat ~/.config/bytebabe/settings.conf
   ```

### Git

#### 🔴 Configurações Git não encontradas
```bash
# Erro: Git configuration not found
```

**Soluções:**
1. Configure Git globalmente:
   ```bash
   bytebabe git config --global
   ```
2. Verifique as configurações:
   ```bash
   bytebabe git config --list
   ```

### Instalação

#### 🔴 Command not found
```bash
# Erro: bytebabe: command not found
```

**Soluções:**
1. Adicione ao PATH:
   ```bash
   echo 'export PATH="$HOME/.bytebabe/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```
2. Verifique a instalação:
   ```bash
   ls -la ~/.bytebabe/bin
   ```

#### 🔴 Dependências faltando
```bash
# Erro: Required dependency not found
```

**Soluções:**
1. Execute o verificador de dependências:
   ```bash
   bytebabe doctor
   ```
2. Instale manualmente as dependências necessárias

## Logs e Diagnóstico

### Verificar Status
```bash
# Verificar status geral
bytebabe status

# Verificar versão
bytebabe --version

# Verificar configuração
bytebabe config show
```

### Logs Detalhados
```bash
# Ativar modo debug
bytebabe --debug <comando>

# Ver logs
cat ~/.bytebabe/logs/bytebabe.log
```

## Ainda com Problemas?

1. Consulte nossa [documentação completa](installation.md)
2. Verifique [issues conhecidas](https://github.com/mrpunkdasilva/bytebabe/issues)
3. Reporte um novo problema no GitHub
4. Use o comando de diagnóstico:
   ```bash
   bytebabe doctor --full
   ```