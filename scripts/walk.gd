extends Node2D
## Procházka s pohledem shora. Podoba místa se bere z WorldData.AREAS.
## Dítě koníka vede (jde vedle něj, přes potůček jen po mostku) nebo na něm jede.
## Po cestě: sbírání věcí, keříky s překvapením, zvířátka, ukrytý poklad a úkol.

const PonyArt := preload("res://scripts/pony/pony_art.gd")
const KidArt := preload("res://scripts/kid_art.gd")
const AnimalArt := preload("res://scripts/animal_art.gd")
const Ambient := preload("res://scripts/walk_ambient.gd")
const Painter := preload("res://scripts/painter.gd")
const MeshBuilder := preload("res://scripts/mesh_builder.gd")
const WORLD := Rect2(0, 0, 3000, 2000)
const CHUNK := Vector2(600, 500)
const START := Vector2(400, 1300)
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
var bushes: Array = []  # {pos, content, searched, shake, layer}
var animals: Array[Node2D] = []
var quest: WalkQuest
var ambient: Node2D
var treasure_found := false
var _camera: Camera2D
var _hint: Label
var _quest_label: Label
var _ride_button: Button
var _drink_button: Button
var _found := 0
var _celebrate := 0.0
var _was_in_stream := false
var _idle := 0.0
var _popups: Array = []  # [pozice, text, barva, zbývá]
var _items_layer: MeshInstance2D
var _treasure_layer: MeshInstance2D
var _fx_layer: Node2D


func _ready() -> void:
	area_id = GameState.current_area
	area = WorldData.AREAS[area_id]
	treasure_found = GameState.discovered.has("poklad_" + area_id)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(area_id) + GameState.walks * 7919
	_place_trees(rng)
	for i in 25:
		items.append([_free_spot(rng), area.items[i % area.items.size()]])
	for i in area.bushes:
		var roll := rng.randf()
		var content := "item" if roll < 0.45 else ("animal" if roll < 0.7 else ("butterfly" if roll < 0.85 else "nothing"))
		bushes.append({"pos": _free_spot(rng), "content": content, "searched": false, "shake": 0.0, "layer": null})
	_build_world()

	pony = PonyArt.new()
	pony.position = START
	pony.scale = Vector2(0.8, 0.8)
	add_child(pony)
	target = pony.position

	for kind in area.animals:
		for n in (1 if kind == "jednorozec" else 2):
			_spawn_animal(kind, _free_spot(rng))

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

	var layer := CanvasLayer.new()
	layer.layer = 1
	layer.follow_viewport_enabled = true
	add_child(layer)
	ambient = Ambient.new()
	layer.add_child(ambient)
	var tint := CanvasModulate.new()
	tint.color = ambient.setup(self, area_id, rng)
	add_child(tint)
	ambient.moment.connect(_on_moment)

	quest = WalkQuest.create(area_id, rng)
	_build_ui()
	Audio.music(area.music)
	if GameState.discover("misto_" + area_id):
		Audio.play("discover", 0.0)
		_say("Nové místo: %s!" % area.name)
	else:
		_say("%s – %s" % [area.name, ambient.greeting()])


func _spawn_animal(kind: String, pos: Vector2) -> Node2D:
	var animal := AnimalArt.new()
	animal.kind = kind
	animal.position = pos
	add_child(animal)
	# Zvířátko mimo obrazovku se nehýbe ani nepřekresluje.
	animal.set_process(false)
	var on_screen := VisibleOnScreenNotifier2D.new()
	on_screen.rect = Rect2(-80, -110, 160, 160)
	on_screen.screen_entered.connect(func(): animal.set_process(true))
	on_screen.screen_exited.connect(func(): animal.set_process(false))
	animal.add_child(on_screen)
	animals.append(animal)
	return animal


