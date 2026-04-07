#!/usr/bin/env bash
# =============================================================================
# update.sh — Keep the dev environment up to date
#
# Run periodically (weekly recommended) to update Homebrew packages,
# global Node modules, Oh My Zsh, and CLI tools.
#
# USAGE
#   ./update.sh
# =============================================================================
set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()     { echo -e "${BLUE}$1${NC}"; }
ok()      { echo -e "${GREEN}✓ $1${NC}"; }
warn()    { echo -e "${YELLOW}⚠ $1${NC}"; }
section() { echo -e "\n${BLUE}━━━ $1 ━━━${NC}"; }

if [[ "$(uname)" != "Darwin" ]]; then
  echo -e "${RED}✗ This script is macOS only.${NC}" && exit 1
fi

FAILED=()

section "📦 Homebrew"
brew update
brew upgrade || { warn "Some Homebrew formulae failed to upgrade"; FAILED+=("brew-upgrade"); }
brew upgrade --cask --greedy || { warn "Some casks failed to upgrade"; FAILED+=("brew-cask-upgrade"); }
brew cleanup --prune=7
brew doctor 2>/dev/null || true
ok "Homebrew updated"

section "⬢  Node.js (mise)"
if command -v mise &>/dev/null; then
  mise upgrade --yes 2>/dev/null || mise install 2>/dev/null || true
  ok "mise runtimes updated"
else
  warn "mise not found — skipping"
fi

section "📦 Global npm packages"
if command -v pnpm &>/dev/null; then
  pnpm update -g || { warn "Some global packages failed to update"; FAILED+=("pnpm-global"); }
  ok "Global packages updated"
else
  warn "pnpm not found — skipping"
fi

section "🐚 Oh My Zsh"
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  (cd "$HOME/.oh-my-zsh" && git pull --rebase --quiet) || true
  ok "Oh My Zsh updated"

  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  for plugin_dir in "$ZSH_CUSTOM/plugins"/*/; do
    if [[ -d "$plugin_dir/.git" ]]; then
      plugin_name="$(basename "$plugin_dir")"
      (cd "$plugin_dir" && git pull --rebase --quiet) && ok "$plugin_name" \
        || warn "Failed to update $plugin_name"
    fi
  done
else
  warn "Oh My Zsh not found — skipping"
fi

section "🤖 AI tools"
if command -v claude &>/dev/null; then
  claude update 2>/dev/null && ok "Claude Code updated" \
    || warn "Claude Code update failed or not supported"
fi

if command -v ollama &>/dev/null; then
  log "Updating Ollama models..."
  for model in $(ollama list 2>/dev/null | awk 'NR>1 {print $1}'); do
    ollama pull "$model" 2>/dev/null && ok "$model" || warn "Failed to pull $model"
  done
fi

section "🧹 Cleanup"
if command -v mise &>/dev/null; then
  mise prune --yes 2>/dev/null || true
fi

section "🎉 Update complete"
echo ""

if [[ ${#FAILED[@]} -gt 0 ]]; then
  echo -e "${YELLOW}Some items failed:${NC}"
  for item in "${FAILED[@]}"; do
    echo -e "  ${RED}✗ $item${NC}"
  done
  echo ""
fi

echo -e "${GREEN}Everything is up to date.${NC}"
echo ""
