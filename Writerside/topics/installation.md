# Installing ByteBabe

> Get the neon assistant on your terminal in one pipe.

## Requirements

- Linux/Unix or WSL (Windows Subsystem for Linux)
- Bash 4 or newer (Bash 5 recommended)
- Git
- `curl` or `wget` (required when installing from the release)
- `sudo` (the installer copies files to `/opt` and creates symlinks in `/usr/local/bin`)
- Docker (optional; you can install it later with `bytebabe devtools docker`)

## Install

### Option 1: One-line script (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/mrpunkdasilva/bytebabe-cli/main/install.sh | bash
```

Or with `wget`:

```bash
wget -qO- https://raw.githubusercontent.com/mrpunkdasilva/bytebabe-cli/main/install.sh | bash
```

The script downloads the `bytebabe-1.6.0.tar.gz` asset from the [GitHub release](https://github.com/mrpunkdasilva/bytebabe-cli/releases) and installs it.

### Option 2: Release tarball

If you prefer to inspect the package before running anything:

```bash
curl -fsSL https://github.com/mrpunkdasilva/bytebabe-cli/releases/download/v1.6.0/bytebabe-1.6.0.tar.gz -o /tmp/bytebabe.tar.gz

mkdir -p /tmp/bytebabe
tar -xzf /tmp/bytebabe.tar.gz -C /tmp/bytebabe

cd /tmp/bytebabe/bytebabe-1.6.0
./install.sh
```

### Option 3: From a clone (development)

```bash
git clone https://github.com/mrpunkdasilva/bytebabe-cli.git
cd bytebabe-cli

# Run the installer (asks for sudo password)
./install.sh
```

When `install.sh` runs inside the clone, it detects `bin/bytebabe` and `lib/` next to the script and installs your local code instead of downloading the release.

## What the installer does

1. Copies the CLI files to `/opt/bytebabe`, replacing any previous installation.
2. Removes `archive/` from the installed copy.
3. Makes `bin/bytebabe` executable.
4. Creates the global symlinks `/usr/local/bin/bytebabe` and `/usr/local/bin/bb` pointing to `/opt/bytebabe/bin/bytebabe`.
5. Refreshes the shell command hash (`hash -r`) and cleans up temporary files from `/tmp/bytebabe-install`.

The global `bytebabe` command runs the copy in `/opt/bytebabe`, not your clone.

## Verify

```bash
hash -r
bytebabe --version
```

The short alias works too:

```bash
bb --version
```

To check from which file your shell actually runs the command (should resolve to `/opt/bytebabe`):

```bash
command -v bytebabe
readlink -f "$(command -v bytebabe)"
```

## Update

Because the global command runs the copy in `/opt/bytebabe`, pulling new changes into a clone is not enough — run the installer again:

```bash
cd /path/to/bytebabe-cli
git pull
./install.sh
```

Or re-run the release install:

```bash
curl -fsSL https://raw.githubusercontent.com/mrpunkdasilva/bytebabe-cli/main/install.sh | bash
```

To try changes without reinstalling:

```bash
bash /path/to/bytebabe-cli/bin/bytebabe devtools
```
