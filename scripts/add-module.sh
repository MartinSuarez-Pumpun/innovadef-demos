#!/usr/bin/env bash
# add-module.sh — Añade un repo como submódulo
# Uso: ./scripts/add-module.sh <github-url> [nombre-carpeta]
# Mac / Linux / Windows (Git Bash)

set -e

URL="$1"
NAME="${2:-$(basename "$URL" .git)}"

if [ -z "$URL" ]; then
  echo "Uso: ./scripts/add-module.sh <github-url> [nombre-carpeta]"
  echo "Ej:  ./scripts/add-module.sh https://github.com/org/demo-nuevo.git"
  exit 1
fi

echo ""
echo "→ Añadiendo submódulo: $NAME"
echo "  URL: $URL"
echo ""

git submodule add "$URL" "$NAME"
git add .gitmodules "$NAME"
git commit -m "add $NAME as submodule"

echo ""
echo "✓ Listo. Sube los cambios con: git push"
echo ""