extends Node2D
## Úvodní obrazovka.

const PonyArt := preload("res://scripts/pony/pony_art.gd")
const MeshBuilder := preload("res://scripts/mesh_builder.gd")

var _rays: MeshInstance2D
var _clouds: Array[MeshInstance2D] = []


func _ready() -> void:
	_build_background()
	var pony := PonyArt.new()
	pony.position = Vector2(640, 430)
	pony.scale = Vector2(1.6, 1.6)
	add_child(pony)

	var ui := CanvasLayer.new()
	add_child(ui)
	var title := UiStyle.label("Koníčci", 96, Color("ffffff"))
	title.add_theme_color_override("font_outline_color", Color("c0508a"))
	title.add_theme_constant_override("outline_size", 18)
	title.position = Vector2(470, 40)
	ui.add_child(title)

	var play := UiStyle.big_button("Hrát", Color("5cb85c"), Vector2(260, 110))
	play.position = Vector2(510, 580)
	play.pressed.connect(func(): Scenes.go("res://scenes/stable.tscn"))
	ui.add_child(play)

	var sound := UiStyle.big_button("", Color("3fa9f5"), Vector2(200, 70))
	sound.add_theme_font_size_override("font_size", 24)
	sound.position = Vector2(1056, 630)
	var label_sound := func(): sound.text = "Zvuk: zapnutý" if GameState.sound_on else "Zvuk: vypnutý"
	label_sound.call()
	sound.pressed.connect(func():
		GameState.set_sound(not GameState.sound_on)
		label_sound.call())
	ui.add_child(sound)

	var parents := UiStyle.big_button("Pro rodiče", Color("8a8f99"), Vector2(200, 70))
	parents.add_theme_font_size_override("font_size", 24)
	parents.position = Vector2(24, 630)
	parents.pressed.connect(func(): Scenes.go("res://scenes/parents.tscn"))
	ui.add_child(parents)
	Audio.music("stable")


func _process(_delta: float) -> void:
	var t := Time.get_ticks_msec() / 1000.0
	var width := get_viewport_rect().size.x
	_rays.rotation = t * 0.2
	for c in _clouds:
		var speed: float = c.get_meta("speed")
		c.position.x = fposmod(c.get_meta("x") + t * 18.0 * speed, width + 300) - 150


## Pozadí se jednou převede na síť trojúhelníků; hýbe se jen celými kusy (paprsky, mraky).
func _build_background() -> void:
	var size := get_viewport_rect().size
	_add_mesh(func(ci):
		# Obloha s přechodem
		for i in 12:
			ci.draw_rect(Rect2(0, i * 45, size.x, 46), Color("7cc8ff").lerp(Color("d6f0ff"), i / 11.0)))
	# Slunce s paprsky
	var sun := Vector2(1100, 120)
	_rays = _add_mesh(func(ci):
		for k in 12:
			var a := k * TAU / 12.0
			ci.draw_line(Vector2.from_angle(a) * 80, Vector2.from_angle(a) * 110, Color("ffe066"), 8))
	_rays.position = sun
	_add_mesh(func(ci): DrawKit.ellipse(ci, sun, 66, 66, Color("ffe066"), 0, 4, Color("f0b429")))
	# Mraky plují
	for c in [[Vector2(220, 130), 1.0], [Vector2(700, 230), 0.7], [Vector2(-80, 260), 0.8]]:
		var s: float = c[1]
		var cloud := _add_mesh(func(ci):
			DrawKit.blob(ci, [[Vector2(-45, 8) * s, 34.0 * s], [Vector2(0, -12) * s, 44.0 * s], [Vector2(48, 8) * s, 32.0 * s]], Color.WHITE, 3, Color("b8dcf5")))
		cloud.position.y = c[0].y
		cloud.set_meta("x", c[0].x)
		cloud.set_meta("speed", s)
		_clouds.append(cloud)
	_add_mesh(func(ci):
		# Kopce
		DrawKit.ellipse(ci, Vector2(300, 900), 560, 520, Color("7bc96f"), 0, 4, Color("4f9a44"))
		DrawKit.ellipse(ci, Vector2(1050, 950), 600, 560, Color("6abf5e"), 0, 4, Color("4f9a44"))
		ci.draw_rect(Rect2(0, 520, size.x, size.y - 520), Color("5fb456"))
		for i in 40:
			var p := Vector2(float((i * 137) % int(size.x)), 540.0 + float((i * 53) % 170))
			ci.draw_line(p, p + Vector2(-5, -12), Color("4a9a42"), 3)
			ci.draw_line(p, p + Vector2(5, -12), Color("4a9a42"), 3)
		for i in 14:
			var p := Vector2(float((i * 211 + 40) % int(size.x)), 560.0 + float((i * 97) % 140))
			DrawKit.ellipse(ci, p, 6, 6, [Color("ff7fc4"), Color("ffe066"), Color.WHITE][i % 3], 0, 2))
	_process(0.0)


func _add_mesh(paint: Callable) -> MeshInstance2D:
	var builder := MeshBuilder.new()
	paint.call(builder)
	var layer := MeshInstance2D.new()
	layer.mesh = builder.commit()
	add_child(layer)
	return layer