func _place_trees(rng: RandomNumberGenerator) -> void:
	var treasure_pos: Vector2 = WorldData.TREASURES[area_id].pos
	for i in area.trees:
		var p := Vector2(rng.randf_range(80, 2920), rng.randf_range(80, 1920))
		if p.distance_to(START) < 250 or p.distance_to(treasure_pos) < 120 or _in_water(p, 60.0):
			continue
		# Mimo les jsou stromy v hájcích po stranách, uprostřed je volná louka.
		if area.tree_style == "oak" and p.x > 900 and p.x < 2100:
			continue
		trees.append(p)


func _free_spot(rng: RandomNumberGenerator) -> Vector2:
	for attempt in 30:
		var p := Vector2(rng.randf_range(150, 2850), rng.randf_range(150, 1850))
		if not _in_water(p, 40.0):
			return p
	return START + Vector2(200, 0)


func _build_ui() -> void:
	var ui := CanvasLayer.new()
	ui.layer = 2
	add_child(ui)
	_hint = UiStyle.label("", 30, Color.WHITE)
	_hint.add_theme_color_override("font_outline_color", Color("2f6b2a"))
	_hint.add_theme_constant_override("outline_size", 10)
	_hint.position = Vector2(24, 20)
	ui.add_child(_hint)

	var quest_box := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1, 0.98, 0.9, 0.9)
	style.set_corner_radius_all(18)
	style.set_content_margin_all(12)
	style.border_color = Color("e0a526")
	style.set_border_width_all(3)
	quest_box.add_theme_stylebox_override("panel", style)
	quest_box.position = Vector2(24, 70)
	ui.add_child(quest_box)
	_quest_label = UiStyle.label("", 22, Color("4a2c1a"))
	_quest_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_quest_label.custom_minimum_size = Vector2(420, 0)
	quest_box.add_child(_quest_label)
	_update_quest_label()

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
		Audio.play("water")
		pony.love()
		_quest_event("drink")
		_say("Čerstvá voda je nejlepší!"))
	buttons.add_child(_drink_button)

	var map := UiStyle.big_button("Mapa", Color("e0a526"))
	map.pressed.connect(func(): Scenes.go("res://scenes/world_map.tscn"))
	buttons.add_child(map)

	var home := UiStyle.big_button("Domů", Color("5cb85c"))
	home.pressed.connect(func():
		GameState.after_walk()
		Scenes.go("res://scenes/stable.tscn"))
	buttons.add_child(home)


func _update_quest_label() -> void:
	_quest_label.text = "Úkol: " + quest.status_text()


func _quest_event(kind: String, detail := "") -> void:
	if quest.record(kind, detail):
		GameState.add_star()
		GameState.add_item("horseshoe", 2)
		_popup(pony.position + Vector2(0, -120), "★ +1  podkovy +2", Color("ffd84d"))
		Audio.play("quest", 0.0)
		_celebrate = 2.0
		_say("Úkol splněn! Máš hvězdu a 2 podkovy.")
	_update_quest_label()


func _toggle_ride() -> void:
	riding = not riding
	pony.rider = riding
	kid.visible = not riding
	if not riding:
		kid.position = _kid_spot()
	Audio.play("neigh")
	_ride_button.text = "Sesednout" if riding else "Nasednout"
	if area.water == "stream":
		_say("Hop, jedeme! Teď přebrodíš i potůček." if riding else "Vedeš koníka. Přes potůček jen po mostku.")
	else:
		_say("Hop, jedeme!" if riding else "Vedeš koníka.")


func _say(text: String) -> void:
	_hint.text = text
	UiStyle.bounce(_hint)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		var world_pos: Vector2 = get_canvas_transform().affine_inverse() * event.position
		if _tap_something(world_pos):
			return
		target = world_pos
		moving = true
	elif event is InputEventScreenDrag:
		target = get_canvas_transform().affine_inverse() * event.position
		moving = true


