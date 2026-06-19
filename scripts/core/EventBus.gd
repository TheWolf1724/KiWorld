extends Node
## Bus de eventos global (autoload).
## Toda comunicacion entre sistemas pasa por aqui mediante senales.
## Esto desacopla los sistemas entre si: el HUD no conoce al Player,
## el Player no conoce al HUD, etc. Es tambien la base para multiplayer:
## en local se emiten directamente; en red, la capa de red puede
## interceptar/replicar estos eventos sin tocar la logica de juego.

## Combate
signal damage_dealt(target: Node, amount: int, is_crit: bool)
signal entity_died(entity: Node)
signal enemy_killed(xp_reward: int, world_pos: Vector2)

## Jugador / progresion
signal player_stats_changed(snapshot: Dictionary)
signal player_leveled_up(level: int)
signal player_ki_changed(current: float, maximum: float)

## Jefe (boss)
signal boss_appeared(display_name: String, max_health: int)
signal boss_health_changed(current: int, maximum: int)
signal boss_defeated()

## Economia / tienda
signal coins_changed(total: int)
signal skin_changed(texture_path: String)

## Feedback visual (lo escucha el mundo para crear texto flotante, etc.)
signal floating_text_requested(world_pos: Vector2, text: String, color: Color)
