#!/usr/bin/env node
/**
 * add-module.mjs — Añade un repo de GitHub como submódulo
 *
 * Uso:
 *   node scripts/add-module.mjs <github-url> [nombre-carpeta]
 *
 * Ejemplo:
 *   node scripts/add-module.mjs https://github.com/MartinSuarez-Pumpun/demo-nuevo.git
 *   node scripts/add-module.mjs https://github.com/MartinSuarez-Pumpun/demo-nuevo.git mi-nombre
 */

import { execSync } from 'child_process'

const [,, url, customName] = process.argv

if (!url) {
  console.error('❌  Uso: node scripts/add-module.mjs <github-url> [nombre-carpeta]')
  process.exit(1)
}

const name = customName ?? url.split('/').pop().replace(/\.git$/, '')

console.log(`\n→ Añadiendo submódulo: ${name}`)
console.log(`  URL: ${url}\n`)

try {
  execSync(`git submodule add ${url} ${name}`, { stdio: 'inherit' })
  execSync(`git add .gitmodules ${name}`, { stdio: 'inherit' })
  execSync(`git commit -m "add ${name} as submodule"`, { stdio: 'inherit' })
  console.log(`\n✓ Listo. Sube los cambios con:\n  git push\n`)
} catch (e) {
  console.error('\n❌  Error al añadir el submódulo. Comprueba que la URL es correcta y tienes acceso al repo.')
  process.exit(1)
}