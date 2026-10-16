extends Node2D
## Kreslená zvířátka do světa a do alba (s obrysy jako koník).

var kind := "zajicek"
## Neobjevené zvíře se v albu kreslí jen jako stín.
var silhouette := false
var animated := true
var _t := 0.0
var _joy := 0.0


func _process(delta: float) -> void:
	if animated:
		_t += delta
		_joy = maxf(0.0, _joy - delta)
		queue_redraw()


## Radostný poskok se srdíčkem, když na zvířátko dítě ťukne.
func react() -> void:
	if _joy > 0.0:
		return
	_joy = 1.0
	var tween := create_tween()
	tween.tween_property(self, "position:y", position.y - 30.0, 0.15).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "position:y", position.y, 0.25).set_trans(Tween.TRANS_BOUNCE)


func _c(color: Color) -> Color:
	return Color("b5bcc4") if silhouette else color


func _e(c: Vector2, rx: float, ry: float, col: Color, rot := 0.0, w := 3.0) -> void:
	DrawKit.ellipse(self, c, rx, ry, _c(col), rot, w, Color("8a929b") if silhouette else DrawKit.OUTLINE)


func _cap(a: Vector2, b: Vector2, r: float, col: Color, w := 3.0) -> void:
	DrawKit.capsule(self, a, b, r, _c(col), w, Color("8a929b") if silhouette else DrawKit.OUTLINE)


func _poly(pts: PackedVector2Array, col: Color, w := 3.0) -> void:
	DrawKit.poly(self, pts, _c(col), w, Color("8a929b") if silhouette else DrawKit.OUTLINE)


func _eye(p: Vector2, r := 3.5) -> void:
	if silhouette:
		return
	var blink := fmod(_t + p.x * 0.1, 4.0) < 0.12
	if blink:
		draw_line(p + Vector2(-r, 0), p + Vector2(r, 0), DrawKit.OUTLINE, 2.5)
	else:
		draw_circle(p, r, DrawKit.OUTLINE)
		draw_circle(p + Vector2(r * 0.35, -r * 0.35), r * 0.35, Color.WHITE)


