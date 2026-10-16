extends Node2D
## Procházka s pohledem shora. Podoba místa se bere z WorldData.AREAS.
## Dítě koníka vede (jde vedle něj, přes potůček jen po mostku) nebo na něm jede.

const PonyArt := preload("res://scripts/pony/pony_art.gd")
const KidArt := preload("res://scripts/kid_art.gd")
const AnimalArt := preload("res://scripts/animal_art.gd")
const WORLD := Rect2(0, 0, 3000, 2000)
const STREAM_X := 1600.0
const STREAM_HALF_WIDTH := 70.0
const BRIDGE := Rect2(1500, 900, 200, 160)
const POND_CENTER := Vector2(1500, 1000)
const POND_RADII := Vector2(450, 280)
const LEAD_SPEED := 220.0
const RIDE_SPEED := 420.0
const ITEM_NAMES := {"apple": "jablko", "flower": "kytička", "horseshoe": "podkova"}

var area_id := "louka"
var area: Dictionary
var pony: Node2D
var kid: Node2D
var riding := false
var target := Vector2.ZERO
var moving := false
var trees: Array[Vector2] = []
var items: Array = []  # [pozice, druh]
var animals: Array[Node2D] = []
var _camera: Camera2D
var _hint: Label
var _ride_button: Button
var _drink_button: Button
var _found := 0
var _celebrate := 0.0


func _ready() -> void:
	area_id = GameState.current_area
	area = WorldData.AREAS[area_id]
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(area_id) + GameState.walks
	_place_trees(rng)
	for i in 25:
		var p := _free_spot(rng)
		items.append([p, area.items[i % area.items.size()]])

	pony = PonyArt.new()
	pony.position = Vector2(400, 1300)
	pony.scale = Vector2(0.8, 0.8)
	add_child(pony)
	target = pony.position

	for kind in area.animals:
		for n in 2:
			var animal := AnimalArt.new()
			animal.kind = kind
			animal.position = _free_spot(rng)
			add_child(animal)
			animals.append(animal)

	kid = KidArt.new()
	kid.scale = Vector2(0.9, 0.9)
	add_child(kid)
	kid.position = _kid_spot()

	_camera = Camera2D.new()
	_camera.limit_left = int(WORLD.position.x)
	_camera.limit_top = int(WORLD.position.y)
	_camera.limit_right = int(WORLD.end.x)
	_camera.limit_bottom = int(WORLD.end.y)
	_camera.position_smoothing_enabled = true
	pony.add_child(_camera)
	_build_ui()
	if GameState.discover("misto_" + area_id):
		_say("Nové místo: %s!" % area.name)
	else:
		_say(area.name)


func _place_trees(rng: RandomNumberGenerator) -> void:
	for i in area.trees:
		var p := Vector2(rng.randf_range(80, 2920), rng.randf_range(80, 1920))
		# Na start a do vody stromy nedáváme.
		if p.distance_to(Vector2(400, 1300)) < 250 or _in_water(p, 60.0):
			continue
		# Na louce jsou stromy v lesíkách v rozích, ne uprostřed.
		if area_id != "lesik" and p.x > 900 and p.x < 2100:
			continue
		trees.append(p)


func _free_spot(rng: RandomNumberGenerator) -> Vector2:
	for attempt in 30:
		var p := Vector2(rng.randf_range(150, 2850), rng.randf_range(150, 1850))
		if not _in_water(p, 40.0):
			return p
	return Vector2(600, 1300)


func _build_ui() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)
	_hint = UiStyle.label("", 30, Color.WHITE)
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
		_say("Čerstvá voda je nejlepší!"))
	buttons.add_child(_drink_button)

	var map := UiStyle.big_button("Mapa", Color("e0a526"))
	map.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/world_map.tscn"))
	buttons.add_child(map)

	var home := UiStyle.big_button("Domů", Color("5cb85c"))
	home.pressed.connect(func():
		GameState.after_walk()
		get_tree().change_scene_to_file("res://scenes/stable.tscn"))
	buttons.add_child(home)


