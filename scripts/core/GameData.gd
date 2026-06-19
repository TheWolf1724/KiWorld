extends Node
## Registro central de datos del juego (autoload).
## Aqui se definen los tipos de enemigos. En un proyecto grande cargarias
## .tres desde res://data/, pero para el slice los creamos por codigo.

var enemies: Dictionary = {}   ## StringName -> EnemyData

## Skins de personaje. id -> {name, price, texture}. Precios bajos para probar.
var skins: Dictionary = {}
var skin_order: Array = []

func _ready() -> void:
	_add_skin("default", "Guerrero Naranja", 0, "res://assets/player.png")
	_add_skin("blue",    "Guerrero Azul",    3, "res://assets/player_blue.png")
	_add_skin("red",     "Guerrero Carmesi", 5, "res://assets/player_red.png")
	_add_skin("green",   "Guerrero Esmeralda", 8, "res://assets/player_green.png")
	_init_enemies()

func _add_skin(id: String, name: String, price: int, texture: String) -> void:
	skins[id] = {"name": name, "price": price, "texture": texture}
	skin_order.append(id)

func get_skin(id: String) -> Dictionary:
	return skins.get(id, {})

func _init_enemies() -> void:
	#                 id           nombre             sprite_row  hp atk def vel  aggro xp
	_register(_make(&"planta",  "Planta Guerrera",  0, 7.0, 16, 4, 1, 42.0, 90.0, 6))
	_register(_make(&"android", "Androide C",       1, 9.0, 30, 9, 3, 58.0, 120.0, 14))
	_register(_make(&"shadow",  "Guerrero Oscuro",  2, 8.0, 24, 7, 2, 72.0, 130.0, 11))

func _make(id: StringName, name: String, row: int, size: float, hp: int, atk: int, def_: int, speed: float, aggro: float, xp: int) -> EnemyData:
	var d := EnemyData.new()
	d.id = id
	d.display_name = name
	d.sprite_row = row
	d.size = size
	d.max_health = hp
	d.attack_power = atk
	d.defense = def_
	d.move_speed = speed
	d.aggro_radius = aggro
	d.xp_reward = xp
	return d

func _register(d: EnemyData) -> void:
	enemies[d.id] = d

func get_enemy(id: StringName) -> EnemyData:
	return enemies.get(id, null)
