extends Node2D
## Nastavení pro rodiče, schované za jednoduchým příkladem (aby ho děti omylem neotevřely).

var _gate: Control
var _settings: Control
var _answer := 0
var _reset_armed := false
var _sound_button: Button
var _speed_button: Button
var _reset_button: Button


func _ready() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)
	var title := UiStyle.label("Pro rodiče", 48, Color("4a2c1a"))
	title.position = Vector2(40, 20)
	ui.add_child(title)
	var back := UiStyle.big_button("Zpět", Color("e0a526"))
	back.position = Vector2(1070, 620)
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
	ui.add_child(back)

	_gate = VBoxContainer.new()
	_gate.position = Vector2(40, 140)
	_gate.add_theme_constant_override("separation", 20)
	ui.add_child(_gate)
	var a := randi_range(6, 9)
	var b := randi_range(6, 9)
	_answer = a * b
	_gate.add_child(UiStyle.label("Kolik je %d × %d?" % [a, b], 40))
	var choices := HBoxContainer.new()
	choices.add_theme_constant_override("separation", 20)
	_gate.add_child(choices)
	var options := [_answer, _answer + randi_range(1, 5), _answer - randi_range(1, 5)]
	options.shuffle()
	for opt in options:
		var button := UiStyle.big_button(str(opt), Color("8a8f99"))
		button.pressed.connect(func():
			if opt == _answer:
				_gate.visible = false
				_settings.visible = true
			else:
				get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
		choices.add_child(button)

	_settings = VBoxContainer.new()
	_settings.position = Vector2(40, 140)
	_settings.add_theme_constant_override("separation", 20)
	_settings.visible = false
	ui.add_child(_settings)
	_sound_button = UiStyle.big_button("", Color("3fa9f5"), Vector2(520, 80))
	_sound_button.pressed.connect(func():
		GameState.set_sound(not GameState.sound_on)
		_refresh())
	_settings.add_child(_sound_button)
	_speed_button = UiStyle.big_button("", Color("7cb342"), Vector2(520, 80))
	_speed_button.pressed.connect(func():
		GameState.set_decay_scale(0.5 if GameState.decay_scale >= 1.0 else 1.0)
		_refresh())
	_settings.add_child(_speed_button)
	_reset_button = UiStyle.big_button("", Color("d9534f"), Vector2(520, 80))
	_reset_button.pressed.connect(func():
		if _reset_armed:
			GameState.reset()
			_reset_armed = false
		else:
			_reset_armed = true
		_refresh())
	_settings.add_child(_reset_button)
	var note := UiStyle.label("Hra je bez reklam a nákupů a nic neposílá na internet.\nUkládá se jen do tohoto zařízení.", 24)
	_settings.add_child(note)
	_refresh()


func _refresh() -> void:
	_sound_button.text = "Zvuk: " + ("zapnutý" if GameState.sound_on else "vypnutý")
	_speed_button.text = "Potřeby koníků klesají: " + ("pomaleji" if GameState.decay_scale < 1.0 else "normálně")
	_reset_button.text = "Opravdu smazat? Ťukni znovu." if _reset_armed else "Začít hru od začátku"


func _draw() -> void:
	draw_rect(get_viewport_rect(), Color("eef1f5"))
