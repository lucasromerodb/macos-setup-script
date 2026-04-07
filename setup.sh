#!/usr/bin/env bash
# =============================================================================
# @fileoverview  dev-setup.sh — Top-Notch Web Developer Setup (2026)
#
# Automatically installs and configures a full development environment on macOS.
# Compatible with both Apple Silicon and Intel.
#
# CASKS (GUI apps)
#   cursor                    — AI-native code editor
#   ghostty                   — Fast, modern terminal emulator
#   raycast                   — Spotlight replacement with workflows and extensions
#   rectangle-pro             — Window manager with advanced keyboard shortcuts
#   google-chrome             — Browser for DevTools and cross-browser testing
#   firefox-developer-edition — Firefox with built-in DevTools and CSS grid inspector
#   zoom                      — Video conferencing for remote calls
#   orbstack                  — Docker Desktop replacement (faster, lower RAM usage)
#   dbeaver-community         — Universal database GUI client
#   proxyman                  — HTTP/HTTPS traffic interceptor and debugger
#   figma                     — UI design and prototyping
#   imageoptim                — Lossless image optimization utility
#   caesiumclt                — Command-line image compression utility
#   bruno                     — Open-source API client (no account required, git-friendly)
#   linear                    — Issue tracking and project management
#   spotify                   — Music streaming app
#   granola                   — AI-powered meeting notes
#   droid                     — AI software engineering agent by Factory
#   slack                     — Team messaging
#   font-jetbrains-mono-nerd-font — Patched font for terminal icons (eza, Ghostty)
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
#   codex           — OpenAI's AI coding agent CLI
#   ollama          — Run AI models locally (LLaMA, Mistral, etc.)
#   htop            — Interactive process viewer
#   wget            — File downloader (not included in macOS by default)
#   trash           — Move files to macOS Trash instead of permanent rm
#   gnupg           — GPG for commit signing and file encryption
#
# STANDALONE INSTALLERS
#   claude-code     — Anthropic's AI coding agent CLI (native installer)
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

# --- Logging ---
LOG_FILE="$HOME/dev-setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# --- Failure tracking ---
FAILED=()

# --- Script directory (for config files) ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure we're running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
  echo -e "${RED}✗ This script is macOS only.${NC}" && exit 1
fi

section "🚀 Top-Notch Web Developer Setup (2026)"
log "Log file → $LOG_FILE"

# ─────────────────────────────────────────────
# 0. Pre-flight checks
# ─────────────────────────────────────────────
section "🔍 Pre-flight checks"

MACOS_VERSION="$(sw_vers -productVersion)"
MACOS_MAJOR="${MACOS_VERSION%%.*}"
if [[ "$MACOS_MAJOR" -lt 14 ]]; then
  warn "macOS $MACOS_VERSION detected — some casks require Sonoma (14) or later"
else
  ok "macOS $MACOS_VERSION"
fi

FREE_GB=$(df -g / | awk 'NR==2 {print $4}')
if [[ "$FREE_GB" -lt 20 ]]; then
  warn "Only ${FREE_GB} GB free disk space — recommend at least 20 GB"
else
  ok "${FREE_GB} GB free disk space"
fi

if xcode-select -p &>/dev/null; then
  ok "Xcode Command Line Tools installed"
else
  log "Installing Xcode Command Line Tools (a popup may appear)..."
  xcode-select --install 2>/dev/null || true
  read -rp "  Press Enter once the Xcode CLT installation finishes..."