## Ťuknutí na koníka, zvířátko nebo keřík. Vrací true, když se něco stalo.
func _tap_something(pos: Vector2) -> bool:
	if pos.distance_to(pony.position + Vector2(0, -30)) < 70:
		pony.love()
		Audio.play("neigh")
		_say("Koník tě má rád!")
		return true
	for animal in animals:
		if pos.distance_to(animal.position) < 60:
			animal.react()
			Audio.play("boing")
			_say(WorldData.ANIMAL_FACTS[animal.kind])
			if GameState.discover(animal.kind):
				_new_friend(animal.kind)
			if not animal.has_meta("petted"):
				animal.set_meta("petted", true)
				_quest_event("pet")
			return true
	for bush in bushes:
		if pos.distance_to(bush.pos) < 60:
			if pony.position.distance_to(bush.pos) > 260:
				target = bush.pos + Vector2(-90 if pony.position.x < bush.pos.x else 90, 0)
				moving = true
				_say("Dojdi blíž ke keříku!")
			else:
				_search_bush(bush)
			return true
	return false


func _search_bush(bush: Dictionary) -> void:
	bush.shake = 0.6
	Audio.play("rustle")
	if bush.searched:
		_say("Tenhle keřík už je prozkoumaný.")
		return
	bush.searched = true
	_rebuild(bush.layer)
	_quest_event("bushes")
	match bush.content:
		"item":
			var item: String = ["apple", "flower", "horseshoe"][randi() % 3]
			GameState.add_item(item)
			Audio.play("pickup")
			_popup(bush.pos + Vector2(0, -40), "+1 " + ITEM_NAMES[item], Color("fff3a0"))
			_say("V keříku bylo schované: %s!" % ITEM_NAMES[item])
		"animal":
			var kind: String = area.animals[randi() % area.animals.size()]
			var animal := _spawn_animal(kind, bush.pos + Vector2(0, 40))
			animal.react()
			_say("Kuk! Z keříku vykukuje: %s." % WorldData.ANIMALS[kind])
			if GameState.discover(kind):
				_new_friend(kind)
		"butterfly":
			_spawn_animal("motyl", bush.pos + Vector2(20, -40))
			_say("Z keříku vyletěl motýlek!")
			if GameState.discover("motyl"):
				_new_friend("motyl")
		_:
			_say("Jen lístky a šustění. Zkus jiný keřík!")


func _new_friend(kind: String) -> void:
	_celebrate = 1.5
	Audio.play("discover", 0.0)
	_say("Nový kamarád: %s! Je zapsaný v albu." % WorldData.ANIMALS[kind])
	_quest_event("meet", kind)


func _on_moment(id: String) -> void:
	if GameState.discover("zazitek_" + id):
		_celebrate = 1.0


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
		_idle = 0.0
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
	else:
		_idle += delta
		if _idle > 8.0:
			_idle = 0.0
			Audio.play("neigh", 0.15)
	pony.walking = moving
	var in_stream := _in_stream(pony.position)
	if in_stream and not _was_in_stream:
		Audio.play("splash")
	if _was_in_stream and not in_stream and riding:
		_quest_event("ford")
		if GameState.discover("zazitek_brod"):
			_celebrate = 1.0
	_was_in_stream = in_stream
	_update_kid(delta)
	_pick_items()
	_meet_animals()
	_check_treasure()
	for bush in bushes:
		if bush.shake > 0.0:
			bush.shake = maxf(0.0, bush.shake - delta)
			bush.layer.position.x = sin(bush.shake * 40.0) * bush.shake * 10.0
	_celebrate = maxf(0.0, _celebrate - delta)
	for p in _popups:
		p[3] -= delta
		p[0] += Vector2(0, -50) * delta
	_popups = _popups.filter(func(p): return p[3] > 0.0)
	_fx_layer.queue_redraw()


func _popup(pos: Vector2, text: String, color: Color) -> void:
	_popups.append([pos, text, color, 1.4])


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
	kid.rope_target = pony.position + Vector2(pony.facing * 78.0, -50.0)


