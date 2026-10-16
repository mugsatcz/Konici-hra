extends Node2D
## Stáj: krmení, napájení, česání a úklid koblížků. Koníků může být víc, šipkami se přepíná.

const PonyArt := preload("res://scripts/pony/pony_art.gd")
const POOP_SPOTS := [Vector2(420, 560), Vector2(470, 600), Vector2(800, 590), Vector2(860, 555), Vector2(540, 620)]
const NEEDS := [
	["hunger", "Jídlo", Color("f0883e")],
	["thirst", "Voda", Color("3fa9f5")],
	["grooming", "Čistota", Color("c06fd8")],
]

var pony: Node2D
var brushing := false
var _bars := {}
var _items_label: Label
var _hint: Label
var _brush_button: Button
var _carrot_button: Button
var _name_label: Label
var _switch: HBoxContainer
var _sparkles: Array = []
var _brush_sound := 0


func _ready() -> void:
	pony = PonyArt.new()
	pony.position = Vector2(640, 470)
	pony.scale = Vector2(1.5, 1.5)
	add_child(pony)
	_build_ui()
	Audio.music("stable")
	GameState.needs_changed.connect(_refresh)
	GameState.inventory_changed.connect(_refresh)
	GameState.looks_changed.connect(_refresh)
	_refresh()


func _build_ui() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)

	var panel := VBoxContainer.new()
	panel.position = Vector2(24, 20)
	panel.add_theme_constant_override("separation", 6)
	ui.add_child(panel)
	var name_row := HBoxContainer.new()
	name_row.add_theme_constant_override("separation", 12)
	panel.add_child(name_row)
	_name_label = UiStyle.label("", 40, Color.WHITE)
	name_row.add_child(_name_label)
	_switch = HBoxContainer.new()
	_switch.add_theme_constant_override("separation", 8)
	name_row.add_child(_switch)
	for dir in [-1, 1]:
		var arrow := UiStyle.big_button("<" if dir < 0 else ">", Color("8a5a35"), Vector2(56, 50))
		arrow.pressed.connect(func():
			GameState.select_pony(GameState.current_pony + dir)
			_brush_button.button_pressed = false
			Audio.play("neigh")
			pony.love())
		_switch.add_child(arrow)
	for need in NEEDS:
		var row := HBoxContainer.new()
		var name_label := UiStyle.label(need[1], 24, Color.WHITE)
		name_label.custom_minimum_size.x = 110
		row.add_child(name_label)
		var bar := ProgressBar.new()
		bar.custom_minimum_size = Vector2(220, 26)
		bar.show_percentage = false
		var fill := StyleBoxFlat.new()
		fill.bg_color = need[2]
		fill.set_corner_radius_all(13)
		var bg := StyleBoxFlat.new()
		bg.bg_color = Color(1, 1, 1, 0.6)
		bg.set_corner_radius_all(13)
		bar.add_theme_stylebox_override("fill", fill)
		bar.add_theme_stylebox_override("background", bg)
		row.add_child(bar)
		panel.add_child(row)
		_bars[need[0]] = bar

	_items_label = UiStyle.label("", 28, Color.WHITE)
	_items_label.position = Vector2(560, 24)
	ui.add_child(_items_label)

	var extras := VBoxContainer.new()
	extras.position = Vector2(1070, 76)
	extras.add_theme_constant_override("separation", 10)
	ui.add_child(extras)
	for entry in [["Album", Color("3fa9f5"), "album"], ["Obchůdek", Color("ff5fa2"), "shop"], ["Zahrádka", Color("7cb342"), "garden"], ["Nový koník", Color("e8742a"), "adopt"]]:
		var button := UiStyle.big_button(entry[0], entry[1], Vector2(190, 56))
		button.add_theme_font_size_override("font_size", 24)
		var scene_path: String = "res://scenes/%s.tscn" % entry[2]
		button.pressed.connect(func(): get_tree().change_scene_to_file(scene_path))
		extras.add_child(button)

	_hint = UiStyle.label("", 28, Color("4a2c1a"))
	_hint.position = Vector2(420, 230)
	ui.add_child(_hint)

	var buttons := HBoxContainer.new()
	buttons.position = Vector2(40, 610)
	buttons.add_theme_constant_override("separation", 22)
	ui.add_child(buttons)

	var hay := UiStyle.big_button("Seno", Color("e0a526"))
	hay.pressed.connect(func():
		var poops_before := GameState.poops
		GameState.feed()
		Audio.play("eat")
		pony.love()
		if GameState.poops > poops_before:
			_say("Mňam! ...a pak udělal koblížek. Ukliď ho ťuknutím!")
			get_tree().create_timer(0.7).timeout.connect(func(): Audio.play("plop"))
		else:
			_say("Mňam!"))
	buttons.add_child(hay)

	var water := UiStyle.big_button("Voda", Color("3fa9f5"))
	water.pressed.connect(func():
		GameState.give_water()
		Audio.play("water")
		_say("Glo glo glo"))
	buttons.add_child(water)

	_carrot_button = UiStyle.big_button("Mrkev", Color("f07c1e"))
	_carrot_button.pressed.connect(func():
		if GameState.feed_carrot():
			Audio.play("eat")
			Audio.play("neigh")
			pony.love()
			_say("Mrkvička ze zahrádky! To je dobrota!"))
	buttons.add_child(_carrot_button)

	_brush_button = UiStyle.big_button("Kartáč", Color("c06fd8"))
	_brush_button.toggle_mode = true
	_brush_button.toggled.connect(func(on):
		brushing = on
		_say("Hlaď koníka prstem" if on else ""))
	buttons.add_child(_brush_button)

	var walk := UiStyle.big_button("Na procházku", Color("5cb85c"), Vector2(300, 90))
	walk.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/world_map.tscn"))
	buttons.add_child(walk)


