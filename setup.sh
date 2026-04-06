#!/usr/bin/env bash
# =============================================================================
# @fileoverview  dev-setup.sh — Top-Notch Web Developer Setup (2026)
#
# Automatically installs and configures a full development environment on macOS.
# Compatible with both Apple Silicon and Intel.
#
# CASKS (GUI apps)
#   cursor                  — AI-native code editor
#   ghostty                 — Fast, modern terminal emulator
#   raycast                 — Spotlight replacement with workflows and extensions
#   rectangle-pro           — Window manager with advanced keyboard shortcuts
#   google-chrome           — Browser for DevTools and cross-browser testing
#   firefox-developer-edition — Firefox with built-in DevTools and CSS grid inspector
#   orbstack                — Docker Desktop replacement (faster, lower RAM usage)
#   tableplus               — GUI client for databases (Postgres, MySQL, SQLite)
#   proxyman                — HTTP/HTTPS traffic interceptor and debugger
#   figma                   — UI design and prototyping
#   bruno                   — Open-source API client (no account required, git-friendly)
#   granola                 — AI-powered meeting notes
#
# FORMULAE (CLI tools)
#   git             — Version control
#   git-delta       — Diff viewer with syntax highlighting
#   lazygit         — Terminal UI for git (replaces editor git panels)
#   mise            — Universal version manager (node, python, ruby, etc.)
#   pnpm            — Fast, disk-efficient Node package manager
#   bun             — Ultra-fast JS runtime and package manager
#   gh              — GitHub CLI (auth, PRs, issues, workflows)
#   zoxide          — Smart cd with frecency-based history
#   eza             — Modern ls with icons and git status support
#   atuin           — Searchable, syncable shell history
#   bat             — cat with syntax highlighting and line numbers
#   fd              — Fast and ergonomic alternative to find
#   ripgrep         — Fast grep alternative (used internally by editors)
#   fzf             — Fuzzy finder (Ctrl+R, previews, shell integrations)
#   jq              — JSON processing in the CLI
#   yq              — YAML processing in the CLI
#   httpie          — Human-friendly HTTP CLI, easier than curl
#   tldr            — Simplified man pages with practical examples
#   tree            — Directory tree viewer
#   ollama          — Run AI models locally (LLaMA, Mistral, etc.)
#   gnupg           — GPG for commit signing and file encryption
#
# GLOBAL PACKAGES (via pnpm)
#   typescript      — TypeScript compiler
#   tsx             — Run TypeScript files without a build step
#   vercel          — Vercel deployment CLI
#
# SHELL
#   oh-my-zsh       — Zsh framework with plugins and themes
#
# USAGE
#   chmod +x dev-setup.sh && ./dev-setup.sh
#
# OPTIONAL ENV VARS
#   GIT_NAME=<n>       — Skip the interactive git name prompt
#   GIT_EMAIL=<email>  — Skip the interactive git email prompt
# =============================================================================
set -euo pipefail

# --- Colors ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()     { echo -e "${BLUE}$1${NC}"; }
ok()      { echo -e "${GREEN}✓ $1${NC}"; }
warn()    { echo -e "${YELLOW}⚠ $1${NC}"; }
section() { echo -e "\n${BLUE}━━━ $1 ━━━${NC}"; }

# Ensure we're running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
  echo -e "${RED}✗ This script is macOS only.${NC}" && exit 1
fi

section "🚀 Top-Notch Web Developer Setup (2026)"

# ─────────────────────────────────────────────
# 1. Homebrew
# ─────────────────────────────────────────────
section "📦 Homebrew"
if ! command -v brew &>/dev/null; then
  log "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Support both Apple Silicon and Intel
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  ok "Homebrew already installed"
  brew update --quiet
fi

# ─────────────────────────────────────────────
# 2. GUI Apps (Casks)
# ─────────────────────────────────────────────
section "🖥️  GUI Apps"
CASKS=(
  # Editors & terminals
  cursor
  ghostty

  # macOS productivity
  raycast
  rectangle-pro

  # Browsers
  google-chrome
  firefox-developer-edition

  # DevOps & databases
  orbstack
  tableplus
  proxyman

  # Design & prototyping
  figma

  # API testing
  bruno

  # Meetings & notes
  granola
)

for cask in "${CASKS[@]}"; do
  if brew list --cask "$cask" &>/dev/null; then
    ok "$cask already installed"
  else
    log "Installing $cask..."
    brew install --cask "$cask" || warn "Could not install $cask — skipping"
  fi
done

# ─────────────────────────────────────────────
# 3. CLI Tools (Formulae)
# ─────────────────────────────────────────────
section "🛠️  CLI Tools"
FORMULAE=(
  # Git
  git
  git-delta
  lazygit

  # Node / runtime management
  mise
  pnpm
  bun

  # GitHub
  gh

  # Modern shell utilities
  zoxide
  eza
  atuin
  bat
  fd
  ripgrep
  fzf

  # Data & HTTP
  jq
  yq
  httpie
  tldr
  tree

  # Local AI
  ollama

  # Security
  gnupg
)

