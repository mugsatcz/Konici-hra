extends Node2D
## Kreslený koník (z boku, hlavou doprava). Kreslí se kódem, takže jde snadno měnit barvy.

@export var coat_color := Color("c8834a")
@export var mane_color := Color("f2d16b")
@export var spots := false
## Když je true, bere barvy z právě vybraného koníka ve hře.
@export var use_current := true
## 0–100, ovlivňuje výraz koníka.
var mood := 100.0
var facing := 1.0:
	set(value):
		facing = signf(value) if value != 0.0 else facing
		scale.x = absf(scale.x) * facing
var rider := false
## Když koník jde, hýbe nohama.
var walking := false

var _t := 0.0
var _hearts := 0.0
var _blink := 0.0
var _next_blink := 2.5


func _process(delta: float) -> void:
	if use_current:
		apply(GameState.current())
	_t += delta
	_hearts = maxf(0.0, _hearts - delta)
	_next_blink -= delta
	if _next_blink <= 0.0:
		_blink = 0.15
		_next_blink = randf_range(2.0, 4.5)
	_blink = maxf(0.0, _blink - delta)
	queue_redraw()


func apply(pony: Dictionary) -> void:
	coat_color = Color(pony.coat)
	mane_color = Color(pony.mane)
	spots = pony.spots


## Nad koníkem vyletí srdíčka (pohlazení, radost).
func love() -> void:
	_hearts = 1.4


func _mane_col(i: int) -> Color:
	if GameState.wears("rainbow"):
		return Color.from_hsv(fmod(i / 7.0, 1.0), 0.55, 1.0)
	return mane_color


