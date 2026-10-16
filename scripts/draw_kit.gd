class_name DrawKit
## Pomůcky pro kreslenou grafiku: tvary s obrysem, jak je známe z kreslených seriálů.

const OUTLINE := Color("3d2416")


static func ellipse_points(c: Vector2, rx: float, ry: float, rot := 0.0, segments := 0) -> PackedVector2Array:
	if segments <= 0:
		segments = clampi(int(maxf(rx, ry) / 3.0), 24, 160)
	var pts := PackedVector2Array()
	for i in segments:
		var a := i * TAU / segments
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry).rotated(rot))
	return pts


## Elipsa s obrysem; width 0 = bez obrysu.
static func ellipse(ci: CanvasItem, c: Vector2, rx: float, ry: float, col: Color, rot := 0.0, width := 4.0, outline := OUTLINE) -> void:
	if width > 0.0:
		ci.draw_colored_polygon(ellipse_points(c, rx + width, ry + width, rot), outline)
	ci.draw_colored_polygon(ellipse_points(c, rx, ry, rot), col)


## Kulatá „tyčka“ (noha, ruka, krk) s obrysem.
static func capsule(ci: CanvasItem, a: Vector2, b: Vector2, r: float, col: Color, width := 4.0, outline := OUTLINE) -> void:
	if width > 0.0:
		ci.draw_line(a, b, outline, (r + width) * 2.0)
		ci.draw_circle(a, r + width, outline)
		ci.draw_circle(b, r + width, outline)
	ci.draw_line(a, b, col, r * 2.0)
	ci.draw_circle(a, r, col)
	ci.draw_circle(b, r, col)


## Mnohoúhelník s obrysem (obrys se kreslí jako silná čára po obvodu).
static func poly(ci: CanvasItem, pts: PackedVector2Array, col: Color, width := 4.0, outline := OUTLINE) -> void:
	if width > 0.0:
		var closed := pts.duplicate()
		closed.append(pts[0])
		ci.draw_polyline(closed, outline, width * 2.0, true)
		for p in pts:
			ci.draw_circle(p, width, outline)
	ci.draw_colored_polygon(pts, col)


static func heart(ci: CanvasItem, p: Vector2, r: float, c: Color) -> void:
	ci.draw_circle(p + Vector2(-r * 0.5, 0), r * 0.6, c)
	ci.draw_circle(p + Vector2(r * 0.5, 0), r * 0.6, c)
	ci.draw_colored_polygon(PackedVector2Array([p + Vector2(-r * 1.05, r * 0.2), p + Vector2(r * 1.05, r * 0.2), p + Vector2(0, r * 1.3)]), c)


static func star(ci: CanvasItem, p: Vector2, r: float, c: Color) -> void:
	var pts := PackedVector2Array()
	for i in 10:
		pts.append(p + Vector2.from_angle(-PI / 2 + i * PI / 5) * (r if i % 2 == 0 else r * 0.45))
	ci.draw_colored_polygon(pts, c)


## Obláček z několika koleček se společným obrysem (koruna stromu, keřík, mrak).
static func blob(ci: CanvasItem, parts: Array, col: Color, width := 4.0, outline := OUTLINE) -> void:
	if width > 0.0:
		for p in parts:
			ci.draw_circle(p[0], p[1] + width, outline)
	for p in parts:
		ci.draw_circle(p[0], p[1], col)
