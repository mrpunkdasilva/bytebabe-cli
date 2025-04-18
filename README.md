
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

ByteBabe is a modular CLI toolkit that brings cyberpunk aesthetics to your development workflow. It provides a unified interface for managing development environments, containers, Git operations, and more.

## 🎯 Key Features

- **Docker Management (Poseidon Module)**
  - Container/image/volume management
  - Compose stack handling
  - Visual container stats
- **Git Operations (Neo Module)**
  - Repository management
  - Branch operations
  - Commit handling
- **Development Tools (Matrix Module)**
  - IDE configuration
  - Language servers
  - Debug tools
- **Database Operations (Oracle Module)**
  - Multiple database support
  - Backup/restore
  - Migration tools

## 🚀 Installation

### Prerequisites
- 🐧 Linux/Unix (sorry Windows-chan)
- 🐚 Bash 4+
- 📦 Git (optional)
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

```bash
# Initialize development environment
bytebabe init

# Manage Docker containers
bytebabe docker up
bytebabe docker down
bytebabe docker logs

# Git operations
bytebabe git push
bytebabe git sync
bytebabe git clean

# Development tools
bytebabe dev install
bytebabe dev update
bytebabe dev doctor
```

## 📦 Module Overview

| Module | Description | Commands |
|--------|-------------|----------|
| `init` | First-time setup | `bytebabe init` |
| `docker` | Container management | `bytebabe docker [up/down/logs]` |
| `git` | Git operations | `bytebabe git [push/pull/sync]` |
| `dev` | Development tools | `bytebabe dev [install/update]` |
| `db` | Database operations | `bytebabe db [backup/restore]` |

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

- 📧 Email: support@bytebabe.dev
- 💻 Discord: [ByteBabe Community](https://discord.gg/bytebabe)
- 🐦 Twitter: [@ByteBabeCLI](https://twitter.com/ByteBabeCLI)

## 🌟 Acknowledgments

- Inspired by modern developer workflows
- Built with cyberpunk aesthetics in mind
- Powered by the open source community

---

<div align="center">
  <sub>Built with ❤️ by Mr Punk da Silva</sub>
</div>