func _pick_items() -> void:
	for item in items.duplicate():
		if pony.position.distance_to(item[0]) < 60:
			items.erase(item)
			_rebuild(_items_layer)
			GameState.add_item(item[1])
			Audio.play("pickup")
			_popup(item[0], "+1 " + ITEM_NAMES[item[1]], Color("fff3a0"))
			_found += 1
			_say("Hurá, %s! (%d)" % [ITEM_NAMES[item[1]], _found])
			_quest_event("collect", item[1])


func _meet_animals() -> void:
	for animal in animals:
		if pony.position.distance_to(animal.position) < 130 and GameState.discover(animal.kind):
			animal.react()
			_new_friend(animal.kind)


func _check_treasure() -> void:
	if treasure_found:
		return
	var info: Dictionary = WorldData.TREASURES[area_id]
	if pony.position.distance_to(info.pos) < 110:
		treasure_found = true
		_rebuild(_treasure_layer)
		GameState.discover("poklad_" + area_id)
		GameState.grant(info.reward)
		Audio.play("treasure", 0.0)
		pony.love()
		_celebrate = 3.0
		_quest_event("treasure")
		_say("POKLAD! %s – najdeš ji v obchůdku." % info.name)


## Svět se skládá z vrstev. Nehybné vrstvy se jednou převedou na síť trojúhelníků (MeshBuilder),
## takže je grafika kreslí jedním voláním. Tráva a stromy jsou navíc rozdělené na dílky,
## aby se kreslilo jen to, co je zrovna vidět.
func _build_world() -> void:
	_add_static(func(ci): ci.draw_rect(WORLD, area.ground))
	for cx in int(WORLD.size.x / CHUNK.x):
		for cy in int(WORLD.size.y / CHUNK.y):
			var rect := Rect2(Vector2(cx, cy) * CHUNK, CHUNK)
			_add_static(func(ci): _paint_ground(ci, rect))
	_add_static(_paint_water)
	_treasure_layer = _add_static(_paint_treasure)
	_items_layer = _add_static(_paint_items)
	for bush in bushes:
		bush.layer = _add_static(func(ci): _paint_bush(ci, bush))
	for cx in int(WORLD.size.x / CHUNK.x):
		for cy in int(WORLD.size.y / CHUNK.y):
			var rect := Rect2(Vector2(cx, cy) * CHUNK, CHUNK)
			var chunk_trees := trees.filter(func(t: Vector2): return rect.has_point(t))
			if not chunk_trees.is_empty():
				_add_static(func(ci):
					for t in chunk_trees:
						_paint_tree(ci, t))
	_fx_layer = Painter.new()
	_fx_layer.paint = _paint_fx
	add_child(_fx_layer)


## Nehybná vrstva: nakreslí se jednou do sítě. Po změně (sebraná věc) se přestaví přes _rebuild.
func _add_static(paint: Callable) -> MeshInstance2D:
	var layer := MeshInstance2D.new()
	layer.set_meta("paint", paint)
	add_child(layer)
	_rebuild(layer)
	return layer


func _rebuild(layer: MeshInstance2D) -> void:
	var builder := MeshBuilder.new()
	layer.get_meta("paint").call(builder)
	layer.mesh = builder.commit()


func _paint_ground(ci, rect: Rect2) -> void:
	var ground: Color = area.ground
	for i in 220:
		var p := Vector2(float((i * 137) % 3000), float((i * 89) % 2000))
		if rect.has_point(p):
			ci.draw_circle(p, 22, ground.darkened(0.05))
	# Trsy trávy
	var g := ground.darkened(0.22)
	for i in 260:
		var p := Vector2(float((i * 263 + 30) % 3000), float((i * 151 + 70) % 2000))
		if rect.has_point(p):
			ci.draw_polyline(PackedVector2Array([p + Vector2(-6, -12), p, p + Vector2(0, -15), p, p + Vector2(6, -12)]), g, 3)
	# Drobné kytičky v trávě
	for i in 90:
		var p := Vector2(float((i * 311 + 50) % 3000), float((i * 173 + 20) % 2000))
		if rect.has_point(p) and not _in_water(p, 10.0):
			ci.draw_circle(p, 4, [Color("fff4a8"), Color("ffd1e8"), Color("ffffff")][i % 3])


