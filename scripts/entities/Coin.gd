extends Area2D
## Moneda especial que sueltan (raramente) los enemigos. Se recoge al tocarla.

@onready var sprite: Sprite2D = $Sprite
var _t := 0.0

func _ready() -> void:
	add_to_group("coins")
	sprite.texture = load("res://assets/orb.png")
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	_t += delta
	sprite.position.y = -2.0 + sin(_t * 5.0) * 1.5   # flotacion

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	SaveManager.add_coins(1)
	EventBus.floating_text_requested.emit(
		global_position + Vector2(0, -10), "+1", Color(1.0, 0.82, 0.25))
	queue_free()
