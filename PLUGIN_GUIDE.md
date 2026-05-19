# Guía de desarrollo de plugins — INNOVADEF

Cualquier módulo nuevo que aparezca en el selector del dashboard es un **plugin**. Esta guía explica cómo crear uno desde cero y cómo integrarlo.

---

## Tipos de plugin

| Tipo | Cuándo usarlo | Dónde vive |
|------|--------------|------------|
| **Módulo interno** | Componente React sencillo, sin dependencias externas | `INNOVADEF-2026/src/modules/` |
| **Plugin externo** | Repo independiente, equipo separado, dependencias propias | Submodulo de `innovadef-demos` |

AeroCognitio es un ejemplo de plugin externo. CyberDefense es un ejemplo de módulo interno.

---

## Opción A — Módulo interno

### 1. Crear el componente

Crea `INNOVADEF-2026/src/modules/MiModulo.jsx`:

```jsx
export default function MiModulo({ onComplete }) {
  const handleFinish = () => {
    onComplete({
      type: 'mi-modulo',
      score: 87, // cualquier dato de resultado
    })
  }

  return (
    <div>
      {/* tu UI aquí */}
      <button onClick={handleFinish}>Finalizar</button>
    </div>
  )
}
```

**Regla única:** el componente recibe `onComplete(result)` y lo llama cuando el usuario termina.

### 2. Registrarlo

Añade una entrada en `INNOVADEF-2026/src/plugins/registry.js`:

```js
import { MiIcono } from 'lucide-react'   // cualquier icono de lucide-react

{
  id: 'mi-modulo',           // único, se usa en la URL /module/mi-modulo
  code: 'MOD-10',            // siguiente número disponible
  label: 'NOMBRE EN MAYÚS',
  desc: 'DESCRIPCIÓN CORTA — VISIBLE EN LA CARD DEL SELECTOR',
  icon: MiIcono,
  color: '#FF6644',          // color de acento de la card
  duration: '~3 MIN',
  tag: 'ETIQUETA',           // texto pequeño en la card (SIMULADOR, EVALUACIÓN, etc.)
  category: 'simulación',    // agrupa las cards en el selector (lowercase)
  status: 'ACTIVO',          // 'ACTIVO' | 'PRÓXIMO' | 'MANTENIMIENTO'
  component: lazy(() => import('../modules/MiModulo')),
},
```

**Eso es todo.** No hay que tocar `App.jsx`.

---

## Opción B — Plugin externo (repo independiente)

> El sistema auto-descubre plugins externos. **No hay que tocar `vite.config.js` ni `registry.js`.**
> Un tercero solo necesita: su propio repo + `plugin.json` + `src/plugin.jsx`.

### 1. Estructura del repo del plugin

```
demo-mi-plugin/
├── src/
│   ├── plugin.jsx      ← entry point obligatorio
│   ├── plugin.css      ← estilos aislados (ver sección CSS)
│   └── ...             ← resto de la app
├── plugin.json         ← manifiesto (campos requeridos abajo)
└── package.json
```

### 2. Manifiesto (`plugin.json`)

Todos los campos son obligatorios:

```json
{
  "id": "mi-plugin",
  "version": "1.0.0",
  "code": "MOD-10",
  "label": "NOMBRE EN MAYÚS",
  "desc": "DESCRIPCIÓN CORTA — VISIBLE EN LA CARD DEL SELECTOR",
  "icon": "Rocket",
  "color": "#FF6644",
  "category": "simulación",
  "tag": "ETIQUETA",
  "duration": "~4 MIN",
  "status": "ACTIVO",
  "entry": "src/plugin.jsx"
}
```

