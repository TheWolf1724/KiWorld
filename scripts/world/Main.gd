extends Node2D
## Mundo / nivel raiz. Construye el mapa con TileMapLayer a partir de
## assets/tiles.png, instancia jugador y enemigos, y gestiona respawn y
## texto flotante. Para nuevas zonas: duplica esta escena y cambia el mapa.

const PlayerScene := preload("res://scenes/entities/Player.tscn")
const EnemyScene := preload("res://scenes/entities/Enemy.tscn")
const CoinScene := preload("res://scenes/entities/Coin.tscn")
const BossScene := preload("res://scenes/entities/Boss.tscn")
const FloatingTextScript := preload("res://scripts/ui/FloatingText.gd")

## Probabilidad de que un enemigo suelte moneda (poco habitual).
const COIN_DROP_CHANCE := 0.15

## El jefe aparece al alcanzar este nivel (bajo para poder probarlo).
const BOSS_SPAWN_LEVEL := 3
var _boss_spawned := false

const TILE := 16
const COLS := 40
const ROWS := 24

# indices de tile en tiles.png: 0 grass,1 grass2,2 path,3 sand,4 rock(borde),
# 5 water,6 crystal,7 tree,8 boulder
# Colision por tipo: poligono ajustado a lo que se ve (coords relativas al
# centro del tile, -8..8). Los tiles sin entrada aqui son transitables.
const TILE_COLLISION := {
	4: [Vector2(-8, -8), Vector2(8, -8), Vector2(8, 8), Vector2(-8, 8)],   # roca borde: lleno
	5: [Vector2(-8, -8), Vector2(8, -8), Vector2(8, 8), Vector2(-8, 8)],   # agua: lleno
	7: [Vector2(-2, 2), Vector2(2, 2), Vector2(2, 7), Vector2(-2, 7)],     # arbol: solo tronco
	8: [Vector2(-5, -3), Vector2(5, -3), Vector2(5, 6), Vector2(-5, 6)],   # canto rodado
}

var _layer: TileMapLayer
var _src_id := 0
var _atlas: TileSetAtlasSource

## Puntos de aparicion de enemigos en coords de TILE: [col, row, id]
var _spawns := [
	[10, 4, &"planta"],
	[28, 6, &"planta"],
	[20, 18, &"shadow"],
	[33, 16, &"android"],
	[6, 19, &"planta"],
	[30, 20, &"shadow"],
]

func _ready() -> void:
	_build_world()

	var player := PlayerScene.instantiate()
	player.global_position = Vector2(COLS, ROWS) * TILE * 0.5
	add_child(player)

	for s in _spawns:
		_spawn_enemy(Vector2(s[0], s[1]) * TILE + Vector2(TILE, TILE) * 0.5, s[2])

	EventBus.floating_text_requested.connect(_on_floating_text)
	EventBus.entity_died.connect(_on_entity_died)
	EventBus.player_leveled_up.connect(_on_player_leveled_up)
	# Si se carga una partida ya avanzada, el jefe puede aparecer al instante.
	if SaveManager.data.get("level", 1) >= BOSS_SPAWN_LEVEL:
		_spawn_boss()

# ---------------- mundo / tiles ----------------
func _build_world() -> void:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE, TILE)
	ts.add_physics_layer()

	_atlas = TileSetAtlasSource.new()
	_atlas.texture = load("res://assets/tiles.png")
	_atlas.texture_region_size = Vector2i(TILE, TILE)
	for i in 9:
		_atlas.create_tile(Vector2i(i, 0))
	_src_id = ts.add_source(_atlas)

	# colision ajustada por tipo de tile (no toda la casilla)
	for idx in TILE_COLLISION:
		var td := _atlas.get_tile_data(Vector2i(idx, 0), 0)
		td.set_collision_polygons_count(0, 1)
		td.set_collision_polygon_points(0, 0, PackedVector2Array(TILE_COLLISION[idx]))

	_layer = TileMapLayer.new()
	_layer.tile_set = ts
	add_child(_layer)
	move_child(_layer, 0)  # detras de las entidades

	for y in ROWS:
		for x in COLS:
			_layer.set_cell(Vector2i(x, y), _src_id, Vector2i(_pick_tile(x, y), 0))

func _hash(x: int, y: int) -> int:
	var h := (x * 73856093) ^ (y * 19349663)
	return absi(h)

func _pick_tile(x: int, y: int) -> int:
	# bordes solidos de roca
	if x == 0 or y == 0 or x == COLS - 1 or y == ROWS - 1:
		return 4
	# camino en cruz
	if x == 19 or x == 20:
		return 2
	if y == 11 or y == 12:
		return 3
	# estanque de agua
	if x >= 7 and x <= 12 and y >= 4 and y <= 7:
		return 5
	# decoracion dispersa sobre hierba
	var h := _hash(x, y)
	if h % 23 == 0:
		return 7   # arbol
	if h % 29 == 0:
		return 8   # canto rodado (colision ajustada)
	if h % 53 == 0:
		return 6   # cristal de energia
	return 0 if h % 2 == 0 else 1  # hierba

# ---------------- entidades ----------------
func _spawn_enemy(pos: Vector2, id: StringName) -> void:
	var data := GameData.get_enemy(id)
	if data == null:
		return
	var e := EnemyScene.instantiate()
	e.global_position = pos
	add_child(e)
	e.setup(data)

func _on_entity_died(entity: Node) -> void:
	if not (entity.has_method("get_defense") and entity.get("data") != null):
		return
	var pos: Vector2 = entity.global_position
	var id: StringName = entity.data.id
	# Drop de moneda especial (poco habitual)
	if randf() < COIN_DROP_CHANCE:
		var coin := CoinScene.instantiate()
		coin.global_position = pos
		add_child(coin)
	var t := get_tree().create_timer(5.0)
	t.timeout.connect(func():
		if is_inside_tree():
			_spawn_enemy(pos, id))

func _on_player_leveled_up(level: int) -> void:
	if not _boss_spawned and level >= BOSS_SPAWN_LEVEL:
		_spawn_boss()

func _spawn_boss() -> void:
	if _boss_spawned:
		return
	_boss_spawned = true
	var boss := BossScene.instantiate()
	boss.global_position = Vector2(COLS * 0.5, 4.0) * TILE   # arena superior-centro
	add_child(boss)
	var player := get_tree().get_first_node_in_group("player")
	if player:
		EventBus.floating_text_requested.emit(
			player.global_position + Vector2(0, -22), "¡APARECE UN JEFE!", Color(1, 0.3, 0.25))

func _on_floating_text(world_pos: Vector2, text: String, color: Color) -> void:
	if text.is_empty():
		return
	var ft := FloatingTextScript.new()
	add_child(ft)
	ft.setup(world_pos, text, color)