fi

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
  cursor                    # AI-native code editor
  ghostty                   # Fast, modern terminal emulator

  # Fonts (required for terminal icons in eza and Ghostty)
  font-jetbrains-mono-nerd-font

  # macOS productivity
  raycast                   # Spotlight replacement with workflows and extensions
  rectangle-pro             # Window manager with advanced keyboard shortcuts

  # Browsers
  google-chrome             # Browser for DevTools and cross-browser testing
  firefox-developer-edition # Firefox with built-in DevTools and CSS grid inspector
  zoom                      # Video conferencing for remote calls

  # DevOps & databases
  orbstack                  # Docker Desktop replacement (faster, lower RAM usage)
  dbeaver-community         # Universal database GUI client
  proxyman                  # HTTP/HTTPS traffic interceptor and debugger

  # Design & prototyping
  figma                     # UI design and prototyping
  imageoptim                # Lossless image optimization utility
  caesiumclt                # Command-line image compression utility

  # API, planning & media
  bruno                     # Open-source API client (no account required, git-friendly)
  linear                    # Issue tracking and project management
  spotify                   # Music streaming app

  # Meetings & notes
  granola                   # AI-powered meeting notes

  # AI coding agents
  droid                     # AI software engineering agent by Factory

  # Communication
  slack                     # Team messaging
  # 1password               # Password/secrets manager (uncomment if used)
  # notion                  # Team documentation (uncomment if used)
  # loom                    # Async video messaging (uncomment if used)
)

for cask in "${CASKS[@]}"; do
  if brew list --cask "$cask" &>/dev/null; then
    ok "$cask already installed"
  else
    log "Installing $cask..."
    brew install --cask "$cask" || { warn "Could not install $cask — skipping"; FAILED+=("$cask"); }
  fi
done

# ─────────────────────────────────────────────
# 3. CLI Tools (Formulae)
# ─────────────────────────────────────────────
section "🛠️  CLI Tools"
FORMULAE=(
  # Git
  git             # Version control system
  git-delta       # Syntax-highlighted and side-by-side git diff pager
  lazygit         # Interactive terminal UI for git

  # Node / runtime management
  mise            # Universal version manager (Node, Python, Ruby, etc.)
  pnpm            # Fast and disk-efficient Node package manager
  bun             # JavaScript runtime and package manager

  # GitHub
  gh              # GitHub CLI for PRs, issues and workflows

  # Modern shell utilities
  zoxide          # Smart directory jumping based on frequency and recency
  eza             # Modern ls replacement with icons and git status
  atuin           # Searchable shell history with optional sync
  bat             # cat replacement with syntax highlighting
  fd              # Faster, ergonomic alternative to find
  ripgrep         # Fast recursive text searcher
  fzf             # Fuzzy finder for files, history and commands

  # Data & HTTP
  jq              # JSON processor for shell pipelines
  yq              # YAML/XML/TOML processor for shell pipelines
  httpie          # Human-friendly HTTP client
  tldr            # Practical command examples for common CLI tools
  tree            # Directory tree viewer

  # AI coding agents
  codex           # OpenAI AI coding agent CLI

  # Local AI
  ollama          # Run local LLMs directly on your machine

  # System utilities
  htop            # Interactive process viewer
  wget            # Network downloader
  trash           # Move files to macOS Trash from terminal

  # Security
  gnupg           # GPG tools for signing and encryption
)

for formula in "${FORMULAE[@]}"; do
  if brew list "$formula" &>/dev/null; then
    ok "$formula already installed"
  else
    log "Installing $formula..."
    brew install "$formula" || { warn "Could not install $formula — skipping"; FAILED+=("$formula"); }
  fi
done

# ─────────────────────────────────────────────
# 4. Claude Code (native installer)
# ─────────────────────────────────────────────
section "🤖 Claude Code"
if command -v claude &>/dev/null; then
  ok "Claude Code already installed"
else
  log "Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash || { warn "Could not install Claude Code — skipping"; FAILED+=("claude-code"); }
fi

# ─────────────────────────────────────────────
# 5. Cursor extensions
# ─────────────────────────────────────────────
section "🧩 Cursor extensions"
if command -v cursor &>/dev/null; then
  EXTENSIONS=(
    dbaeumer.vscode-eslint
    esbenp.prettier-vscode
    bradlc.vscode-tailwindcss
  )
  for ext in "${EXTENSIONS[@]}"; do
    cursor --install-extension "$ext" 2>/dev/null && ok "$ext" \
      || warn "Could not install extension $ext"
  done
else
  warn "Cursor CLI not found — install extensions manually after first launch"
fi

# ─────────────────────────────────────────────
# 6. Oh My Zsh
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

