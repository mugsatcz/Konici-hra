extends Node2D
## Obchůdek: za nasbírané věci se kupují ozdoby. Koupené ozdoby jde nasadit a sundat.

const PonyArt := preload("res://scripts/pony/pony_art.gd")

var _wallet: Label
var _buttons := {}


func _ready() -> void:
	var pony := PonyArt.new()
	pony.position = Vector2(250, 420)
	pony.scale = Vector2(1.5, 1.5)
	add_child(pony)

	var ui := CanvasLayer.new()
	add_child(ui)
	var title := UiStyle.label("Obchůdek", 48, Color.WHITE)
	title.add_theme_color_override("font_outline_color", Color("c0508a"))
	title.add_theme_constant_override("outline_size", 12)
	title.position = Vector2(40, 20)
	ui.add_child(title)

	_wallet = UiStyle.label("", 28, Color("4a2c1a"))
	_wallet.position = Vector2(40, 100)
	ui.add_child(_wallet)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.position = Vector2(500, 30)
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 14)
	ui.add_child(grid)
	for id in WorldData.SHOP:
		var button := UiStyle.big_button("", Color("c06fd8"), Vector2(360, 84))
		button.add_theme_font_size_override("font_size", 21)
		button.pressed.connect(_press.bind(id))
		grid.add_child(button)
		_buttons[id] = button

	var back := UiStyle.big_button("Zpět", Color("e0a526"))
	back.position = Vector2(1060, 620)
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/stable.tscn"))
	ui.add_child(back)
	_refresh()


func _press(id: String) -> void:
	if id in GameState.owned:
		GameState.toggle_worn(id)
	elif not GameState.buy(id):
		_wallet.text = "Na tohle ještě nemáš dost. Nasbírej víc na procházce!"
		UiStyle.bounce(_wallet)
		return
	_refresh()


func _cost_text(cost: Dictionary) -> String:
	var parts := []
	for item in cost:
		parts.append(WorldData.count_text(item, cost[item]))
	return ", ".join(parts)


func _refresh() -> void:
	var inv := GameState.inventory
	_wallet.text = "Máš: %s, %s, %s" % [WorldData.count_text("apple", inv.apple), WorldData.count_text("flower", inv.flower), WorldData.count_text("horseshoe", inv.horseshoe)]
	for id in _buttons:
		var item: Dictionary = WorldData.SHOP[id]
		var text: String = item.name + "\n"
		if id in GameState.owned:
			text += "Sundat" if GameState.wears(id) else "Nasadit"
		else:
			text += _cost_text(item.cost)
		_buttons[id].text = text
		_buttons[id].modulate = Color.WHITE if id in GameState.owned or GameState.can_afford(item.cost) else Color(1, 1, 1, 0.55)
	queue_redraw()


func _draw() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Color("ffd9ec"))
	for x in range(0, int(size.x), 60):
		draw_rect(Rect2(x, 0, 30, size.y), Color("ffcfe6"))
	draw_rect(Rect2(0, 520, 480, 200), Color("f2cf6b"))
