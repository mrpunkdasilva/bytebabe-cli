# Common Issues

## Docker Issues

### 🔴 Container não inicia
```bash
# Erro: Error response from daemon: port is already allocated
```

**Solução:**
1. Verifique portas em uso:
   ```bash
   sudo lsof -i -P -n | grep LISTEN
   ```
2. Altere a porta no docker-compose.yml
3. Pare o serviço usando a porta

### 🔴 Problemas de permissão
```bash
# Erro: Permission denied
```

**Solução:**
1. Adicione seu usuário ao grupo docker:
   ```bash
   sudo usermod -aG docker $USER
   ```
2. Faça logout e login
3. Verifique com: `groups`

## Git Issues

### 🔴 Conflitos de merge
```bash
# Erro: CONFLICT (content): Merge conflict in <file>
```

**Solução:**
1. Use `bytebabe git status` para ver arquivos
2. Resolva conflitos com `bytebabe git merge --tool`
3. Commit as alterações

### 🔴 Branch errada
```bash
# Situação: Commits na branch errada
```

**Solução:**
1. Crie nova branch do ponto atual:
   ```bash
   bytebabe git branch correct-branch
   ```
2. Reset da branch antiga:
   ```bash
   bytebabe git reset --hard HEAD~n
   ```

## Database Issues

### 🔴 Conexão falha
```bash
# Erro: Connection refused
```

**Solução:**
1. Verifique se o serviço está rodando
2. Confira credenciais
3. Teste conectividade:
   ```bash
   bytebabe db test-connection
   ```

### 🔴 Backup falha
```bash
# Erro: Backup failed
```

**Solução:**
1. Verifique permissões
2. Espaço em disco
3. Use modo verbose:
   ```bash
   bytebabe db backup --verbose
   ```

## Network Issues

### 🔴 Firewall bloqueando
```bash
# Erro: Connection timed out
```

**Solução:**
1. Verifique regras:
   ```bash
   bytebabe firewall list
   ```
2. Adicione exceção:
   ```bash
   bytebabe firewall allow <port>
   ```

### 🔴 SSL/TLS
```bash
# Erro: SSL certificate error
```

**Solução:**
1. Verifique certificado:
   ```bash
   bytebabe ssl check
   ```
2. Renove se necessário:
   ```bash
   bytebabe ssl renew
   ```