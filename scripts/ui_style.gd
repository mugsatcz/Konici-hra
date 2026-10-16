class_name UiStyle
## Společný vzhled velkých dětských tlačítek.


static func big_button(text: String, color: Color, min_size := Vector2(170, 90)) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = min_size
	button.add_theme_font_size_override("font_size", 30)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	for state in ["normal", "hover", "pressed", "focus"]:
		var box := StyleBoxFlat.new()
		box.bg_color = color if state != "pressed" else color.darkened(0.2)
		box.set_corner_radius_all(28)
		box.border_color = color.darkened(0.35)
		box.set_border_width_all(4)
		box.shadow_color = Color(0, 0, 0, 0.25)
		box.shadow_size = 4
		box.shadow_offset = Vector2(0, 4)
		if state == "focus":
			box.draw_center = false
		button.add_theme_stylebox_override(state, box)
	button.pressed.connect(func():
		bounce(button)
		Audio.play("click"))
	return button


static func bounce(node: Control) -> void:
	node.pivot_offset = node.size / 2.0
	var tween := node.create_tween()
	tween.tween_property(node, "scale", Vector2(1.12, 1.12), 0.08)
	tween.tween_property(node, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK)


static func label(text: String, size := 32, color := Color("4a2c1a")) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l