func _refresh() -> void:
	for need in _bars:
		_bars[need].value = GameState.needs[need]
	pony.mood = GameState.happiness()
	var inv := GameState.inventory
	_items_label.text = "Jablka %d  Kytky %d  Podkovy %d  Mrkve %d  ★ %d" % [inv.apple, inv.flower, inv.horseshoe, inv.get("carrot", 0), GameState.stars]
	_name_label.text = GameState.pony_name
	_switch.visible = GameState.ponies.size() > 1
	_carrot_button.visible = inv.get("carrot", 0) > 0
	queue_redraw()


func _say(text: String) -> void:
	_hint.text = text
	if text != "":
		UiStyle.bounce(_hint)


func _unhandled_input(event: InputEvent) -> void:
	var pos: Vector2
	if event is InputEventScreenTouch and event.pressed:
		pos = event.position
		if not brushing and pos.distance_to(pony.position + Vector2(20, -60)) < 110:
			pony.love()
			Audio.play("neigh")
			_say("%s se raduje!" % GameState.pony_name)
			return
		_try_clean(pos)
	elif event is InputEventScreenDrag:
		pos = event.position
		if brushing and pos.distance_to(pony.position + Vector2(0, -20)) < 140:
			GameState.brush(0.6)
			_sparkles.append([pos, 0.6])
			_brush_sound -= 1
			if _brush_sound <= 0:
				_brush_sound = 12
				Audio.play("brush", 0.2)
		_try_clean(pos)


func _try_clean(pos: Vector2) -> void:
	for i in GameState.poops:
		if pos.distance_to(POOP_SPOTS[i]) < 45:
			GameState.clean_poop()
			Audio.play("pickup")
			_sparkles.append([POOP_SPOTS[GameState.poops], 0.8])
			_say("Uklizeno! Hnůj půjde na zahrádku." if GameState.poops == 0 else "Uklizeno!")
			return


