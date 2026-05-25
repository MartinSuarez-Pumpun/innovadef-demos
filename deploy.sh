#!/bin/bash
# deploy.sh — actualiza y rebuilds INNOVADEF-2026 en producción
# Uso: bash deploy.sh
set -e

echo "→ Pulling latest changes..."
git pull --rebase

echo "→ Updating submodules..."
git submodule update --init --recursive
git submodule update --remote --merge

echo "→ Installing plugin dependencies..."
for dir in demo-*/; do
  if [ -f "$dir/package.json" ]; then
    echo "  pnpm install in $dir"
    (cd "$dir" && pnpm install)
  fi
done

echo "→ Installing server dependencies..."
(cd INNOVADEF-2026/server && npm install --omit=dev)

echo "→ Building INNOVADEF-2026..."
(cd INNOVADEF-2026 && pnpm install && pnpm build)

echo "✓ Deploy done. Dist: INNOVADEF-2026/dist"