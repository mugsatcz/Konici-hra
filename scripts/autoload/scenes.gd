extends CanvasLayer
## Přechody mezi obrazovkami: krátké ztmavení a rozjasnění.

var _fade: ColorRect
var _busy := false


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_fade = ColorRect.new()
	_fade.color = Color("fff4e0")
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.modulate.a = 0.0
	add_child(_fade)


func go(path: String) -> void:
	if _busy:
		return
	_busy = true
	_fade.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween := create_tween()
	tween.tween_property(_fade, "modulate:a", 1.0, 0.18)
	await tween.finished
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	var back := create_tween()
	back.tween_property(_fade, "modulate:a", 0.0, 0.25)
	await back.finished
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_busy = false
