# Azure DevOps (ADO Module)

> Pull requests across interdimensional portals — ByteBabe's short-command front end for `az` / `az devops`, with badges, grouped dashboards and table-rendered passthrough.

## Purpose

The Azure DevOps module wraps the Azure CLI (`az`) in short, cyberpunk-styled commands with compact, paginated output. It owns the full pull-request flow (create, list, search, filter, categorize, merge), compact views for branches/tags/projects, and full passthrough to the remaining `az devops` groups (pipelines, boards, artifacts, admin) — rendered as tables instead of raw JSON.

The heavy lifting stays in the `az` CLI; the module only orchestrates, defaults and renders.

## Prerequisites

- **Azure CLI (`az`)** — install with `bytebabe azure install` (supports dnf, apt-get, zypper and tdnf).
- **`azure-devops` extension** — required for PRs and projects; `setup` installs it automatically.
- **Login** — via AAD (`az login --allow-no-subscriptions`) or PAT; `setup` handles this step for you.

One shot does everything:

```bash
bytebabe az setup minha-org 'Meu Projeto'
```

Setup in order: install `az` if missing → install the `azure-devops` extension → login (AAD) → save organization/project as CLI defaults. Re-run login explicitly with `setup --login`.

Accepted identifiers:

- Organization: short name (`minha-org`) or URL (`https://dev.azure.com/minha-org`). Legacy `*.visualstudio.com` URLs must be provided in full — the host is treated as the organization.
- Project: passed as a second argument or embedded in the URL; URL-encoded names (`Meu%20Projeto`) are decoded. `--project` for passthrough groups accepts name or ID — quote names with spaces.
- Full passthrough groups still require the complete `--organization` URL.

Login variants:

```bash
bytebabe az login                         # AAD browser/device flow
bytebabe az login minha-org               # login + save org default
bytebabe az login --pat https://dev.azure.com/minha-org   # PAT (token never echoed)
```

## Command Reference

| Command | Aliases | Action |
|---------|---------|--------|
| `install` | `i` | Install Azure CLI via dnf/apt/zypper/tdnf |
| `setup` | — | Install CLI + extension, login, save org/project defaults |
| `login` | `auth` | Azure login (AAD or `--pat`); with an org, also saves the default |
| `pr <title> [base]` | — | Create PR from current branch to `main`/`master` or the given base |
| `prs [term] [options]` | `pr-list`, `search-pr`, `pr-search`, `find-pr` | List, search, filter, group and dashboard PRs |
| `merge [id] [merge\|squash]` | — | Complete a PR; without an ID, finds the PR for the current branch |
| `pr-manage` | — | Passthrough: show/update/vote/add reviewers/abandon PRs |
| `projects [org]` | `proj` | List projects in a compact table |
| `project` | `repo`, `pipeline`, `boards`, `artifacts`, `devops`, `cli` | Passthrough to the matching `az` group with table render |
| `branches <repo>` | `br`, `refs` | List branches sorted, compact and paginated |
| `tags <repo>` | `tag` | List tags sorted, compact and paginated |
| `help` | `--help`, `-h` | Module command center |

Invoke it with any of the top-level module names: `bytebabe azure`, `bytebabe ado`, `bytebabe az`, `bytebabe azdo` (and minor variants like `azuredevops`).

### prs options (via `bytebabe az prs --help`)

| Option | Description |
|--------|-------------|
| `<term>` | Search title, author, branch or ID |
| `-q, --query <term>` | Search a specific text |
| `-a, --author <name>` | Filter by author name |
| `-m, --mine` | Only PRs you created |
| `-T, --type <type>` | Category filter: feat, fix, chore, refactor, task, other |
| `-t, --target <branch>` | Filter by target branch |
| `-b, --source <branch>` | Filter by source branch |
| `--status <status>` | active (default), completed, abandoned, all |
| `-n, --top <num>` | PR page size (default: 100) |
| `--group`, `--by-type` | Group by category (Features, Fixes, Chores...) |
| `--by-author` | Group by author |
| `--by-target` | Group by target branch |
| `--stats`, `--summary` | Dashboard with metrics and bar chart distribution |

## Procedures

### Pull request flow

Create → inspect → merge:

```bash
bytebabe az pr "My change" main       # PR from current branch to main
bytebabe az prs --mine                # my open PRs
bytebabe az prs --type fix            # bugfix PRs only
bytebabe az prs --stats               # dashboard: totals, categories, top authors
bytebabe az merge 20 squash           # complete with squash
bytebabe az merge 20 merge            # complete with a merge commit
```