func _draw() -> void:
	if not silhouette:
		DrawKit.ellipse(self, Vector2(0, 30), 30, 7, Color(0, 0, 0, 0.15), 0, 0)
	if _joy > 0.0:
		var hp := Vector2(0, -75 - (1.0 - _joy) * 30.0)
		DrawKit.heart(self, hp, 10, Color(1, 0.35, 0.55, _joy))
	var hop := absf(sin(_t * 3.0)) * -8.0
	match kind:
		"zajicek":
			_e(Vector2(-22, -2 + hop), 9, 9, Color.WHITE)
			_e(Vector2(0, hop), 24, 20, Color("b8a18a"))
			_e(Vector2(20, -38 + hop), 6, 18, Color("b8a18a"), 0.15)
			_e(Vector2(30, -36 + hop), 6, 17, Color("c9b39c"), 0.35)
			_e(Vector2(22, -16 + hop), 15, 13, Color("b8a18a"))
			_e(Vector2(4, 8 + hop), 14, 8, Color("e9dccb"), 0, 0)
			_eye(Vector2(27, -18 + hop))
			draw_circle(Vector2(36, -12 + hop), 3, _c(Color("f08aa0")))
		"motyl":
			var flap := absf(sin(_t * 8.0)) * 0.6 + 0.4
			var fly := Vector2(0, sin(_t * 2.0) * 10.0 - 10.0)
			for side in [-1.0, 1.0]:
				_e(fly + Vector2(side * 15 * flap, -10), 14 * flap, 15, Color("ff8fd1"))
				_e(fly + Vector2(side * 11 * flap, 10), 10 * flap, 10, Color("ffc94d"))
				if not silhouette:
					draw_circle(fly + Vector2(side * 15 * flap, -10), 4 * flap, Color.WHITE)
			_cap(fly + Vector2(0, -16), fly + Vector2(0, 16), 3.5, Color("4a2c1a"), 2)
			draw_line(fly + Vector2(0, -18), fly + Vector2(-6, -30), _c(DrawKit.OUTLINE), 2)
			draw_line(fly + Vector2(0, -18), fly + Vector2(6, -30), _c(DrawKit.OUTLINE), 2)
		"jezek":
			var spikes := PackedVector2Array()
			for i in 13:
				var a := PI * 0.9 + i * PI * 1.2 / 12.0
				spikes.append(Vector2.from_angle(a) * (36.0 if i % 2 == 0 else 24.0) + Vector2(0, 4))
			spikes.append(Vector2(14, 14))
			spikes.append(Vector2(-20, 16))
			_poly(spikes, Color("6b4a32"))
			_e(Vector2(18, 8), 16, 12, Color("e2c39e"), -0.2)
			draw_circle(Vector2(34, 6), 4, _c(DrawKit.OUTLINE))
			_eye(Vector2(22, 2))
		"veverka":
			var tail_sway := sin(_t * 3.0) * 4.0
			_e(Vector2(-22, -20 + tail_sway), 18, 28, Color("e07a2e"), -0.4)
			_e(Vector2(-18, -26 + tail_sway), 9, 16, Color("f0a050"), -0.4, 0)
			_e(Vector2(0, 0), 15, 20, Color("d96a22"))
			_e(Vector2(4, 6), 8, 12, Color("f5d5b0"), 0, 0)
			_e(Vector2(6, -32), 6, 9, Color("d96a22"), 0.3)
			_e(Vector2(10, -20), 13, 12, Color("d96a22"))
			_e(Vector2(14, 0), 6, 5, Color("8a5a35"))
			_eye(Vector2(15, -22))
		"srnka":
			for x in [-18.0, 16.0]:
				_cap(Vector2(x, 6), Vector2(x, 36), 4, Color("9a5f30"))
			_e(Vector2(0, -4), 30, 18, Color("b8743c"))
			for x in [-8.0, 24.0]:
				_cap(Vector2(x, 6), Vector2(x + 2, 38), 4, Color("b8743c"))
			_cap(Vector2(20, -10), Vector2(32, -34), 7, Color("b8743c"))
			_e(Vector2(30, -50), 6, 10, Color("b8743c"), -0.6)
			_e(Vector2(38, -40), 13, 10, Color("b8743c"), 0.3)
			for p in [Vector2(-12, -10), Vector2(2, -14), Vector2(-20, 0), Vector2(10, -4)]:
				draw_circle(p, 3, _c(Color("f2e3c9")))
			_eye(Vector2(40, -42))
			draw_circle(Vector2(50, -38), 3, _c(DrawKit.OUTLINE))
		"kachna":
			var bob := sin(_t * 2.0) * 3.0
			_e(Vector2(0, bob), 26, 15, Color("f7f2e8"))
			_e(Vector2(-6, -4 + bob), 12, 7, Color("e8e0d0"), 0.2, 0)
			_e(Vector2(18, -18 + bob), 12, 11, Color("2e8b57"))
			_poly(PackedVector2Array([Vector2(28, -20 + bob), Vector2(42, -15 + bob), Vector2(28, -11 + bob)]), Color("f0a030"), 2)
			_eye(Vector2(21, -21 + bob), 2.8)
		"zabka":
			var j := hop * 0.5
			_e(Vector2(-14, 12 + j), 10, 6, Color("3ea83a"))
			_e(Vector2(14, 12 + j), 10, 6, Color("3ea83a"))
			_e(Vector2(0, j), 20, 16, Color("4cbb47"))
			_e(Vector2(0, 6 + j), 12, 7, Color("c8f0a0"), 0, 0)
			for x in [-9.0, 9.0]:
				_e(Vector2(x, -15 + j), 7, 7, Color("4cbb47"))
				_eye(Vector2(x, -16 + j), 3.5)
			draw_arc(Vector2(0, -2 + j), 8, 0.4, 2.7, 8, _c(DrawKit.OUTLINE), 2)
		"sova":
			var blink := fmod(_t, 4.0) < 0.15
			_e(Vector2(0, 0), 26, 32, Color("8a6a4a"))
			_e(Vector2(0, 10), 16, 18, Color("d9c09a"), 0, 0)
			_poly(PackedVector2Array([Vector2(-22, -26), Vector2(-16, -44), Vector2(-6, -28)]), Color("8a6a4a"))
			_poly(PackedVector2Array([Vector2(22, -26), Vector2(16, -44), Vector2(6, -28)]), Color("8a6a4a"))
			for ex in [-11.0, 11.0]:
				_e(Vector2(ex, -12), 10, 10, Color("fff2c0"), 0, 2)
				if not silhouette:
					if blink:
						draw_line(Vector2(ex - 6, -12), Vector2(ex + 6, -12), DrawKit.OUTLINE, 3)
					else:
						draw_circle(Vector2(ex, -12), 5, DrawKit.OUTLINE)
						draw_circle(Vector2(ex + 2, -14), 1.6, Color.WHITE)
			_poly(PackedVector2Array([Vector2(-4, -4), Vector2(4, -4), Vector2(0, 5)]), Color("f0a030"), 2)
		"liska":
			var wag := sin(_t * 4.0) * 0.3
			var tail_c := Vector2(-34, -6) + Vector2(0, -10).rotated(wag)
			_e(tail_c, 22, 11, Color("e8742a"), -0.5 + wag)
			_e(tail_c + Vector2(-18, -10).rotated(-0.5 + wag), 8, 7, Color.WHITE, 0, 0)
			for x in [-14.0, 14.0]:
				_cap(Vector2(x, 4), Vector2(x, 26), 4, Color("3a2a20"))
			_e(Vector2(0, 0), 28, 16, Color("e8742a"))
			_poly(PackedVector2Array([Vector2(16, -30), Vector2(22, -46), Vector2(30, -28)]), Color("c95a1a"))
			_poly(PackedVector2Array([Vector2(16, -26), Vector2(50, -12), Vector2(22, 0)]), Color("e8742a"))
			_poly(PackedVector2Array([Vector2(30, -12), Vector2(50, -12), Vector2(30, -2)]), Color.WHITE, 0)
			draw_circle(Vector2(50, -12), 3.5, _c(DrawKit.OUTLINE))
			_eye(Vector2(28, -18), 3)
		"jednorozec":
			var glow := 0.5 + 0.5 * sin(_t * 3.0)
			if not silhouette:
				draw_circle(Vector2(0, -10), 75, Color(1, 0.95, 1, 0.12 + glow * 0.12))
			for x in [-20.0, 18.0]:
				_cap(Vector2(x, 6), Vector2(x, 38), 5, Color("efe6fa"))
			_e(Vector2(0, -4), 34, 20, Color("fbf7ff"))
			for x in [-8.0, 26.0]:
				_cap(Vector2(x, 6), Vector2(x + 2, 40), 5, Color("fbf7ff"))
			_cap(Vector2(22, -12), Vector2(36, -38), 9, Color("fbf7ff"))
			for i in 5:
				_e(Vector2(24 - i * 4, -46 + i * 9), 8, 6, Color.from_hsv(i / 5.0, 0.45, 1.0), -0.8)
			_e(Vector2(-38, 2), 10, 7, Color.from_hsv(0.8, 0.4, 1.0), 0.6)
			_e(Vector2(-42, 14), 9, 6, Color.from_hsv(0.6, 0.4, 1.0), 0.9)
			_e(Vector2(44, -40), 15, 12, Color("fbf7ff"), 0.3)
			_poly(PackedVector2Array([Vector2(40, -52), Vector2(54, -86), Vector2(50, -50)]), Color("ffd84d"), 2.5)
			_eye(Vector2(46, -43), 3.2)
			if not silhouette:
				draw_circle(Vector2(40, -36), 4, Color(1, 0.6, 0.75, 0.5))
				for i in 4:
					var a := _t * 1.5 + i * TAU / 4.0
					DrawKit.star(self, Vector2.from_angle(a) * 58 + Vector2(0, -10), 5, Color(1, 0.95, 0.5, glow))
	if silhouette:
		draw_string(UiStyle.FONT, Vector2(-12, 14), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, 42, Color.WHITE)
