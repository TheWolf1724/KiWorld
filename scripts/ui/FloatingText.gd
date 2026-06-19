extends Node2D
## Numero de dano / texto flotante que sube y se desvanece.
## Se crea por codigo desde el mundo (Main) al recibir la senal del EventBus.

var text := "0"
var color := Color.WHITE
var _life := 0.7
var _t := 0.0

func _ready() -> void:
	z_index = 100

func setup(world_pos: Vector2, txt: String, col: Color) -> void:
	global_position = world_pos
	text = txt
	color = col

func _process(delta: float) -> void:
	_t += delta
	position.y -= 22.0 * delta
	if _t >= _life:
		queue_free()
	queue_redraw()

func _draw() -> void:
	var font := ThemeDB.fallback_font
	var alpha := clampf(1.0 - (_t / _life), 0.0, 1.0)
	var c := Color(color.r, color.g, color.b, alpha)
	# sombra + texto
	draw_string(font, Vector2(1, 1), text, HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color(0, 0, 0, alpha))
	draw_string(font, Vector2.ZERO, text, HORIZONTAL_ALIGNMENT_CENTER, -1, 10, c)
