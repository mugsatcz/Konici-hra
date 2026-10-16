extends Node2D
## Zahrádka: uklizený hnůj pohnojí záhonek, zasadí se mrkev, zalije a za chvíli se sklízí.

const BED_SIZE := Vector2(250, 150)

var _hint: Label
var _manure_label: Label
var _splashes: Array = []


func _ready() -> void:
	Audio.music("stable")
	var ui := CanvasLayer.new()
	add_child(ui)
	var title := UiStyle.label("Zahrádka", 48, Color.WHITE)
	title.add_theme_color_override("font_outline_color", Color("5a8f3a"))
	title.add_theme_constant_override("outline_size", 12)
	title.position = Vector2(40, 16)
	ui.add_child(title)
	_manure_label = UiStyle.label("", 26, Color("4a2c1a"))
	_manure_label.position = Vector2(40, 90)
	ui.add_child(_manure_label)
	_hint = UiStyle.label("Ťukni na záhonek.", 28, Color("4a2c1a"))
	_hint.position = Vector2(40, 630)
	ui.add_child(_hint)
	var back := UiStyle.big_button("Do stáje", Color("e0a526"), Vector2(220, 80))
	back.position = Vector2(1030, 620)
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/stable.tscn"))
	ui.add_child(back)


func _bed_rect(i: int) -> Rect2:
	return Rect2(Vector2(340 + (i % 3) * 290, 170 + (i / 3) * 200), BED_SIZE)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventScreenTouch and event.pressed):
		return
	for i in GameState.GARDEN_BEDS:
		if _bed_rect(i).has_point(event.position):
			_tap_bed(i)
			return


func _tap_bed(i: int) -> void:
	var center := _bed_rect(i).get_center()
	match GameState.bed_stage(i):
		"empty":
			if GameState.plant(i):
				Audio.play("rustle")
				_say("Pohnojeno a zasazeno! Teď záhonek zalij.")
			else:
				Audio.play("boing")
				_say("Chybí hnůj. Ukliď koblížky ve stáji!")
		"thirsty":
			GameState.water_bed(i)
			Audio.play("water")
			_splashes.append([center, 1.0])
			_say("Zalito! Mrkvička teď poroste.")
		"growing":
			_say("Ještě roste... Zajdi zatím na procházku!")
		"ready":
			GameState.harvest(i)
			Audio.play("pickup")
			Audio.play("quest", 0.0)
			_splashes.append([center, 1.0])
			_say("Sklizeno! Dvě mrkve pro koníky.")


func _say(text: String) -> void:
	_hint.text = text
	UiStyle.bounce(_hint)


func _process(delta: float) -> void:
	for s in _splashes:
		s[1] -= delta
	_splashes = _splashes.filter(func(s): return s[1] > 0.0)
	_manure_label.text = "Hnůj na hnojišti: %d     Mrkve: %d" % [GameState.manure, GameState.inventory.get("carrot", 0)]
	queue_redraw()


func _draw() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Color("8fd3ff"))
	draw_rect(Rect2(0, 140, size.x, size.y - 140), Color("7ccf63"))
	# Plot
	for x in range(0, int(size.x), 60):
		draw_rect(Rect2(x + 10, 118, 16, 50), Color("f4e3c1"))
	draw_rect(Rect2(0, 130, size.x, 10), Color("e6d0a6"))
	# Hnojiště
	draw_circle(Vector2(140, 380), 90, Color("6b4423"))
	draw_circle(Vector2(140, 330), 60, Color("7a5030"))
	for i in mini(GameState.manure, 8):
		draw_circle(Vector2(100 + (i % 4) * 26, 300 + (i / 4) * 26), 10, Color("5a3a1e"))
	draw_string(ThemeDB.fallback_font, Vector2(80, 500), "Hnojiště", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("4a2c1a"))
	# Záhonky
	for i in GameState.GARDEN_BEDS:
		var r := _bed_rect(i)
		var stage := GameState.bed_stage(i)
		draw_rect(r, Color("7a5030") if stage != "empty" else Color("a0764a"))
		draw_rect(r, Color("5a3a1e"), false, 6)
		if stage == "empty":
			continue
		var wet := stage != "thirsty"
		if wet:
			draw_rect(r.grow(-6), Color(0.2, 0.15, 0.1, 0.3))
		var growth := GameState.bed_growth(i)
		for k in 3:
			var p := r.position + Vector2(55 + k * 70, 95)
			if stage == "ready":
				draw_colored_polygon(PackedVector2Array([p + Vector2(-12, -5), p + Vector2(12, -5), p + Vector2(0, 40)]), Color("f07c1e"))
			var leaf := 10.0 + growth * 35.0
			draw_line(p + Vector2(0, -5), p + Vector2(-10, -5 - leaf), Color("3c9a3c"), 6)
			draw_line(p + Vector2(0, -5), p + Vector2(0, -8 - leaf), Color("4cbb47"), 6)
			draw_line(p + Vector2(0, -5), p + Vector2(10, -5 - leaf), Color("3c9a3c"), 6)
		if stage == "thirsty":
			draw_string(ThemeDB.fallback_font, r.position + Vector2(70, 40), "Zalij mě!", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color.WHITE)
		elif stage == "ready":
			draw_string(ThemeDB.fallback_font, r.position + Vector2(60, 40), "Sklidit!", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("ffe066"))
		else:
			draw_rect(Rect2(r.position + Vector2(20, 18), Vector2(r.size.x - 40, 12)), Color(1, 1, 1, 0.4))
			draw_rect(Rect2(r.position + Vector2(20, 18), Vector2((r.size.x - 40) * growth, 12)), Color("8ee04f"))
	for s in _splashes:
		for k in 8:
			var a := k * TAU / 8.0
			draw_circle(s[0] + Vector2.from_angle(a) * (90.0 - s[1] * 50.0), 7, Color(0.6, 0.85, 1.0, s[1]))
