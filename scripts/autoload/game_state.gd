extends Node
## Stav celé hry: potřeby koníka, nasbírané věci a ukládání.

signal needs_changed
signal inventory_changed

const SAVE_PATH := "user://save.json"
## O kolik bodů za minutu hraní klesají potřeby (0–100).
const DECAY_PER_MINUTE := {"hunger": 4.0, "thirst": 5.0, "grooming": 2.0}
## Mezi seancemi potřeby neklesnou pod tuto hodnotu (nikdo se nemá vrátit ke smutnému koníkovi).
const OFFLINE_FLOOR := 40.0

var pony_name := "Jiskra"
## 100 = vše v pořádku, 0 = koník moc potřebuje pomoc.
var needs := {"hunger": 80.0, "thirst": 80.0, "grooming": 80.0}
## Počet koblížků v boxu, které je potřeba uklidit.
var poops := 0
var inventory := {"apple": 0, "flower": 0, "horseshoe": 0}

var _save_timer := 0.0


func _ready() -> void:
	load_game()


func _process(delta: float) -> void:
	for need in DECAY_PER_MINUTE:
		needs[need] = maxf(0.0, needs[need] - DECAY_PER_MINUTE[need] * delta / 60.0)
	needs_changed.emit()
	_save_timer += delta
	if _save_timer > 10.0:
		_save_timer = 0.0
		save_game()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		save_game()


## Radost se počítá z ostatních potřeb a čistoty boxu.
func happiness() -> float:
	var total := 0.0
	for need in needs:
		total += needs[need]
	return clampf(total / needs.size() - poops * 8.0, 0.0, 100.0)


func feed(amount := 30.0) -> void:
	needs.hunger = minf(100.0, needs.hunger + amount)
	# Po jídle koník občas udělá koblížky.
	if randf() < 0.6:
		poops = mini(poops + 1, 5)
	needs_changed.emit()


func give_water(amount := 35.0) -> void:
	needs.thirst = minf(100.0, needs.thirst + amount)
	needs_changed.emit()


func brush(amount := 4.0) -> void:
	needs.grooming = minf(100.0, needs.grooming + amount)
	needs_changed.emit()


func clean_poop() -> void:
	poops = maxi(0, poops - 1)
	needs_changed.emit()


func add_item(item: String, count := 1) -> void:
	inventory[item] = inventory.get(item, 0) + count
	inventory_changed.emit()


## Po procházce je koník trochu hladový, žíznivý a zablácený.
func after_walk() -> void:
	needs.hunger = maxf(0.0, needs.hunger - 10.0)
	needs.thirst = maxf(0.0, needs.thirst - 10.0)
	needs.grooming = maxf(0.0, needs.grooming - 20.0)
	needs_changed.emit()
	save_game()


func save_game() -> void:
	var data := {
		"pony_name": pony_name,
		"needs": needs,
		"poops": poops,
		"inventory": inventory,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var data = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if typeof(data) != TYPE_DICTIONARY:
		return
	pony_name = data.get("pony_name", pony_name)
	for need in needs:
		needs[need] = maxf(float(data.get("needs", {}).get(need, needs[need])), OFFLINE_FLOOR)
	poops = int(data.get("poops", 0))
	for item in data.get("inventory", {}):
		inventory[item] = int(data.inventory[item])


func reset() -> void:
	pony_name = "Jiskra"
	needs = {"hunger": 80.0, "thirst": 80.0, "grooming": 80.0}
	poops = 0
	inventory = {"apple": 0, "flower": 0, "horseshoe": 0}
	save_game()
	needs_changed.emit()
	inventory_changed.emit()
