# macos-setup-script

## Run

```sh
git clone https://github.com/lucasromerodb/macos-setup-script.git
cd macos-setup-script
chmod +x setup.sh
./setup.sh
```

Or without cloning:

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/lucasromerodb/macos-setup-script/main/setup.sh)
```

After it finishes, reload your shell:

```sh
source ~/.zshrc
```

## Warnings

- **Admin password required** — some steps call `sudo` internally.
- **Interactive prompts** — git name and email will be asked if not already configured. You can skip them by prefixing: `GIT_NAME="Your Name" GIT_EMAIL="you@example.com" ./setup.sh`
- **Some casks may fail** silently if they require an Apple ID or are region-restricted — check the output for `⚠` lines.
- **Safe to re-run** — already installed tools are skipped, aliases are only written once.