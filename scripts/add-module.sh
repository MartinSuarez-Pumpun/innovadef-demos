#!/usr/bin/env bash
# add-module.sh — Añade un repo como submódulo y configura rama dev + CI/CD
# Uso: ./scripts/add-module.sh <github-url> [nombre-carpeta]
# Mac / Linux / Windows (Git Bash)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

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

# 1. Añadir como submódulo
git submodule add "$URL" "$NAME"
git add .gitmodules "$NAME"
git commit -m "add $NAME as submodule"

# 2. Entrar en el submódulo y configurar rama dev + workflows
cd "$ROOT_DIR/$NAME"

echo "→ Configurando rama dev y workflows en $NAME..."

# Crear rama dev si no existe
git checkout -b dev 2>/dev/null || git checkout dev

# Copiar plantillas de workflows
mkdir -p .github/workflows
cp "$ROOT_DIR/templates/workflows/ci.yml"             .github/workflows/ci.yml
cp "$ROOT_DIR/templates/workflows/notify-parent.yml"  .github/workflows/notify-parent.yml

git add .github
git commit -m "add CI/CD workflows (ci → dev, deploy → main)"

# Subir ambas ramas
git push -u origin main
git push -u origin dev

echo ""
echo "→ Configurando protección de ramas via gh CLI..."
if command -v gh &>/dev/null; then
  REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)
  if [ -n "$REPO" ]; then
    gh api repos/"$REPO"/branches/main/protection \
      --method PUT \
      --field required_status_checks='{"strict":true,"contexts":["ci"]}' \
      --field enforce_admins=false \
      --field required_pull_request_reviews='{"required_approving_review_count":0}' \
      --field restrictions=null \
      --silent && echo "  ✓ Rama main protegida (requiere PR desde dev)" \
               || echo "  ! No se pudo proteger main automáticamente — hazlo en GitHub → Settings → Branches"
  fi
else
  echo "  ! gh CLI no encontrado. Protege main manualmente en GitHub → Settings → Branches"
  echo "    Regla: require pull request before merging, source branch: dev"
fi

cd "$ROOT_DIR"

echo ""
echo "✓ Listo. Sube el padre con: git push"
echo ""
echo "  Flujo de trabajo:"
echo "    → Desarrolla en rama dev"
echo "    → Abre PR de dev → main para publicar"
echo ""