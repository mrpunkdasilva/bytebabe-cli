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
- Terminal tools (Zsh + plugins)
- Database management GUIs
- API testing tools
- Browser tools
- IDE configuration and management

### ⚙️ System Management (Prime Module)
- Package management (install, upgrade, remove)
- Security tools (firewall, scan, quarantine)
- System utilities (clean, backup, network)
- Service control and monitoring
- System information and stats

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

### 🚀 Server Management
- Docker-based server orchestration
- Multi-service management
- Status monitoring
- Automated setup and configuration

## 🚀 Installation

### Prerequisites
- 🐧 Linux/Unix (sorry Windows-chan)
- 🐚 Bash 4+
- 📦 Git
- 🌐 curl or wget
- 🐳 Docker (optional)

### Quick Install
```bash
# Using curl
curl -fsSL https://raw.githubusercontent.com/mrpunkdasilva/bytebabe/main/install.sh | bash

# Or using wget
wget -qO- https://raw.githubusercontent.com/mrpunkdasilva/bytebabe/main/install.sh | bash
```

### Manual Installation
```bash
# Clone the repository
git clone https://github.com/mrpunkdasilva/bytebabe.git
cd bytebabe

# Run the installer
./install.sh
```

## 💻 Usage

### 🐳 Docker Operations
```bash
# Verbose style
bytebabe docker containers list --all
bytebabe docker images pull nginx

# Short style (cyberpunk)
bytebabe docker c ls -a
bytebabe docker i p nginx
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
# Interactive git status
bytebabe git status

# GitHub repository operations
bytebabe gh clone username/repo
bytebabe gh create my-new-repo
bytebabe gh pr create
```

### 🛠️ Development Tools
```bash
# Install terminal tools
bytebabe devtools terminal all

# Install database tools
bytebabe devtools database dbeaver

# Install API tools
bytebabe devtools api --test
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
bytebabe prime clean temp
bytebabe prime backup create
```

### 🌐 Backend Development
```bash
# Install runtime
bytebabe backend install node
bytebabe backend install python
bytebabe backend install java

# Setup framework
bytebabe backend spring setup
bytebabe backend express setup
```

### 🎨 Frontend Development
```bash
# Setup frontend environment
bytebabe frontend setup

# Create new project
bytebabe frontend new react my-app
bytebabe frontend new vue my-app
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
bytebabe byteedit file.txt

# Greeting message
bytebabe hello
```

## 📦 Module Overview

| Module | Description | Commands |
|--------|-------------|----------|
| `docker` | Container management | `containers`, `images`, `volumes`, `compose` |
| `db` | Database operations | `setup`, `start`, `stop`, `status` |
| `git` | Git operations | `status`, `stage`, `commit`, `push` |
| `gh` | GitHub operations | `clone`, `create`, `pr`, `issues` |
| `devtools` | Development tools | `terminal`, `database`, `api`, `browser` |
| `prime` | System management | `install`, `upgrade`, `firewall`, `scan` |
| `backend` | Backend development | `install`, `setup`, `generate` |
| `frontend` | Frontend development | `setup`, `new`, `generate` |
| `flux` | API development | `get`, `post`, `put`, `delete`, `server` |
| `ide` | IDE management | `vscode`, `zed`, `sublime`, `run` |
| `servers` | Server management | `up`, `down`, `status`, `setup` |
| `init` | Environment setup | Complete development environment |
| `byteedit` | Text editor | Simple file editing |
| `hello` | Greeting | Cyberpunk welcome message |

## 🛠️ Configuration

ByteBabe can be customized through:
- `~/.config/bytebabe/config.json` - General settings
- `~/.config/bytebabe/themes/` - Custom themes
- `~/.config/bytebabe/plugins/` - User plugins

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

Distributed under the MIT License. See `LICENSE` for more information.

## 💬 Support

- 📖 [Documentation](docs/)
- 🐛 [Issues](https://github.com/mrpunkdasilva/bytebabe/issues)
- 💡 [Discussions](https://github.com/mrpunkdasilva/bytebabe/discussions)

## 🌟 Acknowledgments

- Built with cyberpunk aesthetics in mind
- Powered by the open source community
- Inspired by modern developer workflows

---

<div align="center">
  <sub>Built with ❤️ by Mr Punk da Silva</sub>
</div>
