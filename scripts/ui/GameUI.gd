extends CanvasLayer
## Menus modales en pausa: ventana de controles al arrancar y eleccion de
## mejora (1 de 3) al subir de nivel. process_mode = ALWAYS para funcionar
## mientras el arbol esta pausado.

var _upgrade_queue := 0
var _mode := ""        ## "", "controls", "upgrade"
var _root: Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	EventBus.player_leveled_up.connect(func(_l):
		_upgrade_queue += 1
		_maybe_show_upgrade())
	_show_controls()

# ---------------- input por teclado ----------------
func _input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var key := (event as InputEventKey).keycode
	if _mode == "controls":
		if key == KEY_SPACE or key == KEY_ENTER or key == KEY_KP_ENTER:
			_start_game()
	elif _mode == "upgrade":
		if key == KEY_1: _choose("health")
		elif key == KEY_2: _choose("attack")
		elif key == KEY_3: _choose("speed")
	elif _mode == "pause":
		if key == KEY_ESCAPE:
			_resume()
	elif _mode == "shop":
		if key == KEY_ESCAPE or key == KEY_T:
			_resume()
	elif _mode == "":
		if key == KEY_ESCAPE:
			_show_pause()
		elif key == KEY_T:
			_show_shop()

# ---------------- ventana de controles ----------------
func _show_controls() -> void:
	_mode = "controls"
	get_tree().paused = true
	var vb := _make_overlay()
	vb.add_child(_title("KiWorld", 18, Color(1, 0.7, 0.25)))
	vb.add_child(_text(
		"Controles\n" +
		"WASD / Flechas   Mover\n" +
		"Espacio / J      Golpe melee\n" +
		"E                Bola de Ki\n" +
		"Q                Ataque en area\n" +
		"R (mantener)     Cargar ki (inmovil)\n" +
		"T                Tienda\n" +
		"ESC              Pausa\n" +
		"\n" +
		"Derrota enemigos para ganar XP.\n" +
		"En cada nivel eliges una mejora.", 10))
	var btn := _button("Empezar  (Espacio)")
	btn.pressed.connect(_start_game)
	vb.add_child(btn)

func _start_game() -> void:
	_mode = ""
	_clear()
	get_tree().paused = false
	_maybe_show_upgrade()

# ---------------- eleccion de mejora ----------------
func _maybe_show_upgrade() -> void:
	if _mode != "" or _upgrade_queue <= 0:
		return
	_show_upgrade()

func _show_upgrade() -> void:
	_mode = "upgrade"
	get_tree().paused = true
	var vb := _make_overlay()
	vb.add_child(_title("¡Nivel %d!" % _player_level(), 18, Color(0.45, 1, 0.6)))
	vb.add_child(_text("Elige UNA mejora:", 11))
	var b1 := _button("1   ❤  +15 Vida máxima")
	b1.pressed.connect(_choose.bind("health"))
	var b2 := _button("2   ⚔  +3 Daño")
	b2.pressed.connect(_choose.bind("attack"))
	var b3 := _button("3   ⚡  +12 Velocidad")
	b3.pressed.connect(_choose.bind("speed"))
	vb.add_child(b1)
	vb.add_child(b2)
	vb.add_child(b3)

func _choose(kind: String) -> void:
	var p := get_tree().get_first_node_in_group("player")
	if p and p.has_method("apply_upgrade"):
		p.apply_upgrade(kind)
	_upgrade_queue -= 1
	_mode = ""
	_clear()
	if _upgrade_queue > 0:
		_show_upgrade()
	else:
		get_tree().paused = false

# ---------------- menu de pausa (ESC) ----------------
func _show_pause() -> void:
	_mode = "pause"
	get_tree().paused = true
	var vb := _make_overlay()
	vb.add_child(_title("Pausa", 18, Color(1, 0.7, 0.25)))
	var b_cont := _button("Continuar")
	b_cont.pressed.connect(_resume)
	var b_reset := _button("Reiniciar")
	b_reset.pressed.connect(_restart)
	var b_quit := _button("Salir")
	b_quit.pressed.connect(_quit)
	vb.add_child(b_cont)
	vb.add_child(b_reset)
	vb.add_child(b_quit)

func _resume() -> void:
	_mode = ""
	_clear()
	get_tree().paused = false

func _restart() -> void:
	# Vuelve todo a cero: borra progresion y recarga la escena.
	SaveManager.reset()
	_upgrade_queue = 0
	_mode = ""
	_clear()
	get_tree().paused = false
	get_tree().reload_current_scene()

func _quit() -> void:
	get_tree().quit()

# ---------------- tienda (T) ----------------
func _show_shop() -> void:
	_mode = "shop"
	get_tree().paused = true
	_build_shop("")

func _build_shop(msg: String) -> void:
	var vb := _make_overlay()
	vb.add_child(_title("Tienda", 18, Color(1.0, 0.82, 0.25)))
	vb.add_child(_text("Monedas: %d" % SaveManager.get_coins(), 12))
	if msg != "":
		vb.add_child(_title(msg, 11, Color(1.0, 0.5, 0.4)))
	for id in GameData.skin_order:
		var sk: Dictionary = GameData.get_skin(id)
		var label := ""
		if SaveManager.equipped_skin() == id:
			label = "%s   ✓ Equipado" % sk["name"]
		elif SaveManager.owns_skin(id):
			label = "%s   — Equipar" % sk["name"]
		else:
			label = "%s   — Comprar (%d)" % [sk["name"], sk["price"]]
		var b := _button(label)
		b.pressed.connect(_shop_action.bind(id))
		vb.add_child(b)
	var close := _button("Cerrar  (T / ESC)")
	close.pressed.connect(_resume)
	vb.add_child(close)

func _shop_action(id: String) -> void:
	var sk: Dictionary = GameData.get_skin(id)
	var msg := ""
	if SaveManager.owns_skin(id):
		SaveManager.set_skin(id)
		EventBus.skin_changed.emit(sk["texture"])
	elif SaveManager.spend_coins(sk["price"]):
		SaveManager.unlock_skin(id)
		SaveManager.set_skin(id)
		EventBus.skin_changed.emit(sk["texture"])
		msg = "¡Comprado!"
	else:
		msg = "Monedas insuficientes"
	_build_shop(msg)

func _player_level() -> int:
	var p := get_tree().get_first_node_in_group("player")
	if p:
		var s := p.get_node_or_null("Stats") as StatsComponent
		if s:
			return s.level
	return 1

# ---------------- construccion de UI ----------------
func _clear() -> void:
	if _root and is_instance_valid(_root):
		_root.queue_free()
	_root = null

func _make_overlay() -> VBoxContainer:
	_clear()
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.65)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(center)

	var panel := PanelContainer.new()
	center.add_child(panel)

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	panel.add_child(margin)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 5)
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(vb)
	return vb

func _title(text: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l

func _text(text: String, size: int) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	return l

func _button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(230, 26)
	b.add_theme_font_size_override("font_size", 13)
	return b
