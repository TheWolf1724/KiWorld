# Prompts maestros — KiWorld

Dos familias de prompts: **código** (para Claude Code / Cursor / Copilot) y
**arte** (para generadores de imagen). La clave de la coherencia es usar
**siempre el mismo bloque base** y pedir **una cosa concreta cada vez**.

> Nota legal: para uso **personal/privado** puedes inspirarte en lo que
> quieras. Si algún día lo distribuyes, mantén los assets **originales**
> (inspirados, no calcados de obras con copyright).

---

## A) PROMPT BASE DE CÓDIGO — pégalo SIEMPRE al principio

```
Trabajo en "KiWorld", un MMORPG 2D top-down pixel-art SINGLE-PLAYER hecho en
Godot 4.7 (GDScript), con arquitectura preparada para multiplayer futuro.

RESPETA SIEMPRE la arquitectura existente del proyecto:
- Comunicación entre sistemas SOLO vía el autoload EventBus (señales). Nada
  de referencias directas entre Player/Enemy/HUD/World.
- Datos separados de la lógica: tipos de enemigo/objeto como Resource
  (estilo EnemyData.gd) registrados en GameData. Nada de números mágicos
  dispersos.
- Composición sobre herencia: reutiliza HealthComponent y StatsComponent;
  crea componentes nuevos como nodos reutilizables, no clases monolíticas.
- Cálculos puros (daño, etc.) en utilidades static tipo Combat.gd.
- El input del jugador se recoge en un único punto (_gather_input) para que
  la red pueda sustituir la fuente sin tocar movimiento/combate.
- Guardado local vía SaveManager (user://).

REGLAS DE GENERACIÓN:
- Primero explica brevemente el diseño y qué archivos tocas; luego el código.
- GDScript 4.7 idiomático, tipado estático, comentarios en español.
- Código funcional y completo (nada de pseudocódigo ni "// TODO implementar").
- Indica exactamente dónde va cada archivo y cómo conectarlo en el editor.
- Optimizado para móvil: evita trabajo en _process si puede ir por señales;
  usa object pooling para cosas frecuentes (proyectiles, números flotantes).
- No añadas dependencias ni plugins salvo que lo pida explícitamente.
- No rompas lo existente: si cambias una señal o API, dilo y actualiza usos.

OBJETIVO DE ESTA TAREA:
<<aquí UNA sola cosa: "implementa el inventario", "añade habilidad de
proyectil de Ki con cooldown", "crea un sistema de dungeons por escenas",
"añade NPC con diálogo", etc.>>
```

### Cómo pedir los sistemas (uno por uno, en este orden sugerido)
1. Spritesheets + `AnimatedSprite2D` para Player/Enemy (sustituir placeholders).
2. `TileMapLayer` + tileset real para el mundo (sustituir el suelo dibujado).
3. Habilidades: ataque a distancia (proyectil) y una magia con cooldown/coste.
4. Inventario + equipo + loot al morir enemigos.
5. NPCs con diálogo y quests simples.
6. Transición entre zonas/escenas (mundo → dungeon → boss room).
7. Un boss con varias fases.
8. Control táctil para Android (joystick virtual + botones).
9. (Futuro) Capa de red: `MultiplayerSpawner`/`Synchronizer` sobre lo que ya hay.

---

## B) PROMPTS DE ARTE

### B0) STYLE LOCK — pégalo SIEMPRE, en CADA imagen
Es lo que garantiza que todo case. No lo cambies entre assets.

```
Pixel art, estilo retro MMORPG top-down (vista cenital ligeramente inclinada),
inspirado en Rucoy Online y en anime de acción de guerreros de energía (estilo
original, no personajes con copyright). Paleta vibrante y limitada (máx ~4
tonos por color), outline oscuro consistente de 1px, sombreado plano (cel),
contraste alto, siluetas muy legibles a tamaño pequeño. SIN anti-aliasing, SIN
desenfoque, SIN degradados suaves, SIN estilo HD-2D, SIN iluminación realista.
Fondo transparente. Sprite nítido alineado a la rejilla de píxeles.
```

