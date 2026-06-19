extends Node
## Generador de pixel-art procedural (estilo anime de artes marciales, original).
## Crea los PNG del juego en res://assets/. Ejecutar una vez con:
##   godot --headless res://tools/gen.tscn
## Reejecutable: regenera todo de forma determinista (sin aleatoriedad real).

const S := 16  # tamano de celda

# --- Paleta ---
const OUT := Color8(24, 16, 24)
const SKIN := Color8(245, 200, 140)
const SKIN_SH := Color8(208, 150, 96)
const BELT := Color8(44, 74, 156)
const BOOT := Color8(34, 50, 112)
const EYE := Color8(40, 28, 40)

# Paleta del heroe (variable segun skin). Se fija en _gen_player.
var GI := Color8(232, 98, 42)
var GI_HI := Color8(255, 146, 78)
var GI_SH := Color8(176, 64, 26)
var HAIR := Color8(32, 28, 44)
var HAIR_HI := Color8(64, 60, 92)

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets"))
	_gen_player()
	_gen_enemies()
	_gen_tiles()
	_gen_fx()
	_gen_orb()
	_gen_boss()
	print("ASSETS OK")
	get_tree().quit()

# ---------- helpers ----------
func _img(w: int, h: int) -> Image:
	return Image.create(w, h, false, Image.FORMAT_RGBA8)

func _px(img: Image, x: int, y: int, c: Color) -> void:
	if x >= 0 and y >= 0 and x < img.get_width() and y < img.get_height():
		img.set_pixel(x, y, c)

func _rect(img: Image, x: int, y: int, w: int, h: int, c: Color) -> void:
	for j in h:
		for i in w:
			_px(img, x + i, y + j, c)

## Copia una celda 16x16 de src dentro de dst en (cx,cy), opcionalmente espejada.
func _blit(dst: Image, src: Image, cx: int, cy: int, flip: bool = false) -> void:
	for y in S:
		for x in S:
			var sx := (S - 1 - x) if flip else x
			var c := src.get_pixel(sx, y)
			if c.a > 0.0:
				_px(dst, cx + x, cy + y, c)

func _save(img: Image, name: String) -> void:
	img.save_png("res://assets/%s.png" % name)

# ---------- jugador (con skins) ----------
func _gen_player() -> void:
	# Skin por defecto (gi naranja, pelo oscuro) + skins comprables.
	_gen_player_skin("player",       Color8(232, 98, 42),  Color8(255, 146, 78), Color8(176, 64, 26),  Color8(32, 28, 44),  Color8(64, 60, 92))
	_gen_player_skin("player_blue",  Color8(52, 110, 210), Color8(96, 160, 245), Color8(34, 70, 150),  Color8(28, 30, 50),  Color8(70, 80, 130))
	_gen_player_skin("player_red",   Color8(196, 44, 52),  Color8(240, 90, 86),  Color8(140, 24, 36),  Color8(20, 18, 24),  Color8(60, 50, 56))
	_gen_player_skin("player_green", Color8(64, 168, 84),  Color8(110, 214, 120), Color8(38, 116, 56), Color8(24, 40, 28),  Color8(70, 120, 80))

func _gen_player_skin(file: String, gi: Color, gi_hi: Color, gi_sh: Color, hair: Color, hair_hi: Color) -> void:
	GI = gi; GI_HI = gi_hi; GI_SH = gi_sh; HAIR = hair; HAIR_HI = hair_hi
	# Atlas 64x64: filas = abajo/arriba/izq/der, cols = idle/walk1/walk2/attack
	var atlas := _img(S * 4, S * 4)
	for f in 4:
		_blit(atlas, _hero_front(f), f * S, 0)            # fila 0: abajo
		_blit(atlas, _hero_back(f), f * S, S)             # fila 1: arriba
		_blit(atlas, _hero_side(f), f * S, S * 2, true)   # fila 2: izquierda (espejo)
		_blit(atlas, _hero_side(f), f * S, S * 3)         # fila 3: derecha
	_save(atlas, file)

