extends Node2D
## Kreslená mapa světa: odemčená místa se dají vybrat na procházku.

const STABLE_POS := Vector2(140, 600)

var _hint: Label


func _ready() -> void:
	Audio.music("stable")
	var ui := CanvasLayer.new()
	add_child(ui)
	var title := UiStyle.label("Kam vyrazíme?", 44, Color.WHITE)
	title.add_theme_color_override("font_outline_color", Color("8a5a35"))
	title.add_theme_constant_override("outline_size", 12)
	title.position = Vector2(24, 16)
	ui.add_child(title)

	for id in WorldData.AREAS:
		var area: Dictionary = WorldData.AREAS[id]
		var unlocked := GameState.is_area_unlocked(id)
		var button := UiStyle.big_button(area.name, Color("5cb85c") if unlocked else Color("9aa5b1"), Vector2(250, 70))
		button.add_theme_font_size_override("font_size", 24)
		button.position = area.map_pos + Vector2(-125, 70)
		button.pressed.connect(_go.bind(id))
		ui.add_child(button)

	var home := UiStyle.big_button("Do stáje", Color("e0a526"), Vector2(220, 80))
	home.position = Vector2(1036, 620)
	home.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/stable.tscn"))
	ui.add_child(home)

	_hint = UiStyle.label("", 28, Color("4a2c1a"))
	_hint.position = Vector2(24, 660)
	ui.add_child(_hint)


func _go(id: String) -> void:
	if not GameState.is_area_unlocked(id):
		var left: int = WorldData.AREAS[id].unlock_walks - GameState.walks
		_hint.text = "Sem se dostaneš po %d %s." % [left, "procházce" if left == 1 else "procházkách"]
		UiStyle.bounce(_hint)
		return
	GameState.current_area = id
	get_tree().change_scene_to_file("res://scenes/walk.tscn")


func _draw() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Color("f3e2b3"))
	draw_rect(Rect2(Vector2(10, 10), size - Vector2(20, 20)), Color("8fd16f"))
	# Cestičky ze stáje ke všem místům
	var points := [STABLE_POS]
	for id in WorldData.AREAS:
		points.append(WorldData.AREAS[id].map_pos)
	for i in points.size() - 1:
		draw_line(points[i], points[i + 1], Color("e8c27a"), 26)
	# Stáj
	draw_rect(Rect2(STABLE_POS + Vector2(-60, -50), Vector2(120, 80)), Color("c0392b"))
	draw_colored_polygon(PackedVector2Array([STABLE_POS + Vector2(-75, -50), STABLE_POS + Vector2(0, -100), STABLE_POS + Vector2(75, -50)]), Color("8a3a2a"))
	draw_rect(Rect2(STABLE_POS + Vector2(-20, -10), Vector2(40, 40)), Color("6b3f22"))
	# Místa
	for id in WorldData.AREAS:
		var p: Vector2 = WorldData.AREAS[id].map_pos
		var unlocked := GameState.is_area_unlocked(id)
		draw_circle(p, 80, Color(1, 1, 1, 0.35))
		match id:
			"louka":
				draw_rect(Rect2(p + Vector2(-12, -70), Vector2(24, 140)), Color("4fb3e8"))
				for f in [Vector2(-45, -20), Vector2(40, 10), Vector2(-30, 35)]:
					draw_circle(p + f, 9, Color("ff7fc4"))
			"lesik":
				for t in [Vector2(-35, 0), Vector2(0, -25), Vector2(35, 5), Vector2(5, 30)]:
					draw_rect(Rect2(p + t + Vector2(-5, 0), Vector2(10, 30)), Color("f4f1ea"))
					draw_circle(p + t, 26, Color("8fd14f"))
			"rybnicek":
				draw_set_transform(p, 0, Vector2(1, 0.6))
				draw_circle(Vector2.ZERO, 60, Color("4fb3e8"))
				draw_set_transform(Vector2.ZERO)
				draw_circle(p + Vector2(20, -5), 10, Color("f7f2e8"))
			"kouzelny_les":
				for t in [Vector2(-35, 5), Vector2(0, -25), Vector2(35, 5)]:
					draw_circle(p + t, 28, Color("2f7f78"))
				for s in [Vector2(-20, -40), Vector2(25, -30), Vector2(0, 20), Vector2(40, 30)]:
					draw_circle(p + s, 5, Color("fff3a0"))
				draw_circle(p + Vector2(-5, 30), 9, Color("b388ff"))
		if GameState.discovered.has("poklad_" + id):
			draw_circle(p + Vector2(60, -60), 18, Color("e8b923"))
			draw_rect(Rect2(p + Vector2(50, -66), Vector2(20, 12)), Color("8a5a35"))
		if not unlocked:
			draw_circle(p, 80, Color(0.3, 0.3, 0.35, 0.55))
			draw_rect(Rect2(p + Vector2(-20, -10), Vector2(40, 32)), Color("e0a526"))
			draw_arc(p + Vector2(0, -12), 14, PI, TAU, 10, Color("e0a526"), 7)