### Workflow para coherencia ABSOLUTA (lo que hacen los indies)
1. Genera **1 imagen maestra** (un personaje base) que te encante.
2. Para todo lo demás usa **image-to-image** partiendo de esa imagen + el
   STYLE LOCK, variando solo el sujeto.
3. Mantén **mismo tamaño de canvas**, **misma paleta**, **mismo STYLE LOCK**.
4. Guarda tu paleta (los códigos hex) y pásala como referencia cada vez.

### B1) Personajes (jugador / clases)
```
[STYLE LOCK]
Hoja de sprite de personaje para un MMORPG top-down. Sujeto: <guerrero de
energía / espadachín / mago / arquero / androide>, proporción chibi ligera
(cabeza algo grande), silueta heroica reconocible. Canvas 48x48 por frame.
Entrega filas de animación: idle (4 frames), walk (4 frames por cada una de
las 4 direcciones: abajo/arriba/izq/der), attack (4), cast (4), hurt (2),
death (4). Colores vivos, expresión marcada. Coherente para combinar con el
resto del set.
```

### B2) Enemigos
```
[STYLE LOCK]
Enemigo para MMORPG top-down. Sujeto: <slime de energía / androide /
guerrero sombra / alien / demonio>. Tamaño según rango: small 32x32,
medium 48x48, large 64x64, boss 96x96. La silueta debe comunicar de un
vistazo su peligrosidad. Color coherente con su bioma. Animaciones: idle (4),
walk (4 x 4 direcciones), attack (4), hurt (2), death (4). Mismo lenguaje
visual que el resto de enemigos del set.
```

### B3) Tiles / mapas
```
[STYLE LOCK]
Tileset modular 16x16 para mundo top-down, ensamblable sin costuras
(seamless). Bioma: <bosque / desierto / volcán / nieve / ciudad futurista /
islas flotantes / ruinas antiguas>. Incluye: suelo base + variantes,
transiciones de borde (auto-tiling 47 piezas si es posible), caminos, agua
con bordes, rocas, árboles/props, decoración. Caminos y zonas transitables
muy legibles. Paleta coherente entre todos los biomas del juego.
```

### B4) Objetos / iconos
```
[STYLE LOCK]
Iconos de objeto de MMORPG, 32x32, fondo transparente, estilo "ficha" clásica
con outline. Set: <espadas / arcos / bastones / pociones / armaduras /
cristales de energía / monedas>. Muy identificables de un vistazo, poco
detalle, color fuerte. Misma luz y mismo grosor de outline en todo el set.
```

### B5) UI
```
[STYLE LOCK]
Kit de UI pixel-art minimalista para MMORPG móvil. Elementos: barra de vida,
barra de maná/energía, barra de XP, marco de inventario (slots), barra de
habilidades, ventana de chat, minimapa, marco de party. Bordes pixelados,
alto contraste, pocos colores, cómodo para dedos en pantalla pequeña. 9-slice
friendly (esquinas y bordes separables). No recargar la pantalla.
```

### B6) Efectos (VFX)
```
[STYLE LOCK]
Spritesheet de efecto de combate pixel-art. Efecto: <impacto melee / explosión
/ aura de energía / onda de Ki / proyectil de energía / dash / crítico>. 6-8
frames, lectura clara del movimiento, colores intensos, pocas partículas pero
contundentes. Pensado para verse fluido en móvil modesto.
```

---

## C) Consejo de escala
No hagas 100 mapas / 300 enemigos / 50 sistemas. Primero cierra el bucle:
**1 zona + 1 dungeon + 5 enemigos + 3 habilidades + 1 boss**, todo jugable y
divertido. Con esa base sólida, escalar con IA es rapidísimo y consistente.
