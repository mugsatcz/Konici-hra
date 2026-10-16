extends SceneTree
## Rychlý test: načte všechny scény, chvíli je nechá běžet a ověří herní logiku.
## Spuštění: godot --headless --script res://tests/smoke_test.gd

const SCENES := ["res://scenes/main_menu.tscn", "res://scenes/stable.tscn", "res://scenes/world_map.tscn", "res://scenes/album.tscn", "res://scenes/shop.tscn", "res://scenes/adopt.tscn", "res://scenes/garden.tscn", "res://scenes/parents.tscn"]


func _initialize() -> void:
	# Pojistka: když test spadne uprostřed, nesmí viset donekonečna.
	create_timer(90.0).timeout.connect(func():
		push_error("Test nedoběhl včas.")
		quit(1))
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
		var script: Script = node.get_script()
		if script == null or not script.can_instantiate():
			push_error("Skript scény nejde načíst: " + path)
			failures += 1
		root.add_child(node)
		for i in 10:
			await process_frame
		node.queue_free()
		await process_frame
		print("OK ", path)

	# Procházka ve všech místech světa.
	for area in WorldData.AREAS:
		state.current_area = area
		var walk: Node = load("res://scenes/walk.tscn").instantiate()
		root.add_child(walk)
		for i in 10:
			await process_frame
		walk.queue_free()
		await process_frame
		print("OK procházka ", area)

	state.reset()
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
	failures += _check(not state.is_area_unlocked("rybnicek"), "rybníček je na začátku zamčený")
	state.after_walk()
	failures += _check(state.is_area_unlocked("lesik"), "po procházce se odemkne lesík")
	failures += _check(state.discover("jezek") and not state.discover("jezek"), "objev se zapíše jen jednou")
	state.inventory.flower = 3
	failures += _check(state.buy("bow") and state.wears("bow") and state.inventory.flower == 0, "koupě mašle")
	failures += _check(not state.buy("crown"), "bez kytiček věneček koupit nejde")
	state.toggle_worn("bow")
	failures += _check(not state.wears("bow"), "mašli jde sundat")
	state.grant("crystal")
	failures += _check(state.wears("crystal"), "poklad dá ozdobu")
	var quest = load("res://scripts/walk_quest.gd").new()
	quest.kind = "collect"
	quest.detail = "flower"
	quest.count = 2
	failures += _check(not quest.record("collect", "apple") and not quest.record("collect", "flower") and quest.record("collect", "flower"), "úkol se splní po 2 kytičkách")
	for area in WorldData.AREAS:
		failures += _check(WorldData.TREASURES.has(area) and WorldData.TREASURE_REWARDS.has(WorldData.TREASURES[area].reward), "poklad v místě " + area)
	for id in WorldData.ANIMALS:
		failures += _check(WorldData.ANIMAL_FACTS.has(id), "zvířátko %s má zajímavost" % id)

	# Víc koníků
	state.reset()
	failures += _check(not state.can_adopt(), "bez hvězd adopce nejde")
	state.stars = 3
	failures += _check(state.adopt("Hvězdička", Color.WHITE, Color.PINK, true) and state.ponies.size() == 2 and state.stars == 0, "adopce za 3 hvězdy")
	failures += _check(state.pony_name == "Hvězdička", "nový koník je vybraný")
	state.needs.hunger = 10.0
	state.select_pony(0)
	failures += _check(state.pony_name == "Jiskra" and state.needs.hunger > 10.0, "každý koník má vlastní potřeby")
	state.save_game()
	state.ponies = []
	state.load_game()
	failures += _check(state.ponies.size() == 2 and state.ponies[1].spots, "koníci se uloží i načtou")

	# Zahrádka
	failures += _check(not state.plant(0), "bez hnoje se nesází")
	state.poops = 1
	state.clean_poop()
	failures += _check(state.manure == 1 and state.plant(0), "hnůj z úklidu pohnojí záhonek")
	failures += _check(state.bed_stage(0) == "thirsty" and state.water_bed(0), "záhonek jde zalít")
	failures += _check(state.bed_stage(0) == "growing" and not state.harvest(0), "rostoucí mrkev nejde sklidit")
	state.garden[0].watered_at -= state.GROW_SECONDS + 1.0
	failures += _check(state.harvest(0) and state.inventory.carrot == 2, "sklizeň dá 2 mrkve")
	var hunger_before: float = state.needs.hunger
	failures += _check(state.feed_carrot() and state.needs.hunger > hunger_before and state.inventory.carrot == 1, "krmení mrkví")

	# Stará uložená hra s jedním koníkem
	var f := FileAccess.open(state.SAVE_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify({"pony_name": "Stará", "needs": {"hunger": 90}, "poops": 2, "inventory": {"apple": 4}}))
	f.close()
	state.load_game()
	failures += _check(state.ponies.size() == 1 and state.pony_name == "Stará" and state.poops == 2 and state.inventory.apple == 4, "převod staré uložené hry")
	state.reset()
	state.reset()

	print("Hotovo, chyb: ", failures)
	quit(1 if failures > 0 else 0)


func _check(ok: bool, what: String) -> int:
	print(("OK " if ok else "CHYBA ") + what)
	return 0 if ok else 1