func _paint_water(ci) -> void:
	var path := [Vector2(300, 1350), Vector2(900, 1150), Vector2(1600, 980), Vector2(2300, 900), Vector2(2900, 700)]
	if area.water == "pond":
		path = [Vector2(300, 1350), Vector2(1000, 1500), Vector2(2000, 1500), Vector2(2900, 1200)]
	ci.draw_polyline(PackedVector2Array(path), Color("e8c27a") if area.tree_style != "magic" else Color("c9b8e8"), 60)
	if area.water == "stream":
		_paint_stream(ci)
	elif area.water == "pond":
		_paint_pond(ci)


func _paint_items(ci) -> void:
	for item in items:
		var p: Vector2 = item[0]
		DrawKit.ellipse(ci, p + Vector2(0, 18), 14, 4, Color(0, 0, 0, 0.15), 0, 0)
		match item[1]:
			"apple":
				ci.draw_line(p + Vector2(0, -12), p + Vector2(4, -24), DrawKit.OUTLINE, 4)
				DrawKit.ellipse(ci, p, 16, 15, Color("e0413a"), 0, 3)
				DrawKit.ellipse(ci, p + Vector2(10, -20), 8, 4, Color("5cb85c"), -0.5, 2)
				ci.draw_circle(p + Vector2(-6, -6), 4, Color(1, 1, 1, 0.6))
			"flower":
				DrawKit.blob(ci, [[p + Vector2.from_angle(0.0) * 12, 9.0], [p + Vector2.from_angle(TAU / 5) * 12, 9.0], [p + Vector2.from_angle(2 * TAU / 5) * 12, 9.0], [p + Vector2.from_angle(3 * TAU / 5) * 12, 9.0], [p + Vector2.from_angle(4 * TAU / 5) * 12, 9.0]], Color("ff7fc4"), 3)
				DrawKit.ellipse(ci, p, 7, 7, Color("ffe066"), 0, 2)
			"horseshoe":
				ci.draw_arc(p, 16, 0.3, PI - 0.3 + PI, 14, DrawKit.OUTLINE, 14)
				ci.draw_arc(p, 16, 0.3, PI - 0.3 + PI, 14, Color("c9d1da"), 8)


## Věci, které se hýbou: kroužek cíle, vyskakující nápisy, oslava, třpytka pokladu a proud potůčku.
func _paint_fx(ci) -> void:
	if area.water == "stream":
		var flow := fmod(Time.get_ticks_msec() / 1000.0 * 40.0, 140.0)
		for y in range(-140, 2000, 140):
			var a := Vector2(STREAM_X - 30, y + flow)
			if a.y + 30 < BRIDGE.position.y or a.y > BRIDGE.end.y:
				ci.draw_line(a, a + Vector2(40, 30), Color("b8e6ff"), 6)
	if not treasure_found:
		var tp: Vector2 = WorldData.TREASURES[area_id].pos
		var s := fmod(Time.get_ticks_msec() / 1000.0, 2.0)
		if s < 0.6:
			var r := 18.0 * sin(s / 0.6 * PI)
			ci.draw_line(tp + Vector2(20 - r, -30), tp + Vector2(20 + r, -30), Color.WHITE, 3)
			ci.draw_line(tp + Vector2(20, -30 - r), tp + Vector2(20, -30 + r), Color.WHITE, 3)
	if moving:
		ci.draw_arc(target, 22, 0, TAU, 20, Color(1, 1, 1, 0.8), 4)
	for p in _popups:
		var a := minf(1.0, p[3] / 0.4)
		var c: Color = p[2]
		c.a = a
		ci.draw_string_outline(UiStyle.FONT, p[0] + Vector2(-150, 0), p[1], HORIZONTAL_ALIGNMENT_CENTER, 300, 30, 8, Color(0.24, 0.14, 0.09, a))
		ci.draw_string(UiStyle.FONT, p[0] + Vector2(-150, 0), p[1], HORIZONTAL_ALIGNMENT_CENTER, 300, 30, c)
	if _celebrate > 0.0:
		for i in 10:
			var a := i * TAU / 10.0 + _celebrate * 2.0
			ci.draw_circle(pony.position + Vector2.from_angle(a) * (170.0 - _celebrate * 40.0), 9, Color(1, 0.9, 0.3, minf(1.0, _celebrate)))