func _toggle_ride() -> void:
	riding = not riding
	pony.rider = riding
	kid.visible = not riding
	if not riding:
		kid.position = _kid_spot()
	_ride_button.text = "Sesednout" if riding else "Nasednout"
	if area.water == "stream":
		_say("Hop, jedeme! Teď přebrodíš i potůček." if riding else "Vedeš koníka. Přes potůček jen po mostku.")
	else:
		_say("Hop, jedeme!" if riding else "Vedeš koníka.")


func _say(text: String) -> void:
	_hint.text = text
	UiStyle.bounce(_hint)


func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventScreenTouch and event.pressed) or event is InputEventScreenDrag:
		target = get_canvas_transform().affine_inverse() * event.position
		moving = true


func _in_stream(p: Vector2, margin := 0.0) -> bool:
	return area.water == "stream" and absf(p.x - STREAM_X) < STREAM_HALF_WIDTH + margin and not BRIDGE.has_point(p)


func _in_pond(p: Vector2, margin := 0.0) -> bool:
	if area.water != "pond":
		return false
	var d := (p - POND_CENTER) / (POND_RADII + Vector2(margin, margin))
	return d.length() < 1.0


func _in_water(p: Vector2, margin := 0.0) -> bool:
	return _in_stream(p, margin) or _in_pond(p, margin)


func _process(delta: float) -> void:
	_drink_button.visible = _in_water(pony.position, 90.0)
	if moving:
		var to_target := target - pony.position
		if to_target.length() < 8.0:
			moving = false
		else:
			var speed := RIDE_SPEED if riding else LEAD_SPEED
			var next := pony.position + to_target.normalized() * minf(speed * delta, to_target.length())
			next = next.clamp(WORLD.position + Vector2(60, 60), WORLD.end - Vector2(60, 60))
			if _in_pond(next):
				moving = false
				_say("Do rybníčka nelez, napij se z kraje!")
			elif _in_stream(next) and not riding:
				moving = false
				_say("Vedeného koníka přes vodu nepřevedeš. Najdi mostek, nebo nasedni!")
			else:
				if absf(to_target.x) > 2.0:
					pony.facing = signf(to_target.x)
				pony.position = next
	_update_kid(delta)
	_pick_items()
	_meet_animals()
	_celebrate = maxf(0.0, _celebrate - delta)
	queue_redraw()


## Dítě jde vedle koníka, u jeho ramene, s vodítkem u hlavy.
func _kid_spot() -> Vector2:
	return pony.position + Vector2(pony.facing * 45.0, 48.0)


func _update_kid(delta: float) -> void:
	if riding:
		return
	var spot := _kid_spot()
	var before := kid.position
	kid.position = kid.position.lerp(spot, minf(1.0, delta * 8.0))
	kid.walking = moving or before.distance_to(kid.position) > 0.5
	kid.facing = pony.facing
	kid.rope_target = pony.position + Vector2(pony.facing * 70.0, -30.0)


func _pick_items() -> void:
	for item in items.duplicate():
		if pony.position.distance_to(item[0]) < 60:
			items.erase(item)
			GameState.add_item(item[1])
			_found += 1
			_say("Hurá, %s! (%d)" % [ITEM_NAMES[item[1]], _found])


func _meet_animals() -> void:
	for animal in animals:
		if pony.position.distance_to(animal.position) < 130 and GameState.discover(animal.kind):
			_celebrate = 1.5
			_say("Nový kamarád: %s! Je zapsaný v albu." % WorldData.ANIMALS[animal.kind])