func _process(delta: float) -> void:
	for s in _sparkles:
		s[1] -= delta
	_sparkles = _sparkles.filter(func(s): return s[1] > 0.0)
	queue_redraw()


func _draw() -> void:
	var size := get_viewport_rect().size
	# Dřevěná stěna
	draw_rect(Rect2(0, 0, size.x, 520), Color("b5774a"))
	for x in range(0, int(size.x), 80):
		draw_line(Vector2(x, 0), Vector2(x, 520), Color("9a6038"), 4)
	# Okno s oblohou
	draw_rect(Rect2(820, 130, 220, 160), Color("8fd3ff"))
	draw_circle(Vector2(990, 170), 25, Color("ffe066"))
	draw_rect(Rect2(820, 130, 220, 160), Color("6b3f22"), false, 10)
	draw_line(Vector2(930, 130), Vector2(930, 290), Color("6b3f22"), 8)
	if GameState.wears("window_flowers"):
		draw_rect(Rect2(810, 290, 240, 30), Color("8a5a35"))
		for i in 7:
			var f := Vector2(830 + i * 33, 282)
			draw_line(f, f + Vector2(0, 12), Color("3c9a3c"), 4)
			draw_circle(f, 11, [Color("ff7fc4"), Color("ffe066"), Color("ff5f5f")][i % 3])
	if GameState.wears("lantern"):
		var glow := 0.75 + 0.25 * sin(Time.get_ticks_msec() / 300.0)
		draw_circle(Vector2(560, 190), 70, Color(1, 0.85, 0.4, 0.18 * glow))
		draw_line(Vector2(560, 110), Vector2(560, 165), Color("4a2c1a"), 4)
		draw_rect(Rect2(542, 165, 36, 50), Color("ffd966"))
		draw_rect(Rect2(542, 165, 36, 50), Color("4a2c1a"), false, 4)
	if GameState.wears("crystal"):
		var hue := fmod(Time.get_ticks_msec() / 3000.0, 1.0)
		var c := Color.from_hsv(hue, 0.45, 1.0)
		draw_circle(Vector2(1180, 470), 50, Color(c, 0.25))
		draw_colored_polygon(PackedVector2Array([Vector2(1180, 420), Vector2(1205, 465), Vector2(1180, 500), Vector2(1155, 465)]), c)
	if GameState.wears("lucky_shoe"):
		draw_arc(Vector2(640, 150), 34, 0.2, PI - 0.2, 16, Color("c9a227"), 14)
	# Sláma na podlaze
	draw_rect(Rect2(0, 500, size.x, size.y - 500), Color("f2cf6b"))
	for i in 60:
		var x := float((i * 97) % int(size.x))
		var y := 510.0 + float((i * 53) % 200)
		draw_line(Vector2(x, y), Vector2(x + 25, y - 6), Color("d9ae42"), 3)
	# Žlab a kýbl
	draw_rect(Rect2(140, 400, 160, 70), Color("8a5a35"))
	draw_rect(Rect2(150, 390, 140, 20), Color("e0a526").lerp(Color("8a5a35"), 1.0 - GameState.needs.hunger / 100.0))
	draw_rect(Rect2(1010, 400, 90, 90), Color("7d8b99"))
	draw_rect(Rect2(1018, 408, 74, 20), Color("3fa9f5").lerp(Color("7d8b99"), 1.0 - GameState.needs.thirst / 100.0))
	# Koblížky
	for i in GameState.poops:
		var p: Vector2 = POOP_SPOTS[i]
		draw_circle(p + Vector2(0, 6), 20, Color("6b4423"))
		draw_circle(p + Vector2(0, -8), 14, Color("7a5030"))
		draw_circle(p + Vector2(0, -20), 8, Color("8a5c38"))
	# Třpytky po česání
	for s in _sparkles:
		draw_circle(s[0], 10.0 * s[1], Color(1, 1, 0.6, s[1]))
