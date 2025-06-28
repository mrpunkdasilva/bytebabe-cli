# Init Command

The Init command provides initial system setup and configuration for ByteBabe CLI.

## Overview

This command performs the initial configuration of your development environment, installing essential tools, configuring Git, and setting up Docker.

## Usage

```bash
bytebabe init
```

## Features

### System Updates
- Prompts for system package updates
- Installs essential development tools
- Configures build environment

### Essential Tools Installation
The command installs the following essential packages:
- `build-essential` - Compilation tools
- `libssl-dev` - SSL development libraries
- `zlib1g-dev` - Compression library
- `libbz2-dev` - Bzip2 compression
- `libreadline-dev` - Readline library
- `libsqlite3-dev` - SQLite development
- `llvm` - LLVM compiler infrastructure
- `libncursesw5-dev` - Terminal interface
- `xz-utils` - XZ compression utilities
- `tk-dev` - Tk GUI toolkit
- `libxml2-dev` - XML parsing library
- `libxmlsec1-dev` - XML security
- `libffi-dev` - Foreign function interface
- `liblzma-dev` - LZMA compression
- `jq` - JSON processor
- `unzip` - Archive extraction
- `tree` - Directory listing
- `htop` - Process viewer
- `neofetch` - System information

### Git Configuration
- Sets up Git user identity
- Configures default branch as `main`
- Sets up pull rebase strategy
- Configures VS Code as default editor

### Docker Installation
- Installs Docker if requested
- Configures user permissions
- Sets up Docker group membership

### Node.js Setup
- Installs Node Version Manager (nvm)
- Configures Node.js environment

### Neovim Tools
- Installs Neovim development tools
- Configures editor environment

## Interactive Prompts

The command uses interactive prompts to customize the setup:

### System Updates
```
Deseja atualizar o sistema? (s/n)
```

### Essential Tools
```
Deseja instalar ferramentas de desenvolvimento essenciais? (s/n)
```

### Docker Installation
```
Deseja instalar o Docker? (s/n)
```

### Git Configuration
```
Nome para commits Git: [user input]
Email para commits Git: [user input]
```

## Configuration Storage

The command saves configuration values for future use:
- Git user name and email
- Docker installation status
- System preferences

## Dependencies

- `curl` - For downloads
- `wget` - Alternative download tool
- `git` - Version control system
- `sudo` - Administrative privileges

## Post-Installation

After running the init command:
1. Restart your terminal for Docker group changes to take effect
2. Verify installations with individual module commands
3. Configure additional tools as needed

## Example Output

```
⚡ INICIALIZANDO BYTEBABE CLI ⚡

▶ Atualizando sistema...
Deseja atualizar o sistema? (s/n): s
Atualizando pacotes...

▶ Instalando ferramentas base...
Deseja instalar ferramentas de desenvolvimento essenciais? (s/n): s
Instalando pacotes essenciais...

Nome para commits Git: John Doe
Email para commits Git: john@example.com

▶ Instalando Docker...
Deseja instalar o Docker? (s/n): s
Instalando Docker...
✔ Docker instalado
⚠ Reinicie o terminal para usar Docker sem sudo

⚡ CONFIGURAÇÃO INICIAL COMPLETA! ⚡
```

## Troubleshooting

### Permission Issues
If you encounter permission errors:
```bash
# Check sudo access
sudo -l

# Fix ownership issues
sudo chown -R $USER:$USER ~/.config
```

### Docker Group Issues
If Docker commands require sudo:
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Restart terminal or log out/in
```

### Git Configuration
If Git is not configured:
```bash
# Manual Git setup
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
``` 