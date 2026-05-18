# InnovaDEF Demos

Colección de demos tecnológicas para aplicaciones de defensa y formación militar.
Cada demo es un módulo independiente incluido como submódulo de git.

## Demos disponibles

| Módulo | Descripción | Estado |
|--------|-------------|--------|
| [demo-aerocognitio](./demo-aerocognitio) | demo-aerocognitio | ✅ Activo |
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
   - Permissions: `Contents` → Read & Write
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

## Incorporar un módulo existente

Si ya tienes un repositorio construido y quieres añadirlo a la colección:

1. Abre un issue usando la plantilla **Añadir módulo existente**
2. Rellena la URL de tu repo y el nombre de la carpeta
3. El propietario revisará y añadirá la etiqueta `approved`
4. El workflow se encarga de todo automáticamente:
   - Añade tu repo como submódulo
   - Instala el workflow de sync en tu repositorio
   - Inyecta el secret `PARENT_REPO_TOKEN` en tu repo
   - Actualiza este README

A partir de ese momento, cualquier push a `main` en tu repo actualizará el submódulo aquí de forma automática.

---

### Secrets requeridos en `innovadef-demos` (solo el propietario)

| Secret | Descripción |
|--------|-------------|
| `MODULES_TOKEN` | Classic PAT con scope `repo` — lee/escribe repos externos, inyecta secrets |
| `CHILD_NOTIFY_TOKEN` | Fine-Grained PAT con Contents R/W solo en `innovadef-demos` — se inyecta como `PARENT_REPO_TOKEN` en cada módulo hijo |