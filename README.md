<div align="center">
  <img height="300" src="https://github.com/user-attachments/assets/924b4161-f63a-4ec3-bebb-00d74eff7b73" />
  <br/>
  <img height="50" src=".github/ByteBabe.svg" />

  <h1>ByteBabe CLI</h1>
  <p>A cyberpunk-themed developer toolkit for supercharged workflows 🚀</p>

  <p>
    <a href="#installation">Installation</a> •
    <a href="#key-features">Features</a> •
    <a href="#usage">Usage</a> •
    <a href="#contributing">Contributing</a> •
    <a href="#support">Support</a>
  </p>
</div>

## ⚡ Overview

ByteBabe is a modular CLI toolkit that brings cyberpunk aesthetics to your development workflow. It provides a unified interface for managing development environments, containers, Git operations, databases, and more - all with a unique cyberpunk twist.

## 🎯 Key Features

### 🐳 Docker Management (Poseidon Module)
- Container/image/volume management
- Compose stack handling
- Visual container stats
- Resource monitoring
- Supports both verbose and short command styles

### 🗄️ Database Operations (Oracle Module)
- Support for MySQL, PostgreSQL, MongoDB, Redis
- Backup/restore operations
- Migration tools
- GUI tool integration (TablePlus, DBeaver, etc.)

### 🔧 Git & GitHub Operations (Neo Module)
- Interactive Git interface
- Repository management
- Branch operations
- Semantic commit handling
- GitHub CLI integration
- Pull requests and issues management

### 🛠️ Development Tools (Matrix Module)
- Terminal tools (Zsh, Oh My Zsh, Spaceship, Atuin)
- Database management GUIs
- API testing tools
- Browser tools
- IDE configuration and management
- Quick aliases: `dev`, `dt`, `term`, `atuin`

### ⚙️ System Management (Prime Module)
- Package management (install, upgrade, remove)
- Security tools (firewall, scan, quarantine)
- System utilities (clean, backup, network); deep clean also removes unused Flatpak runtimes and cache
- Service control and monitoring
- System overview with `prime sysinfo`: OS, CPU, RAM/disk usage bars, environment and network

### 🌐 Backend Development
- Multi-language runtime support (Node.js, Python, Java, Go, Rust, PHP)
- Framework installation (Spring Boot, Express, Django, Flask, NestJS, Laravel)
- Universal package manager detection
- Development environment setup

### 🎨 Frontend Development
- Framework support (React, Vue, Angular, Next.js)
- Package manager installation (npm, yarn, pnpm, bun)
- Project scaffolding and generation
- Development server management

### 🔌 API Development (Flux Module)
- REST API client with HTTP verbs (GET, POST, PUT, DELETE)
- JSON server integration
- Request history and management
- Interactive API testing

### 💻 IDE Management
- Multiple IDE support (VS Code, Zed, Sublime, JetBrains)
- Installation and configuration
- Status monitoring
- Quick launch capabilities

### ☁️ Azure DevOps (ADO Module)
- Pull request creation from the current branch (`pr`)
- PR search, filters, grouping and stats dashboard (`prs`)
- Merge workflows with squash support (`merge`)
- Projects, repos, branches and tags listing
- Full passthrough groups (pipelines, boards, artifacts, devops)
- One-shot setup: installs CLI + extension, logs in and saves org/project

### 🚀 Server Management
- Docker-based server orchestration
- Multi-service management
- Status monitoring
- Automated setup and configuration

## 🚀 Installation

### Prerequisites
- 🐧 Linux/Unix or WSL (Windows Subsystem for Linux)
- 🐚 Bash 5+
- 📦 Git
- 🌐 curl or wget (required when installing from the release)
- 🔑 `sudo` (the installer copies files to `/opt` and creates a symlink in `/usr/local/bin`)
- 🐳 Docker (optional; can also be installed later with `bytebabe devtools docker`)

### Quick Install (release v1.5.0)
```bash
# Using curl
curl -fsSL https://raw.githubusercontent.com/mrpunkdasilva/bytebabe-cli/main/install.sh | bash

# Or using wget
wget -qO- https://raw.githubusercontent.com/mrpunkdasilva/bytebabe-cli/main/install.sh | bash
```

