class_name HealthComponent
extends Node
## Componente de vida reutilizable (composicion sobre herencia).
## Lo usan tanto el jugador como los enemigos. No conoce nada del mundo:
## solo gestiona puntos de vida y emite senales. Asi mismo componente
## sirve para single-player y, mas adelante, para entidades replicadas.

signal health_changed(current: int, maximum: int)
signal died

@export var max_health: int = 20
var current_health: int

func _ready() -> void:
	current_health = max_health

func take_damage(amount: int) -> void:
	if current_health <= 0:
		return
	current_health = clampi(current_health - maxi(0, amount), 0, max_health)
	health_changed.emit(current_health, max_health)
	if current_health <= 0:
		died.emit()

func heal(amount: int) -> void:
	current_health = clampi(current_health + maxi(0, amount), 0, max_health)
	health_changed.emit(current_health, max_health)

func set_max_health(value: int, refill: bool = false) -> void:
	max_health = maxi(1, value)
	if refill:
		current_health = max_health
	current_health = clampi(current_health, 0, max_health)
	health_changed.emit(current_health, max_health)

func is_alive() -> bool:
	return current_health > 0
