extends CharacterBody2D
## Jugador top-down: movimiento 8 direcciones, sprite animado, golpe melee
## y bola de ki a distancia.
##
## NOTA MULTIPLAYER: el input se recoge en un unico sitio (_gather_input).
## Para red, sustituyes esa fuente local por input del owner y anades un
## MultiplayerSynchronizer sobre position/velocity. Movimiento y combate
## quedan intactos.

const KiBlastScene := preload("res://scenes/entities/KiBlast.tscn")
const AreaBlastScript := preload("res://scripts/entities/AreaBlast.gd")

@export var move_speed: float = 95.0
@export var attack_range: float = 24.0
@export var attack_cooldown: float = 0.35
@export var ki_cooldown: float = 0.6
@export var area_range: float = 42.0
@export var area_cooldown: float = 1.6

## Ki (energia). Se gasta con las habilidades y se regenera con el tiempo;
## manteniendo R se carga rapido a cambio de quedar inmovil.
const KI_COST_BLAST := 12.0
const KI_COST_AREA := 26.0
const KI_REGEN := 5.0       ## pasiva por segundo
const KI_CHARGE := 28.0     ## cargando con R por segundo

var max_ki := 45.0
var current_ki := 45.0
var _charging := false
var _charge_pulse := 0.0

@onready var health: HealthComponent = $Health
@onready var stats: StatsComponent = $Stats
@onready var sprite: Sprite2D = $Sprite

var facing := Vector2.DOWN
var _attack_timer := 0.0
var _ki_timer := 0.0
var _area_timer := 0.0
var _attack_anim := 0.0
var _hit_flash := 0.0
var _anim_time := 0.0
var _spawn_point := Vector2.ZERO

func _ready() -> void:
	add_to_group("player")
	_spawn_point = global_position
	sprite.texture = _skin_texture()
	EventBus.skin_changed.connect(func(path): sprite.texture = load(path))
	sprite.region_enabled = true
	sprite.region_rect = Rect2(0, 0, 16, 16)
	sprite.position = Vector2(0, -2)  # apoya los pies cerca del centro de colision

	stats.level = SaveManager.data.get("level", 1)
	stats.xp = SaveManager.data.get("xp", 0)
	stats.bonus_health = SaveManager.data.get("bonus_health", 0)
	stats.bonus_attack = SaveManager.data.get("bonus_attack", 0)
	stats.bonus_speed = SaveManager.data.get("bonus_speed", 0.0)
	health.set_max_health(stats.max_health(), true)
	max_ki = _ki_max()
	current_ki = max_ki
	_emit_ki()
	stats.leveled_up.connect(_on_leveled_up)
	stats.changed.connect(_on_stats_changed)
	health.health_changed.connect(func(_c, _m): _on_stats_changed())
	health.died.connect(_on_died)
	EventBus.enemy_killed.connect(func(xp, _pos): stats.add_xp(xp))
	_on_stats_changed()

func _physics_process(delta: float) -> void:
	_attack_timer = maxf(0.0, _attack_timer - delta)
	_ki_timer = maxf(0.0, _ki_timer - delta)
	_area_timer = maxf(0.0, _area_timer - delta)
	_attack_anim = maxf(0.0, _attack_anim - delta)
	_hit_flash = maxf(0.0, _hit_flash - delta)

	# Cargar ki con R: inmovil, sin atacar, recarga acelerada (vulnerable).
	_charging = Input.is_action_pressed("charge")
	if _charging:
		_charge_pulse += delta
		velocity = Vector2.ZERO
		move_and_slide()
		_gain_ki(KI_CHARGE * delta)
		_animate(delta, false)
		queue_redraw()
		return

	# Regeneracion pasiva.
	_gain_ki(KI_REGEN * delta)

	var dir := _gather_input()
	if dir != Vector2.ZERO:
		facing = dir
	velocity = dir * (move_speed + stats.bonus_speed)
	move_and_slide()

	if Input.is_action_pressed("attack") and _attack_timer == 0.0:
		_do_melee()
	if Input.is_action_pressed("cast") and _ki_timer == 0.0:
		_do_ki_blast()
	if Input.is_action_pressed("area") and _area_timer == 0.0:
		_do_area()

	_animate(delta, dir != Vector2.ZERO)
	queue_redraw()

func _gather_input() -> Vector2:
	var dir := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	return dir.normalized() if dir.length() > 0.1 else Vector2.ZERO

func _do_melee() -> void:
	_attack_timer = attack_cooldown
	_attack_anim = 0.18
	for e in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(e):
			continue
		var to: Vector2 = e.global_position - global_position
		if to.length() <= attack_range + 8.0 and facing.dot(to.normalized()) > 0.2:
			var res := Combat.resolve(stats.attack_power(), e.get_defense())
			e.take_hit(res[0], res[1])

func _do_ki_blast() -> void:
	if current_ki < KI_COST_BLAST:
		_no_ki_feedback()
		return
	_spend_ki(KI_COST_BLAST)
	_ki_timer = ki_cooldown
	_attack_anim = 0.18
	var blast := KiBlastScene.instantiate()
	blast.global_position = global_position + facing * 10.0
	blast.setup(facing, stats.attack_power() + 2, "player")
	get_parent().add_child(blast)

