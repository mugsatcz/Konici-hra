extends Node2D
## Zástupná kreslená zvířátka do světa a do alba.

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
	return Color(0.35, 0.35, 0.4, 0.5) if silhouette else color


func _draw() -> void:
	var dark := _c(Color("3a2a20"))
	if _joy > 0.0:
		var hc := Color(1, 0.35, 0.55, _joy)
		var hp := Vector2(0, -70 - (1.0 - _joy) * 30.0)
		draw_circle(hp + Vector2(-5, 0), 7, hc)
		draw_circle(hp + Vector2(5, 0), 7, hc)
		draw_colored_polygon(PackedVector2Array([hp + Vector2(-11, 2), hp + Vector2(11, 2), hp + Vector2(0, 14)]), hc)
	var hop := absf(sin(_t * 3.0)) * -8.0
	match kind:
		"zajicek":
			draw_circle(Vector2(0, hop), 22, _c(Color("b8a18a")))
			draw_circle(Vector2(20, -18 + hop), 14, _c(Color("b8a18a")))
			draw_rect(Rect2(14, -52 + hop, 7, 26), _c(Color("b8a18a")))
			draw_rect(Rect2(23, -50 + hop, 7, 24), _c(Color("c9b39c")))
			draw_circle(Vector2(-22, -4 + hop), 8, _c(Color.WHITE))
			draw_circle(Vector2(26, -20 + hop), 2.5, dark)
		"motyl":
			var flap := absf(sin(_t * 8.0)) * 0.6 + 0.4
			draw_set_transform(Vector2(0, sin(_t * 2.0) * 10.0), 0, Vector2(flap, 1))
			draw_circle(Vector2(-14, -10), 14, _c(Color("ff8fd1")))
			draw_circle(Vector2(14, -10), 14, _c(Color("ff8fd1")))
			draw_circle(Vector2(-10, 10), 10, _c(Color("ffc94d")))
			draw_circle(Vector2(10, 10), 10, _c(Color("ffc94d")))
			draw_set_transform(Vector2.ZERO)
			draw_rect(Rect2(-3, -16, 6, 32), dark)
		"jezek":
			for i in 7:
				var a := PI + i * PI / 6.0
				draw_colored_polygon(PackedVector2Array([Vector2.from_angle(a - 0.25) * 18, Vector2.from_angle(a) * 36, Vector2.from_angle(a + 0.25) * 18]), _c(Color("6b4a32")))
			draw_circle(Vector2.ZERO, 22, _c(Color("7d5a3c")))
			draw_circle(Vector2(24, 6), 11, _c(Color("e2c39e")))
			draw_circle(Vector2(34, 8), 4, dark)
			draw_circle(Vector2(24, 2), 2.5, dark)
		"veverka":
			draw_circle(Vector2(-22, -18 + sin(_t * 3) * 3), 20, _c(Color("e07a2e")))
			draw_circle(Vector2(0, 0), 16, _c(Color("d96a22")))
			draw_circle(Vector2(10, -20), 11, _c(Color("d96a22")))
			draw_colored_polygon(PackedVector2Array([Vector2(6, -30), Vector2(9, -42), Vector2(14, -29)]), _c(Color("d96a22")))
			draw_circle(Vector2(14, -22), 2.5, dark)
			draw_circle(Vector2(12, 4), 5, _c(Color("8a5a35")))
		"srnka":
			draw_set_transform(Vector2(0, 0), 0, Vector2(1, 0.6))
			draw_circle(Vector2.ZERO, 32, _c(Color("b8743c")))
			draw_set_transform(Vector2.ZERO)
			for x in [-20, -8, 12, 22]:
				draw_rect(Rect2(x - 3, 10, 6, 30), _c(Color("9a5f30")))
			draw_line(Vector2(24, -10), Vector2(36, -36), _c(Color("b8743c")), 12)
			draw_circle(Vector2(40, -40), 12, _c(Color("b8743c")))
			draw_circle(Vector2(44, -42), 2.5, dark)
			for p in [Vector2(-10, -4), Vector2(4, -10), Vector2(-18, 6)]:
				draw_circle(p, 3, _c(Color("f2e3c9")))
		"kachna":
			var bob := sin(_t * 2.0) * 3.0
			draw_set_transform(Vector2(0, bob), 0, Vector2(1, 0.6))
			draw_circle(Vector2.ZERO, 26, _c(Color("f7f2e8")))
			draw_set_transform(Vector2.ZERO)
			draw_circle(Vector2(18, -18 + bob), 12, _c(Color("2e8b57")))
			draw_colored_polygon(PackedVector2Array([Vector2(28, -20 + bob), Vector2(42, -16 + bob), Vector2(28, -12 + bob)]), _c(Color("f0a030")))
			draw_circle(Vector2(22, -21 + bob), 2.5, dark)
		"zabka":
			draw_circle(Vector2(0, hop * 0.5), 18, _c(Color("4cbb47")))
			draw_circle(Vector2(-9, -16 + hop * 0.5), 7, _c(Color("4cbb47")))
			draw_circle(Vector2(9, -16 + hop * 0.5), 7, _c(Color("4cbb47")))
			draw_circle(Vector2(-9, -17 + hop * 0.5), 3, dark)
			draw_circle(Vector2(9, -17 + hop * 0.5), 3, dark)
			draw_arc(Vector2(0, 0 + hop * 0.5), 8, 0.4, 2.7, 8, dark, 2)
		"sova":
			var blink := 1.0 if fmod(_t, 4.0) > 0.15 else 0.1
			draw_set_transform(Vector2.ZERO, 0, Vector2(1, 1.25))
			draw_circle(Vector2.ZERO, 26, _c(Color("8a6a4a")))
			draw_set_transform(Vector2.ZERO)
			draw_circle(Vector2(0, 10), 15, _c(Color("d9c09a")))
			draw_colored_polygon(PackedVector2Array([Vector2(-22, -24), Vector2(-14, -40), Vector2(-6, -26)]), _c(Color("8a6a4a")))
			draw_colored_polygon(PackedVector2Array([Vector2(22, -24), Vector2(14, -40), Vector2(6, -26)]), _c(Color("8a6a4a")))
			for ex in [-11, 11]:
				draw_circle(Vector2(ex, -12), 10, _c(Color("fff2c0")))
				draw_set_transform(Vector2(ex, -12), 0, Vector2(1, blink))
				draw_circle(Vector2.ZERO, 5, dark)
				draw_set_transform(Vector2.ZERO)
			draw_colored_polygon(PackedVector2Array([Vector2(-4, -4), Vector2(4, -4), Vector2(0, 4)]), _c(Color("f0a030")))
		"liska":
			var wag := sin(_t * 4.0) * 0.3
			draw_set_transform(Vector2(-30, -5), wag, Vector2(1.4, 0.6))
			draw_circle(Vector2(-12, 0), 16, _c(Color("e8742a")))
			draw_circle(Vector2(-26, 0), 8, _c(Color.WHITE))
			draw_set_transform(Vector2.ZERO)
			draw_set_transform(Vector2(0, 0), 0, Vector2(1.3, 0.75))
			draw_circle(Vector2.ZERO, 22, _c(Color("e8742a")))
			draw_set_transform(Vector2.ZERO)
			for x in [-14, -4, 12, 20]:
				draw_rect(Rect2(x - 3, 10, 6, 20), _c(Color("3a2a20")))
			draw_colored_polygon(PackedVector2Array([Vector2(18, -26), Vector2(48, -10), Vector2(20, 2)]), _c(Color("e8742a")))
			draw_colored_polygon(PackedVector2Array([Vector2(30, -12), Vector2(48, -10), Vector2(30, -2)]), _c(Color.WHITE))
			draw_colored_polygon(PackedVector2Array([Vector2(18, -26), Vector2(22, -42), Vector2(30, -22)]), _c(Color("c95a1a")))
			draw_circle(Vector2(48, -10), 3, dark)
			draw_circle(Vector2(28, -16), 2.5, dark)
		"jednorozec":
			var glow := 0.5 + 0.5 * sin(_t * 3.0)
			if not silhouette:
				draw_circle(Vector2(0, -10), 70, Color(1, 0.95, 1, 0.15 + glow * 0.15))
			draw_set_transform(Vector2.ZERO, 0, Vector2(1, 0.6))
			draw_circle(Vector2.ZERO, 34, _c(Color("fbf7ff")))
			draw_set_transform(Vector2.ZERO)
			for x in [-20, -8, 12, 22]:
				draw_rect(Rect2(x - 4, 10, 8, 30), _c(Color("efe6fa")))
			draw_line(Vector2(24, -8), Vector2(38, -36), _c(Color("fbf7ff")), 14)
			draw_circle(Vector2(44, -40), 14, _c(Color("fbf7ff")))
			draw_colored_polygon(PackedVector2Array([Vector2(42, -52), Vector2(54, -84), Vector2(52, -50)]), _c(Color("ffd84d")))
			for i in 4:
				draw_circle(Vector2(28 - i * 4, -44 + i * 10), 8, _c(Color.from_hsv(i / 4.0, 0.5, 1.0)))
			draw_circle(Vector2(-36, 0), 9, _c(Color.from_hsv(0.8, 0.4, 1.0)))
			draw_circle(Vector2(-42, 10), 8, _c(Color.from_hsv(0.6, 0.4, 1.0)))
			draw_circle(Vector2(48, -42), 2.5, dark)
			if not silhouette:
				for i in 4:
					var a := _t * 1.5 + i * TAU / 4.0
					draw_circle(Vector2.from_angle(a) * 55 + Vector2(0, -10), 3, Color(1, 0.95, 0.5, glow))
	draw_set_transform(Vector2.ZERO)
	if silhouette:
		draw_string(ThemeDB.fallback_font, Vector2(-10, 12), "?", HORIZONTAL_ALIGNMENT_CENTER, -1, 40, Color.WHITE)
