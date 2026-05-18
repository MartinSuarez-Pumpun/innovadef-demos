# InnovaDEF Demos

Colección de demos tecnológicas para aplicaciones de defensa y formación militar.
Cada demo es un módulo independiente incluido como submódulo de git.

## Demos disponibles

| Módulo | Descripción | Estado |
|--------|-------------|--------|
| [demo-aerocognitio](./demo-aerocognitio) | Batería psicotécnica para selección de personal RPAS — rotación mental 3D, orientación espacial, memoria táctica e informe IA | ✅ Activo |

## Clonar con todos los módulos

```bash
git clone --recurse-submodules https://github.com/MartinSuarez-Pumpun/innovadef-demos.git
```

Si ya tienes el repo clonado sin los submódulos:

```bash
git submodule update --init --recursive
```

## Añadir un módulo

Mac / Linux / Windows (Git Bash):
```bash
./scripts/add-module.sh https://github.com/MartinSuarez-Pumpun/nombre-del-repo.git
```

Windows (CMD):
```bat
scripts\add-module.bat https://github.com/MartinSuarez-Pumpun/nombre-del-repo.git
```

## Solicitar un nuevo módulo

Abre un issue usando la plantilla **Nueva demo** en GitHub Issues.