for formula in "${FORMULAE[@]}"; do
  if brew list "$formula" &>/dev/null; then
    ok "$formula already installed"
  else
    log "Installing $formula..."
    brew install "$formula" || warn "Could not install $formula — skipping"
  fi
done

# ─────────────────────────────────────────────
# 4. Oh My Zsh
# ─────────────────────────────────────────────
section "🐚 Oh My Zsh"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  log "Installing Oh My Zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  ok "Oh My Zsh installed"
else
  ok "Oh My Zsh already installed"
fi

# Recommended plugins (beyond the defaults)
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  ok "Plugin: zsh-autosuggestions"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  ok "Plugin: zsh-syntax-highlighting"
fi

# Enable plugins in .zshrc (replaces the default plugins line)
if grep -q 'plugins=(git)' ~/.zshrc 2>/dev/null; then
  sed -i '' 's/plugins=(git)/plugins=(git gh z fzf zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
  ok "Oh My Zsh plugins configured"
fi

# ─────────────────────────────────────────────
# 5. Mise — Node.js + global packages
# ─────────────────────────────────────────────
section "⬢  Mise / Node.js"
if ! grep -q 'mise activate zsh' ~/.zshrc 2>/dev/null; then
  echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
fi
eval "$(mise activate zsh)" 2>/dev/null || true

mise use --global node@lts  # LTS is more stable than @25 for production

log "Installing global Node packages..."
pnpm add -g \
  typescript \
  tsx \
  vercel || warn "Some global packages failed to install"

# ─────────────────────────────────────────────
# 6. Git — minimal global config
# ─────────────────────────────────────────────
section "🔧 Git config"
GIT_NAME="${GIT_NAME:-$(git config --global user.name 2>/dev/null || echo '')}"
GIT_EMAIL="${GIT_EMAIL:-$(git config --global user.email 2>/dev/null || echo '')}"

if [[ -z "$GIT_NAME" ]]; then
  read -rp "  Your name for git: " GIT_NAME
  git config --global user.name "$GIT_NAME"
fi
if [[ -z "$GIT_EMAIL" ]]; then
  read -rp "  Your email for git: " GIT_EMAIL
  git config --global user.email "$GIT_EMAIL"
fi

git config --global core.pager             "delta"
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate         true
git config --global delta.side-by-side     true
git config --global pull.rebase            true
git config --global init.defaultBranch     main

ok "Git configured"

# ─────────────────────────────────────────────
# 7. .zshrc — aliases and modern tools
# ─────────────────────────────────────────────
section "✍️  .zshrc — aliases"

MARKER="# ── dev-setup 2026 ──"
if ! grep -qF "$MARKER" ~/.zshrc 2>/dev/null; then
  cat >> ~/.zshrc << 'ZSHEOF'

# ── dev-setup 2026 ──
# Zoxide (smart cd)
eval "$(zoxide init zsh)"

# Atuin (enhanced shell history)
eval "$(atuin init zsh)"

# Mise
eval "$(mise activate zsh)"

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Modern aliases
alias ls='eza --icons --git'
alias ll='eza -lh --icons --git'
alias la='eza -lah --icons --git'
alias lt='eza --tree --icons --git-ignore'
alias cat='bat --paging=never'
alias cd='z'
alias find='fd'
alias grep='rg'
alias http='http --style=solarized'

# Git shortcuts
alias g='git'
alias gs='git status'
alias gp='git push'
alias gl='git pull'
alias lg='lazygit'

# GitHub CLI
alias ghprc='gh pr create --web'
alias ghprv='gh pr view --web'

# Node / pnpm
alias nr='pnpm run'
alias ni='pnpm install'
alias nd='pnpm dev'

# Utilities
alias ip='ipconfig getifaddr en0'
alias ports='lsof -i -P -n | grep LISTEN'
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
ZSHEOF
  ok "Aliases added to ~/.zshrc"
else
  ok "Aliases already present — skipping"
fi

# ─────────────────────────────────────────────
# 8. macOS sensible defaults
# ─────────────────────────────────────────────
section "⚙️  macOS defaults"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
sudo nvram StartupMute=%01 2>/dev/null || true
defaults write com.apple.dock autohide -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
killall Dock Finder 2>/dev/null || true
ok "macOS defaults applied"

# ─────────────────────────────────────────────
# 9. Done
# ─────────────────────────────────────────────
section "🎉 Setup complete"
echo ""
echo -e "${GREEN}All done. Next steps:${NC}"
echo ""
echo "  1. Run: source ~/.zshrc"
echo "  2. Run: gh auth login              (authenticate GitHub CLI)"
echo "  3. Set up Raycast and disable Spotlight (System Settings → Siri & Spotlight)"
echo "  4. Open OrbStack to migrate containers from Docker Desktop"
echo "  5. Pick an Oh My Zsh theme — edit ZSH_THEME in ~/.zshrc (recommended: 'robbyrussell' or 'af-magic')"
echo ""
echo -e "${YELLOW}Tip — GPG commit signing:${NC}"
echo "  gpg --full-generate-key"
echo "  git config --global commit.gpgsign true"
echo ""