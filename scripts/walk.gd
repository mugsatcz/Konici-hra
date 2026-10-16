extends Node2D
## Procházka s pohledem shora: louka, lesík a potůček s mostkem.
## Dítě koníka vede (pomaleji, přes potůček jen po mostku) nebo na něm jede.

const PonyArt := preload("res://scripts/pony/pony_art.gd")
const WORLD := Rect2(0, 0, 3000, 2000)
const STREAM_X := 1600.0
const STREAM_HALF_WIDTH := 70.0
const BRIDGE := Rect2(1500, 900, 200, 160)
const LEAD_SPEED := 220.0
const RIDE_SPEED := 420.0
const ITEM_NAMES := {"apple": "jablko", "flower": "kytičku", "horseshoe": "podkovu"}

var pony: Node2D
var riding := false
var target := Vector2.ZERO
var moving := false
var trees: Array[Vector2] = []
var items: Array = []  # [pozice, druh]
var _camera: Camera2D
var _hint: Label
var _ride_button: Button
var _drink_button: Button
var _found := 0


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	# Lesík nahoře vlevo a vpravo dole, louka uprostřed.
	for i in 70:
		var p := Vector2(rng.randf_range(100, 1300), rng.randf_range(80, 700))
		if i >= 35:
			p = Vector2(rng.randf_range(1900, 2900), rng.randf_range(1200, 1900))
		trees.append(p)
	var kinds := ["apple", "apple", "flower", "flower", "horseshoe"]
	for i in 25:
		var p := Vector2(rng.randf_range(150, 2850), rng.randf_range(150, 1850))
		if absf(p.x - STREAM_X) > STREAM_HALF_WIDTH + 30:
			items.append([p, kinds[i % kinds.size()]])

	pony = PonyArt.new()
	pony.position = Vector2(500, 1200)
	pony.scale = Vector2(0.8, 0.8)
	add_child(pony)
	target = pony.position

	_camera = Camera2D.new()
	_camera.limit_left = int(WORLD.position.x)
	_camera.limit_top = int(WORLD.position.y)
	_camera.limit_right = int(WORLD.end.x)
	_camera.limit_bottom = int(WORLD.end.y)
	_camera.position_smoothing_enabled = true
	pony.add_child(_camera)
	_build_ui()


func _build_ui() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)
	_hint = UiStyle.label("Ťukni, kam má koník jít", 30, Color.WHITE)
	_hint.add_theme_color_override("font_outline_color", Color("2f6b2a"))
	_hint.add_theme_constant_override("outline_size", 10)
	_hint.position = Vector2(24, 20)
	ui.add_child(_hint)

	var buttons := HBoxContainer.new()
	buttons.position = Vector2(24, 610)
	buttons.add_theme_constant_override("separation", 22)
	ui.add_child(buttons)

	_ride_button = UiStyle.big_button("Nasednout", Color("d9534f"), Vector2(230, 90))
	_ride_button.pressed.connect(_toggle_ride)
	buttons.add_child(_ride_button)

	_drink_button = UiStyle.big_button("Napít se", Color("3fa9f5"), Vector2(210, 90))
	_drink_button.pressed.connect(func():
		GameState.give_water(50.0)
		_say("Voda z potůčku je nejlepší!"))
	buttons.add_child(_drink_button)

	var home := UiStyle.big_button("Domů", Color("5cb85c"))
	home.pressed.connect(func():
		GameState.after_walk()
		get_tree().change_scene_to_file("res://scenes/stable.tscn"))
	buttons.add_child(home)


func _toggle_ride() -> void:
	riding = not riding
	pony.rider = riding
	_ride_button.text = "Sesednout" if riding else "Nasednout"
	_say("Hop, jedeme! Teď přebrodíš i potůček." if riding else "Vedeš koníka. Přes potůček jen po mostku.")


func _say(text: String) -> void:
	_hint.text = text
	UiStyle.bounce(_hint)


func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventScreenTouch and event.pressed) or event is InputEventScreenDrag:
		target = get_canvas_transform().affine_inverse() * event.position
		moving = true


func _in_stream(p: Vector2) -> bool:
	return absf(p.x - STREAM_X) < STREAM_HALF_WIDTH and not BRIDGE.has_point(p)


