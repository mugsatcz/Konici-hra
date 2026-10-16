class_name WalkQuest
extends RefCounted
## Úkol na jednu procházku („Natrhej 3 kytičky“, „Najdi poklad“...).

var kind := ""
var detail := ""
var count := 1
var progress := 0
var text := ""
var done := false


static func create(area_id: String, rng: RandomNumberGenerator) -> WalkQuest:
	var area: Dictionary = WorldData.AREAS[area_id]
	var q := WalkQuest.new()
	if not GameState.discovered.has("poklad_" + area_id) and rng.randf() < 0.5:
		q.kind = "treasure"
		q.text = "Najdi ukrytý poklad! " + WorldData.TREASURES[area_id].hint
		return q
	var options := [
		["collect", "flower", 3, "Natrhej 3 kytičky"],
		["collect", "apple", 3, "Najdi 3 jablka"],
		["collect", "horseshoe", 2, "Najdi 2 podkovy"],
		["bushes", "", 3, "Prozkoumej 3 keříky"],
		["pet", "", 2, "Pohlaď 2 zvířátka (ťukni na ně)"],
	]
	var animal: String = area.animals[rng.randi() % area.animals.size()]
	options.append(["meet", animal, 1, "Najdi zvířátko: " + WorldData.ANIMALS[animal]])
	if area.water != "none":
		options.append(["drink", "", 1, "Napoj koníka u vody"])
	if area.water == "stream":
		options.append(["ford", "", 1, "Přejeď v sedle přes potůček"])
	var pick: Array = options[rng.randi() % options.size()]
	q.kind = pick[0]
	q.detail = pick[1]
	q.count = pick[2]
	q.text = pick[3]
	return q


## Zaznamená událost; vrací true ve chvíli, kdy se úkol právě splnil.
func record(event_kind: String, event_detail := "") -> bool:
	if done or event_kind != kind or (detail != "" and event_detail != detail):
		return false
	progress += 1
	if progress >= count:
		done = true
		return true
	return false


func status_text() -> String:
	if done:
		return "Úkol splněn! ★"
	if count > 1:
		return "%s (%d/%d)" % [text, progress, count]
	return text