func _legs(img: Image, frame: int) -> void:
	# Piernas con balanceo segun frame (0 idle,1,2 walk,3 attack=idle)
	var la := 13
	var ra := 13
	if frame == 1: la = 12
	elif frame == 2: ra = 12
	_rect(img, 6, la, 2, 16 - la, GI)
	_rect(img, 8, ra, 2, 16 - ra, GI)
	_rect(img, 6, 15, 2, 1, BOOT)
	_rect(img, 8, 15, 2, 1, BOOT)

func _hero_front(frame: int) -> Image:
	var img := _img(S, S)
	# pelo puntiagudo
	_rect(img, 5, 1, 6, 3, HAIR)
	_rect(img, 4, 2, 8, 3, HAIR)
	_px(img, 5, 0, HAIR); _px(img, 7, 0, HAIR); _px(img, 9, 0, HAIR); _px(img, 10, 0, HAIR)
	_rect(img, 6, 2, 4, 1, HAIR_HI)
	# cara
	_rect(img, 5, 4, 6, 3, SKIN)
	_px(img, 6, 5, EYE); _px(img, 9, 5, EYE)
	_px(img, 5, 6, SKIN_SH); _px(img, 10, 6, SKIN_SH)
	# torso gi
	_rect(img, 5, 7, 6, 4, GI)
	_rect(img, 5, 7, 1, 4, GI_SH)
	_rect(img, 10, 7, 1, 4, GI_HI)
	_rect(img, 5, 10, 6, 1, BELT)
	_px(img, 7, 8, GI_HI); _px(img, 8, 8, GI_HI)
	# brazos
	if frame == 3:
		# ataque: brazo derecho extendido + puno
		_rect(img, 11, 8, 3, 2, GI)
		_rect(img, 13, 8, 2, 2, SKIN)
	else:
		_rect(img, 4, 7, 1, 3, GI); _px(img, 4, 10, SKIN)
		_rect(img, 11, 7, 1, 3, GI); _px(img, 11, 10, SKIN)
	# piernas (gi naranja)
	_rect(img, 5, 11, 6, 2, GI)
	_legs(img, frame)
	_outline(img)
	return img

func _hero_back(frame: int) -> Image:
	var img := _img(S, S)
	_rect(img, 5, 1, 6, 3, HAIR)
	_rect(img, 4, 2, 8, 4, HAIR)
	_px(img, 5, 0, HAIR); _px(img, 7, 0, HAIR); _px(img, 9, 0, HAIR); _px(img, 10, 0, HAIR)
	_rect(img, 6, 2, 4, 2, HAIR_HI)
	_rect(img, 5, 5, 6, 1, HAIR)  # nuca
	# torso (de espaldas, sin cara)
	_rect(img, 5, 6, 6, 5, GI)
	_rect(img, 5, 6, 1, 5, GI_SH)
	_rect(img, 5, 10, 6, 1, BELT)
	if frame == 3:
		_rect(img, 2, 8, 3, 2, GI); _rect(img, 1, 8, 2, 2, SKIN)
	else:
		_rect(img, 4, 6, 1, 3, GI); _px(img, 4, 9, SKIN)
		_rect(img, 11, 6, 1, 3, GI); _px(img, 11, 9, SKIN)
	_rect(img, 5, 11, 6, 2, GI)
	_legs(img, frame)
	_outline(img)
	return img