DESIRED_PLUGINS="plugins=(git gh z fzf zsh-autosuggestions zsh-syntax-highlighting)"
if grep -qF "$DESIRED_PLUGINS" ~/.zshrc 2>/dev/null; then
  ok "Oh My Zsh plugins already configured"
elif grep -q '^plugins=(' ~/.zshrc 2>/dev/null; then
  sed -i '' "s/^plugins=(.*)/$DESIRED_PLUGINS/" ~/.zshrc
  ok "Oh My Zsh plugins configured"
else
  echo "$DESIRED_PLUGINS" >> ~/.zshrc
  ok "Oh My Zsh plugins added to .zshrc"
fi

# ─────────────────────────────────────────────
# 7. Mise — Node.js + global packages
# ─────────────────────────────────────────────
section "⬢  Mise / Node.js"
if ! grep -q 'mise activate zsh' ~/.zshrc 2>/dev/null; then
  echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
fi
eval "$(mise activate zsh)" 2>/dev/null || true

mise use --global node@lts  # LTS is more stable than @25 for production

log "Installing global Node packages..."
GLOBAL_PACKAGES=(
  typescript  # TypeScript compiler
  tsx         # Run TypeScript/ESM scripts directly
  vercel      # Vercel deployment CLI
)
pnpm add -g "${GLOBAL_PACKAGES[@]}" || { warn "Some global packages failed to install"; FAILED+=("global-npm-packages"); }

# ─────────────────────────────────────────────
# 8. Git — minimal global config
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

git config --global pull.rebase            true
git config --global init.defaultBranch     main

ok "Git configured"

# ─────────────────────────────────────────────
# 9. SSH key & GitHub authentication
# ─────────────────────────────────────────────
section "🔑 SSH key & GitHub auth"
SSH_KEY="$HOME/.ssh/id_ed25519"

if [[ -f "$SSH_KEY" ]]; then
  ok "SSH key already exists at $SSH_KEY"
else
  log "Generating Ed25519 SSH key..."
  mkdir -p "$HOME/.ssh"
  ssh-keygen -t ed25519 -C "${GIT_EMAIL}" -f "$SSH_KEY" -N ""
  ok "SSH key generated"
fi

ssh-add --apple-use-keychain "$SSH_KEY" 2>/dev/null || true

if [[ -f "$SCRIPT_DIR/configs/ssh-config" ]]; then
  if [[ ! -f "$HOME/.ssh/config" ]]; then
    cp "$SCRIPT_DIR/configs/ssh-config" "$HOME/.ssh/config"
    chmod 600 "$HOME/.ssh/config"
    ok "SSH config installed"
  else
    ok "SSH config already exists — skipping"
  fi
fi

if command -v gh &>/dev/null; then
  if gh auth status &>/dev/null 2>&1; then
    ok "GitHub CLI already authenticated"
  else
    log "Authenticate with GitHub (opens browser)..."
    gh auth login -p ssh -w || warn "GitHub auth skipped — run 'gh auth login' later"
  fi

  if gh auth status &>/dev/null 2>&1 && [[ -f "$SSH_KEY.pub" ]]; then
    KEY_FINGERPRINT=$(ssh-keygen -lf "$SSH_KEY.pub" | awk '{print $2}')
    if gh ssh-key list 2>/dev/null | grep -q "$KEY_FINGERPRINT"; then
      ok "SSH key already uploaded to GitHub"
    else
      gh ssh-key add "$SSH_KEY.pub" -t "$(hostname)-$(date +%Y%m%d)" \
        && ok "SSH key uploaded to GitHub" \
        || warn "Could not upload SSH key — add it manually at https://github.com/settings/keys"
    fi
  fi
fi

# ─────────────────────────────────────────────
# 10. Development folder
# ─────────────────────────────────────────────
section "📁 Development folder"
DEV_DIR="$HOME/Documents/development"
mkdir -p "$DEV_DIR"
ok "Directory ready: $DEV_DIR"

# ─────────────────────────────────────────────
# 11. Config files (from configs/ directory)
# ─────────────────────────────────────────────
section "📄 Config files"

