extends Node
## Guardado local en user:// (perfecto para single-player).
## Guarda nivel/xp y posicion del jugador. Amplialo con inventario, mundo, etc.

const SAVE_PATH := "user://savegame.json"

var data: Dictionary = {
	"level": 1,
	"xp": 0,
	"player_pos": [0.0, 0.0],
	"bonus_health": 0,
	"bonus_attack": 0,
	"bonus_speed": 0.0,
	"coins": 0,
	"owned_skins": ["default"],
	"skin": "default",
}

func _ready() -> void:
	load_game()

func save_game() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		push_warning("No se pudo abrir el guardado para escritura")
		return
	f.store_string(JSON.stringify(data, "\t"))
	f.close()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) == TYPE_DICTIONARY:
		data.merge(parsed, true)

func set_value(key: String, value) -> void:
	data[key] = value

# ---------------- monedas ----------------
func get_coins() -> int:
	return int(data.get("coins", 0))

func add_coins(n: int) -> void:
	data["coins"] = get_coins() + n
	save_game()
	EventBus.coins_changed.emit(get_coins())

func spend_coins(n: int) -> bool:
	if get_coins() < n:
		return false
	data["coins"] = get_coins() - n
	save_game()
	EventBus.coins_changed.emit(get_coins())
	return true

# ---------------- skins ----------------
func owns_skin(id: String) -> bool:
	return id in data.get("owned_skins", [])

func unlock_skin(id: String) -> void:
	var owned: Array = data.get("owned_skins", [])
	if id not in owned:
		owned.append(id)
		data["owned_skins"] = owned
		save_game()

func equipped_skin() -> String:
	return str(data.get("skin", "default"))

func set_skin(id: String) -> void:
	data["skin"] = id
	save_game()

## Reinicia toda la progresion a cero y borra el archivo de guardado.
func reset() -> void:
	data = {
		"level": 1,
		"xp": 0,
		"player_pos": [0.0, 0.0],
		"bonus_health": 0,
		"bonus_attack": 0,
		"bonus_speed": 0.0,
		"coins": 0,
		"owned_skins": ["default"],
		"skin": "default",
	}
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
