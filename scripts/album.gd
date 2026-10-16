extends Node2D
## Album objevů: zvířátka a místa, která už dítě potkalo.

const AnimalArt := preload("res://scripts/animal_art.gd")


func _ready() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)
	var found := 0
	var total := WorldData.ANIMALS.size() + WorldData.AREAS.size()
	var col := 0
	var row := 0
	for id in WorldData.ANIMALS:
		var known: bool = id in GameState.discovered
		found += int(known)
		var card_pos := Vector2(70 + col * 290, 140 + row * 200)
		var art := AnimalArt.new()
		art.kind = id
		art.silhouette = not known
		art.position = card_pos + Vector2(120, 70)
		art.scale = Vector2(1.4, 1.4)
		add_child(art)
		var name_label := UiStyle.label(WorldData.ANIMALS[id] if known else "???", 26)
		name_label.position = card_pos + Vector2(20, 135)
		ui.add_child(name_label)
		col += 1
		if col == 4:
			col = 0
			row += 1
	var places := HBoxContainer.new()
	places.position = Vector2(70, 560)
	places.add_theme_constant_override("separation", 30)
	ui.add_child(places)
	places.add_child(UiStyle.label("Místa:", 28))
	for id in WorldData.AREAS:
		var known: bool = "misto_" + id in GameState.discovered
		found += int(known)
		places.add_child(UiStyle.label(WorldData.AREAS[id].name if known else "???", 26, Color("2f6b2a") if known else Color("9aa5b1")))

	var title := UiStyle.label("Album objevů  %d / %d" % [found, total], 44, Color.WHITE)
	title.add_theme_color_override("font_outline_color", Color("8a5a35"))
	title.add_theme_constant_override("outline_size", 12)
	title.position = Vector2(70, 24)
	ui.add_child(title)

	var back := UiStyle.big_button("Zpět", Color("e0a526"))
	back.position = Vector2(1060, 620)
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/stable.tscn"))
	ui.add_child(back)


func _draw() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Color("c98b5a"))
	draw_rect(Rect2(Vector2(30, 110), Vector2(size.x - 60, 500)), Color("fbf3dc"))
	for i in WorldData.ANIMALS.size():
		var p := Vector2(70 + (i % 4) * 290, 140 + (i / 4) * 200)
		draw_rect(Rect2(p, Vector2(250, 180)), Color("fff9ea"))
		draw_rect(Rect2(p, Vector2(250, 180)), Color("e6cfa0"), false, 4)
