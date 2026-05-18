# InnovaDEF Demos

Colección de demos tecnológicas para aplicaciones de defensa y formación militar.
Cada demo es un módulo independiente incluido como submódulo de git.

## Demos disponibles

| Módulo | Descripción | Estado |
|--------|-------------|--------|
| [demo-aerocognitio](./demo-aerocognitio) | Batería psicotécnica para selección de personal RPAS — rotación mental 3D, orientación espacial, memoria táctica e informe IA | ✅ Activo |

---

## Clonar con todos los módulos

```bash
git clone --recurse-submodules https://github.com/MartinSuarez-Pumpun/innovadef-demos.git
```

Si ya tienes el repo clonado sin los submódulos:

```bash
git submodule update --init --recursive
```

---

## Añadir un módulo

El script añade el repo como submódulo, crea la rama `dev` y copia los workflows de CI/CD automáticamente.

Mac / Linux / Windows (Git Bash):
```bash
./scripts/add-module.sh https://github.com/MartinSuarez-Pumpun/nombre-del-repo.git
```

Windows (CMD):
```bat
scripts\add-module.bat https://github.com/MartinSuarez-Pumpun/nombre-del-repo.git
```

### Activar el deploy a GitHub Pages (paso manual, una vez por módulo)

Después de ejecutar el script, hay que habilitar GitHub Pages en el repo hijo:

1. Ve a **Settings → Pages** en el repo del módulo
2. En **Source**, selecciona **GitHub Actions**
3. Guarda

A partir de ese momento, cada merge a `main` despliega automáticamente.

### Proteger la rama main (recomendado)

Para que nadie pueda subir directamente a `main` sin pasar por `dev`:

1. Ve a **Settings → Branches** en el repo del módulo
2. Pulsa **Add rule** y escribe `main`
3. Activa **Require a pull request before merging**
4. Activa **Require status checks to pass** y añade el check `ci`
5. Guarda

---

## Flujo de trabajo en cada módulo

```
rama dev  →  push  →  CI corre (build check)
rama dev  →  PR → main  →  merge  →  Deploy a GitHub Pages
```

---

## Solicitar un nuevo módulo

Abre un issue usando la plantilla **Nueva demo** en GitHub Issues.