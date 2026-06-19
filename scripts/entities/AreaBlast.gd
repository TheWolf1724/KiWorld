extends Node2D
## Onda expansiva del ataque en area (solo visual). El dano lo aplica el
## jugador al lanzarla. Se crea por codigo y se autodestruye.

var radius := 40.0
var _t := 0.0
const LIFE := 0.32

func setup(world_pos: Vector2, r: float) -> void:
	global_position = world_pos
	radius = r

func _ready() -> void:
	z_index = 50

func _process(delta: float) -> void:
	_t += delta
	if _t >= LIFE:
		queue_free()
	queue_redraw()

func _draw() -> void:
	var p := clampf(_t / LIFE, 0.0, 1.0)
	var r := radius * p
	var alpha := 1.0 - p
	# anillo de energia naranja con nucleo claro
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 32, Color(1.0, 0.7, 0.2, alpha), 3.0)
	draw_arc(Vector2.ZERO, r * 0.7, 0.0, TAU, 32, Color(1.0, 0.95, 0.6, alpha * 0.8), 2.0)