func _draw() -> void:
	var o := DrawKit.OUTLINE
	var w := 4.0
	var bob := sin(_t * (9.0 if walking else 2.0)) * (3.0 if walking else 1.5)
	var dark := coat_color.darkened(0.18)
	var light := coat_color.lightened(0.25)
	var hoof := Color("e8b923") if GameState.wears("golden_hooves") else Color("5a3a28")

	# Stín
	DrawKit.ellipse(self, Vector2(0, 66), 82, 14, Color(0, 0, 0, 0.16), 0, 0)

	# Ocas (několik pramenů, které se pohupují)
	var tail_base := Vector2(-66, -22 + bob)
	for i in 4:
		var sway := sin(_t * 2.5 + i * 0.6) * 8.0
		var end := tail_base + Vector2(-26 - i * 4 + sway * 0.3, 40 + i * 8 + sway)
		var mid := tail_base + Vector2(-22 - i * 3, 10 + i * 3)
		DrawKit.capsule(self, tail_base, mid, 9, _mane_col(i), w)
		DrawKit.capsule(self, mid, end, 8, _mane_col(i), w)
	for i in 4:
		var sway := sin(_t * 2.5 + i * 0.6) * 8.0
		var end := tail_base + Vector2(-26 - i * 4 + sway * 0.3, 40 + i * 8 + sway)
		var mid := tail_base + Vector2(-22 - i * 3, 10 + i * 3)
		DrawKit.capsule(self, tail_base, mid, 9, _mane_col(i), 0)
		DrawKit.capsule(self, mid, end, 8, _mane_col(i), 0)

	# Vzdálenější nohy (tmavší)
	for x in [-30.0, 46.0]:
		var step := sin(_t * 9.0 + x) * 10.0 if walking else 0.0
		DrawKit.capsule(self, Vector2(x, 0 + bob), Vector2(x + step, 50), 10, dark, w)
		DrawKit.ellipse(self, Vector2(x + step, 56), 12, 7, hoof, 0, w)

	# Krk: nejdřív jen obrys, výplň až po těle, aby krk plynule navazoval
	var nod := sin(_t * 1.3) * 2.0
	var head := Vector2(84, -86 + bob + nod)
	var neck := PackedVector2Array([Vector2(26, -44 + bob), head + Vector2(-24, -8), head + Vector2(8, 12), Vector2(62, -10 + bob)])
	DrawKit.poly(self, neck, coat_color, w)

	# Tělo
	DrawKit.ellipse(self, Vector2(0, -16 + bob), 72, 42, coat_color, 0, w)
	DrawKit.ellipse(self, Vector2(6, 2 + bob), 52, 18, light, 0, 0)
	DrawKit.ellipse(self, Vector2(-8, -40 + bob), 40, 9, coat_color.lightened(0.12), 0, 0)
	if spots:
		for sp in [[Vector2(-34, -20), 20.0, 14.0], [Vector2(8, -2), 16.0, 12.0], [Vector2(30, -32), 12.0, 9.0], [Vector2(-52, 2), 10.0, 8.0]]:
			DrawKit.ellipse(self, sp[0] + Vector2(0, bob), sp[1], sp[2], Color("fbf7f0"), 0.3, 0)

	# Deky
	if GameState.wears("star_blanket") or GameState.wears("blanket"):
		var starry := GameState.wears("star_blanket")
		var pts := PackedVector2Array([Vector2(-40, -54), Vector2(30, -56), Vector2(36, 0), Vector2(-46, 2)])
		for i in pts.size():
			pts[i] += Vector2(0, bob)
		DrawKit.poly(self, pts, Color("27306b") if starry else Color("3b7dd8"), 3)
		if starry:
			for sp in [Vector2(-26, -40), Vector2(-4, -22), Vector2(16, -42), Vector2(-24, -12), Vector2(20, -12)]:
				DrawKit.star(self, sp + Vector2(0, bob), 7, Color("ffe066"))
		else:
			draw_line(Vector2(-44, -6 + bob), Vector2(34, -8 + bob), Color("ffe066"), 5)
			draw_line(Vector2(-41, -46 + bob), Vector2(31, -48 + bob), Color("ffe066"), 5)

	# Bližší nohy
	for x in [-48.0, 26.0]:
		var step := sin(_t * 9.0 + x + PI) * 10.0 if walking else 0.0
		DrawKit.capsule(self, Vector2(x, 0 + bob), Vector2(x + step, 52), 11, coat_color, w)
		DrawKit.ellipse(self, Vector2(x + step, 58), 13, 7, hoof, 0, w)

	# Výplň krku přes obrys těla
	DrawKit.poly(self, neck, coat_color, 0)

	# Hříva podél krku
	for i in 7:
		var t := i / 6.0
		var p := (head + Vector2(-20, -18)).lerp(Vector2(22, -46 + bob), t)
		var sway := sin(_t * 2.0 + i * 0.8) * 3.0
		DrawKit.ellipse(self, p + Vector2(-10 + sway, 4), 14, 10, _mane_col(i), -0.9, w)
	for i in 7:
		var t := i / 6.0
		var p := (head + Vector2(-20, -18)).lerp(Vector2(22, -46 + bob), t)
		var sway := sin(_t * 2.0 + i * 0.8) * 3.0
		DrawKit.ellipse(self, p + Vector2(-10 + sway, 4), 14, 10, _mane_col(i), -0.9, 0)

	# Uši
	for e in [[Vector2(-18, -20), -0.35], [Vector2(-6, -25), 0.05]]:
		var base: Vector2 = head + e[0]
		var rot: float = e[1] + sin(_t * 1.7) * 0.05
		var ear_c: Vector2 = base + Vector2(0, -8).rotated(rot)
		DrawKit.ellipse(self, ear_c, 8, 14, coat_color, rot, w)
		DrawKit.ellipse(self, ear_c + Vector2(0, 2).rotated(rot), 4, 8, Color("f4a6b8"), rot, 0)

	# Hlava a čumáček
	DrawKit.ellipse(self, head, 34, 30, coat_color, 0.2, w)
	DrawKit.ellipse(self, head + Vector2(26, 18), 24, 19, light, 0.15, w)
	draw_circle(head + Vector2(36, 12), 3.5, o)
	draw_circle(head + Vector2(6, 14), 7, Color(1, 0.55, 0.6, 0.45))

	# Ofina
	for i in 3:
		DrawKit.ellipse(self, head + Vector2(-12 + i * 9, -26 + i * 2), 10, 8, _mane_col(i + 3), 0.4, 3)

	# Oko (s mrkáním)
	var eye := head + Vector2(6, -6)
	var open := 0.12 if _blink > 0.0 else 1.0
	DrawKit.ellipse(self, eye, 11, 13 * open, Color.WHITE, 0, 3)
	if open > 0.5:
		DrawKit.ellipse(self, eye + Vector2(3, 2), 7, 9, Color("2a1a12"), 0, 0)
		draw_circle(eye + Vector2(5, -2), 3, Color.WHITE)
		draw_circle(eye + Vector2(1, 6), 1.6, Color.WHITE)
	for k in 3:
		var a := -2.4 + k * 0.35
		draw_line(eye + Vector2.from_angle(a) * 13 * Vector2(1, open), eye + Vector2.from_angle(a) * 19 * Vector2(1, open), o, 2.5)
	if mood < 40.0:
		draw_line(eye + Vector2(-10, -18), eye + Vector2(10, -13), o, 3.5)

	# Pusa
	var mouth := head + Vector2(30, 28)
	if mood >= 60.0:
		draw_arc(mouth, 8, 0.3, 2.6, 10, o, 3)
	elif mood >= 40.0:
		draw_line(mouth + Vector2(-6, 4), mouth + Vector2(6, 4), o, 3)
	else:
		draw_arc(mouth + Vector2(0, 10), 7, 3.7, 5.7, 10, o, 3)

	# Ozdoby na hlavě
	if GameState.wears("bow"):
		var b := head + Vector2(-26, -18)
		DrawKit.poly(self, PackedVector2Array([b, b + Vector2(-16, -12), b + Vector2(-16, 12)]), Color("ff5fa2"), 2.5)
		DrawKit.poly(self, PackedVector2Array([b, b + Vector2(16, -12), b + Vector2(16, 12)]), Color("ff5fa2"), 2.5)
		DrawKit.ellipse(self, b, 5, 5, Color("d63f86"), 0, 2.5)
	if GameState.wears("crown"):
		for i in 5:
			var f := head + Vector2(-22 + i * 10, -34 + absf(i - 2) * 3)
			for k in 5:
				draw_circle(f + Vector2.from_angle(k * TAU / 5) * 4, 4, [Color("ff7fc4"), Color("ffe066"), Color("8fd3ff")][i % 3])
			draw_circle(f, 2.5, Color.WHITE)

	# Jezdec
	if rider:
		_draw_rider(bob)

	if _hearts > 0.0:
		for i in 3:
			var hp := head + Vector2(-20 + i * 24, -50 - (1.4 - _hearts) * 60.0 - i * 10)
			DrawKit.heart(self, hp, 11, Color(1, 0.35, 0.55, minf(1.0, _hearts)))


