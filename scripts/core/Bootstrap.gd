extends Node
## Registra las acciones de input por codigo (mas robusto que el .godot).
## Teclado para PC y, mas adelante, podras mapear botones tactiles a estas
## mismas acciones para Android sin tocar la logica del juego.

func _ready() -> void:
	_add_action("move_up",    [KEY_W, KEY_UP])
	_add_action("move_down",  [KEY_S, KEY_DOWN])
	_add_action("move_left",  [KEY_A, KEY_LEFT])
	_add_action("move_right", [KEY_D, KEY_RIGHT])
	_add_action("attack",     [KEY_SPACE, KEY_J])
	_add_action("cast",       [KEY_E])   # bola de ki
	_add_action("area",       [KEY_Q])   # ataque en area
	_add_action("charge",     [KEY_R])   # cargar ki (inmovil)
	_add_action("shop",       [KEY_T])   # abrir tienda
	_add_action("pause",      [KEY_ESCAPE])

func _add_action(action: String, keycodes: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for kc in keycodes:
		var ev := InputEventKey.new()
		ev.physical_keycode = kc
		InputMap.action_add_event(action, ev)
