# Mac Setup Instructions

## Prerequisites

- Fresh macOS installation (or clean user account)
- Admin/sudo access
- Internet connection

---

## Step 1: Run the Setup Script

```bash
chmod +x setup.sh
./setup.sh
```

The script will automatically:

1. Install **Xcode Command Line Tools** (required for everything else)
2. Install **Homebrew** + all packages from `Brewfile`
3. Install **nvm** → Node.js LTS → **pnpm** + **bun**
4. Install **SDKMAN** → Java 21 & 17 (Temurin) → **Maven** + **Gradle**
5. Install **pyenv** → Python 3.13.0 → **pip** + **pipx** + **Poetry**
6. Configure **Git** (prompts for name and email)
7. Generate **SSH key** (Ed25519) and display the public key

> At the end, copy the printed SSH public key and add it to GitHub/GitLab.

---

## Step 2: Copy Shell Config

```bash
cp .zshrc ~/.zshrc
```

Then reload the shell:

```bash
source ~/.zshrc
```

---

## Step 3: Add SSH Key to GitHub/GitLab

Copy the SSH public key (printed at the end of Step 1, or run `cat ~/.ssh/id_ed25519.pub`) and add it to:

- **GitHub**: https://github.com/settings/keys
- **GitLab**: https://gitlab.com/-/user_settings/ssh_keys

---

## Step 3.5: (Optional) Configure Starship Prompt

[Starship](https://starship.rs) is already installed via Homebrew and enabled in `.zshrc`. To customize it, create a config file:

```bash
mkdir -p ~/.config && touch ~/.config/starship.toml
cp starship.toml ~/.config/starship.toml
```

Full reference: https://starship.rs/config/

An example config using custom script:

```toml
format = """${custom.moon}$all """
add_newline = false

[line_break]
disabled = true

[java]
disabled = true

[git_status]
disabled = true

[username]
disabled = true

[custom.moon]
command = "~/moon.sh"          # Path to your script (chmod +x moon.sh)
when = "true"                  # Always show the moon
format = "[$output]($style)"   # How it looks
style = "bold yellow"          # Optional styling
```

---

## Step 4: Manual Post-Setup

These are not automated and must be done manually:

| Task | Notes |
|------|-------|
| Sign in to **1Password** | Required before using SSH agent integration |
| Sign in to **Slack** / **Zoom** | Open from `/Applications` |
| Configure **Rectangle** | Launch and grant Accessibility permissions |
| Configure **iTerm2** | Import profile if you have one, set font to JetBrains Mono |
| Sign in to **VS Code** | Sync settings via GitHub account |
| Sign in to **TablePlus** / **Insomnia** / **Postman** | Restore licenses/workspaces |
| Configure **AWS / Azure / GCP CLI** | Run `aws configure`, `az login`, `gcloud auth login` |
| Configure **kubectl** contexts | Copy or merge your `~/.kube/config` |
