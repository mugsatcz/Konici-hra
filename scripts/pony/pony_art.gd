extends Node2D
## Zástupná kreslená grafika koníka (do doby, než bude hotová finální grafika).

@export var coat_color := Color("c8834a")
@export var mane_color := Color("f2d16b")
@export var spots := false
## Když je true, bere barvy z právě vybraného koníka ve hře.
@export var use_current := true
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

## Když koník jde, hýbe nohama.
var walking := false

var _t := 0.0
var _hearts := 0.0


func _process(delta: float) -> void:
	if use_current:
		apply(GameState.current())
	_t += delta
	_hearts = maxf(0.0, _hearts - delta)
	queue_redraw()


func apply(pony: Dictionary) -> void:
	coat_color = Color(pony.coat)
	mane_color = Color(pony.mane)
	spots = pony.spots


## Nad koníkem vyletí srdíčka (pohlazení, radost).
func love() -> void:
	_hearts = 1.4


func _draw() -> void:
	var outline := Color("4a2c1a")
	var bob := sin(_t * 2.0) * 2.0
	# Stín
	draw_set_transform(Vector2(0, 62), 0, Vector2(1, 0.25))
	draw_circle(Vector2.ZERO, 70, Color(0, 0, 0, 0.18))
	draw_set_transform(Vector2.ZERO)
	# Nohy
	var hoof := Color("e8b923") if GameState.wears("golden_hooves") else outline
	for i in 4:
		var x: float = [-38, -18, 22, 42][i]
		var step := sin(_t * 9.0 + i * PI * 0.5) * 7.0 if walking else 0.0
		draw_line(Vector2(x, 10), Vector2(x + step, 56), coat_color.darkened(0.1), 14)
		draw_rect(Rect2(x + step - 8, 52, 16, 10), hoof)
	# Ocas
	var tail := PackedVector2Array([Vector2(-55, -10 + bob), Vector2(-85, 5 + sin(_t * 3) * 6), Vector2(-75, 30), Vector2(-55, 5 + bob)])
	draw_colored_polygon(tail, Color("c77dff") if GameState.wears("rainbow") else mane_color)
	# Tělo
	draw_set_transform(Vector2(0, -5 + bob), 0, Vector2(1.0, 0.6))
	draw_circle(Vector2.ZERO, 62, coat_color)
	draw_set_transform(Vector2.ZERO)
	if spots:
		for sp in [[Vector2(-30, -15), 20.0], [Vector2(10, 5), 16.0], [Vector2(28, -25), 13.0], [Vector2(-45, 10), 11.0]]:
			draw_circle(sp[0] + Vector2(0, bob), sp[1], Color("fbf7f0"))
	if GameState.wears("star_blanket"):
		draw_rect(Rect2(-35, -38 + bob, 60, 44), Color("27306b"))
		for sp in [Vector2(-25, -28), Vector2(-5, -12), Vector2(12, -30), Vector2(-20, -2), Vector2(15, -6)]:
			_star(sp + Vector2(0, bob), 6, Color("ffe066"))
	elif GameState.wears("blanket"):
		draw_rect(Rect2(-35, -38 + bob, 60, 44), Color("3b7dd8"))
		draw_rect(Rect2(-35, -38 + bob, 60, 44), Color("ffe066"), false, 5)
		draw_circle(Vector2(-5, -16 + bob), 7, Color("ffe066"))
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
	var rainbow := GameState.wears("rainbow")
	for i in 5:
		var c := Color.from_hsv(i / 5.0, 0.6, 1.0) if rainbow else mane_color
		draw_circle(Vector2(48 + i * 6, -80 + i * 13 + bob), 11, c)
	if GameState.wears("bow"):
		var b := Vector2(52, -88 + bob)
		draw_colored_polygon(PackedVector2Array([b, b + Vector2(-16, -10), b + Vector2(-16, 10)]), Color("ff5fa2"))
		draw_colored_polygon(PackedVector2Array([b, b + Vector2(16, -10), b + Vector2(16, 10)]), Color("ff5fa2"))
		draw_circle(b, 5, Color("d63f86"))
	if GameState.wears("crown"):
		for i in 5:
			var f := Vector2(62 + i * 9, -94 + absf(i - 2) * 3 + bob)
			draw_circle(f, 6, [Color("ff7fc4"), Color("ffe066"), Color("8fd3ff")][i % 3])
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
	if _hearts > 0.0:
		for i in 3:
			var hp := Vector2(70 + i * 22 - 22, -120 - (1.4 - _hearts) * 60.0 - i * 10)
			_heart(hp, 10, Color(1, 0.35, 0.55, minf(1.0, _hearts)))
	# Jezdec (zatím jednoduchá postavička)
	if rider:
		draw_rect(Rect2(-20, -55 + bob, 40, 10), Color("d9534f"))
		draw_rect(Rect2(-10, -100 + bob, 20, 45), Color("3b7dd8"))
		draw_circle(Vector2(0, -112 + bob), 15, Color("f5c7a0"))
		draw_arc(Vector2(0, -116 + bob), 15, PI, TAU, 10, Color("7a4b2a"), 8)


func _heart(p: Vector2, r: float, c: Color) -> void:
	draw_circle(p + Vector2(-r * 0.5, 0), r * 0.6, c)
	draw_circle(p + Vector2(r * 0.5, 0), r * 0.6, c)
	draw_colored_polygon(PackedVector2Array([p + Vector2(-r * 1.05, r * 0.2), p + Vector2(r * 1.05, r * 0.2), p + Vector2(0, r * 1.3)]), c)


func _star(p: Vector2, r: float, c: Color) -> void:
	var pts := PackedVector2Array()
	for i in 10:
		pts.append(p + Vector2.from_angle(-PI / 2 + i * PI / 5) * (r if i % 2 == 0 else r * 0.45))
	draw_colored_polygon(pts, c)
