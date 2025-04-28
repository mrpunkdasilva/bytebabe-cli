
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

- **Docker Management (Poseidon Module) 🐳**
  - Container/image/volume management
  - Compose stack handling
  - Visual container stats
  - Resource monitoring
  - Supports both verbose and short command styles
  
- **Database Operations (Oracle Module) 🗄️**
  - Support for MySQL, PostgreSQL, MongoDB, Redis
  - Backup/restore operations
  - Migration tools
  - GUI tool integration (TablePlus, DBeaver, etc.)
  
- **Git Operations (Neo Module) 🔧**
  - Interactive Git interface
  - Repository management
  - Branch operations
  - Semantic commit handling
  
- **Development Tools (Matrix Module) 🛠️**
  - Terminal tools (Zsh + plugins)
  - Database management GUIs
  - API testing tools
  - Browser tools
  - IDE configuration

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

### Docker Operations
```bash
# Verbose style
bytebabe docker containers list --all
bytebabe docker images pull nginx

# Short style (cyberpunk)
bytebabe docker c ls -a
bytebabe docker i p nginx
```

### Database Operations
```bash
# Setup database
bytebabe db setup mysql

# Start specific database
bytebabe db start postgres

# Backup operations
bytebabe db backup create
```

### Git Operations
```bash
# Interactive git status
bytebabe git status

# Smart staging
bytebabe git stage

# Semantic commit
bytebabe git commit
```

### Development Tools
```bash
# Install all terminal tools
bytebabe devtools terminal all

# Install specific database tool
bytebabe devtools database dbeaver

# Install API tools
bytebabe devtools api --test
```

## 📦 Module Overview

| Module | Description | Style |
|--------|-------------|-------|
| `docker` | Container management | Verbose/Short |
| `db` | Database operations | Interactive |
| `git` | Git operations | Interactive |
| `dev` | Development tools | Category-based |

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


## 🌟 Acknowledgments

- Built with cyberpunk aesthetics in mind
- Powered by the open source community
- Inspired by modern developer workflows

---

<div align="center">
  <sub>Built with ❤️ by Mr Punk da Silva</sub>
</div>
