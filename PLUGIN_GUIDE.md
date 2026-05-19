# Guía de desarrollo de plugins — INNOVADEF

Cualquier módulo nuevo que aparezca en el selector del dashboard es un **plugin**. Esta guía explica cómo crear uno desde cero, registrarlo, y probarlo en local.

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
      // cualquier dato de resultado que necesites
      score: 87,
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

**Regla única:** el componente recibe `onComplete(result)` y lo llama cuando el usuario termina. El dashboard se encarga del resto (transición a email, vuelta al selector, etc.).

### 2. Registrarlo

Añade una entrada en `INNOVADEF-2026/src/plugins/registry.js`:

```js
import { lazy } from 'react'
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

Usa esta opción cuando el plugin tiene su propio repo, equipo o dependencias pesadas.

### 1. Estructura del repo del plugin

```
mi-plugin/
├── src/
│   ├── plugin.jsx      ← entry point obligatorio
│   ├── plugin.css      ← estilos aislados (ver sección CSS)
│   └── ...             ← resto de la app
├── plugin.json         ← manifiesto
└── package.json
```

### 2. Entry point (`src/plugin.jsx`)

```jsx
import './plugin.css'
import MiApp from './MiApp'

/**
 * onComplete(result) — llámalo cuando el usuario termine.
 * pluginMode={true}  — desactiva elementos fixed-position propios
 *                      que chocarían con el HUD del dashboard.
 */
export default function MiPlugin({ onComplete }) {
  return (
    <div className="mi-plugin">
      <MiApp onPluginComplete={onComplete} pluginMode={true} />
    </div>
  )
}
```

### 3. Aislamiento de CSS (`src/plugin.css`)

El dashboard define sus variables en `:root`. Tu plugin debe redefinirlas en su propio wrapper para no depender de que el dashboard las cargue:

```css
.mi-plugin {
  /* Redefine aquí las variables CSS que uses */
  --bg: #070707;
  --accent: #00FF41;
  --border: rgba(0, 255, 65, 0.22);
  /* ... */

  width: 100%;
  min-height: 100%;
  display: flex;
  flex-direction: column;
}

/* Si tu app tiene un shell con height: 100svh, sobrescríbelo */
.mi-plugin .app-shell {
  height: auto;
  min-height: 100%;
  overflow: visible;
}
```

### 4. Manifiesto (`plugin.json`)

```json
{
  "id": "mi-plugin",
  "version": "1.0.0",
  "label": "NOMBRE EN MAYÚS",
  "desc": "DESCRIPCIÓN CORTA",
  "category": "simulación",
  "tag": "ETIQUETA",
  "duration": "~4 MIN",
  "color": "#FF6644",
  "status": "ACTIVO",
  "entry": "src/plugin.jsx"
}
```

### 5. Añadirlo como submodulo de `innovadef-demos`

```bash
cd innovadef-demos
git submodule add https://github.com/org/mi-plugin.git demo-mi-plugin
git submodule update --init
```

### 6. Añadir el alias en `INNOVADEF-2026/vite.config.js`

```js
resolve: {
  alias: {
    '@aerocognitio': path.resolve(__dirname, '../demo-aerocognitio/src'),
    '@mi-plugin':    path.resolve(__dirname, '../demo-mi-plugin/src'),  // ← añadir
  },
  dedupe: ['react', 'react-dom', 'react/jsx-runtime'],
},
```

### 7. Registrarlo en `registry.js`

```js
{
  id: 'mi-plugin',
  code: 'MOD-10',
  // ...
  component: lazy(() => import('@mi-plugin/plugin')),
},
```

---

## El contrato de `onComplete`

El dashboard espera que `onComplete` reciba un objeto con al menos `type`. El resto es libre:

```js
onComplete({
  type: 'mi-plugin',       // obligatorio — identifica el plugin
  sessionId: '...',        // recomendado
  score: 87,               // opcional — lo que necesites
  report: { ... },         // opcional
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
import { usePluginSDK } from '@innovadef/plugin-sdk'
// o con la ruta relativa si es módulo interno:
// import { usePluginSDK } from '../plugins/PluginSDK'

function MiComponente() {
  const { theme, sfx, onComplete, callApi } = usePluginSDK()

  // Usar sonidos del sistema
  sfx.sfxHover()

  // Colores del tema
  const { ACCENT, BORDER } = theme

  // API backend (cuando esté disponible)
  // await callApi('results/save', { score: 87 })
}
```

---

## Probar en local

```bash
# 1. Clonar el repo principal con submodulos
git clone --recurse-submodules https://github.com/MartinSuarez-Pumpun/innovadef-demos.git
cd innovadef-demos

# 2. Instalar dependencias del plugin externo
cd demo-aerocognitio && pnpm install && cd ..
# (repetir para cada plugin externo que tengas)

# 3. Arrancar el dashboard
cd INNOVADEF-2026
pnpm install
pnpm dev --host
```

El plugin aparecerá en el selector junto al resto de módulos.

---

## Checklist antes de entregar un plugin

- [ ] El componente exporta `default function MiPlugin({ onComplete })`
- [ ] Llama a `onComplete(result)` al terminar y `onComplete(null)` si cancela
- [ ] Los estilos están aislados (no contamina el dashboard ni se rompe dentro de él)
- [ ] Está registrado en `registry.js` con todos los campos
- [ ] `pnpm build` en `INNOVADEF-2026` no da errores
- [ ] Si es plugin externo: tiene `plugin.json` y `src/plugin.jsx`