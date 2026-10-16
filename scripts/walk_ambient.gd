extends Node2D
## Nálada procházky: denní doba, světlušky, padající listí, déšť s duhou a skákající rybky.
## Kreslí se nad světem (ve vlastní vrstvě), takže ji neztlumí večerní šero.

signal moment(id: String)

const TIMES := {
	"rano": {"name": "Ráno", "tint": Color(1.0, 0.95, 0.88)},
	"den": {"name": "Krásný den", "tint": Color(1, 1, 1)},
	"zapad": {"name": "Západ slunce", "tint": Color(1.0, 0.78, 0.62)},
	"vecer": {"name": "Večer", "tint": Color(0.55, 0.6, 0.88)},
}

var walk: Node2D
var time_of_day := "den"
var fireflies := false
var leaves := false
var fish := false

var _t := 0.0
var _flies: Array = []
var _leaves: Array = []
var _rain_start := -1.0
var _rain_left := 0.0
var _drops: Array = []
var _rainbow_pos := Vector2.ZERO
var _rainbow_left := 0.0
var _fish_timer := 6.0
var _fish_jump := 0.0
var _fish_pos := Vector2.ZERO


func setup(walk_node: Node2D, area_id: String, rng: RandomNumberGenerator) -> Color:
	walk = walk_node
	var area: Dictionary = WorldData.AREAS[area_id]
	if area_id == "kouzelny_les":
		time_of_day = "vecer"
	else:
		time_of_day = ["rano", "den", "den", "zapad", "vecer"][rng.randi() % 5]
		if rng.randf() < 0.3:
			_rain_start = rng.randf_range(8.0, 20.0)
	fireflies = time_of_day == "vecer"
	leaves = area.tree_style == "birch"
	fish = area.water == "pond"
	for i in 45:
		_flies.append([Vector2(rng.randf_range(-700, 700), rng.randf_range(-400, 400)), rng.randf() * TAU])
	for i in 18:
		_leaves.append([Vector2(rng.randf_range(-700, 700), rng.randf_range(-450, 450)), rng.randf() * TAU])
	if area_id == "kouzelny_les":
		return Color(0.72, 0.68, 0.95)
	return TIMES[time_of_day].tint


func greeting() -> String:
	return TIMES[time_of_day].name


func _view_center() -> Vector2:
	var cam := get_viewport().get_camera_2d()
	return cam.get_screen_center_position() if cam else Vector2(640, 360)


func _process(delta: float) -> void:
	_t += delta
	if _t > 3.0 and fireflies:
		moment.emit("svetlusky")
	if _t > 4.0 and leaves:
		moment.emit("listi")
	if time_of_day == "zapad" and _t > 1.0:
		moment.emit("zapad")
	# Déšť a po něm duha
	if _rain_start >= 0.0 and _t >= _rain_start and _rain_left <= 0.0 and _rainbow_left <= 0.0 and _drops.is_empty():
		_rain_left = 12.0
		_rain_start = -1.0
		for i in 120:
			_drops.append(Vector2(randf_range(-700, 700), randf_range(-450, 450)))
		walk.call("_say", "Prší! Kapky bubnují do listí.")
	if _rain_left > 0.0:
		_rain_left -= delta
		for i in _drops.size():
			_drops[i] += Vector2(-120, 900) * delta
			if _drops[i].y > 450:
				_drops[i] = Vector2(randf_range(-700, 760), -450)
		if _rain_left <= 0.0:
			_drops.clear()
			_rainbow_left = 25.0
			_rainbow_pos = _view_center() + Vector2(0, -60)
			moment.emit("duha")
			Audio.play("discover", 0.0)
			walk.call("_say", "Přestalo pršet a je tu duha!")
	_rainbow_left = maxf(0.0, _rainbow_left - delta)
	# Rybka vyskočí z rybníčka
	if fish:
		_fish_timer -= delta
		if _fish_timer <= 0.0:
			_fish_timer = randf_range(5.0, 10.0)
			_fish_jump = 1.0
			_fish_pos = walk.POND_CENTER + Vector2(randf_range(-250, 250), randf_range(-140, 140))
			if _fish_pos.distance_to(_view_center()) < 700:
				Audio.play("splash")
				moment.emit("rybka")
		_fish_jump = maxf(0.0, _fish_jump - delta)
	for f in _flies:
		f[1] += delta
		f[0] += Vector2(cos(f[1] * 0.7), sin(f[1] * 1.1)) * 25.0 * delta
	for l in _leaves:
		l[1] += delta
		l[0] += Vector2(sin(l[1] * 1.5) * 40.0, 60.0) * delta
		if l[0].y > 450:
			l[0].y = -450
	queue_redraw()


func _draw() -> void:
	var c := _view_center()
	if _rainbow_left > 0.0:
		var a := minf(1.0, _rainbow_left / 3.0) * 0.75
		var colors := [Color("ff4d4d"), Color("ff9f40"), Color("ffe066"), Color("6ad16a"), Color("4fb3e8"), Color("8a6cf0")]
		for i in colors.size():
			var col: Color = colors[i]
			col.a = a
			draw_arc(_rainbow_pos + Vector2(0, 140), 330 - i * 14, PI, TAU, 48, col, 14)
	if fish and _fish_jump > 0.0:
		var p := _fish_pos + Vector2((1.0 - _fish_jump) * 80.0 - 40.0, -sin(_fish_jump * PI) * 70.0)
		draw_set_transform(p, (0.5 - _fish_jump) * 2.0, Vector2(1, 0.6))
		draw_circle(Vector2.ZERO, 16, Color("ff9a3c"))
		draw_set_transform(Vector2.ZERO)
		draw_colored_polygon(PackedVector2Array([p + Vector2(-14, 0), p + Vector2(-28, -10), p + Vector2(-28, 10)]), Color("ff7a1c"))
		draw_arc(_fish_pos, 30.0 + (1.0 - _fish_jump) * 40.0, 0, TAU, 24, Color(1, 1, 1, _fish_jump * 0.7), 3)
	if fireflies:
		for f in _flies:
			var glow := 0.5 + 0.5 * sin(f[1] * 3.0)
			var p: Vector2 = c + f[0]
			draw_circle(p, 9, Color(1, 1, 0.5, 0.15 * glow))
			draw_circle(p, 3.5, Color(1, 1, 0.6, 0.5 + 0.5 * glow))
	if leaves:
		for l in _leaves:
			var p: Vector2 = c + l[0]
			draw_set_transform(p, sin(l[1] * 2.0), Vector2(1, 0.5))
			draw_circle(Vector2.ZERO, 8, Color("f2c94c") if int(l[1] * 10) % 2 == 0 else Color("e8913a"))
			draw_set_transform(Vector2.ZERO)
	if not _drops.is_empty():
		draw_rect(Rect2(c - Vector2(700, 450), Vector2(1400, 900)), Color(0.3, 0.4, 0.6, 0.18))
		for d in _drops:
			draw_line(c + d, c + d + Vector2(-6, 24), Color(0.8, 0.9, 1.0, 0.7), 2)
