extends Node2D
## Zástupná kreslená postavička dítěte, které vede koníka.

var walking := false
var facing := 1.0:
	set(value):
		facing = signf(value) if value != 0.0 else facing
## Kam vede vodítko (v souřadnicích rodiče, např. hlava koníka).
var rope_target := Vector2.ZERO

var _t := 0.0


func _process(delta: float) -> void:
	if walking:
		_t += delta
	queue_redraw()


func _draw() -> void:
	var skin := Color("f5c7a0")
	var outline := Color("4a2c1a")
	var swing := sin(_t * 10.0) * 9.0 if walking else 0.0
	var bob := absf(sin(_t * 10.0)) * -3.0 if walking else 0.0
	# Stín
	draw_set_transform(Vector2(0, 40), 0, Vector2(1, 0.3))
	draw_circle(Vector2.ZERO, 26, Color(0, 0, 0, 0.18))
	draw_set_transform(Vector2.ZERO)
	# Nohy
	draw_line(Vector2(-5, 8 + bob), Vector2(-5 + swing, 38), Color("2e5fa8"), 9)
	draw_line(Vector2(5, 8 + bob), Vector2(5 - swing, 38), Color("2e5fa8"), 9)
	draw_circle(Vector2(-5 + swing, 39), 6, outline)
	draw_circle(Vector2(5 - swing, 39), 6, outline)
	# Tělo
	draw_rect(Rect2(-14, -22 + bob, 28, 34), Color("e8505b"))
	# Ruka s vodítkem
	var hand := Vector2(14 * facing, -8 + bob)
	draw_line(Vector2(8 * facing, -16 + bob), hand, skin, 7)
	if rope_target != Vector2.ZERO:
		var local_target := to_local(get_parent().to_global(rope_target))
		var mid := (hand + local_target) / 2.0 + Vector2(0, 18)
		var curve := PackedVector2Array()
		for i in 11:
			var t := i / 10.0
			curve.append(hand.lerp(mid, t).lerp(mid.lerp(local_target, t), t))
		draw_polyline(curve, Color("c0392b"), 3)
	# Hlava a vlasy
	draw_circle(Vector2(0, -36 + bob), 15, skin)
	draw_arc(Vector2(0, -40 + bob), 15, PI, TAU, 10, Color("7a4b2a"), 9)
	draw_circle(Vector2(6 * facing, -37 + bob), 2.5, outline)
	draw_arc(Vector2(5 * facing, -31 + bob), 4, 0.3, 2.8, 6, outline, 2)
