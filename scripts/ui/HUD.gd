extends CanvasLayer
## HUD minimalista construido por codigo (barras de HP/XP + nivel).
## No conoce al jugador: solo escucha EventBus.player_stats_changed.
## Reemplaza las barras por tu UI pixel-art cuando la tengas.

var _hp_bar: ProgressBar
var _ki_bar: ProgressBar
var _xp_bar: ProgressBar
var _level_label: Label
var _coin_label: Label
var _boss_box: Control
var _boss_bar: ProgressBar
var _boss_name: Label

func _ready() -> void:
	var root := MarginContainer.new()
	root.set_anchors_preset(Control.PRESET_TOP_WIDE)
	root.add_theme_constant_override("margin_left", 8)
	root.add_theme_constant_override("margin_top", 6)
	root.add_theme_constant_override("margin_right", 8)
	add_child(root)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 2)
	root.add_child(vb)

	_level_label = Label.new()
	_level_label.text = "Nivel 1"
	vb.add_child(_level_label)

	_hp_bar = _make_bar(Color(0.85, 0.2, 0.25))
	vb.add_child(_hp_bar)

	_ki_bar = _make_bar(Color(0.95, 0.78, 0.2))
	_ki_bar.custom_minimum_size = Vector2(140, 8)
	vb.add_child(_ki_bar)

	_xp_bar = _make_bar(Color(0.3, 0.6, 0.95))
	_xp_bar.custom_minimum_size = Vector2(140, 6)
	vb.add_child(_xp_bar)

	# Contador de monedas (arriba a la derecha)
	var coin_box := MarginContainer.new()
	coin_box.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	coin_box.offset_left = -120
	coin_box.offset_right = -8
	coin_box.add_theme_constant_override("margin_top", 6)
	add_child(coin_box)
	var hb := HBoxContainer.new()
	hb.alignment = BoxContainer.ALIGNMENT_END
	hb.add_theme_constant_override("separation", 4)
	coin_box.add_child(hb)
	var icon := TextureRect.new()
	icon.texture = load("res://assets/orb.png")
	icon.custom_minimum_size = Vector2(12, 12)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hb.add_child(icon)
	_coin_label = Label.new()
	_coin_label.add_theme_font_size_override("font_size", 14)
	hb.add_child(_coin_label)

	# Barra del jefe (arriba al centro, oculta hasta que aparece)
	_boss_box = VBoxContainer.new()
	_boss_box.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_boss_box.offset_left = -110
	_boss_box.offset_right = 110
	_boss_box.offset_top = 6
	_boss_box.add_theme_constant_override("separation", 1)
	_boss_box.visible = false
	add_child(_boss_box)
	_boss_name = Label.new()
	_boss_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_boss_name.add_theme_font_size_override("font_size", 12)
	_boss_name.add_theme_color_override("font_color", Color(1, 0.5, 0.4))
	_boss_box.add_child(_boss_name)
	_boss_bar = _make_bar(Color(0.85, 0.18, 0.2))
	_boss_bar.custom_minimum_size = Vector2(220, 10)
	_boss_box.add_child(_boss_bar)

	EventBus.player_stats_changed.connect(_on_stats_changed)
	EventBus.player_ki_changed.connect(_on_ki_changed)
	EventBus.coins_changed.connect(_on_coins_changed)
	EventBus.boss_appeared.connect(_on_boss_appeared)
	EventBus.boss_health_changed.connect(_on_boss_health)
	EventBus.boss_defeated.connect(_on_boss_defeated)
	_on_coins_changed(SaveManager.get_coins())

func _make_bar(color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(140, 10)
	bar.show_percentage = false
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0, 0, 0, 0.6)
	bar.add_theme_stylebox_override("fill", fill)
	bar.add_theme_stylebox_override("background", bg)
	return bar

func _on_stats_changed(s: Dictionary) -> void:
	_level_label.text = "Nivel %d" % s.get("level", 1)
	_hp_bar.max_value = s.get("max_health", 1)
	_hp_bar.value = s.get("current_health", 0)
	_xp_bar.max_value = s.get("xp_to_next", 1)
	_xp_bar.value = s.get("xp", 0)

func _on_ki_changed(current: float, maximum: float) -> void:
	_ki_bar.max_value = maximum
	_ki_bar.value = current

func _on_coins_changed(total: int) -> void:
	_coin_label.text = str(total)

func _on_boss_appeared(display_name: String, max_health: int) -> void:
	_boss_name.text = display_name
	_boss_bar.max_value = max_health
	_boss_bar.value = max_health
	_boss_box.visible = true

func _on_boss_health(current: int, maximum: int) -> void:
	_boss_bar.max_value = maximum
	_boss_bar.value = current

func _on_boss_defeated() -> void:
	_boss_box.visible = false