func _draw_rider(bob: float) -> void:
	var skin := Color("f5c7a0")
	# Sedlo
	DrawKit.ellipse(self, Vector2(-6, -56 + bob), 30, 10, Color("a0522d"), 0, 3)
	# Noha přes bok
	DrawKit.capsule(self, Vector2(-4, -60 + bob), Vector2(6, -22 + bob), 7, Color("2e5fa8"), 3)
	DrawKit.ellipse(self, Vector2(9, -18 + bob), 9, 6, Color("4a2c1a"), 0, 3)
	# Tělo, ruce a hlava
	DrawKit.capsule(self, Vector2(-6, -66 + bob), Vector2(-4, -98 + bob), 13, Color("e8505b"), 3)
	DrawKit.capsule(self, Vector2(0, -90 + bob), Vector2(24, -72 + bob), 5, skin, 3)
	DrawKit.ellipse(self, Vector2(-2, -122 + bob), 17, 17, skin, 0, 3)
	draw_arc(Vector2(-4, -126 + bob), 17, PI * 0.95, TAU * 1.02, 12, Color("7a4b2a"), 10)
	draw_circle(Vector2(6, -122 + bob), 2.5, DrawKit.OUTLINE)
	draw_arc(Vector2(6, -114 + bob), 5, 0.3, 2.6, 6, DrawKit.OUTLINE, 2)
	draw_circle(Vector2(-4, -116 + bob), 4, Color(1, 0.5, 0.55, 0.4))