El campo `icon` debe ser el nombre exacto de un componente de [lucide-react](https://lucide.dev/icons/).

### 3. Entry point (`src/plugin.jsx`)

```jsx
import './plugin.css'
import MiApp from './MiApp'

export default function MiPlugin({ onComplete }) {
  return (
    <div className="mi-plugin">
      <MiApp onPluginComplete={onComplete} pluginMode={true} />
    </div>
  )
}
```

`pluginMode={true}` desactiva elementos `position: fixed` propios que chocarían con el HUD del dashboard.

### 4. Aislamiento de CSS (`src/plugin.css`)

El dashboard define sus variables en `:root`. Tu plugin debe redefinirlas en su propio wrapper:

```css
.mi-plugin {
  --bg: #070707;
  --accent: #00FF41;
  --border: rgba(0, 255, 65, 0.22);
  /* resto de variables que uses */

  width: 100%;
  min-height: 100%;
  display: flex;
  flex-direction: column;
}

/* Si tu app tiene height: 100svh en el shell, sobrescríbelo */
.mi-plugin .app-shell {
  height: auto;
  min-height: 100%;
  overflow: visible;
}
```

### 5. Añadirlo como submodulo

Esto lo hace quien gestiona `innovadef-demos`, no el autor del plugin:

```bash
cd innovadef-demos
git submodule add https://github.com/org/mi-plugin.git demo-mi-plugin
git add .gitmodules demo-mi-plugin
git commit -m "feat: add demo-mi-plugin submodule"
git push
```

**El directorio debe empezar por `demo-`** — es la convención que usa el auto-discovery.

**Listo.** En el siguiente `pnpm dev` o `pnpm build` el plugin aparece automáticamente en el selector. No hay que modificar ningún otro archivo.

---

## El contrato de `onComplete`

El dashboard espera que `onComplete` reciba un objeto con al menos `type`. El resto es libre:

```js
onComplete({
  type: 'mi-plugin',   // obligatorio — identifica el plugin
  sessionId: '...',    // recomendado
  score: 87,           // opcional
  report: { ... },     // opcional
})
```

Si el usuario cancela o sale sin terminar, pasa `null`:

```js
onComplete(null)
```

El dashboard redirige a la pantalla de email con cualquier resultado no-nulo, y vuelve al selector con `null`.

---

## SDK del dashboard (opcional)

Dentro de cualquier plugin puedes acceder al contexto del dashboard:

```js
// Plugin externo
import { usePluginSDK } from '@mi-plugin/../plugins/PluginSDK'
// Módulo interno
import { usePluginSDK } from '../plugins/PluginSDK'

function MiComponente() {
  const { theme, sfx, onComplete, callApi } = usePluginSDK()

  sfx.sfxHover()                          // sonidos del sistema
  const { ACCENT, BORDER } = theme        // colores del tema
  // await callApi('results/save', data)  // API backend (cuando esté disponible)
}
```

---

## Probar en local

```bash
# 1. Clonar el repo principal con submodulos
git clone --recurse-submodules https://github.com/MartinSuarez-Pumpun/innovadef-demos.git
cd innovadef-demos

# 2. Instalar dependencias de cada plugin externo
for dir in demo-*/; do
  [ -f "$dir/package.json" ] && (cd "$dir" && pnpm install)
done

# 3. Arrancar el dashboard
cd INNOVADEF-2026
pnpm install
pnpm dev --host
```

Los plugins aparecerán en el selector automáticamente.

---

## Checklist antes de entregar un plugin externo

- [ ] `plugin.json` tiene todos los campos: `id`, `code`, `label`, `desc`, `icon`, `color`, `category`, `tag`, `duration`, `status`
- [ ] `icon` es un nombre válido de [lucide-react](https://lucide.dev/icons/)
- [ ] `src/plugin.jsx` exporta `default function MiPlugin({ onComplete })`
- [ ] Llama a `onComplete(result)` al terminar y `onComplete(null)` si cancela
- [ ] Los estilos están aislados con una clase wrapper (no usa `:root`)
- [ ] El directorio del repo empieza por `demo-` en `innovadef-demos`
- [ ] `pnpm build` en `INNOVADEF-2026` no da errores tras añadir el submodulo