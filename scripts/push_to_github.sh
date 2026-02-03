#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./scripts/push_to_github.sh <git_remote_url>
# Example:
#   ./scripts/push_to_github.sh https://github.com/USERNAME/REPO.git

REMOTE_URL="${1:-}"
if [[ -z "$REMOTE_URL" ]]; then
  echo "Missing remote url. Example: ./scripts/push_to_github.sh https://github.com/USERNAME/REPO.git" >&2
  exit 1
fi

if [[ ! -d .git ]]; then
  git init
  git branch -M main
fi

git add .
git commit -m "Initial commit" || true

git remote remove origin 2>/dev/null || true
git remote add origin "$REMOTE_URL"
git push -u origin main

echo "Pushed to: $REMOTE_URL"