The script downloads `bytebabe-1.5.0.tar.gz` from the GitHub release and installs it.

### Manual Installation (recommended for development)
```bash
# Clone the repository
git clone https://github.com/mrpunkdasilva/bytebabe-cli.git
cd bytebabe-cli

# Run the installer (asks for sudo password)
./install.sh

# Refresh the shell command cache and check the version
hash -r
bytebabe --version
```

When `install.sh` runs inside the clone, it installs the local code instead of downloading the release.

### What the installer does
1. Copies the CLI files to `/opt/bytebabe`, replacing any previous installation.
2. Removes `archive/` from the installed copy.
3. Makes `bin/bytebabe` executable.
4. Creates the global symlinks `/usr/local/bin/bytebabe` and `/usr/local/bin/bb` pointing to `/opt/bytebabe/bin/bytebabe`.

### Updating an existing installation
The global `bytebabe` command runs the copy in `/opt/bytebabe`, not the clone. After pulling new changes, run `./install.sh` again inside the clone; otherwise the global command keeps the old code.

To check which copy your shell runs:
```bash
command -v bytebabe
readlink -f "$(command -v bytebabe)"
```

To run the clone directly without reinstalling:
```bash
bash /path/to/bytebabe-cli/bin/bytebabe devtools
```

## 💻 Usage

> `bb` is a short alias for `bytebabe`, created by the installer (e.g. `bb prime sys`).

### 🐳 Docker Operations
```bash
# Verbose style
bytebabe docker containers list --all
bytebabe docker images --list

# Short style (cyberpunk)
bytebabe docker c ls -a
bytebabe docker i --prune
```

### 🗄️ Database Operations
```bash
# Setup database environment
bytebabe db setup

# Start specific database
bytebabe db start postgres

# Check database status
bytebabe db status
```

### 🔧 Git & GitHub Operations
```bash
# Interactive git menu
bytebabe git

# GitHub repository operations
bytebabe gh clone username/repo
bytebabe gh create my-new-repo
bytebabe gh pr "My feature" main
```

### 🛠️ Development Tools
```bash
# Install terminal tools (including Atuin)
bytebabe devtools terminal all
bytebabe devtools terminal atuin

# Install database tools
bytebabe devtools database dbeaver

# Install API tools
bytebabe devtools api --test

# Install Docker
bytebabe devtools docker

# Short aliases
bytebabe devtools t all      # terminal
bytebabe devtools d dbeaver  # database
bytebabe devtools b chrome   # browser
bytebabe devtools a --test   # api
bytebabe dt at               # devtools terminal atuin
bytebabe atuin               # install Atuin
```

### ⚙️ System Management
```bash
# Package management
bytebabe prime install package-name
bytebabe prime upgrade
bytebabe prime remove package-name

# Security tools
bytebabe prime firewall status
bytebabe prime scan system

# System utilities
bytebabe prime clean basic
bytebabe prime clean deep    # also cleans unused Flatpak runtimes and cache
bytebabe prime backup create

# System overview (OS, hardware, disk, environment, network)
bytebabe prime sysinfo
bb prime sys
```

### 🌐 Backend Development
```bash
# Install runtime
bytebabe backend install node
bytebabe backend install python
bytebabe backend install java

# Install framework
bytebabe backend install spring
bytebabe backend install express
```

### 🎨 Frontend Development
```bash
# Setup frontend environment
bytebabe frontend setup

# Create new project
bytebabe frontend new react my-app
bytebabe frontend new vue my-app

# Add features and generate code
bytebabe frontend add tailwind
bytebabe frontend g component Button
```

### 🔌 API Development
```bash
# Start JSON server
bytebabe flux server

# Make API requests
bytebabe flux get users
bytebabe flux post users '{"name": "John"}'
bytebabe flux put users/1 '{"name": "Jane"}'
bytebabe flux delete users/1
```

