# 🏥 Sistema Experto — Diagnóstico de Varicela

Sistema experto en **Prolog** para el diagnóstico asistido de varicela, con interfaz web construida en **AstroJS** y conexión al motor de inferencia mediante **Node.js**.

## Características

- **105 reglas Prolog** que cubren síntomas, diagnóstico, tratamiento, complicaciones y triage
- Interpretación dinámica de resultados de laboratorio (temperatura, leucocitos, PCR)
- Soporte de múltiples alergias e historial médico por paciente
- Mecanismo de feedback del paciente que ajusta el diagnóstico y tratamiento
- Interfaz web con View Transitions y formulario de 5 secciones
- API REST que genera hechos Prolog dinámicos y ejecuta consultas en tiempo real

## Tecnologías

| Capa | Tecnología |
|---|---|
| Motor de inferencia | SWI-Prolog |
| Frontend | AstroJS 4 + View Transitions |
| Backend / Bridge | Node.js (SSR con `@astrojs/node`) |
| Lenguaje | TypeScript |

## Requisitos

- [Node.js](https://nodejs.org/) >= 18
- [SWI-Prolog](https://www.swi-prolog.org/)

```bash
# Arch Linux
sudo pacman -S swi-prolog

# Ubuntu / Debian
sudo apt install swi-prolog
```

## Instalación y uso

```bash
# 1. Clonar el repositorio
git clone git@github.com:Rodrigoss06/SI-Project.git
cd SI-Project

# 2. Instalar dependencias
npm install

# 3. Iniciar en modo desarrollo
npm run dev
# → http://localhost:4321

# 4. Build para producción
npm run build
npm start
```

## Estructura del proyecto

```
project/
├── varicela.pl              # Base de conocimiento Prolog (105 reglas)
├── astro.config.mjs         # Configuración AstroJS SSR
├── src/
│   ├── layouts/
│   │   └── Layout.astro     # Layout base con ViewTransitions
│   ├── lib/
│   │   └── prologBridge.ts  # Puente Node.js ↔ SWI-Prolog
│   └── pages/
│       ├── index.astro      # Formulario de diagnóstico (5 secciones)
│       ├── resultado.astro  # Página de resultados
│       └── api/
│           └── diagnostico.ts  # Endpoint POST /api/diagnostico
```

## Flujo del sistema

```
Usuario llena formulario
        ↓
POST /api/diagnostico (JSON)
        ↓
prologBridge genera hechos .pl temporales
        ↓
swipl ejecuta consultar_paciente/1
        ↓
Se parsea la salida y se retorna JSON
        ↓
resultado.astro muestra diagnóstico con View Transitions
```

## Base de conocimiento Prolog

El archivo `varicela.pl` implementa:

- **Hechos**: síntomas clave, factores de riesgo, complicaciones, tratamientos, pruebas clínicas
- **Diagnóstico**: `varicela_probable/1`, `diagnostico_final/2` (leve / grave / descartado)
- **Laboratorio**: `interpretar_temperatura/2`, `interpretar_leucocitos/2`, `resultado_lab_critico/2`
- **Tratamiento**: `tratamiento_recomendado/2` con lógica de alergias y tolerancia
- **Feedback**: `feedback_empeora/1`, `alerta_por_feedback/1`, `ajuste_por_feedback/3`
- **Triage**: `prioridad_alta/1`, `prioridad_media/1`, `caso_grave/1`
- **Derivación**: `manejo_ambulatorio/1`, `derivacion_hospitalaria/1`

## Checklist de requisitos

| Requisito | Estado |
|---|---|
| Mínimo 40 hechos y reglas | ✅ 105 reglas |
| Síntomas → inferir condiciones | ✅ |
| Contraindicaciones y alergias | ✅ múltiples alergias por paciente |
| Recomendaciones de tratamiento | ✅ |
| Base de conocimiento médico | ✅ |
| Historial médico del paciente | ✅ múltiples entradas, enf. previas |
| Pruebas de laboratorio — interpretar resultados | ✅ reglas con umbrales dinámicos |
| Feedback del paciente | ✅ afecta diagnóstico y tratamiento |
| Interfaz de Usuario | ✅ AstroJS + View Transitions |
| GitHub | ✅ |