func _hero_side(frame: int) -> Image:
	# Mira a la derecha. Cuerpo desplazado, un solo ojo, mechon frontal.
	var img := _img(S, S)
	_rect(img, 5, 1, 6, 4, HAIR)
	_px(img, 6, 0, HAIR); _px(img, 8, 0, HAIR); _px(img, 10, 0, HAIR)
	_px(img, 11, 3, HAIR)  # mechon frontal
	_rect(img, 6, 2, 3, 1, HAIR_HI)
	# cara de perfil
	_rect(img, 7, 4, 4, 3, SKIN)
	_px(img, 9, 5, EYE)
	_px(img, 11, 5, SKIN)  # nariz
	# torso
	_rect(img, 6, 7, 5, 4, GI)
	_rect(img, 6, 10, 5, 1, BELT)
	_px(img, 9, 8, GI_HI)
	# brazo
	if frame == 3:
		_rect(img, 11, 8, 3, 2, GI); _rect(img, 13, 8, 2, 2, SKIN)
	else:
		_rect(img, 9, 7, 2, 3, GI); _px(img, 10, 10, SKIN)
	# piernas perfil
	var la := 13
	var ra := 13
	if frame == 1: la = 12
	elif frame == 2: ra = 12
	_rect(img, 6, 11, 5, 2, GI)
	_rect(img, 6, la, 2, 16 - la, GI)
	_rect(img, 9, ra, 2, 16 - ra, GI)
	_rect(img, 6, 15, 3, 1, BOOT)
	_rect(img, 9, 15, 2, 1, BOOT)
	_outline(img)
	return img

## Anade contorno oscuro alrededor de los pixeles opacos (estilo Rucoy).
func _outline(img: Image) -> void:
	var src := img.duplicate()
	for y in S:
		for x in S:
			if src.get_pixel(x, y).a > 0.0:
				continue
			var near := false
			for d in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
				var nx: int = x + d.x
				var ny: int = y + d.y
				if nx >= 0 and ny >= 0 and nx < S and ny < S and src.get_pixel(nx, ny).a > 0.0:
					near = true
					break
			if near:
				_px(img, x, y, OUT)

# ---------- enemigos ----------
func _gen_enemies() -> void:
	# Atlas 32x48: 3 filas (planta/androide/sombra), 2 cols (idle bob)
	var atlas := _img(S * 2, S * 3)
	for fr in 2:
		_blit(atlas, _enemy_plant(fr), fr * S, 0)
		_blit(atlas, _enemy_android(fr), fr * S, S)
		_blit(atlas, _enemy_shadow(fr), fr * S, S * 2)
	_save(atlas, "enemies")

func _enemy_plant(fr: int) -> Image:
	# Bicho verde tipo planta guerrera (original)
	var img := _img(S, S)
	var dy := fr  # bob
	var g := Color8(86, 168, 78)
	var gd := Color8(54, 120, 54)
	var gh := Color8(140, 210, 110)
	_rect(img, 4, 4 + dy, 8, 8, g)
	_rect(img, 4, 4 + dy, 8, 1, gh)
	_rect(img, 4, 11 + dy, 8, 1, gd)
	# antena/hoja
	_rect(img, 7, 1 + dy, 2, 3, gd)
	# ojos rojos
	_px(img, 6, 7 + dy, Color8(220, 40, 40)); _px(img, 9, 7 + dy, Color8(220, 40, 40))
	# patas
	_rect(img, 5, 12 + dy, 2, 2, gd); _rect(img, 9, 12 + dy, 2, 2, gd)
	_outline(img)
	return img

func _enemy_android(fr: int) -> Image:
	# Androide humanoide gris/azul (original)
	var img := _img(S, S)
	var dy := fr
	var m := Color8(150, 158, 175)
	var md := Color8(96, 104, 124)
	var mh := Color8(196, 204, 220)
	_rect(img, 5, 2 + dy, 6, 4, m)        # cabeza
	_rect(img, 5, 2 + dy, 6, 1, mh)
	_px(img, 6, 4 + dy, Color8(220, 60, 60)); _px(img, 9, 4 + dy, Color8(60, 160, 220))  # ojo rojo/azul
	_rect(img, 4, 6 + dy, 8, 6, m)        # torso
	_rect(img, 4, 6 + dy, 1, 6, md); _rect(img, 11, 6 + dy, 1, 6, md)
	_rect(img, 6, 8 + dy, 4, 2, Color8(70, 170, 220))  # nucleo de energia
	_rect(img, 5, 12 + dy, 2, 3, md); _rect(img, 9, 12 + dy, 2, 3, md)  # piernas
	_outline(img)
	return img

