class_name WorldData
## Popis míst ve světě, zvířátek do alba a věcí v obchůdku.

const AREAS := {
	"louka": {
		"name": "Louka u potůčku",
		"unlock_walks": 0,
		"map_pos": Vector2(300, 470),
		"ground": Color("7ccf63"),
		"water": "stream",
		"trees": 40,
		"birch": false,
		"animals": ["zajicek", "motyl"],
		"items": ["apple", "apple", "flower", "flower", "horseshoe"],
	},
	"lesik": {
		"name": "Březový lesík",
		"unlock_walks": 1,
		"map_pos": Vector2(660, 250),
		"ground": Color("6cbf5a"),
		"water": "none",
		"trees": 110,
		"birch": true,
		"animals": ["jezek", "veverka", "srnka"],
		"items": ["flower", "flower", "horseshoe", "apple"],
	},
	"rybnicek": {
		"name": "Rybníček",
		"unlock_walks": 3,
		"map_pos": Vector2(1000, 470),
		"ground": Color("86d66b"),
		"water": "pond",
		"trees": 30,
		"birch": false,
		"animals": ["kachna", "zabka"],
		"items": ["apple", "flower", "horseshoe", "horseshoe"],
	},
}

const ANIMALS := {
	"zajicek": "Zajíček",
	"motyl": "Motýlek",
	"jezek": "Ježek",
	"veverka": "Veverka",
	"srnka": "Srnka",
	"kachna": "Kachnička",
	"zabka": "Žabka",
}

## Tvary pro 1, 2–4 a 5+ kusů (ve 4. pádě: „máš 1 podkovu“).
const ITEM_FORMS := {
	"apple": ["jablko", "jablka", "jablek"],
	"flower": ["kytičku", "kytičky", "kytiček"],
	"horseshoe": ["podkovu", "podkovy", "podkov"],
}

## Ozdoby: cena v nasbíraných věcech, kde se ukazují.
const SHOP := {
	"bow": {"name": "Mašle do hřívy", "cost": {"flower": 3}},
	"blanket": {"name": "Barevná deka", "cost": {"apple": 5}},
	"crown": {"name": "Věneček z kytek", "cost": {"flower": 6}},
	"rainbow": {"name": "Duhová hříva", "cost": {"horseshoe": 4, "flower": 2}},
	"window_flowers": {"name": "Kytky do okna stáje", "cost": {"flower": 4}},
	"lucky_shoe": {"name": "Podkova pro štěstí", "cost": {"horseshoe": 3}},
}


static func count_text(item: String, n: int) -> String:
	var forms: Array = ITEM_FORMS[item]
	var form: String = forms[0] if n == 1 else (forms[1] if n >= 2 and n <= 4 else forms[2])
	return "%d %s" % [n, form]
