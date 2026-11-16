# Development Tools

> Batteries for your terminal, browsers, databases and APIs — installed with cyberpunk flair.

## Command Matrix

| Command | Aliases | What it installs |
|---------|---------|------------------|
| `bytebabe devtools terminal` | `term`, `t` | Zsh, Oh My Zsh, Spaceship Prompt, Atuin, Zsh plugins |
| `bytebabe devtools database` | `db`, `d` | TablePlus, DBeaver, MongoDB Compass, pgAdmin, MySQL Workbench |
| `bytebabe devtools browser` | `bwsr`, `b` | Google Chrome, Firefox, Brave, Microsoft Edge, Vivaldi |
| `bytebabe devtools api` | `api-tools`, `a` | curl, httpie, jq, yq, grpcurl, websocat plus docs and proxy/debug tools |
| `bytebabe devtools docker` | `install-docker` | Docker itself (asks for confirmation, requires sudo) |
| `bytebabe devtools help` | `h` | Module help screen |

Run `bytebabe devtools` with no arguments to open the interactive cyberpunk menu.

### Terminal Tools
- Zsh + Oh My Zsh
- Spaceship Prompt
- Atuin (shell history)

<!-- PLANNED: more plugin tooling, see `bytebabe devtools t all` list -->

### Database Tools
- TablePlus
- DBeaver
- MongoDB Compass
- pgAdmin
- MySQL Workbench

### API Tools
- Test tools (curl, httpie, jq, yq, grpcurl, websocat)

<!-- PLANNED: documentation tooling (OpenAPI/Spectral), proxy/debug (mitmproxy, ngrok) and GUI clients are selectable in the interactive menu when their installers land -->

### Browser Tools
- Google Chrome
- Firefox
- Brave
- Microsoft Edge
- Vivaldi

## Usage

```bash
# Interactive mode
bytebabe devtools

# Direct installation
bytebabe devtools [category] [tool]

# Examples:
bytebabe devtools terminal all      # Installs every terminal tool
bytebabe devtools database dbeaver  # Installs only DBeaver
bytebabe devtools api --test        # Installs API test tools

# Aliases
bytebabe devtools t all             # Same as "terminal all"
bytebabe devtools d dbeaver         # Same as "database dbeaver"
bytebabe devtools b chrome          # Same as "browser chrome"
bytebabe devtools a --test          # Same as "api --test"

# Global aliases
bytebabe dev                        # Same as "devtools"
bytebabe dt                         # Same as "devtools terminal"
bytebabe term                       # Same as "devtools terminal"
bytebabe atuin                      # Same as "devtools terminal atuin"
```

## Features

- Automated installation pipelines
- Package manager detection (apt, dnf/yum, pacman, plus zypper and apk fallbacks)
- Pre-tuned configuration for each tool
- Interactive cyberpunk interface with ASCII headers and neon dividers