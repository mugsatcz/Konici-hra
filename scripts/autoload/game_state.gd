extends Node
## Stav celé hry: koníci a jejich potřeby, nasbírané věci, zahrádka a ukládání.

signal needs_changed
signal inventory_changed
signal looks_changed

const SAVE_PATH := "user://save.json"
## O kolik bodů za minutu hraní klesají potřeby (0–100).
const DECAY_PER_MINUTE := {"hunger": 4.0, "thirst": 5.0, "grooming": 2.0}
## Mezi seancemi potřeby neklesnou pod tuto hodnotu (nikdo se nemá vrátit ke smutnému koníkovi).
const OFFLINE_FLOOR := 40.0

const MAX_PONIES := 4
const ADOPT_STARS := 3
const GARDEN_BEDS := 6
## Za kolik sekund od zalití vyroste mrkev.
const GROW_SECONDS := 120.0

## Každý koník: jméno, barva srsti a hřívy, strakatost, potřeby a koblížky v boxu.
var ponies: Array = [_new_pony("Jiskra", "c8834a", "f2d16b", false)]
var current_pony := 0
## Zkratky na právě vybraného koníka (většina hry pracuje s ním).
var pony_name: String:
	get: return ponies[current_pony].name
	set(value): ponies[current_pony].name = value
## 100 = vše v pořádku, 0 = koník moc potřebuje pomoc.
var needs: Dictionary:
	get: return ponies[current_pony].needs
	set(value): ponies[current_pony].needs = value
## Počet koblížků v boxu, které je potřeba uklidit.
var poops: int:
	get: return ponies[current_pony].poops
	set(value): ponies[current_pony].poops = value
var inventory := {"apple": 0, "flower": 0, "horseshoe": 0, "carrot": 0}
## Uklizený hnůj na hnojišti; hnojí se jím zahrádka.
var manure := 0
## Záhonky: {"state": "empty"|"planted", "watered_at": čas zalití nebo 0}.
var garden: Array = []
## Rodičovské nastavení: 0.5 = potřeby klesají pomaleji.
var decay_scale := 1.0
## Počet dokončených procházek (odemyká nová místa).
var walks := 0
## Objevená zvířátka a místa (album).
var discovered: Array = []
## Koupené ozdoby a ty, které jsou právě nasazené.
var owned: Array = []
var worn: Array = []
## Kam vede příští procházka.
var current_area := "louka"
## Hvězdy za splněné úkoly.
var stars := 0
var sound_on := true

var _save_timer := 0.0
var _notify_timer := 0.0


func _ready() -> void:
	_reset_garden()
	load_game()
	Audio.enabled = sound_on


func _process(delta: float) -> void:
	for pony in ponies:
		for need in DECAY_PER_MINUTE:
			pony.needs[need] = maxf(0.0, pony.needs[need] - DECAY_PER_MINUTE[need] * decay_scale * delta / 60.0)
	# Ubývání je pomalé, stačí dát vědět dvakrát za vteřinu (ne v každém snímku).
	_notify_timer += delta
	if _notify_timer > 0.5:
		_notify_timer = 0.0
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
	if poops > 0:
		manure += 1
	poops = maxi(0, poops - 1)
	needs_changed.emit()


func add_item(item: String, count := 1) -> void:
	inventory[item] = inventory.get(item, 0) + count
	inventory_changed.emit()


## Po procházce je koník trochu hladový, žíznivý a zablácený.
func after_walk() -> void:
	walks += 1
	needs.hunger = maxf(0.0, needs.hunger - 10.0)
	needs.thirst = maxf(0.0, needs.thirst - 10.0)
	needs.grooming = maxf(0.0, needs.grooming - 20.0)
	needs_changed.emit()
	save_game()


