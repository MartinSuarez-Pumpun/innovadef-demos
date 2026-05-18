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

El script añade el repo como submódulo, crea la rama `dev` y copia el workflow de CI automáticamente.

Mac / Linux / Windows (Git Bash):
```bash
./scripts/add-module.sh https://github.com/MartinSuarez-Pumpun/nombre-del-repo.git
```

Windows (CMD):
```bat
scripts\add-module.bat https://github.com/MartinSuarez-Pumpun/nombre-del-repo.git
```

### Añadir el secret para sincronizar con el padre (obligatorio)

El workflow `notify-parent.yml` necesita un token para poder avisar al repo padre:

1. Crea un **Fine-grained token** en GitHub → Settings → Developer settings → Personal access tokens
   - Repository access: solo `innovadef-demos`
   - Permissions: `Actions` → Read & Write
2. En el repo del módulo ve a **Settings → Secrets and variables → Actions → New repository secret**
   - Name: `PARENT_REPO_TOKEN`
   - Value: el token creado

Sin este secret el sync no funciona.

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
rama dev  →  push  →  CI corre (build check, no está roto)
rama dev  →  PR → main  →  merge  →  submódulo se sincroniza en el padre
```

---

## Solicitar un nuevo módulo

Abre un issue usando la plantilla **Nueva demo** en GitHub Issues.