# Scripts

Utility scripts for bootstrapping and configuring machines.

## Available scripts

| Script | Description |
| --- | --- |
| [`scripts/zsh/zsh.sh`](scripts/zsh/zsh.sh) | Installs Zsh, Oh My Zsh, Powerlevel10k, and a baseline shell configuration. Optionally installs Kubernetes CLI tools. |

## Usage

Run the Zsh setup script directly from GitHub:

```bash
curl -fsSL https://raw.githubusercontent.com/padawarmik/scripts/main/scripts/zsh/zsh.sh | bash
```

Or download and inspect it before running:

```bash
curl -fsSLO https://raw.githubusercontent.com/padawarmik/scripts/main/scripts/zsh/zsh.sh
bash zsh.sh
rm zsh.sh
```

## Repository notes

This repository stores scripts directly and no longer builds or publishes a Docker image for serving them.
