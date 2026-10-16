extends SceneTree
func _initialize() -> void:
	create_timer(80).timeout.connect(func(): quit(1))
	_run.call_deferred()
func _shot(path: String, name: String, setup := Callable(), frames := 40) -> void:
	var node = load(path).instantiate()
	root.add_child(node)
	if setup.is_valid():
		setup.call(node)
	for i in frames:
		await process_frame
	root.get_texture().get_image().save_png(OS.get_environment("OUT") + "/" + name + ".png")
	node.queue_free()
	await process_frame
func _run() -> void:
	var s = root.get_node("GameState")
	s.reset()
	s.owned = ["bow"]
	s.worn = ["bow"]
	await _shot("res://scenes/main_menu.tscn", "p7_menu")
	await _shot("res://scenes/stable.tscn", "p7_staj")
	s.walks = 6
	s.discovered = ["zajicek", "motyl", "jezek", "veverka", "srnka", "kachna", "zabka", "sova", "liska"]
	await _shot("res://scenes/album.tscn", "p7_album")
	s.current_area = "lesik"
	await _shot("res://scenes/walk.tscn", "p7_lesik", func(n):
		n._spawn_animal("veverka", n.pony.position + Vector2(250, -60))
		n._spawn_animal("srnka", n.pony.position + Vector2(-220, 140))
		n._spawn_animal("jezek", n.pony.position + Vector2(260, 160)))
	s.reset()
	quit()
