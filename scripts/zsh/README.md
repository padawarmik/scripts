# Zsh setup

Installs a minimal, frameworkless Zsh setup on Debian-like (`apt`) and Arch-like (`pacman`) distributions.

The installer can optionally install the recommended CLI tools from the 2026 setup note:

- `neovim`
- `eza`
- `bat` / `batcat`
- `fd` / `fdfind`
- `fzf`
- `zoxide`
- `starship`
- `ripgrep`

If you decline additional software, the installer still writes a safe modular Zsh configuration. Integrations for missing tools are skipped at shell startup instead of failing.

```bash
curl -fsSL https://raw.githubusercontent.com/padawarmik/scripts/main/scripts/zsh/zsh.sh | bash
```

If you prefer to inspect the script first:

```bash
curl -fsSLO https://raw.githubusercontent.com/padawarmik/scripts/main/scripts/zsh/zsh.sh
bash zsh.sh
rm zsh.sh
```

The installer writes:

- `~/.zshenv` with a managed `ZDOTDIR` block
- `~/.config/zsh/.zshenv`
- `~/.config/zsh/.zshrc`
- `~/.config/zsh/fzf.zsh`
- `~/.config/zsh/aliases.zsh`
- `~/.config/zsh/bindings.zsh`
- `~/.config/zsh/plugins.zsh`
- `~/.config/zsh/prompt.zsh`
- `~/.config/zsh/starship.toml`

Existing files are backed up with a `.bak.<timestamp>` suffix before replacement.
