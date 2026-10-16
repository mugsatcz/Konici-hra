extends Node2D
## Kreslená postavička dítěte, které vede koníka.

var walking := false
var facing := 1.0:
	set(value):
		facing = signf(value) if value != 0.0 else facing
## Kam vede vodítko (v souřadnicích rodiče, např. hlava koníka).
var rope_target := Vector2.ZERO

var _t := 0.0


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	var skin := Color("f5c7a0")
	var o := DrawKit.OUTLINE
	var f := facing
	var swing := sin(_t * 10.0) * 9.0 if walking else 0.0
	var bob := -absf(sin(_t * 10.0)) * 3.0 if walking else sin(_t * 2.0) * 0.8
	DrawKit.ellipse(self, Vector2(0, 42), 24, 7, Color(0, 0, 0, 0.18), 0, 0)
	# Nohy a botky
	for side in [-1.0, 1.0]:
		var foot := Vector2(side * 5 + swing * side, 36)
		DrawKit.capsule(self, Vector2(side * 5, 6 + bob), foot, 5, Color("2e5fa8"), 3)
		DrawKit.ellipse(self, foot + Vector2(3 * f, 3), 8, 5, Color("e8505b"), 0, 3)
	# Zadní ruka
	DrawKit.capsule(self, Vector2(-6 * f, -16 + bob), Vector2(-12 * f + swing * 0.5, 2 + bob), 4, skin, 3)
	# Tričko
	DrawKit.poly(self, PackedVector2Array([Vector2(-13, -24 + bob), Vector2(13, -24 + bob), Vector2(15, 10 + bob), Vector2(-15, 10 + bob)]), Color("ffb02e"), 3)
	draw_line(Vector2(-14, -4 + bob), Vector2(14, -4 + bob), Color("ff7a1c"), 4)
	# Ruka s vodítkem
	var hand := Vector2(16 * f, -6 + bob)
	DrawKit.capsule(self, Vector2(8 * f, -18 + bob), hand, 4, skin, 3)
	if rope_target != Vector2.ZERO:
		var local_target := to_local(get_parent().to_global(rope_target))
		var mid := (hand + local_target) / 2.0 + Vector2(0, 20)
		var curve := PackedVector2Array()
		for i in 13:
			var t := i / 12.0
			curve.append(hand.lerp(mid, t).lerp(mid.lerp(local_target, t), t))
		draw_polyline(curve, o, 5)
		draw_polyline(curve, Color("e8505b"), 3)
	# Hlava, vlasy s culíkem, obličej
	var h := Vector2(0, -40 + bob)
	DrawKit.ellipse(self, h + Vector2(-15 * f, 2 + swing * 0.2), 7, 9, Color("8a4b22"), 0, 3)
	DrawKit.ellipse(self, h, 16, 16, skin, 0, 3)
	draw_arc(h + Vector2(-2 * f, -3), 15, PI * 0.95, TAU * 1.02, 14, Color("8a4b22"), 10)
	draw_circle(h + Vector2(7 * f, 0), 2.6, o)
	draw_circle(h + Vector2(8 * f, -1), 0.9, Color.WHITE)
	draw_arc(h + Vector2(7 * f, 6), 4.5, 0.3, 2.6, 6, o, 2)
	draw_circle(h + Vector2(1 * f, 5), 3.5, Color(1, 0.5, 0.55, 0.45))
