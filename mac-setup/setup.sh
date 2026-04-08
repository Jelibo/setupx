#!/usr/bin/env bash
set -euo pipefail

# Ensure .zshrc exists
touch "$HOME/.zshrc"

# Check for Xcode Command Line Tools
echo "==> Checking Xcode Command Line Tools"
if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install
  echo "Please finish installing Xcode Command Line Tools, then re-run the script."
  exit 1
fi

# Install Homebrew and packages
echo "==> Installing Homebrew (if missing)"
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "==> Initializing Homebrew"
eval "$(brew shellenv)"
brew update

echo "==> Installing from Brewfile (if present)"
BREWFILE="$(dirname "$0")/Brewfile"
if [ -f "$BREWFILE" ]; then
  brew bundle --file="$BREWFILE"
  brew cleanup
else
  echo "No Brewfile found, skipping."
fi

# Install nvm and Node.js
echo "==> Installing nvm (Node version manager)"
if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi

# Add nvm initialization to .zshrc if not present
if ! grep -q 'export NVM_DIR="$HOME/.nvm"' "$HOME/.zshrc"; then
  cat <<'EOF' >> "$HOME/.zshrc"

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF
fi

# Load nvm for current shell session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

echo "==> Installing Node LTS"
nvm install --lts
nvm use --lts

echo "==> Installing pnpm"
npm install -g pnpm

echo "==> Installing Bun"
if ! command -v bun >/dev/null 2>&1; then
  curl -fsSL https://bun.sh/install | bash
fi

# Install SDKMAN and Java versions
echo "==> Installing SDKMAN"
if [ ! -d "$HOME/.sdkman" ]; then
  curl -s "https://get.sdkman.io" | bash
fi

source "$HOME/.sdkman/bin/sdkman-init.sh"

echo "==> Installing Java versions"
sdk install java 21-tem || true
sdk install java 17-tem || true
sdk default java 21-tem || true

# Install Maven, Gradle
echo "==> Installing Maven and Gradle"
sdk install maven || true
sdk install gradle || true

# Install pyenv and Python
echo "==> Installing Python via pyenv"
if command -v pyenv >/dev/null 2>&1; then
  if ! pyenv versions --bare | grep -q "3.13.0"; then
    pyenv install 3.13.0
  fi

  pyenv global 3.13.0

  if ! grep -q 'pyenv init' "$HOME/.zshrc"; then
    echo 'eval "$(pyenv init -)"' >> "$HOME/.zshrc"
  fi
fi

echo "==> Upgrading pip and installing poetry"
python3 -m pip install --upgrade pip pipx
pipx ensurepath
pipx install poetry || true

# GIT CONFIGURATION
echo "==> Setting up Git"
read -p "Git name: " GIT_NAME
read -p "Git email: " GIT_EMAIL

git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global core.editor "code --wait"

git config --global credential.helper=osxkeychain
git config --global credential.usehttppath=false

echo "==> Setting up global .gitignore"
cp "$(dirname "$0")/.gitignore" "$HOME/.gitignore_global"
git config --global core.excludesfile "$HOME/.gitignore_global"

echo "==> Setting up SSH"
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
  echo "Generating SSH key..."
  ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$HOME/.ssh/id_ed25519" -N ""
fi

eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519"

echo ""
echo "==> Add this SSH key to GitHub/GitLab:"
cat "$HOME/.ssh/id_ed25519.pub"

echo ""
echo "✅ Setup complete!"
echo "Restart your terminal or run: source ~/.zshrc"