func save_game() -> void:
	var data := {
		"version": 2,
		"ponies": ponies,
		"current_pony": current_pony,
		"manure": manure,
		"garden": garden,
		"decay_scale": decay_scale,
		"inventory": inventory,
		"walks": walks,
		"discovered": discovered,
		"owned": owned,
		"worn": worn,
		"stars": stars,
		"sound_on": sound_on,
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
	if data.has("ponies"):
		ponies = []
		for p in data.ponies:
			var pony := _new_pony(str(p.get("name", "Jiskra")), str(p.get("coat", "c8834a")), str(p.get("mane", "f2d16b")), bool(p.get("spots", false)))
			for need in pony.needs:
				pony.needs[need] = maxf(float(p.get("needs", {}).get(need, 80.0)), OFFLINE_FLOOR)
			pony.poops = int(p.get("poops", 0))
			ponies.append(pony)
		if ponies.is_empty():
			ponies = [_new_pony("Jiskra", "c8834a", "f2d16b", false)]
	else:
		# Uložená hra z doby, kdy byl jen jeden koník.
		var pony := _new_pony(str(data.get("pony_name", "Jiskra")), "c8834a", "f2d16b", false)
		for need in pony.needs:
			pony.needs[need] = maxf(float(data.get("needs", {}).get(need, 80.0)), OFFLINE_FLOOR)
		pony.poops = int(data.get("poops", 0))
		ponies = [pony]
	current_pony = clampi(int(data.get("current_pony", 0)), 0, ponies.size() - 1)
	manure = int(data.get("manure", 0))
	decay_scale = float(data.get("decay_scale", 1.0))
	var beds: Array = data.get("garden", [])
	for i in mini(beds.size(), GARDEN_BEDS):
		garden[i] = {"state": str(beds[i].get("state", "empty")), "watered_at": float(beds[i].get("watered_at", 0.0))}
	for item in data.get("inventory", {}):
		inventory[item] = int(data.inventory[item])
	walks = int(data.get("walks", 0))
	discovered = data.get("discovered", [])
	owned = data.get("owned", [])
	worn = data.get("worn", [])
	stars = int(data.get("stars", 0))
	sound_on = bool(data.get("sound_on", true))


func reset() -> void:
	ponies = [_new_pony("Jiskra", "c8834a", "f2d16b", false)]
	current_pony = 0
	inventory = {"apple": 0, "flower": 0, "horseshoe": 0, "carrot": 0}
	manure = 0
	decay_scale = 1.0
	_reset_garden()
	walks = 0
	discovered = []
	owned = []
	worn = []
	current_area = "louka"
	stars = 0
	save_game()
	needs_changed.emit()
	inventory_changed.emit()
	looks_changed.emit()


func is_area_unlocked(area: String) -> bool:
	return walks >= WorldData.AREAS[area].unlock_walks


## Vrací true, pokud jde o nový objev.
func discover(id: String) -> bool:
	if id in discovered:
		return false
	discovered.append(id)
	save_game()
	return true


func can_afford(cost: Dictionary) -> bool:
	for item in cost:
		if inventory.get(item, 0) < cost[item]:
			return false
	return true


func buy(id: String) -> bool:
	var cost: Dictionary = WorldData.SHOP[id].cost
	if id in owned or not can_afford(cost):
		return false
	for item in cost:
		inventory[item] -= cost[item]
	owned.append(id)
	worn.append(id)
	save_game()
	inventory_changed.emit()
	looks_changed.emit()
	return true


func toggle_worn(id: String) -> void:
	if id not in owned:
		return
	if id in worn:
		worn.erase(id)
	else:
		worn.append(id)
	save_game()
	looks_changed.emit()


func wears(id: String) -> bool:
	return id in worn


## Poklad dá ozdobu zdarma a rovnou ji nasadí.
func grant(reward: String) -> void:
	if reward in owned:
		return
	owned.append(reward)
	worn.append(reward)
	save_game()
	looks_changed.emit()


func add_star() -> void:
	stars += 1
	save_game()
	inventory_changed.emit()


func set_sound(on: bool) -> void:
	sound_on = on
	Audio.enabled = on
	save_game()



static func _new_pony(name: String, coat: String, mane: String, spots: bool) -> Dictionary:
	return {
		"name": name,
		"coat": coat,
		"mane": mane,
		"spots": spots,
		"needs": {"hunger": 80.0, "thirst": 80.0, "grooming": 80.0},
		"poops": 0,
	}


func current() -> Dictionary:
	return ponies[current_pony]


func select_pony(index: int) -> void:
	current_pony = posmod(index, ponies.size())
	needs_changed.emit()
	looks_changed.emit()


func can_adopt() -> bool:
	return ponies.size() < MAX_PONIES and stars >= ADOPT_STARS


func adopt(name: String, coat: Color, mane: Color, spots: bool) -> bool:
	if not can_adopt():
		return false
	stars -= ADOPT_STARS
	ponies.append(_new_pony(name, coat.to_html(false), mane.to_html(false), spots))
	current_pony = ponies.size() - 1
	save_game()
	inventory_changed.emit()
	needs_changed.emit()
	looks_changed.emit()
	return true


## Mrkev zasytí víc než seno a koník z ní má velkou radost.
func feed_carrot() -> bool:
	if inventory.get("carrot", 0) <= 0:
		return false
	inventory.carrot -= 1
	needs.hunger = minf(100.0, needs.hunger + 40.0)
	needs.grooming = minf(100.0, needs.grooming + 5.0)
	inventory_changed.emit()
	needs_changed.emit()
	return true


func _reset_garden() -> void:
	garden = []
	for i in GARDEN_BEDS:
		garden.append({"state": "empty", "watered_at": 0.0})


## Fáze záhonku: "empty", "thirsty" (zasazeno, nezalito), "growing", "ready".
func bed_stage(i: int, now := -1.0) -> String:
	var bed: Dictionary = garden[i]
	if bed.state == "empty":
		return "empty"
	if bed.watered_at <= 0.0:
		return "thirsty"
	if now < 0.0:
		now = Time.get_unix_time_from_system()
	return "ready" if now - bed.watered_at >= GROW_SECONDS else "growing"


## 0–1, jak daleko je mrkev v růstu.
func bed_growth(i: int) -> float:
	var bed: Dictionary = garden[i]
	if bed.watered_at <= 0.0:
		return 0.0
	return clampf((Time.get_unix_time_from_system() - bed.watered_at) / GROW_SECONDS, 0.0, 1.0)


func plant(i: int) -> bool:
	if garden[i].state != "empty" or manure <= 0:
		return false
	manure -= 1
	garden[i] = {"state": "planted", "watered_at": 0.0}
	save_game()
	return true


func water_bed(i: int) -> bool:
	if bed_stage(i) != "thirsty":
		return false
	garden[i].watered_at = Time.get_unix_time_from_system()
	save_game()
	return true


func harvest(i: int) -> bool:
	if bed_stage(i) != "ready":
		return false
	garden[i] = {"state": "empty", "watered_at": 0.0}
	add_item("carrot", 2)
	save_game()
	return true


func set_decay_scale(value: float) -> void:
	decay_scale = value
	save_game()
