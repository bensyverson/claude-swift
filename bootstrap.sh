#!/bin/bash
# bootstrap.sh — Clone repos into /workspace (idempotent)
# Reads repo URLs from /shared/repos.txt (one per line)
set -euo pipefail

REPO_FILE="/shared/repos.txt"

if [ ! -f "$REPO_FILE" ]; then
    if [ -f "/shared/repos.example.txt" ]; then
        echo "No repos.txt found. Copying from repos.example.txt..."
        echo "Edit /shared/repos.txt (shared/repos.txt on the host) to customize."
        cp /shared/repos.example.txt "$REPO_FILE"
    else
        echo "No repo file found at $REPO_FILE"
        echo "Create it with one git URL per line, e.g.:"
        echo "  git@github.com:user/repo.git"
        echo "  https://github.com/user/repo.git"
        exit 1
    fi
fi

# Add SSH hosts to known_hosts (avoids interactive prompts)
mkdir -p ~/.ssh
while IFS= read -r url || [ -n "$url" ]; do
    url=$(echo "$url" | xargs)
    [[ -z "$url" || "$url" == \#* ]] && continue
    # Extract hostname from SSH URLs (git@host:...) or HTTPS (https://host/...)
    if [[ "$url" == git@* ]]; then
        host="${url#git@}" && host="${host%%:*}"
    elif [[ "$url" == https://* ]]; then
        host="${url#https://}" && host="${host%%/*}"
    else
        continue
    fi
    if ! grep -qF "$host" ~/.ssh/known_hosts 2>/dev/null; then
        ssh-keyscan -t ed25519,rsa "$host" >> ~/.ssh/known_hosts 2>/dev/null
    fi
done < "$REPO_FILE"

cd /workspace

while IFS= read -r url || [ -n "$url" ]; do
    # Skip blank lines and comments
    url=$(echo "$url" | xargs)
    [[ -z "$url" || "$url" == \#* ]] && continue

    # Extract repo name from URL (strip trailing .git and path)
    name=$(basename "$url" .git)

    if [ -d "$name" ]; then
        echo "✓ $name already exists, skipping"
    else
        echo "→ Cloning $name..."
        git clone "$url"
    fi
done < "$REPO_FILE"

echo ""
echo "All repos ready in /workspace"