func _enemy_shadow(fr: int) -> Image:
	# Guerrero sombra: silueta morada con aura
	var img := _img(S, S)
	var dy := fr
	var p := Color8(120, 64, 168)
	var pd := Color8(78, 38, 120)
	_rect(img, 5, 1 + dy, 6, 3, pd)       # pelo
	_px(img, 5, 0 + dy, pd); _px(img, 8, 0 + dy, pd); _px(img, 10, 0 + dy, pd)
	_rect(img, 5, 4 + dy, 6, 3, p)        # cara
	_px(img, 6, 5 + dy, Color8(255, 230, 90)); _px(img, 9, 5 + dy, Color8(255, 230, 90))  # ojos
	_rect(img, 5, 7 + dy, 6, 5, pd)       # cuerpo
	_rect(img, 4, 7 + dy, 1, 3, p); _rect(img, 11, 7 + dy, 1, 3, p)  # brazos
	_rect(img, 5, 12 + dy, 2, 3, pd); _rect(img, 9, 12 + dy, 2, 3, pd)
	_outline(img)
	return img

# ---------- tiles ----------
func _gen_tiles() -> void:
	# 9 tiles: grass, grass2, path, sand, rock(borde), water, crystal, tree, boulder
	var t := _img(S * 9, S)
	_tile_grass(t, 0, false)
	_tile_grass(t, 1, true)
	_tile_path(t, 2)
	_tile_sand(t, 3)
	_tile_rock(t, 4)
	_tile_water(t, 5)
	_tile_crystal(t, 6)
	_tile_tree(t, 7)
	_tile_boulder(t, 8)
	_save(t, "tiles")

func _tile_boulder(img: Image, idx: int) -> void:
	# Canto rodado centrado sobre hierba (deja huecos visibles entre rocas).
	var ox := idx * S
	_rect(img, ox, 0, S, S, Color8(74, 132, 66))
	for y in S:
		for x in S:
			if _h(x + idx * 31, y) % 11 == 0:
				_px(img, ox + x, y, Color8(58, 112, 54))
	var g := Color8(122, 122, 134)
	var gh := Color8(162, 162, 174)
	var gd := Color8(86, 86, 98)
	# contorno oscuro + cuerpo redondeado (filas 4..12)
	for j in 9:
		var ww: int = 11 - abs(4 - j)
		_rect(img, ox + 8 - int((ww + 1) / 2.0), 4 + j, ww + 1, 1, OUT)
	for j in 9:
		var ww: int = 10 - abs(4 - j)
		_rect(img, ox + 8 - int(ww / 2.0), 4 + j, ww, 1, g)
	_rect(img, ox + 5, 5, 4, 1, gh)
	_rect(img, ox + 4, 11, 6, 1, gd)

func _h(x: int, y: int) -> int:
	return (x * 73856093) ^ (y * 19349663)

func _tile_grass(img: Image, idx: int, alt: bool) -> void:
	var ox := idx * S
	var base := Color8(74, 132, 66) if not alt else Color8(80, 140, 70)
	var d := Color8(58, 112, 54)
	var l := Color8(104, 168, 88)
	_rect(img, ox, 0, S, S, base)
	for y in S:
		for x in S:
			var hsh := _h(x + idx * 31, y)
			if hsh % 11 == 0:
				_px(img, ox + x, y, d)
			elif hsh % 17 == 0:
				_px(img, ox + x, y, l)

func _tile_path(img: Image, idx: int) -> void:
	var ox := idx * S
	_rect(img, ox, 0, S, S, Color8(178, 150, 104))
	for y in S:
		for x in S:
			if _h(x, y + 7) % 9 == 0:
				_px(img, ox + x, y, Color8(150, 122, 80))
			elif _h(x, y + 3) % 13 == 0:
				_px(img, ox + x, y, Color8(200, 176, 130))

