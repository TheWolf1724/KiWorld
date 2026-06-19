extends CharacterBody2D
## Enemigo con maquina de estados simple: IDLE -> CHASE -> ATTACK -> DEAD.
## Parametros y sprite vienen de un EnemyData (datos separados de la logica).

enum State { IDLE, CHASE, ATTACK, DEAD }

@onready var health: HealthComponent = $Health
@onready var sprite: Sprite2D = $Sprite

var data: EnemyData
var _state: State = State.IDLE
var _attack_timer := 0.0
var _hit_flash := 0.0
var _anim_time := 0.0
var _player: Node2D

## Configura el enemigo a partir de su definicion. Llamar tras instanciar.
func setup(enemy_data: EnemyData) -> void:
	data = enemy_data
	if not is_inside_tree():
		await ready
	health.set_max_health(data.max_health, true)
	var shape := $Collision.shape as CircleShape2D
	if shape:
		shape.radius = data.size
	sprite.texture = load("res://assets/enemies.png")
	sprite.region_enabled = true
	sprite.region_rect = Rect2(0, data.sprite_row * 16, 16, 16)

func _ready() -> void:
	add_to_group("enemies")
	health.died.connect(_on_died)

func _physics_process(delta: float) -> void:
	if _state == State.DEAD or data == null:
		return
	_attack_timer = maxf(0.0, _attack_timer - delta)
	_hit_flash = maxf(0.0, _hit_flash - delta)
	_anim_time += delta * 4.0

	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player")
	if not is_instance_valid(_player):
		return

	var to_player: Vector2 = _player.global_position - global_position
	var dist := to_player.length()

	if dist <= data.attack_range:
		_state = State.ATTACK
		velocity = Vector2.ZERO
		if _attack_timer == 0.0:
			_attack_timer = data.attack_cooldown
			var res := Combat.resolve(data.attack_power, _player_defense())
			_player.take_hit(res[0], res[1])
	elif dist <= data.aggro_radius:
		_state = State.CHASE
		velocity = to_player.normalized() * data.move_speed
		sprite.flip_h = to_player.x < 0.0
	else:
		_state = State.IDLE
		velocity = velocity.move_toward(Vector2.ZERO, data.move_speed * delta * 4.0)

	move_and_slide()
	_animate()
	queue_redraw()

func _player_defense() -> int:
	var s := _player.get_node_or_null("Stats") as StatsComponent
	return s.defense() if s else 0

## Defensa expuesta para el calculo de dano del jugador.
func get_defense() -> int:
	return data.defense if data else 0

## Recibe un golpe (melee del jugador o bola de ki).
func take_hit(amount: int, is_crit: bool) -> void:
	if _state == State.DEAD:
		return
	health.take_damage(amount)
	_hit_flash = 0.12
	EventBus.floating_text_requested.emit(
		global_position + Vector2(0, -data.size - 8), str(amount),
		Color(1, 0.45, 0.1) if is_crit else Color(1, 1, 1))

func _on_died() -> void:
	_state = State.DEAD
	EventBus.enemy_killed.emit(data.xp_reward, global_position)
	EventBus.entity_died.emit(self)
	queue_free()

func _animate() -> void:
	var frame := int(_anim_time) % 2
	sprite.region_rect = Rect2(frame * 16, data.sprite_row * 16, 16, 16)
	sprite.modulate = Color(1.4, 1.4, 1.4) if _hit_flash > 0.0 else Color.WHITE

# --- barra de vida sobre el sprite ---
func _draw() -> void:
	if data == null:
		return
	var w := 16.0
	var ratio := float(health.current_health) / float(maxi(1, health.max_health))
	var top := Vector2(-w * 0.5, -data.size - 7)
	draw_rect(Rect2(top, Vector2(w, 2)), Color(0, 0, 0, 0.6))
	draw_rect(Rect2(top, Vector2(w * ratio, 2)), Color(0.3, 0.9, 0.4))
