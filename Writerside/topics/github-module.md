# GitHub Module

The GitHub module provides comprehensive GitHub CLI integration with cyberpunk aesthetics for managing repositories, pull requests, issues, and GitHub workflows.

## Overview

This module extends the GitHub CLI (`gh`) with ByteBabe's signature cyberpunk interface and additional automation features for repository management, CI/CD setup, and GitHub Pages deployment.

## Commands

### Basic Commands

#### Repository Management
- `clone` - Clone a repository from GitHub
- `create` - Create a new repository
- `checkout` - Switch to a different branch
- `branch` - Create a new branch
- `branches` - List all branches

#### Git Operations
- `commit` - Commit changes with cyberpunk messages
- `push` - Push changes to remote repository
- `pull` - Pull latest changes from remote

#### Pull Requests
- `pr` - Create a new pull request
- `prs` - List all pull requests
- `status` - Check repository status

### Advanced Commands

#### Repository Templates
- `create-template` - Create repository from template

#### CI/CD and Automation
- `setup-actions` - Set up GitHub Actions workflows
- `protect-branch` - Configure branch protection rules

#### Releases and Deployment
- `release` - Create a new release
- `pages` - Deploy to GitHub Pages

#### Issue Management
- `issues` - List repository issues
- `issue-create` - Create a new issue

#### Bulk Operations
- `clone-all` - Clone all repositories from an organization

## Usage Examples

```bash
# Basic repository operations
bytebabe gh clone username/repo
bytebabe gh create my-new-repo
bytebabe gh checkout feature-branch

# Pull request workflow
bytebabe gh pr create --title "Add new feature"
bytebabe gh prs

# Advanced features
bytebabe gh setup-actions
bytebabe gh protect-branch main
bytebabe gh release v1.0.0
```

## Features

### Cyberpunk Interface
- Custom ASCII art headers
- Color-coded output with cyberpunk theme
- Animated progress indicators
- Hacker-style messages and quotes

### Automation
- Automated repository setup
- CI/CD workflow configuration
- Branch protection setup
- Release management

### Integration
- Seamless GitHub CLI integration
- Repository template support
- GitHub Pages deployment
- Issue tracking integration

## Configuration

The module uses the standard GitHub CLI configuration. Ensure you have:
- GitHub CLI installed (`gh`)
- Authenticated with GitHub (`gh auth login`)
- Proper permissions for the repositories you're working with

## Dependencies

- GitHub CLI (`gh`)
- Standard Unix tools (curl, jq, git) 