### 💻 IDE Management
```bash
# Install IDE
bytebabe ide vscode
bytebabe ide zed

# Run IDE
bytebabe ide run code
bytebabe ide status zed
```

### ☁️ Azure DevOps
```bash
# One-shot setup (CLI + extension + login + org/project defaults)
bytebabe azure setup minha-org 'Meu Projeto'

# Create a PR from the current branch
bytebabe azure pr "Minha alteração" main

# List, search and group pull requests
bytebabe azure prs
bytebabe azure prs --mine
bytebabe azure prs --type fix
bytebabe azure prs --stats

# Merge a PR (merge or squash)
bytebabe azure merge 20 squash

# Projects, branches and tags
bytebabe azure projects minha-org
bytebabe azure branches meu-repo
bytebabe azure tags meu-repo

# Full passthrough groups
bytebabe azure pipeline list --output table
bytebabe azure boards work-item show --id 123

# Short alias
bytebabe az prs
```

### 🚀 Server Management
```bash
# Start servers
bytebabe servers up

# Check status
bytebabe servers status

# Stop servers
bytebabe servers down
```

### 🛠️ Utilities
```bash
# Initialize environment
bytebabe init

# Simple text editor
bytebabe edit file.txt

# Greeting message
bytebabe hello
```

### ❓ Help & Version
```bash
# General help (also accepts -h and --help)
bytebabe help

# Detailed help for a command
bytebabe devtools --help
bytebabe frontend --help

# CLI version
bytebabe --version
```

## 📦 Module Overview

| Module | Description | Commands |
|--------|-------------|----------|
| `docker` | Container management | `containers`, `images`, `volumes`, `compose` |
| `db` | Database operations | `setup`, `start`, `stop`, `status` |
| `git` | Git operations | `status`, `stage`, `commit`, `push` |
| `gh` | GitHub operations | `clone`, `create`, `pr`, `issues` |
| `devtools` | Development tools | `terminal`, `database`, `api`, `browser`, `docker` |
| `prime` | System management | `install`, `upgrade`, `firewall`, `scan`, `clean`, `sysinfo` |
| `backend` | Backend development | `install`, `setup`, `generate` |
| `frontend` | Frontend development | `setup`, `new`, `add`, `generate`, `install`, `test`, `build`, `serve` |
| `flux` | API development | `get`, `post`, `put`, `delete`, `server` |
| `ide` | IDE management | `vscode`, `zed`, `sublime`, `run` |
| `servers` | Server management | `up`, `down`, `status`, `setup` |
| `azure` | Azure DevOps operations | `setup`, `pr`, `prs`, `merge`, `projects`, `branches`, `tags` |
| `init` | Environment setup | Complete development environment |
| `edit` | Text editor | Simple file editing |
| `hello` | Greeting | Cyberpunk welcome message |

## 🛠️ Configuration

ByteBabe can be customized through:
- `~/.config/bytebabe/config.json` - General settings
- `~/.config/bytebabe/themes/` - Custom themes
- `~/.config/bytebabe/plugins/` - User plugins

## 🤝 Contributing

### Development Setup
```bash
# Clone and setup
git clone https://github.com/mrpunkdasilva/bytebabe-cli.git
cd bytebabe-cli

# Make your changes
# Follow Conventional Commits for commit messages
git commit -m "feat: add new feature"
git commit -m "fix: resolve bug in module"
```

### Commit Guidelines
We follow [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `refactor:` - Code refactoring
- `style:` - Code style changes
- `perf:` - Performance improvements

## 📝 License

Distributed under the MIT License. See `LICENSE` for more information.

## 💬 Support

- 📐 [Product & Module Specs](spec/README.md)
- 🐛 [Issues](https://github.com/mrpunkdasilva/bytebabe-cli/issues)
- 💡 [Discussions](https://github.com/mrpunkdasilva/bytebabe-cli/discussions)

## 🌟 Acknowledgments

- Built with cyberpunk aesthetics in mind
- Powered by the open source community
- Inspired by modern developer workflows
- Quality-driven development

---

<div align="center">
  <sub>Built with ❤️ by Mr Punk da Silva</sub>
</div>