func _tile_sand(img: Image, idx: int) -> void:
	var ox := idx * S
	_rect(img, ox, 0, S, S, Color8(214, 190, 132))
	for y in S:
		for x in S:
			if _h(x + 5, y) % 14 == 0:
				_px(img, ox + x, y, Color8(190, 164, 110))

func _tile_rock(img: Image, idx: int) -> void:
	var ox := idx * S
	_rect(img, ox, 0, S, S, Color8(120, 120, 132))
	_rect(img, ox, 0, S, 2, Color8(156, 156, 168))   # luz arriba
	_rect(img, ox, 13, S, 3, Color8(86, 86, 98))      # sombra abajo
	_px(img, ox + 5, 6, Color8(86, 86, 98)); _px(img, ox + 9, 9, Color8(86, 86, 98))

func _tile_water(img: Image, idx: int) -> void:
	var ox := idx * S
	_rect(img, ox, 0, S, S, Color8(54, 110, 190))
	_rect(img, ox, 4, S, 1, Color8(96, 156, 224))
	_rect(img, ox, 10, S, 1, Color8(96, 156, 224))
	_px(img, ox + 3, 7, Color8(150, 200, 240)); _px(img, ox + 11, 12, Color8(150, 200, 240))

func _tile_crystal(img: Image, idx: int) -> void:
	var ox := idx * S
	# suelo oscuro + gema de energia
	_rect(img, ox, 0, S, S, Color8(40, 60, 70))
	var c := Color8(90, 220, 230)
	var ch := Color8(200, 255, 255)
	# diamante
	for j in 12:
		var w: int = 12 - abs(6 - j) * 2
		_rect(img, ox + 8 - int(w / 2.0), 2 + j, w, 1, c)
	_rect(img, ox + 6, 5, 2, 3, ch)
	_outline_region(img, ox)

func _tile_tree(img: Image, idx: int) -> void:
	var ox := idx * S
	_rect(img, ox, 0, S, S, Color8(74, 132, 66))  # base hierba
	_rect(img, ox + 7, 10, 2, 5, Color8(110, 78, 44))  # tronco
	var g := Color8(56, 128, 60)
	var gh := Color8(92, 168, 80)
	for j in 9:
		var w: int = 12 - abs(4 - j)
		_rect(img, ox + 8 - int(w / 2.0), 1 + j, w, 1, g)
	_rect(img, ox + 5, 3, 4, 2, gh)

func _outline_region(img: Image, ox: int) -> void:
	# outline solo para celda de cristal (sobre fondo oscuro no hace falta full)
	pass

# ---------- fx (ki blast) ----------
func _gen_fx() -> void:
	var t := _img(S * 2, S)
	for fr in 2:
		var img := _img(S, S)
		var r := 3 + fr
		var core := Color8(255, 255, 255)
		var ring := Color8(255, 170, 60)
		var glow := Color8(255, 120, 30)
		_disc(img, 8, 8, r + 2, glow)
		_disc(img, 8, 8, r + 1, ring)
		_disc(img, 8, 8, r, core)
		_blit(t, img, fr * S, 0)
	_save(t, "kiblast")

func _disc(img: Image, cx: int, cy: int, r: int, c: Color) -> void:
	for y in range(cy - r, cy + r + 1):
		for x in range(cx - r, cx + r + 1):
			if (x - cx) * (x - cx) + (y - cy) * (y - cy) <= r * r:
				_px(img, x, y, c)

# ---------- orbe coleccionable ----------
func _gen_orb() -> void:
	var img := _img(S, S)
	var o := Color8(240, 150, 40)
	var oh := Color8(255, 210, 120)
	var od := Color8(190, 100, 20)
	_disc(img, 8, 8, 5, o)
	_disc(img, 8, 8, 5, o)
	_px(img, 6, 6, oh); _px(img, 7, 6, oh); _px(img, 6, 7, oh)  # brillo
	# estrella central
	_px(img, 8, 8, Color8(200, 40, 40))
	_px(img, 8, 7, Color8(200, 40, 40)); _px(img, 8, 9, Color8(200, 40, 40))
	_px(img, 7, 8, Color8(200, 40, 40)); _px(img, 9, 8, Color8(200, 40, 40))
	_disc(img, 8, 11, 1, od)
	_outline(img)
	_save(img, "orb")

