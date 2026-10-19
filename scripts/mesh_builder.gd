extends RefCounted
## Sbírá kreslení (kruhy, čáry, mnohoúhelníky) do jedné sítě trojúhelníků.
## Má stejné funkce jako CanvasItem, takže DrawKit i kreslicí funkce světa fungují beze změny.
## Hotová síť se pak kreslí jedním voláním grafické karty místo stovek, což tablet ocení nejvíc.

var _verts := PackedVector2Array()
var _colors := PackedColorArray()
var _xf := Transform2D.IDENTITY
var _scale := 1.0


func draw_set_transform(pos: Vector2, rot := 0.0, scale := Vector2.ONE) -> void:
	_xf = Transform2D(rot, scale, 0.0, pos)
	_scale = maxf(absf(scale.x), absf(scale.y))


func _tri(a: Vector2, b: Vector2, c: Vector2, col: Color) -> void:
	_verts.append(_xf * a)
	_verts.append(_xf * b)
	_verts.append(_xf * c)
	_colors.append(col)
	_colors.append(col)
	_colors.append(col)


func _quad(a: Vector2, b: Vector2, c: Vector2, d: Vector2, col: Color) -> void:
	_tri(a, b, c, col)
	_tri(a, c, d, col)


func draw_circle(c: Vector2, r: float, col: Color, _filled := true, _width := -1.0, _aa := false) -> void:
	var n := clampi(int(r * _scale * 0.5) + 10, 12, 64)
	var prev := c + Vector2(r, 0)
	for i in range(1, n + 1):
		var p := c + Vector2.from_angle(i * TAU / n) * r
		_tri(c, prev, p, col)
		prev = p


func draw_line(a: Vector2, b: Vector2, col: Color, width := 1.0, _aa := false) -> void:
	var dir := b - a
	if dir.length_squared() < 0.0001:
		return
	var side := dir.normalized().orthogonal() * maxf(width, 1.0) * 0.5
	_quad(a + side, b + side, b - side, a - side, col)


func draw_polyline(pts: PackedVector2Array, col: Color, width := 1.0, _aa := false) -> void:
	for i in pts.size() - 1:
		draw_line(pts[i], pts[i + 1], col, width)
	if width >= 4.0:
		for i in range(1, pts.size() - 1):
			draw_circle(pts[i], width * 0.5, col)


func draw_arc(c: Vector2, r: float, from: float, to: float, points: int, col: Color, width := 1.0, aa := false) -> void:
	var pts := PackedVector2Array()
	for i in points:
		pts.append(c + Vector2.from_angle(lerpf(from, to, i / float(points - 1))) * r)
	draw_polyline(pts, col, width, aa)


func draw_rect(rect: Rect2, col: Color, filled := true, width := 1.0) -> void:
	if filled:
		_quad(rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y), col)
		return
	var p := rect.position
	var e := rect.end
	var h := width * 0.5
	draw_rect(Rect2(p - Vector2(h, h), Vector2(rect.size.x + width, width)), col)
	draw_rect(Rect2(Vector2(p.x - h, e.y - h), Vector2(rect.size.x + width, width)), col)
	draw_rect(Rect2(p + Vector2(-h, h), Vector2(width, rect.size.y - width)), col)
	draw_rect(Rect2(Vector2(e.x - h, p.y + h), Vector2(width, rect.size.y - width)), col)


func draw_colored_polygon(pts: PackedVector2Array, col: Color) -> void:
	var idx := Geometry2D.triangulate_polygon(pts)
	for i in range(0, idx.size(), 3):
		_tri(pts[idx[i]], pts[idx[i + 1]], pts[idx[i + 2]], col)


func is_empty() -> bool:
	return _verts.is_empty()


## Vytvoří z nasbíraných trojúhelníků síť pro MeshInstance2D (nebo null, když nic nebylo nakresleno).
func commit() -> ArrayMesh:
	if _verts.is_empty():
		return null
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = _verts
	arrays[Mesh.ARRAY_COLOR] = _colors
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh
