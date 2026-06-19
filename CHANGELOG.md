# Changelog

Todos los cambios notables de KiWorld. El formato sigue
[Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y el proyecto usa
versionado semántico aproximado mientras está en `0.x`.

## [Sin publicar]
### Añadido
- **Jefe (boss)** "Kael, Tirano del Ki" con **dos fases** y varios patrones de
  ataque (persecución, golpe cuerpo a cuerpo, bola de ki, ráfaga de 3 bolas y
  golpe en área). Aparece al alcanzar cierto nivel, con **barra de vida grande**
  en pantalla y botín garantizado de monedas + XP al derrotarlo.

### Cambiado
- Licencia del proyecto pasa de MIT a **CC BY-NC 4.0** (uso no comercial con
  atribución obligatoria al autor).

## [0.2.0] - 2026-06-18
### Añadido
- Sistema de **monedas especiales** con drop poco habitual (15%) al matar
  enemigos; caen como coleccionable y se recogen al tocarlas.
- **Contador de monedas** en pantalla (HUD) con icono.
- **Tienda** (tecla `T`) para comprar y equipar **skins de personaje**, con
  descuento de monedas, bloqueo sin saldo y aplicación instantánea de la skin.
- **3 skins comprables** además de la inicial: Azul, Carmesí y Esmeralda.
- Documentación: `LICENSE` (MIT), `README` ampliado, `CONTRIBUTING`, `ROADMAP`
  y este `CHANGELOG`.

### Cambiado
- Al **cargar ki** (`R`) ahora tampoco se puede atacar (además de no moverse).

## [0.1.0] - 2026-06-18
### Añadido
- Jugador top-down con sprite animado en 4 direcciones y cámara.
- Mundo con **TileMapLayer** (hierba, camino, arena, agua, rocas, árboles,
  cristales) y colisiones ajustadas a lo que se ve.
- Enemigos temáticos con IA (idle → aggro/persecución → ataque) y barra de vida.
- Combate: golpe melee, **bola de ki** (`E`) y **ataque en área** (`Q`), con
  críticos y números de daño flotantes.
- **Barra de ki**: gasto por habilidad, regeneración pasiva y carga rápida
  manteniendo `R` (inmóvil).
- Progresión: XP, niveles y elección de **1 de 3 mejoras** por nivel.
- **Menú de pausa** (`ESC`) con Continuar / Reiniciar / Salir y **ventana de
  controles** al iniciar.
- Generador procedural de pixel-art (`tools/gen_assets.gd`) y `PROMPTS.md`.
- Guardado local en `user://savegame.json`.

[Sin publicar]: https://github.com/TheWolf1724/KiWorld/compare/v0.2.0...dev
[0.2.0]: https://github.com/TheWolf1724/KiWorld/releases/tag/v0.2.0
[0.1.0]: https://github.com/TheWolf1724/KiWorld/releases/tag/v0.1.0
