extends SceneTree
## Rychlý test: načte všechny scény, chvíli je nechá běžet a ověří herní logiku.
## Spuštění: godot --headless --script res://tests/smoke_test.gd

const SCENES := ["res://scenes/main_menu.tscn", "res://scenes/stable.tscn", "res://scenes/walk.tscn"]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures := 0
	var state = root.get_node("GameState")
	state.reset()
	for path in SCENES:
		var scene: PackedScene = load(path)
		if scene == null:
			push_error("Nelze načíst " + path)
			failures += 1
			continue
		var node := scene.instantiate()
		root.add_child(node)
		for i in 10:
			await process_frame
		node.queue_free()
		await process_frame
		print("OK ", path)

	var hunger: float = state.needs.hunger
	state.feed()
	failures += _check(state.needs.hunger > hunger, "krmení zvedne jídlo")
	state.poops = 2
	state.clean_poop()
	failures += _check(state.poops == 1, "úklid odebere koblížek")
	state.add_item("apple")
	failures += _check(state.inventory.apple == 1, "sebrané jablko je v inventáři")
	state.save_game()
	state.inventory.apple = 0
	state.load_game()
	failures += _check(state.inventory.apple == 1, "uložení a načtení hry")
	state.reset()

	print("Hotovo, chyb: ", failures)
	quit(1 if failures > 0 else 0)


func _check(ok: bool, what: String) -> int:
	print(("OK " if ok else "CHYBA ") + what)
	return 0 if ok else 1
