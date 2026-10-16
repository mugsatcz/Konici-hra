extends Node2D
## Zástupná kreslená grafika koníka (do doby, než bude hotová finální grafika).

@export var coat_color := Color("c8834a")
@export var mane_color := Color("f2d16b")
## 0–100, ovlivňuje výraz koníka.
var mood := 100.0:
	set(value):
		mood = value
		queue_redraw()
var facing := 1.0:
	set(value):
		facing = signf(value) if value != 0.0 else facing
		scale.x = absf(scale.x) * facing
var rider := false:
	set(value):
		rider = value
		queue_redraw()

var _t := 0.0


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	var outline := Color("4a2c1a")
	var bob := sin(_t * 2.0) * 2.0
	# Stín
	draw_set_transform(Vector2(0, 62), 0, Vector2(1, 0.25))
	draw_circle(Vector2.ZERO, 70, Color(0, 0, 0, 0.18))
	draw_set_transform(Vector2.ZERO)
	# Nohy
	for x in [-38, -18, 22, 42]:
		draw_rect(Rect2(x - 7, 10, 14, 50), coat_color.darkened(0.1))
		draw_rect(Rect2(x - 8, 52, 16, 10), outline)
	# Ocas
	var tail := PackedVector2Array([Vector2(-55, -10 + bob), Vector2(-85, 5 + sin(_t * 3) * 6), Vector2(-75, 30), Vector2(-55, 5 + bob)])
	draw_colored_polygon(tail, mane_color)
	# Tělo
	draw_set_transform(Vector2(0, -5 + bob), 0, Vector2(1.0, 0.6))
	draw_circle(Vector2.ZERO, 62, coat_color)
	draw_set_transform(Vector2.ZERO)
	# Krk a hlava
	draw_colored_polygon(PackedVector2Array([Vector2(30, -25 + bob), Vector2(55, -75 + bob), Vector2(80, -60 + bob), Vector2(60, -5 + bob)]), coat_color)
	draw_set_transform(Vector2(80, -70 + bob), 0.4, Vector2(1.0, 0.7))
	draw_circle(Vector2.ZERO, 30, coat_color)
	draw_set_transform(Vector2.ZERO)
	draw_circle(Vector2(102, -56 + bob), 14, coat_color.lightened(0.25))
	draw_circle(Vector2(106, -58 + bob), 2.5, outline)
	# Ucho
	draw_colored_polygon(PackedVector2Array([Vector2(62, -88 + bob), Vector2(66, -112 + bob), Vector2(76, -90 + bob)]), coat_color.darkened(0.15))
	# Hříva
	for i in 5:
		draw_circle(Vector2(48 + i * 6, -80 + i * 13 + bob), 11, mane_color)
	# Oko podle nálady
	var eye := Vector2(84, -76 + bob)
	draw_circle(eye, 9, Color.WHITE)
	draw_circle(eye + Vector2(2, 1), 6, outline)
	draw_circle(eye + Vector2(4, -2), 2, Color.WHITE)
	if mood < 40.0:
		draw_line(eye + Vector2(-9, -12), eye + Vector2(9, -8), outline, 3)
	# Pusa
	if mood >= 60.0:
		draw_arc(Vector2(100, -46 + bob), 7, 0.2, 2.6, 8, outline, 2.5)
	else:
		draw_arc(Vector2(100, -38 + bob), 7, 3.6, 5.8, 8, outline, 2.5)
	# Jezdec (zatím jednoduchá postavička)
	if rider:
		draw_rect(Rect2(-20, -55 + bob, 40, 10), Color("d9534f"))
		draw_rect(Rect2(-10, -100 + bob, 20, 45), Color("3b7dd8"))
		draw_circle(Vector2(0, -112 + bob), 15, Color("f5c7a0"))
		draw_arc(Vector2(0, -116 + bob), 15, PI, TAU, 10, Color("7a4b2a"), 8)