# ---------- jefe (boss) ----------
func _gen_boss() -> void:
	# Atlas 64x32: 2 frames de 32x32 (idle / ataque con aura)
	var atlas := _img(32 * 2, 32)
	for fr in 2:
		var f := _img(32, 32)
		_boss_draw(f, fr)
		_outline_full(f)
		_blit_img(atlas, f, fr * 32, 0)
	_save(atlas, "boss")

func _boss_draw(img: Image, fr: int) -> void:
	var armor := Color8(58, 44, 78)
	var armor_hi := Color8(98, 76, 128)
	var armor_sh := Color8(38, 28, 52)
	var trim := Color8(196, 48, 48)
	var gem := Color8(255, 96, 72)
	var eye := Color8(255, 70, 60)
	var skin := Color8(206, 184, 206)
	# cuernos
	_rect(img, 6, 2, 3, 5, armor); _rect(img, 23, 2, 3, 5, armor)
	_rect(img, 7, 0, 1, 3, armor_sh); _rect(img, 24, 0, 1, 3, armor_sh)
	# casco
	_rect(img, 9, 3, 14, 6, armor)
	_rect(img, 9, 3, 14, 1, armor_hi)
	# cara
	_rect(img, 11, 8, 10, 5, skin)
	var ec := eye if fr == 0 else Color8(255, 150, 90)
	_rect(img, 13, 10, 2, 2, ec); _rect(img, 17, 10, 2, 2, ec)
	_rect(img, 11, 12, 10, 1, armor_sh)
	# hombros anchos
	_rect(img, 5, 13, 22, 4, armor)
	_rect(img, 5, 13, 22, 1, armor_hi)
	_rect(img, 5, 16, 22, 1, trim)
	# brazos
	_rect(img, 4, 15, 4, 10, armor); _rect(img, 24, 15, 4, 10, armor)
	_rect(img, 4, 23, 4, 3, armor_sh); _rect(img, 24, 23, 4, 3, armor_sh)
	# torso
	_rect(img, 10, 17, 12, 8, armor)
	_rect(img, 10, 17, 1, 8, armor_sh); _rect(img, 21, 17, 1, 8, armor_hi)
	_rect(img, 14, 19, 4, 3, gem)
	_px(img, 15, 20, Color8(255, 220, 200)); _px(img, 16, 20, Color8(255, 220, 200))
	# cinturon + piernas
	_rect(img, 10, 25, 12, 2, trim)
	_rect(img, 11, 27, 4, 5, armor); _rect(img, 17, 27, 4, 5, armor)
	_rect(img, 11, 30, 4, 2, armor_sh); _rect(img, 17, 30, 4, 2, armor_sh)
	# aura (frame de ataque): destellos rojos en los bordes
	if fr == 1:
		var a := Color8(230, 70, 50)
		for p in [Vector2i(2, 12), Vector2i(29, 12), Vector2i(3, 20), Vector2i(28, 20), Vector2i(16, 1)]:
			_px(img, p.x, p.y, a)

func _outline_full(img: Image) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var src := img.duplicate()
	for y in h:
		for x in w:
			if src.get_pixel(x, y).a > 0.0:
				continue
			var near := false
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var nx: int = x + d.x
				var ny: int = y + d.y
				if nx >= 0 and ny >= 0 and nx < w and ny < h and src.get_pixel(nx, ny).a > 0.0:
					near = true
					break
			if near:
				_px(img, x, y, OUT)

func _blit_img(dst: Image, src: Image, ox: int, oy: int) -> void:
	for y in src.get_height():
		for x in src.get_width():
			var c := src.get_pixel(x, y)
			if c.a > 0.0:
				_px(dst, ox + x, oy + y, c)
