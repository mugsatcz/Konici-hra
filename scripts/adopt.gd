extends Node2D
## Adopce nového koníka: výběr srsti, hřívy a jména. Stojí hvězdy za splněné úkoly.

const PonyArt := preload("res://scripts/pony/pony_art.gd")

var _pony: Node2D
var _coat := 0
var _mane := 0
var _name_edit: LineEdit
var _info: Label


func _ready() -> void:
	Audio.music("stable")
	_pony = PonyArt.new()
	_pony.use_current = false
	_pony.position = Vector2(300, 440)
	_pony.scale = Vector2(1.6, 1.6)
	add_child(_pony)

	var ui := CanvasLayer.new()
	add_child(ui)
	var title := UiStyle.label("Nový koník", 48, Color.WHITE)
	title.add_theme_color_override("font_outline_color", Color("e8742a"))
	title.add_theme_constant_override("outline_size", 12)
	title.position = Vector2(40, 20)
	ui.add_child(title)

	_info = UiStyle.label("", 26, Color("4a2c1a"))
	_info.position = Vector2(40, 96)
	ui.add_child(_info)

	var col := VBoxContainer.new()
	col.position = Vector2(600, 40)
	col.add_theme_constant_override("separation", 12)
	ui.add_child(col)

	col.add_child(UiStyle.label("Srst", 28))
	var coats := HBoxContainer.new()
	coats.add_theme_constant_override("separation", 8)
	col.add_child(coats)
	for i in WorldData.COATS.size():
		var c: Array = WorldData.COATS[i]
		var b := UiStyle.big_button(c[0], Color(c[1]).darkened(0.1), Vector2(100, 60))
		b.add_theme_font_size_override("font_size", 18)
		b.pressed.connect(func():
			_coat = i
			_update())
		coats.add_child(b)

	col.add_child(UiStyle.label("Hříva", 28))
	var manes := HBoxContainer.new()
	manes.add_theme_constant_override("separation", 8)
	col.add_child(manes)
	for i in WorldData.MANES.size():
		var b := UiStyle.big_button("", Color(WorldData.MANES[i]), Vector2(70, 60))
		b.pressed.connect(func():
			_mane = i
			_update())
		manes.add_child(b)

	col.add_child(UiStyle.label("Jméno", 28))
	var name_row := HBoxContainer.new()
	name_row.add_theme_constant_override("separation", 10)
	col.add_child(name_row)
	_name_edit = LineEdit.new()
	_name_edit.custom_minimum_size = Vector2(330, 64)
	_name_edit.max_length = 14
	_name_edit.add_theme_font_size_override("font_size", 30)
	_name_edit.text = WorldData.PONY_NAMES[randi() % WorldData.PONY_NAMES.size()]
	name_row.add_child(_name_edit)
	var dice := UiStyle.big_button("Jiné jméno", Color("3fa9f5"), Vector2(220, 64))
	dice.add_theme_font_size_override("font_size", 24)
	dice.pressed.connect(func(): _name_edit.text = WorldData.PONY_NAMES[randi() % WorldData.PONY_NAMES.size()])
	name_row.add_child(dice)

	var adopt := UiStyle.big_button("Přivést do stáje", Color("5cb85c"), Vector2(360, 90))
	adopt.position = Vector2(600, 610)
	adopt.pressed.connect(_adopt)
	ui.add_child(adopt)

	var back := UiStyle.big_button("Zpět", Color("e0a526"))
	back.position = Vector2(1070, 610)
	back.pressed.connect(func(): Scenes.go("res://scenes/stable.tscn"))
	ui.add_child(back)
	_update()


func _update() -> void:
	var c: Array = WorldData.COATS[_coat]
	_pony.apply({"coat": c[1], "mane": WorldData.MANES[_mane], "spots": c[2]})
	_pony.love()
	if GameState.ponies.size() >= GameState.MAX_PONIES:
		_info.text = "Stáj je plná, víc koníků se nevejde."
	elif GameState.stars < GameState.ADOPT_STARS:
		_info.text = "Potřebuješ %d hvězdy (máš %d).\nHvězdy dostaneš za úkoly na procházce." % [GameState.ADOPT_STARS, GameState.stars]
	else:
		_info.text = "Za %d hvězdy přivedeš kamaráda.\nMáš %d." % [GameState.ADOPT_STARS, GameState.stars]


func _adopt() -> void:
	var c: Array = WorldData.COATS[_coat]
	var chosen := _name_edit.text.strip_edges()
	if chosen == "":
		chosen = WorldData.PONY_NAMES[0]
	if GameState.adopt(chosen, Color(c[1]), Color(WorldData.MANES[_mane]), c[2]):
		Audio.play("treasure", 0.0)
		Scenes.go("res://scenes/stable.tscn")
	else:
		Audio.play("boing")
		UiStyle.bounce(_info)


func _draw() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Color("ffe9cc"))
	draw_circle(Vector2(300, 900), 520, Color("8fd16f"))
	draw_rect(Rect2(560, 20, 700, 400), Color(1, 1, 1, 0.55))