func _paint_tree(ci, t: Vector2) -> void:
	DrawKit.ellipse(ci, t + Vector2(8, 52), 50, 12, Color(0, 0, 0, 0.14), 0, 0)
	match area.tree_style:
		"birch":
			DrawKit.poly(ci, PackedVector2Array([t + Vector2(-8, 0), t + Vector2(8, 0), t + Vector2(10, 52), t + Vector2(-10, 52)]), Color("f4f1ea"), 3)
			for k in 3:
				ci.draw_line(t + Vector2(-8 + k * 5, 14 + k * 13), t + Vector2(1 + k * 5, 14 + k * 13), Color("333333"), 3)
			var c := t + Vector2(0, -4)
			DrawKit.blob(ci, [[c + Vector2(-22, 0), 28.0], [c + Vector2(20, 4), 26.0], [c + Vector2(0, -22), 30.0]], Color("8fd14f"), 3)
			DrawKit.blob(ci, [[c + Vector2(-10, -24), 14.0], [c + Vector2(-26, -4), 10.0]], Color("b7e57a"), 0)
		"magic":
			DrawKit.poly(ci, PackedVector2Array([t + Vector2(-10, 0), t + Vector2(10, 0), t + Vector2(14, 52), t + Vector2(-14, 52)]), Color("5a3d6b"), 3)
			var c := t + Vector2(0, -6)
			DrawKit.blob(ci, [[c + Vector2(-28, 4), 32.0], [c + Vector2(26, 6), 30.0], [c + Vector2(0, -26), 36.0]], Color("2f7f78"), 3)
			DrawKit.blob(ci, [[c + Vector2(-14, -30), 16.0], [c + Vector2(-32, 0), 11.0]], Color("4fb3a5"), 0)
			for f in [Vector2(20, -10), Vector2(-25, 15), Vector2(5, 20)]:
				ci.draw_circle(c + f, 12, Color(1.0, 0.75, 0.95, 0.25))
				ci.draw_circle(c + f, 6, Color(1.0, 0.85, 0.97, 0.85))
			DrawKit.capsule(ci, t + Vector2(32, 50), t + Vector2(32, 58), 3, Color("f2e9ff"), 2)
			DrawKit.ellipse(ci, t + Vector2(32, 48), 12, 8, Color("b388ff"), 0, 2)
		_:
			DrawKit.poly(ci, PackedVector2Array([t + Vector2(-10, 4), t + Vector2(10, 4), t + Vector2(14, 52), t + Vector2(-14, 52)]), Color("8a5a35"), 3)
			var c := t + Vector2(0, -6)
			DrawKit.blob(ci, [[c + Vector2(-30, 6), 32.0], [c + Vector2(30, 8), 30.0], [c + Vector2(0, -24), 38.0], [c + Vector2(4, 16), 30.0]], Color("3aa64a"), 3)
			DrawKit.blob(ci, [[c + Vector2(-14, -30), 18.0], [c + Vector2(-34, -2), 12.0]], Color("62c46a"), 0)
			if int(t.x) % 3 == 0:
				for a in [Vector2(18, -6), Vector2(-10, 10), Vector2(28, 18)]:
					DrawKit.ellipse(ci, c + a, 6, 6, Color("e0413a"), 0, 2)


