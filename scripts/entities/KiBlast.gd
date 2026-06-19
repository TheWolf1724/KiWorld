extends Area2D
## Bola de energia (proyectil). Viaja en linea recta, dana al primer objetivo
## del grupo contrario y se desvanece. Reutilizable por jugador y enemigos.

@onready var sprite: Sprite2D = $Sprite

var _dir := Vector2.RIGHT
var _speed := 160.0
var _damage := 5
var _source := "player"   ## "player" -> golpea enemigos; otro -> golpea al jugador
var _life := 1.4
var _anim := 0.0

func setup(direction: Vector2, damage: int, source: String) -> void:
	_dir = direction.normalized()
	_damage = damage
	_source = source

func _ready() -> void:
	sprite.texture = load("res://assets/kiblast.png")
	sprite.region_enabled = true
	sprite.region_rect = Rect2(0, 0, 16, 16)
	rotation = _dir.angle()
	body_entered.connect(_on_hit)

func _physics_process(delta: float) -> void:
	global_position += _dir * _speed * delta
	_anim += delta * 12.0
	sprite.region_rect = Rect2((int(_anim) % 2) * 16, 0, 16, 16)
	_life -= delta
	if _life <= 0.0:
		queue_free()

func _on_hit(body: Node) -> void:
	var target_group := "enemies" if _source == "player" else "player"
	if not body.is_in_group(target_group):
		return
	if body.has_method("take_hit"):
		body.take_hit(_damage, false)
	queue_free()
