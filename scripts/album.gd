extends Node2D
## Album objevů: zvířátka, místa, poklady a zážitky, které dítě na procházkách zažilo.

const AnimalArt := preload("res://scripts/animal_art.gd")
const TABS := ["Zvířátka", "Místa a poklady", "Zážitky"]
const CARD := Vector2(210, 190)

var _page := 0
var _art_root: Node2D
var _ui_root: Control
var _title: Label
var _cards: Array = []  # {rect, kind, known}


func _ready() -> void:
	Audio.music("stable")
	_art_root = Node2D.new()
	add_child(_art_root)
	var ui := CanvasLayer.new()
	add_child(ui)
	_title = UiStyle.label("", 40, Color.WHITE)
	_title.add_theme_color_override("font_outline_color", Color("8a5a35"))
	_title.add_theme_constant_override("outline_size", 12)
	_title.position = Vector2(40, 18)
	ui.add_child(_title)

	var tabs := HBoxContainer.new()
	tabs.position = Vector2(40, 620)
	tabs.add_theme_constant_override("separation", 16)
	ui.add_child(tabs)
	for i in TABS.size():
		var tab := UiStyle.big_button(TABS[i], [Color("5cb85c"), Color("3fa9f5"), Color("c06fd8")][i], Vector2(240, 80))
		tab.add_theme_font_size_override("font_size", 26)
		tab.pressed.connect(_show.bind(i))
		tabs.add_child(tab)

	var back := UiStyle.big_button("Zpět", Color("e0a526"))
	back.position = Vector2(1070, 620)
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/stable.tscn"))
	ui.add_child(back)

	_ui_root = Control.new()
	ui.add_child(_ui_root)
	_show(0)


func _total_counts() -> Vector2i:
	var ids: Array = WorldData.ANIMALS.keys()
	for id in WorldData.AREAS:
		ids.append("misto_" + id)
		ids.append("poklad_" + id)
	for id in WorldData.MOMENTS:
		ids.append("zazitek_" + id)
	var found := 0
	for id in ids:
		found += int(GameState.discovered.has(id))
	return Vector2i(found, ids.size())


func _show(page: int) -> void:
	_page = page
	for child in _art_root.get_children():
		child.queue_free()
	for child in _ui_root.get_children():
		child.queue_free()
	_cards.clear()
	var counts := _total_counts()
	_title.text = "Album objevů  %d / %d" % [counts.x, counts.y]
	match page:
		0:
			var i := 0
			for id in WorldData.ANIMALS:
				var known: bool = GameState.discovered.has(id)
				var pos := _card_pos(i)
				var art := AnimalArt.new()
				art.kind = id
				art.silhouette = not known
				art.position = pos + Vector2(CARD.x / 2, 85)
				art.scale = Vector2(1.2, 1.2)
				_art_root.add_child(art)
				_card_label(pos, WorldData.ANIMALS[id] if known else "???", "", known)
				i += 1
		1:
			var i := 0
			for id in WorldData.AREAS:
				var known: bool = GameState.discovered.has("misto_" + id)
				_card_label(_card_pos(i), WorldData.AREAS[id].name if known else "???", "Místo", known)
				i += 1
			for id in WorldData.TREASURES:
				var known: bool = GameState.discovered.has("poklad_" + id)
				_card_label(_card_pos(i), WorldData.TREASURES[id].name if known else "???", "Poklad", known)
				i += 1
		2:
			var i := 0
			for id in WorldData.MOMENTS:
				var known: bool = GameState.discovered.has("zazitek_" + id)
				_card_label(_card_pos(i), WorldData.MOMENTS[id] if known else "???", "Zážitek", known)
				i += 1
	queue_redraw()


func _card_pos(i: int) -> Vector2:
	return Vector2(45 + (i % 5) * (CARD.x + 30), 100 + (i / 5) * (CARD.y + 20))


func _card_label(pos: Vector2, text: String, kind: String, known: bool) -> void:
	_cards.append({"rect": Rect2(pos, CARD), "kind": kind, "known": known})
	var label := UiStyle.label(text, 22)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size = Vector2(CARD.x - 20, 60)
	label.position = pos + Vector2(10, CARD.y - 62)
	_ui_root.add_child(label)


func _draw() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Color("c98b5a"))
	draw_rect(Rect2(Vector2(25, 85), Vector2(size.x - 50, 515)), Color("fbf3dc"))
	for card in _cards:
		var r: Rect2 = card.rect
		draw_rect(r, Color("fff9ea"))
		draw_rect(r, Color("e6cfa0"), false, 4)
		if _page == 0:
			continue
		var c := r.position + Vector2(r.size.x / 2, 70)
		var known: bool = card.known
		var kind: String = card.kind
		var col := Color("9aa5b1") if not known else Color.WHITE
		match kind:
			"Místo":
				draw_circle(c, 48, Color("8fd16f") if known else Color("c9ced3"))
				draw_circle(c + Vector2(-15, -5), 18, Color("2f9e44") if known else Color("aab1b8"))
				draw_circle(c + Vector2(15, 5), 14, Color("4fb3e8") if known else Color("aab1b8"))
			"Poklad":
				draw_rect(Rect2(c + Vector2(-40, -20), Vector2(80, 55)), Color("8a5a35") if known else Color("aab1b8"))
				draw_rect(Rect2(c + Vector2(-40, -32), Vector2(80, 18)), Color("a8733f") if known else Color("c9ced3"))
				draw_rect(Rect2(c + Vector2(-7, -18), Vector2(14, 16)), Color("e8b923") if known else col)
			"Zážitek":
				for k in 5:
					var a := -PI / 2 + k * TAU / 5
					draw_line(c, c + Vector2.from_angle(a) * 45, Color("ffd84d") if known else Color("c9ced3"), 6)
				draw_circle(c, 22, Color("ffb84d") if known else Color("aab1b8"))
		if not known:
			draw_string(ThemeDB.fallback_font, c + Vector2(-12, 16), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, 48, Color.WHITE)
