# macos-setup

Bootstrap a complete macOS developer environment with a single command. Installs Homebrew, GUI apps, CLI tools, shell configuration, SSH keys, and sensible macOS defaults.

## Prerequisites

- **macOS 14 (Sonoma) or later** — some casks require it; the script warns on older versions.
- **Admin access** — several steps call `sudo`.
- **Apple ID signed in** — required for some Mac App Store–distributed casks.
- **~20 GB free disk space** — the script warns if you're below this threshold.

## Quick Start

```sh
git clone https://github.com/cooper-square-technologies/macos-setup
cd macos-setup
chmod +x setup.sh
./setup.sh
```

After it finishes, reload your shell:

```sh
source ~/.zshrc
```

A log file is written to `~/dev-setup.log` — share it if anything goes wrong.

## What Gets Installed

| Category | Tools |
|---|---|
| **Editor & terminal** | Cursor, Ghostty, JetBrains Mono Nerd Font |
| **Productivity** | Raycast, Rectangle Pro |
| **Browsers** | Chrome, Firefox Developer Edition |
| **Communication** | Slack, Zoom |
| **DevOps & databases** | OrbStack, DBeaver, Proxyman |
| **Design** | Figma, ImageOptim, CaesiumCLT |
| **API & planning** | Bruno, Linear |
| **Meetings** | Granola |
| **AI coding** | Droid, Codex, Claude Code, Ollama |
| **Media** | Spotify |
| **Git** | git, git-delta, lazygit, GPG |
| **Runtimes** | mise (Node LTS), pnpm, Bun |
| **GitHub** | gh CLI, SSH key + upload |
| **Shell** | Oh My Zsh, zsh-autosuggestions, zsh-syntax-highlighting |
| **Modern CLI** | zoxide, eza, atuin, bat, fd, ripgrep, fzf |
| **Data & HTTP** | jq, yq, httpie, tldr, tree |
| **System** | htop, wget, trash |
| **Node globals** | typescript, tsx, vercel |
| **Cursor extensions** | ESLint, Prettier, Tailwind CSS |

## Config Files

The `configs/` directory contains opinionated defaults that the script copies into place on first run (existing files are never overwritten):

| File | Destination | Purpose |
|---|---|---|
| `configs/ghostty` | `~/.config/ghostty/config` | Ghostty terminal theme, font, padding |
| `configs/ssh-config` | `~/.ssh/config` | macOS Keychain integration, GitHub host |
| `configs/gitconfig-delta` | `~/.gitconfig-delta` | Delta pager theme and options (included via `git config include.path`) |

## Alias Behavior

The script only creates aliases when they do not already exist.

- If Oh My Zsh (or a plugin) already defines an alias, that alias is kept.
- Script aliases are added as fallbacks only.
- This avoids collisions for common aliases like `g`, `gl`, `gp`, `ll`, `la`, `lt`, and others.

## Post-Setup Checklist

Things the script cannot automate — work through these after running `setup.sh`:

- [ ] **Reload shell** — `source ~/.zshrc`
- [ ] **Sign in to apps** — Slack, Chrome, Figma, Linear, Spotify, Zoom
- [ ] **Raycast** — open Raycast, complete onboarding, disable Spotlight (`System Settings → Keyboard → Keyboard Shortcuts → Spotlight`)
- [ ] **Ghostty** — set as default terminal (`Ghostty → Settings → Make Default`)
- [ ] **OrbStack** — open to complete Docker engine setup
- [ ] **Clone team repos** — into `~/Documents/development`
- [ ] **Environment files** — create `.env` / `.env.local` in each project as needed
- [ ] **Oh My Zsh theme** — edit `ZSH_THEME` in `~/.zshrc` (recommended: `robbyrussell` or `af-magic`)
- [ ] **GPG commit signing** (optional) — `gpg --full-generate-key && git config --global commit.gpgsign true`

## Customization

### Adding or removing tools

Edit the `CASKS` or `FORMULAE` arrays in `setup.sh`. Some optional apps are already listed but commented out — uncomment to include them:

```sh
# 1password               # Password/secrets manager (uncomment if used)
# notion                  # Team documentation (uncomment if used)
# loom                    # Async video messaging (uncomment if used)
```

### Skipping interactive prompts

Pass git identity via environment variables for fully unattended runs:

```sh
GIT_NAME="Ada Lovelace" GIT_EMAIL="ada@example.com" ./setup.sh
```

### Cursor extensions

Edit the `EXTENSIONS` array in `setup.sh` to match your team's standard set.

## Troubleshooting

| Problem | Fix |
|---|---|
| **Xcode CLT popup hangs** | Close it, run `sudo rm -rf /Library/Developer/CommandLineTools`, then re-run the script. |
| **Cask "is already installed"** | Run `brew reinstall --cask <name>` manually. |
| **"App can't be opened" (Gatekeeper)** | `System Settings → Privacy & Security → Open Anyway`, or run `xattr -cr /Applications/<App>.app`. |
| **eza icons render as boxes** | Make sure your terminal uses JetBrains Mono Nerd Font (installed by the script; set in Ghostty config). |
| **`mise` / `node` not found after install** | Run `source ~/.zshrc` or open a new terminal tab. |
| **SSH key not working with GitHub** | Verify with `ssh -T git@github.com`. If it fails, run `gh ssh-key add ~/.ssh/id_ed25519.pub`. |
| **Something else failed** | Check `~/dev-setup.log` for the full output and error messages. |

## Re-running

The script is safe to re-run — installed packages are skipped, existing config files are preserved, and aliases are only added once.