func _draw() -> void:
	var ground: Color = area.ground
	draw_rect(WORLD, ground)
	for i in 220:
		var p := Vector2(float((i * 137) % 3000), float((i * 89) % 2000))
		draw_circle(p, 18, ground.darkened(0.08))
	# Cestička
	var path := [Vector2(300, 1350), Vector2(900, 1150), Vector2(1600, 980), Vector2(2300, 900), Vector2(2900, 700)]
	if area.water == "pond":
		path = [Vector2(300, 1350), Vector2(1000, 1500), Vector2(2000, 1500), Vector2(2900, 1200)]
	draw_polyline(PackedVector2Array(path), Color("e8c27a"), 60)
	if area.water == "stream":
		_draw_stream()
	elif area.water == "pond":
		_draw_pond()
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
	# Stromy
	for t in trees:
		if area.birch:
			draw_rect(Rect2(t + Vector2(-8, 0), Vector2(16, 50)), Color("f4f1ea"))
			draw_line(t + Vector2(-8, 18), t + Vector2(2, 18), Color("333333"), 3)
			draw_line(t + Vector2(0, 34), t + Vector2(8, 34), Color("333333"), 3)
			draw_circle(t, 45, Color("8fd14f"))
			draw_circle(t + Vector2(-18, -14), 28, Color("a6de62"))
		else:
			draw_rect(Rect2(t + Vector2(-10, 10), Vector2(20, 40)), Color("7a4b2a"))
			draw_circle(t, 55, Color("2f9e44"))
			draw_circle(t + Vector2(-20, -15), 35, Color("40b856"))
	if moving:
		draw_arc(target, 22, 0, TAU, 20, Color(1, 1, 1, 0.8), 4)
	# Hvězdičky při novém objevu
	if _celebrate > 0.0:
		for i in 8:
			var a := i * TAU / 8.0 + _celebrate
			draw_circle(pony.position + Vector2.from_angle(a) * (160.0 - _celebrate * 60.0), 8, Color(1, 0.9, 0.3, _celebrate / 1.5))


func _draw_stream() -> void:
	draw_rect(Rect2(STREAM_X - STREAM_HALF_WIDTH, 0, STREAM_HALF_WIDTH * 2, WORLD.size.y), Color("4fb3e8"))
	for y in range(40, 2000, 140):
		draw_line(Vector2(STREAM_X - 30, y), Vector2(STREAM_X + 10, y + 30), Color("b8e6ff"), 6)
		draw_circle(Vector2(STREAM_X - STREAM_HALF_WIDTH, y + 70), 14, Color("a0a8b0"))
		draw_circle(Vector2(STREAM_X + STREAM_HALF_WIDTH, y + 20), 12, Color("a0a8b0"))
	draw_rect(BRIDGE, Color("a86a3c"))
	for x in range(int(BRIDGE.position.x), int(BRIDGE.end.x), 25):
		draw_line(Vector2(x, BRIDGE.position.y), Vector2(x, BRIDGE.end.y), Color("7d4b29"), 3)
	draw_rect(Rect2(BRIDGE.position, Vector2(BRIDGE.size.x, 12)), Color("6b3f22"))
	draw_rect(Rect2(BRIDGE.position + Vector2(0, BRIDGE.size.y - 12), Vector2(BRIDGE.size.x, 12)), Color("6b3f22"))


func _draw_pond() -> void:
	draw_set_transform(POND_CENTER, 0, POND_RADII / POND_RADII.x)
	draw_circle(Vector2.ZERO, POND_RADII.x + 25, Color("d9c48a"))
	draw_circle(Vector2.ZERO, POND_RADII.x, Color("4fb3e8"))
	draw_circle(Vector2(-80, -40), POND_RADII.x * 0.6, Color("6cc3ee"))
	draw_set_transform(Vector2.ZERO)
	for p in [Vector2(1250, 950), Vector2(1700, 1100), Vector2(1550, 850)]:
		draw_circle(p, 26, Color("3c9a3c"))
		draw_circle(p + Vector2(8, -6), 7, Color("ff9ccf"))
	for x in range(1080, 1940, 60):
		var y := POND_CENTER.y + POND_RADII.y + 10.0
		draw_line(Vector2(x, y), Vector2(x - 6, y - 40), Color("5a8f3a"), 5)
		draw_rect(Rect2(x - 10, y - 55, 8, 18), Color("7a4b2a"))