func _process(delta: float) -> void:
	_drink_button.visible = absf(pony.position.x - STREAM_X) < STREAM_HALF_WIDTH + 90
	if moving:
		var to_target := target - pony.position
		if to_target.length() < 8.0:
			moving = false
		else:
			var speed := RIDE_SPEED if riding else LEAD_SPEED
			var next := pony.position + to_target.normalized() * minf(speed * delta, to_target.length())
			next = next.clamp(WORLD.position + Vector2(60, 60), WORLD.end - Vector2(60, 60))
			if _in_stream(next) and not riding:
				moving = false
				_say("Vedeného koníka přes vodu nepřevedeš. Najdi mostek, nebo nasedni!")
			else:
				if absf(to_target.x) > 2.0:
					pony.facing = signf(to_target.x)
				pony.position = next
	_pick_items()
	queue_redraw()


func _pick_items() -> void:
	for item in items.duplicate():
		if pony.position.distance_to(item[0]) < 60:
			items.erase(item)
			GameState.add_item(item[1])
			_found += 1
			_say("Našel jsi %s! (%d)" % [ITEM_NAMES[item[1]], _found])


func _draw() -> void:
	# Louka
	draw_rect(WORLD, Color("7ccf63"))
	for i in 220:
		var p := Vector2(float((i * 137) % 3000), float((i * 89) % 2000))
		draw_circle(p, 18, Color("6fc057"))
	# Cestička
	draw_polyline(PackedVector2Array([Vector2(300, 1250), Vector2(900, 1100), Vector2(1600, 980), Vector2(2300, 900), Vector2(2900, 700)]), Color("e8c27a"), 60)
	# Potůček s kamínky
	draw_rect(Rect2(STREAM_X - STREAM_HALF_WIDTH, 0, STREAM_HALF_WIDTH * 2, WORLD.size.y), Color("4fb3e8"))
	for y in range(40, 2000, 140):
		draw_line(Vector2(STREAM_X - 30, y), Vector2(STREAM_X + 10, y + 30), Color("b8e6ff"), 6)
		draw_circle(Vector2(STREAM_X - STREAM_HALF_WIDTH, y + 70), 14, Color("a0a8b0"))
		draw_circle(Vector2(STREAM_X + STREAM_HALF_WIDTH, y + 20), 12, Color("a0a8b0"))
	# Mostek
	draw_rect(BRIDGE, Color("a86a3c"))
	for x in range(int(BRIDGE.position.x), int(BRIDGE.end.x), 25):
		draw_line(Vector2(x, BRIDGE.position.y), Vector2(x, BRIDGE.end.y), Color("7d4b29"), 3)
	draw_rect(Rect2(BRIDGE.position, Vector2(BRIDGE.size.x, 12)), Color("6b3f22"))
	draw_rect(Rect2(BRIDGE.position + Vector2(0, BRIDGE.size.y - 12), Vector2(BRIDGE.size.x, 12)), Color("6b3f22"))
	# Sbírací věci
	for item in items:
		var p: Vector2 = item[0]
		match item[1]:
			"apple":
				draw_circle(p, 16, Color("e0413a"))
				draw_line(p + Vector2(0, -14), p + Vector2(4, -24), Color("6b3f22"), 3)
			"flower":
				for a in 5:
					draw_circle(p + Vector2.from_angle(a * TAU / 5) * 12, 9, Color("ff7fc4"))
				draw_circle(p, 8, Color("ffe066"))
			"horseshoe":
				draw_arc(p, 16, 0.3, PI - 0.3 + PI, 12, Color("9aa5b1"), 8)
	# Stromy (kmen a koruna); jednoduché, bez řazení podle výšky
	for t in trees:
		draw_rect(Rect2(t + Vector2(-10, 10), Vector2(20, 40)), Color("7a4b2a"))
		draw_circle(t, 55, Color("2f9e44"))
		draw_circle(t + Vector2(-20, -15), 35, Color("40b856"))
	# Cíl ťuknutí
	if moving:
		draw_arc(target, 22, 0, TAU, 20, Color(1, 1, 1, 0.8), 4)