func _paint_bush(ci, bush: Dictionary) -> void:
	var p: Vector2 = bush.pos
	var green := Color("3fa34d") if not bush.searched else Color("6dbb63")
	DrawKit.ellipse(ci, bush.pos + Vector2(0, 30), 50, 10, Color(0, 0, 0, 0.14), 0, 0)
	DrawKit.blob(ci, [[p + Vector2(-24, 8), 24.0], [p + Vector2(24, 8), 24.0], [p + Vector2(0, -10), 30.0]], green, 3)
	DrawKit.blob(ci, [[p + Vector2(-8, -20), 12.0]], green.lightened(0.2), 0)
	if not bush.searched:
		for b in [Vector2(-14, -8), Vector2(12, -18), Vector2(22, 8), Vector2(-26, 10)]:
			DrawKit.ellipse(ci, p + b, 5.5, 5.5, Color("d6336c"), 0, 2)


func _paint_treasure(ci) -> void:
	var p: Vector2 = WorldData.TREASURES[area_id].pos
	var wood := Color("8a5a35")
	if treasure_found:
		ci.draw_rect(Rect2(p + Vector2(-34, -10), Vector2(68, 40)), wood)
		ci.draw_rect(Rect2(p + Vector2(-34, -40), Vector2(68, 14)), wood.lightened(0.15))
		return
	ci.draw_rect(Rect2(p + Vector2(-34, -20), Vector2(68, 50)), wood)
	ci.draw_rect(Rect2(p + Vector2(-34, -24), Vector2(68, 16)), wood.lightened(0.15))
	ci.draw_rect(Rect2(p + Vector2(-6, -12), Vector2(12, 14)), Color("e8b923"))


func _paint_stream(ci) -> void:
	ci.draw_rect(Rect2(STREAM_X - STREAM_HALF_WIDTH, 0, STREAM_HALF_WIDTH * 2, WORLD.size.y), Color("4fb3e8"))
	for y in range(-140, 2000, 140):
		ci.draw_circle(Vector2(STREAM_X - STREAM_HALF_WIDTH, y + 70), 14, Color("a0a8b0"))
		ci.draw_circle(Vector2(STREAM_X + STREAM_HALF_WIDTH, y + 20), 12, Color("a0a8b0"))
	ci.draw_rect(BRIDGE, Color("a86a3c"))
	for x in range(int(BRIDGE.position.x), int(BRIDGE.end.x), 25):
		ci.draw_line(Vector2(x, BRIDGE.position.y), Vector2(x, BRIDGE.end.y), Color("7d4b29"), 3)
	ci.draw_rect(Rect2(BRIDGE.position, Vector2(BRIDGE.size.x, 12)), Color("6b3f22"))
	ci.draw_rect(Rect2(BRIDGE.position + Vector2(0, BRIDGE.size.y - 12), Vector2(BRIDGE.size.x, 12)), Color("6b3f22"))


func _paint_pond(ci) -> void:
	ci.draw_set_transform(POND_CENTER, 0, POND_RADII / POND_RADII.x)
	ci.draw_circle(Vector2.ZERO, POND_RADII.x + 25, Color("d9c48a"))
	ci.draw_circle(Vector2.ZERO, POND_RADII.x, Color("4fb3e8"))
	ci.draw_circle(Vector2(-80, -40), POND_RADII.x * 0.6, Color("6cc3ee"))
	ci.draw_set_transform(Vector2.ZERO)
	for p in [Vector2(1250, 950), Vector2(1700, 1100), Vector2(1550, 850)]:
		ci.draw_circle(p, 26, Color("3c9a3c"))
		ci.draw_circle(p + Vector2(8, -6), 7, Color("ff9ccf"))
	for x in range(1080, 1940, 60):
		var y := POND_CENTER.y + POND_RADII.y + 10.0
		ci.draw_line(Vector2(x, y), Vector2(x - 6, y - 40), Color("5a8f3a"), 5)
		ci.draw_rect(Rect2(x - 10, y - 55, 8, 18), Color("7a4b2a"))
