class_name StatsComponent
extends Node
## Estadisticas y progresion del jugador (nivel, xp y derivados).
## Las stats derivan del nivel mediante formulas, asi subir de nivel
## actualiza todo automaticamente. Ajusta las curvas a tu gusto.

signal changed
signal leveled_up(level: int)

@export var level: int = 1
@export var xp: int = 0

## Bonos elegidos al subir de nivel (mejoras), persistentes.
var bonus_health: int = 0
var bonus_attack: int = 0
var bonus_speed: float = 0.0

func xp_to_next() -> int:
	return int(round(10.0 * pow(level, 1.5)))

func max_health() -> int:
	return 20 + level * 5 + bonus_health

func attack_power() -> int:
	return 4 + level * 2 + bonus_attack

func defense() -> int:
	return 1 + int(level / 2.0)

func add_xp(amount: int) -> void:
	xp += maxi(0, amount)
	while xp >= xp_to_next():
		xp -= xp_to_next()
		level += 1
		leveled_up.emit(level)
	changed.emit()

func snapshot() -> Dictionary:
	return {
		"level": level,
		"xp": xp,
		"xp_to_next": xp_to_next(),
		"max_health": max_health(),
		"attack_power": attack_power(),
		"defense": defense(),
	}
