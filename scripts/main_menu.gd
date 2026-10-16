extends Node2D
## Úvodní obrazovka.

const PonyArt := preload("res://scripts/pony/pony_art.gd")


func _ready() -> void:
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
	play.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/stable.tscn"))
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
	parents.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/parents.tscn"))
	ui.add_child(parents)
	Audio.music("stable")


func _draw() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Color("8fd3ff"))
	draw_circle(Vector2(1100, 120), 70, Color("ffe066"))
	for c in [Vector2(200, 130), Vector2(260, 110), Vector2(320, 135)]:
		draw_circle(c, 45, Color.WHITE)
	draw_circle(Vector2(300, 900), 520, Color("7bc96f"))
	draw_circle(Vector2(1050, 950), 560, Color("6abf5e"))
	draw_rect(Rect2(0, 520, size.x, size.y - 520), Color("5fb456"))