func _do_area() -> void:
	if current_ki < KI_COST_AREA:
		_no_ki_feedback()
		return
	_spend_ki(KI_COST_AREA)
	_area_timer = area_cooldown
	_attack_anim = 0.18
	# dana a TODOS los enemigos dentro del radio
	for e in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(e):
			continue
		if e.global_position.distance_to(global_position) <= area_range:
			var res := Combat.resolve(stats.attack_power(), e.get_defense())
			e.take_hit(res[0], res[1])
	# onda visual
	var wave := AreaBlastScript.new()
	get_parent().add_child(wave)
	wave.setup(global_position, area_range)

## Aplica una mejora elegida al subir de nivel. kind: "health" | "attack" | "speed".
func apply_upgrade(kind: String) -> void:
	match kind:
		"health":
			stats.bonus_health += 15
			health.set_max_health(stats.max_health(), false)
			health.heal(15)
		"attack":
			stats.bonus_attack += 3
		"speed":
			stats.bonus_speed += 12.0
	_on_stats_changed()

func _skin_texture() -> Texture2D:
	var sk := GameData.get_skin(SaveManager.equipped_skin())
	var path: String = sk.get("texture", "res://assets/player.png")
	return load(path)

# ---------------- ki ----------------
func _ki_max() -> float:
	return 40.0 + stats.level * 5.0

func _gain_ki(amount: float) -> void:
	var prev := current_ki
	current_ki = minf(max_ki, current_ki + amount)
	if current_ki != prev:
		_emit_ki()

func _spend_ki(amount: float) -> void:
	current_ki = maxf(0.0, current_ki - amount)
	_emit_ki()

func _emit_ki() -> void:
	EventBus.player_ki_changed.emit(current_ki, max_ki)

func _no_ki_feedback() -> void:
	# evita spam: solo un aviso cada cooldown corto
	if _ki_timer == 0.0:
		_ki_timer = 0.3
		EventBus.floating_text_requested.emit(
			global_position + Vector2(0, -16), "Sin ki", Color(0.5, 0.7, 1.0))

## Recibe dano (llamado por enemigos).
func take_hit(amount: int, is_crit: bool) -> void:
	health.take_damage(amount)
	_hit_flash = 0.15
	EventBus.floating_text_requested.emit(
		global_position + Vector2(0, -16), str(amount),
		Color(1, 0.5, 0.2) if is_crit else Color(1, 0.85, 0.3))

func _on_died() -> void:
	global_position = _spawn_point
	health.set_max_health(stats.max_health(), true)
	EventBus.floating_text_requested.emit(global_position + Vector2(0, -18), "KO!", Color(1, 0.2, 0.2))

func _on_leveled_up(level: int) -> void:
	health.set_max_health(stats.max_health(), true)
	max_ki = _ki_max()
	current_ki = max_ki
	_emit_ki()
	EventBus.player_leveled_up.emit(level)
	EventBus.floating_text_requested.emit(global_position + Vector2(0, -20), "LV %d!" % level, Color(0.4, 1, 0.6))

func _on_stats_changed() -> void:
	var snap := stats.snapshot()
	snap["current_health"] = health.current_health
	snap["max_health"] = health.max_health
	EventBus.player_stats_changed.emit(snap)
	SaveManager.set_value("level", stats.level)
	SaveManager.set_value("xp", stats.xp)
	SaveManager.set_value("bonus_health", stats.bonus_health)
	SaveManager.set_value("bonus_attack", stats.bonus_attack)
	SaveManager.set_value("bonus_speed", stats.bonus_speed)
	SaveManager.set_value("player_pos", [global_position.x, global_position.y])
	SaveManager.save_game()

## Selecciona el frame del atlas (4 filas: abajo/arriba/izq/der; 4 cols).
func _animate(delta: float, moving: bool) -> void:
	var row := 0
	if absf(facing.x) > absf(facing.y):
		row = 2 if facing.x < 0.0 else 3
	else:
		row = 1 if facing.y < 0.0 else 0

	var col := 0
	if _attack_anim > 0.0:
		col = 3
	elif moving:
		_anim_time += delta * 8.0
		col = 1 + (int(_anim_time) % 2)
	else:
		_anim_time = 0.0
		col = 0

	sprite.region_rect = Rect2(col * 16, row * 16, 16, 16)
	if _hit_flash > 0.0:
		sprite.modulate = Color(1, 0.6, 0.6)
	elif _charging:
		sprite.modulate = Color(1.0, 0.95, 0.5)   # tinte energetico al cargar
	else:
		sprite.modulate = Color.WHITE

# Aura de energia mientras se carga ki (se dibuja detras del sprite).
func _draw() -> void:
	if not _charging:
		return
	var pulse := 9.0 + sin(_charge_pulse * 14.0) * 2.5
	draw_arc(Vector2.ZERO, pulse, 0.0, TAU, 24, Color(1.0, 0.85, 0.3, 0.9), 2.0)
	draw_arc(Vector2.ZERO, pulse + 4.0, 0.0, TAU, 24, Color(1.0, 0.6, 0.1, 0.5), 1.5)