Without an ID, `merge` looks up the active PR for the current branch. The merge strategy is mandatory and must be `merge` or `squash` — anything else prints the usage line:

```bash
bytebabe az merge 42 rebase
# Usage: bytebabe azure merge [id] [merge|squash]
```

Full `az repos pr` subcommands are available through the passthrough:

```bash
bytebabe az pr-manage show --id 20
bytebabe az pr-manage reviewer add --id 20 --reviewers person@company.com
bytebabe az pr-manage set-vote --id 20 --vote approve
bytebabe az pr-manage update --id 20 --status abandoned
```

`prs` searches and categorizes:

```bash
bytebabe az prs "rum"                       # term match on any field
bytebabe az prs --author "Gustavo"          # by author
bytebabe az prs --target develop            # only PRs targeting develop
bytebabe az prs --group                     # grouped by category
bytebabe az prs --by-author                 # grouped by author
bytebabe az prs --by-target                 # grouped by target branch
```

### Branches and tags

Compact, sorted, paginated listings (shows BRANCH/ID/AUTHOR and a `Total:` line for branches):

```bash
bytebabe az branches meu-repo
bytebabe az branches meu-repo https://dev.azure.com/minha-org
bytebabe az tags meu-repo
```

Without a repository, `branches`/`tags` print the usage instead of calling `az`.

### Projects and repositories

```bash
bytebabe az projects minha-org                # compact project table
bytebabe az project show --project 'My Project'
bytebabe az project create --name 'My Project'
bytebabe az repo list --project 'My Project' --output table
bytebabe az repo create --name my-repo --project 'My Project'
bytebabe az repo ref list --repository my-repo
bytebabe az repo policy list --repository-id <id> --output table
```

### Passthrough groups

These groups forward extra arguments straight to `az` (as an array, no `eval`) and render the JSON response as tables — objects become CAMPO/VALUE blocks, lists become columnar tables, nulls become `—`. Organization/project defaults from `setup` (or Git remote detection) apply; use `--detect false` where supported to force defaults only.

Delivery and planning:

```bash
bytebabe az pipeline list --output table
bytebabe az pipeline run --name my-pipeline --branch main
bytebabe az pipeline runs show --id 42
bytebabe az boards work-item create --type Task --title 'My task'
bytebabe az boards work-item show --id 123
bytebabe az boards query --wiql 'SELECT [System.Id] FROM WorkItems'
bytebabe az artifacts universal publish \
  --feed my-feed --name my-package --version 1.0.0 --path ./dist
bytebabe az artifacts universal download \
  --feed my-feed --name my-package --version 1.0.0 --path ./package
```

Administration and general Azure (beyond DevOps):

```bash
bytebabe az devops team list --project 'My Project' --output table
bytebabe az devops user list --output table
bytebabe az cli account list --output table
bytebabe az cli group list --output table
bytebabe az cli vm list --output table
```

Every passthrough group supports `--help` for the underlying `az` operations:

```bash
bytebabe az repo --help
bytebabe az pr-manage reviewer add --help
```

## Behavior Notes

- **Friendly failures.** Credential errors produce targeted guidance (`az login`, `az devops login`, `bytebabe azure setup`) instead of the raw `ERROR:` line from `az`; raw CLI stderr is never leaked to the user.
- **Missing CLI/extension.** Every command checks for `az` plus the `azure-devops` extension first and tells you how to install (`bytebabe az install` / `setup`).
- **Git context required.** `pr` and `merge` without an ID must run inside a Git repository; the PR base defaults to `main` or `master`, whichever exists.
- **`--mine` resolution.** Resolves your identity via `git config`, then `az account show`, then `whoami`.
- **Pagination.** `prs` fetches a window of `--top` PRs (default 100); there is no interactive cursor, so raise `--top` to scan deeper.
- **Defaults & detection.** Commands use the defaults saved by `setup` when present, otherwise `az` detection via the Git remote.
- **Irreversible actions.** Deletion and merge can be permanent; interactive commands describe what `setup` will do before running it.

## Known Limitations

- **Passthrough depends on local `az`.** Operations groups (`project`, `repo`, `pipeline`, `boards`, `artifacts`, `devops`, `cli`, `pr-manage`) shell out to the locally installed CLI; the module adds no offline behavior.
- **`prs` pagination is not interactive.** Listing is capped by `--top` (default 100) with no cursor to walk pages.
- **`merge` without branch policy.** If no branch policy or approval is configured, the merge completes without reviewers — there is no extra guard.

## See Also

- `bytebabe azure help` / `bytebabe az --help` — module command center
- `bytebabe az prs --help` — full PR search/filter reference
- Procedures: [Git Workflows](git-workflows.md)
