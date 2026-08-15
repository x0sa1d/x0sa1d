#!/usr/bin/env bash
# Idempotent environment bootstrap for the profile README repo.
# Installs the two tools that make up the dev loop:
#   - markdownlint-cli2 : lint the README (Node, via npm)
#   - grip              : GitHub-accurate README preview server (Python, via pip)
# Both are symlinked into /usr/local/bin so they resolve on PATH regardless of
# the image's default npm prefix or Python user-base.
set -euo pipefail

NPM_GLOBAL_DIR="$HOME/.npm-global"

echo "==> Installing markdownlint-cli2"
npm install -g markdownlint-cli2 --prefix "$NPM_GLOBAL_DIR" --no-fund --no-audit
sudo ln -sf "$NPM_GLOBAL_DIR/bin/markdownlint-cli2" /usr/local/bin/markdownlint-cli2

echo "==> Installing grip (GitHub Readme Instant Preview)"
pip install --user --break-system-packages --upgrade grip
# Write a small launcher instead of symlinking pip's generated console script:
# pip reports "already satisfied" and skips recreating that script on re-runs,
# which can leave a dangling symlink. This wrapper imports grip from the user
# site-packages (already on the ubuntu user's sys.path) and stays valid.
sudo tee /usr/local/bin/grip >/dev/null <<'LAUNCHER'
#!/usr/bin/env python3
import sys
from grip.command import main
sys.exit(main())
LAUNCHER
sudo chmod +x /usr/local/bin/grip

echo "==> Installed tool versions"
markdownlint-cli2 --version
grip --version