GHOSTTY_DIR="$HOME/.config/ghostty"
if [[ -f "$SCRIPT_DIR/configs/ghostty" ]]; then
  mkdir -p "$GHOSTTY_DIR"
  if [[ ! -f "$GHOSTTY_DIR/config" ]]; then
    cp "$SCRIPT_DIR/configs/ghostty" "$GHOSTTY_DIR/config"
    ok "Ghostty config installed"
  else
    ok "Ghostty config already exists — skipping"
  fi
fi

if [[ -f "$SCRIPT_DIR/configs/gitconfig-delta" ]]; then
  DELTA_CFG="$HOME/.gitconfig-delta"
  if [[ ! -f "$DELTA_CFG" ]]; then
    cp "$SCRIPT_DIR/configs/gitconfig-delta" "$DELTA_CFG"
    git config --global include.path "~/.gitconfig-delta"
    ok "Git delta config installed"
  else
    ok "Git delta config already exists — skipping"
  fi
fi

# ─────────────────────────────────────────────
# 12. .zshrc — aliases and modern tools
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
(( $+aliases[ls] )) || alias ls='eza --icons --git'
(( $+aliases[ll] )) || alias ll='eza -lh --icons --git'
(( $+aliases[la] )) || alias la='eza -lah --icons --git'
(( $+aliases[lt] )) || alias lt='eza --tree --icons --git-ignore'
(( $+aliases[cat] )) || alias cat='bat --paging=never'
(( $+aliases[cd] )) || alias cd='z'
(( $+aliases[find] )) || alias find='fd'
(( $+aliases[grep] )) || alias grep='rg'
(( $+aliases[http] )) || alias http='http --style=solarized'
(( $+aliases[godev] )) || alias godev='cd ~/Documents/development'

# Git shortcuts
(( $+aliases[g] )) || alias g='git'
(( $+aliases[gs] )) || alias gs='git status'
(( $+aliases[gp] )) || alias gp='git push'
(( $+aliases[gl] )) || alias gl='git pull'
(( $+aliases[lg] )) || alias lg='lazygit'

# GitHub CLI
(( $+aliases[ghprc] )) || alias ghprc='gh pr create --web'
(( $+aliases[ghprv] )) || alias ghprv='gh pr view --web'

# Node / pnpm
(( $+aliases[nr] )) || alias nr='pnpm run'
(( $+aliases[ni] )) || alias ni='pnpm install'
(( $+aliases[nd] )) || alias nd='pnpm dev'

# Utilities
(( $+aliases[ip] )) || alias ip='ipconfig getifaddr en0'
(( $+aliases[ports] )) || alias ports='lsof -i -P -n | grep LISTEN'
(( $+aliases[flushdns] )) || alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
ZSHEOF
  ok "Aliases added to ~/.zshrc"
else
  ok "Aliases already present — skipping"
fi

# ─────────────────────────────────────────────
# 13. macOS sensible defaults
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
# 14. Done
# ─────────────────────────────────────────────
section "🎉 Setup complete"
echo ""

if [[ ${#FAILED[@]} -gt 0 ]]; then
  echo -e "${YELLOW}Some items failed to install:${NC}"
  for item in "${FAILED[@]}"; do
    echo -e "  ${RED}✗ $item${NC}"
  done
  echo ""
  echo -e "${YELLOW}Check the log for details: $LOG_FILE${NC}"
  echo ""
fi

echo -e "${GREEN}Post-setup checklist:${NC}"
echo ""
echo "  1. Run: source ~/.zshrc"
echo "  2. Sign in to: Slack, Chrome, Figma, Linear, Spotify"
echo "  3. Set up Raycast and disable Spotlight (System Settings → Siri & Spotlight)"
echo "  4. Set Ghostty as default terminal"
echo "  5. Open OrbStack to complete Docker setup"
echo "  6. Clone your team repos into ~/Documents/development"
echo "  7. Pick an Oh My Zsh theme — edit ZSH_THEME in ~/.zshrc (recommended: 'robbyrussell' or 'af-magic')"
echo ""
echo -e "${YELLOW}Tip — GPG commit signing:${NC}"
echo "  gpg --full-generate-key"
echo "  git config --global commit.gpgsign true"
echo ""