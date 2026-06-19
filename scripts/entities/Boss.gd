extends CharacterBody2D
## Jefe con dos fases y varios patrones de ataque. Comparte el grupo
## "enemies" para que el jugador pueda dañarlo con melee/ki/area.
##
## Fase 1 (>50% vida): persigue, golpea de cerca y dispara una bola de ki.
## Fase 2 (<=50% vida): más rápido, ráfaga de 3 bolas y golpe en área cercano.

const KiBlastScene := preload("res://scenes/entities/KiBlast.tscn")
const AreaBlastScript := preload("res://scripts/entities/AreaBlast.gd")
const CoinScene := preload("res://scenes/entities/Coin.tscn")

@export var display_name: String = "Kael, Tirano del Ki"
@export var max_health: int = 240
@export var move_speed: float = 58.0
@export var contact_damage: int = 12
@export var ranged_damage: int = 10
@export var defense_value: int = 4
@export var xp_reward: int = 120
@export var coin_drop: int = 5

@onready var health: HealthComponent = $Health
@onready var sprite: Sprite2D = $Sprite

var _player: Node2D
var _phase := 1
var _shoot_cd := 2.0
var _slam_cd := 3.5
var _melee_cd := 0.0
var _hit_flash := 0.0
var _anim := 0.0
var _dead := false

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("boss")
	sprite.texture = load("res://assets/boss.png")
	sprite.region_enabled = true
	sprite.region_rect = Rect2(0, 0, 32, 32)
	health.set_max_health(max_health, true)
	health.health_changed.connect(_on_health_changed)
	health.died.connect(_on_died)
	EventBus.boss_appeared.emit(display_name, max_health)

func _physics_process(delta: float) -> void:
	if _dead:
		return
	_shoot_cd = maxf(0.0, _shoot_cd - delta)
	_slam_cd = maxf(0.0, _slam_cd - delta)
	_melee_cd = maxf(0.0, _melee_cd - delta)
	_hit_flash = maxf(0.0, _hit_flash - delta)
	_anim += delta * 3.0

	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player")
	if not is_instance_valid(_player):
		return

	var to_player: Vector2 = _player.global_position - global_position
	var dist := to_player.length()
	var dir := to_player.normalized()

	# Movimiento: acercarse pero no encima.
	if dist > 26.0:
		velocity = dir * move_speed
		sprite.flip_h = dir.x < 0.0
	else:
		velocity = Vector2.ZERO
		if _melee_cd == 0.0:
			_melee_cd = 1.1
			var res := Combat.resolve(contact_damage, _player_defense())
			_player.take_hit(res[0], res[1])
	move_and_slide()

	# Disparo a distancia.
	if _shoot_cd == 0.0:
		_shoot_cd = 2.4 if _phase == 1 else 1.7
		_shoot(dir)

	# Golpe en área (solo fase 2, si el jugador está cerca).
	if _phase == 2 and _slam_cd == 0.0 and dist <= 55.0:
		_slam_cd = 3.0
		_slam()

	_animate()
	queue_redraw()

func _shoot(dir: Vector2) -> void:
	var angles := [0.0]
	if _phase == 2:
		angles = [-0.34, 0.0, 0.34]   # ráfaga de 3
	for a in angles:
		var blast := KiBlastScene.instantiate()
		blast.global_position = global_position + dir * 14.0
		blast.setup(dir.rotated(a), ranged_damage, "boss")
		get_parent().add_child(blast)

func _slam() -> void:
	for e in get_tree().get_nodes_in_group("player"):
		if e.global_position.distance_to(global_position) <= 60.0:
			var res := Combat.resolve(contact_damage + 4, _player_defense())
			e.take_hit(res[0], res[1])
	var wave := AreaBlastScript.new()
	get_parent().add_child(wave)
	wave.setup(global_position, 60.0)

func _player_defense() -> int:
	var s := _player.get_node_or_null("Stats") as StatsComponent
	return s.defense() if s else 0

func get_defense() -> int:
	return defense_value

## Recibe daño del jugador (melee / ki / área).
func take_hit(amount: int, is_crit: bool) -> void:
	if _dead:
		return
	health.take_damage(amount)
	_hit_flash = 0.1
	EventBus.floating_text_requested.emit(
		global_position + Vector2(0, -22), str(amount),
		Color(1, 0.45, 0.1) if is_crit else Color(1, 1, 1))

func _on_health_changed(current: int, maximum: int) -> void:
	EventBus.boss_health_changed.emit(current, maximum)
	if _phase == 1 and float(current) / float(maximum) <= 0.5:
		_phase = 2
		move_speed *= 1.4
		EventBus.floating_text_requested.emit(
			global_position + Vector2(0, -26), "¡FASE 2!", Color(1, 0.3, 0.2))

func _on_died() -> void:
	_dead = true
	EventBus.boss_defeated.emit()
	EventBus.enemy_killed.emit(xp_reward, global_position)   # da XP al jugador
	EventBus.floating_text_requested.emit(global_position + Vector2(0, -26), "¡DERROTADO!", Color(0.5, 1, 0.6))
	# botín garantizado de monedas
	for i in coin_drop:
		var coin := CoinScene.instantiate()
		coin.global_position = global_position + Vector2(randf_range(-18, 18), randf_range(-12, 12))
		get_parent().add_child(coin)
	queue_free()

func _animate() -> void:
	var frame := int(_anim) % 2
	sprite.region_rect = Rect2(frame * 32, 0, 32, 32)
	sprite.modulate = Color(1.5, 1.5, 1.5) if _hit_flash > 0.0 else Color.WHITE

# barra de vida flotante pequeña (la grande está en el HUD)
func _draw() -> void:
	if _dead:
		return
	var w := 28.0
	var ratio := float(health.current_health) / float(maxi(1, health.max_health))
	var top := Vector2(-w * 0.5, -22)
	draw_rect(Rect2(top, Vector2(w, 3)), Color(0, 0, 0, 0.6))
	draw_rect(Rect2(top, Vector2(w * ratio, 3)), Color(0.9, 0.25, 0.25))
