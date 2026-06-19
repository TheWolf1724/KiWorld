<div align="center">

# ⚔️ KiWorld

**MMORPG 2D top-down pixel-art** — combate rápido, guerreros de energía y progresión de rol.
Inspirado libremente en clásicos como Rucoy Online, con estética original.

[![Engine](https://img.shields.io/badge/Godot-4.7-478CBF?logo=godotengine&logoColor=white)](https://godotengine.org)
[![Lenguaje](https://img.shields.io/badge/GDScript-tipado-355570)](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/)
[![Licencia](https://img.shields.io/badge/Licencia-CC%20BY--NC%204.0-lightgrey)](LICENSE)
[![Plataforma](https://img.shields.io/badge/Plataforma-PC%20%C2%B7%20Android-lightgrey)]()

</div>

---

## 📖 Sobre el proyecto

KiWorld es un juego de rol de acción en 2D con vista cenital, hecho en **Godot 4.7**.
Es **single-player** pero su arquitectura está desacoplada de la red para poder
añadir multiplayer en el futuro sin reescribir la lógica. Todo el pixel-art se
genera proceduralmente (estilo anime de artes marciales, **100% original**).

## ✨ Características

- 🥋 **Guerrero top-down** con sprite animado en 4 direcciones y cámara que sigue.
- 🗺️ **Mundo con tiles** (hierba, camino, arena, agua, rocas, árboles, cristales) y colisiones ajustadas a lo que se ve.
- 👾 **Enemigos con IA** (idle → persecución/aggro → ataque): Planta Guerrera, Androide C y Guerrero Oscuro.
- 💥 **Combate**: golpe melee, **bola de ki** a distancia y **ataque en área**, con críticos y números de daño flotantes.
- 🔵 **Barra de ki**: se gasta con las habilidades, se regenera con el tiempo y se **carga rápido manteniendo R** (quedas inmóvil y sin atacar: vulnerable).
- 📈 **Progresión**: XP, niveles y **elección de 1 de 3 mejoras por nivel** (vida / daño / velocidad).
- 🪙 **Monedas especiales** (drop poco habitual) y **tienda** para comprar y equipar **skins de personaje**.
- ⏸️ **Menú de pausa** (Continuar / Reiniciar / Salir) y **ventana de controles** al iniciar.
- 💾 **Guardado local** automático.

## 🎮 Controles

| Tecla | Acción |
|---|---|
| `WASD` / Flechas | Mover (8 direcciones) |
| `Espacio` / `J` | Golpe melee |
| `E` | Bola de ki (gasta ki) |
| `Q` | Ataque en área (gasta ki) |
| `R` (mantener) | Cargar ki — inmóvil y sin atacar |
| `T` | Abrir la tienda |
| `ESC` | Pausa |

## 🚀 Cómo ejecutarlo

1. Instala **[Godot 4.7](https://godotengine.org/download)** (rama estándar, no .NET).
2. Abre Godot → **Import** → selecciona este `project.godot`.
3. Pulsa **F5** para jugar.

Desde terminal:

```bash
godot --path .
```

### 📱 Exportar a Android
*Project → Export → Android*, apuntando a un Android SDK + JDK 17. Para el control
táctil, mapea botones en pantalla a las mismas acciones de input — la lógica no cambia.

## 🧱 Estructura del proyecto

```
KiWorld/
├── project.godot          # Configuración del proyecto y autoloads
├── assets/                # Pixel-art generado (player, enemigos, tiles, fx, skins)
├── scenes/                # Escenas (.tscn): Main, entidades, UI
├── scripts/
│   ├── core/              # EventBus, GameData, SaveManager, Combat, Bootstrap
│   ├── components/        # HealthComponent, StatsComponent (composición)
│   ├── data/              # EnemyData (datos ≠ lógica)
│   ├── entities/          # Player, Enemy, KiBlast, AreaBlast, Coin
│   ├── ui/                # HUD, GameUI (controles/pausa/tienda/mejoras), FloatingText
│   └── world/             # Main (mundo, tilemap, spawns)
└── tools/                 # gen_assets.gd (generador de pixel-art)
```

**Arquitectura:** comunicación entre sistemas vía `EventBus` (señales), datos
separados de la lógica (`EnemyData`/`GameData`), composición sobre herencia
(`HealthComponent`/`StatsComponent`) y guardado en `SaveManager`. El input del
jugador se recoge en un único punto, lista la base para multiplayer.

## 🎨 Regenerar los assets

El pixel-art se crea con un generador procedural:

```bash
godot --headless res://tools/gen.tscn
```

Para sustituirlos por arte propio (p. ej. generado con IA), reemplaza los PNG de
`assets/` manteniendo el tamaño de celda (16×16). Ver prompts en [`PROMPTS.md`](PROMPTS.md).

## 🌿 Ramas

- **`main`** — rama estable.
- **`dev`** — desarrollo activo.

## 📚 Más documentación

- [`ROADMAP.md`](ROADMAP.md) — qué viene después.
- [`CHANGELOG.md`](CHANGELOG.md) — historial de cambios.
- [`CONTRIBUTING.md`](CONTRIBUTING.md) — cómo trabajar en el proyecto.
- [`PROMPTS.md`](PROMPTS.md) — prompts de desarrollo y de arte.

## 📄 Licencia

Licenciado bajo **[CC BY-NC 4.0](LICENSE)** (Creative Commons Atribución-NoComercial) © 2026 TheWolf1724.

Puedes **usar, compartir y adaptar** el proyecto **sin fines comerciales**,
siempre que **des crédito** al autor (TheWolf1724) y enlaces a este repositorio.
El **uso comercial no está permitido** sin autorización expresa.

Los assets son originales generados proceduralmente; el proyecto no está
afiliado a ninguna marca y la temática es inspiración del género.
