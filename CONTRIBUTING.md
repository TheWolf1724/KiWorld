# Guía de desarrollo — KiWorld

Instrucciones para trabajar en el proyecto de forma consistente.

## Requisitos

- **Godot 4.7** (rama estándar, no .NET / Mono).
- Para exportar a Android: Android SDK + JDK 17.

## Puesta en marcha

```bash
# Abrir el editor
godot --path .

# Ejecutar sin abrir el editor
godot --path . --headless        # sin ventana (para pruebas)
```

## Flujo de ramas

- **`main`** — estable. No se trabaja directamente aquí.
- **`dev`** — desarrollo. Crea ramas de feature desde `dev` y fusiónalas a `dev`.
- Promociona `dev → main` cuando haya un hito estable.

```bash
git checkout dev
git checkout -b feature/mi-cambio
# ... trabajo ...
git push -u origin feature/mi-cambio   # abre PR hacia dev
```

## Estilo de commits

Formato breve tipo *Conventional Commits*, en castellano:

```
feat: añade sistema de inventario
fix: corrige colisión del jugador con árboles
chore: actualiza dependencias del export
docs: amplía el README
```

> Mantén **README, ROADMAP y CHANGELOG actualizados** en el mismo commit que
> introduce el cambio relevante.

## Arquitectura (resúmen)

- **EventBus** (`scripts/core/EventBus.gd`): toda comunicación entre sistemas va
  por señales. Nada de referencias directas entre Player/Enemy/HUD/World.
- **Datos ≠ lógica**: tipos de enemigo (`EnemyData`) y skins se registran en
  `GameData`. Evita números mágicos dispersos.
- **Composición**: reutiliza `HealthComponent` y `StatsComponent`; crea
  componentes nuevos como nodos reutilizables.
- **Cálculos puros** en utilidades `static` (`Combat.gd`).
- **Guardado** centralizado en `SaveManager` (`user://savegame.json`).
- **Input** del jugador recogido en un único punto (`_gather_input`) → base lista
  para multiplayer.

## Assets (pixel-art)

Se generan proceduralmente. Tras editar `tools/gen_assets.gd`:

```bash
godot --headless res://tools/gen.tscn
```

Reglas de estilo y prompts de arte en [`PROMPTS.md`](PROMPTS.md). Mantén celdas de
**16×16** y paletas limitadas para que todo case visualmente.

## Pruebas

Las pruebas se hacen en **headless** (sin abrir ventana), cargando la escena y
comprobando estado por código. Patrón habitual:

```bash
godot --headless res://scenes/Main.tscn --quit-after 120   # smoke test sin errores
```

Para lógica concreta, crea una escena temporal en `tools/` que instancie `Main`,
manipule el estado y haga `print(...)`, y bórrala al terminar.

## Convenciones de código (GDScript 4.7)

- Tipado estático siempre que sea posible.
- Comentarios en castellano; identificadores en inglés.
- Funciones privadas con prefijo `_`.
- Nada de `Update`/trabajo innecesario por frame: prioriza señales y pooling.
