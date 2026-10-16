extends Node2D
## Zástupná kreslená zvířátka do světa a do alba.

var kind := "zajicek"
## Neobjevené zvíře se v albu kreslí jen jako stín.
var silhouette := false
var animated := true
var _t := 0.0


func _process(delta: float) -> void:
	if animated:
		_t += delta
		queue_redraw()


func _c(color: Color) -> Color:
	return Color(0.35, 0.35, 0.4, 0.5) if silhouette else color


func _draw() -> void:
	var dark := _c(Color("3a2a20"))
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
	if silhouette:
		draw_string(ThemeDB.fallback_font, Vector2(-10, 12), "?", HORIZONTAL_ALIGNMENT_CENTER, -1, 40, Color.WHITE)
