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
		"tree_style": "oak",
		"bushes": 8,
		"animals": ["zajicek", "motyl"],
		"items": ["apple", "apple", "flower", "flower", "horseshoe"],
		"music": "walk",
	},
	"lesik": {
		"name": "Březový lesík",
		"unlock_walks": 1,
		"map_pos": Vector2(640, 250),
		"ground": Color("6cbf5a"),
		"water": "none",
		"trees": 110,
		"tree_style": "birch",
		"bushes": 12,
		"animals": ["jezek", "veverka", "srnka"],
		"items": ["flower", "flower", "horseshoe", "apple"],
		"music": "walk",
	},
	"rybnicek": {
		"name": "Rybníček",
		"unlock_walks": 3,
		"map_pos": Vector2(930, 480),
		"ground": Color("86d66b"),
		"water": "pond",
		"trees": 30,
		"tree_style": "oak",
		"bushes": 8,
		"animals": ["kachna", "zabka"],
		"items": ["apple", "flower", "horseshoe", "horseshoe"],
		"music": "walk",
	},
	"kouzelny_les": {
		"name": "Kouzelný les",
		"unlock_walks": 5,
		"map_pos": Vector2(1090, 220),
		"ground": Color("5fae86"),
		"water": "none",
		"trees": 90,
		"tree_style": "magic",
		"bushes": 10,
		"animals": ["sova", "liska", "jednorozec"],
		"items": ["flower", "horseshoe", "horseshoe", "apple"],
		"music": "magic",
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
	"sova": "Sova",
	"liska": "Liška",
	"jednorozec": "Jednorožec",
}

## Co zvířátko „řekne“, když na něj dítě ťukne.
const ANIMAL_FACTS := {
	"zajicek": "Zajíček má dlouhé uši, aby slyšel každý šelest.",
	"motyl": "Motýlek ochutnává kytičky nožičkama!",
	"jezek": "Ježek v noci hledá brouky a na zimu spí.",
	"veverka": "Veverka si schovává oříšky a pak je hledá.",
	"srnka": "Srnka je plachá, šeptej, ať ji nevyplašíš.",
	"kachna": "Kachnička má nepromokavé peříčko.",
	"zabka": "Žabka umí skočit mnohokrát dál, než je sama dlouhá.",
	"sova": "Sova umí otočit hlavu skoro dokola. Hů hů!",
	"liska": "Liška má huňatý ocas, který ji v zimě hřeje.",
	"jednorozec": "Jednorožec se ukáže jen kamarádům koníků!",
}

## Ukrytý poklad v každém místě; odměnou je ozdoba.
const TREASURES := {
	"louka": {"name": "Zlatá podkova", "pos": Vector2(2700, 300), "reward": "golden_hooves", "hint": "Na druhé straně potůčku, úplně nahoře."},
	"lesik": {"name": "Hvězdná deka", "pos": Vector2(2780, 1800), "reward": "star_blanket", "hint": "V nejvzdálenějším rohu lesíka, dole vpravo."},
	"rybnicek": {"name": "Kouzelná lucerna", "pos": Vector2(2650, 380), "reward": "lantern", "hint": "Za rybníčkem, nahoře vpravo."},
	"kouzelny_les": {"name": "Duhový krystal", "pos": Vector2(250, 250), "reward": "crystal", "hint": "Tam, kde les začíná, v levém horním rohu."},
}

## Zážitky do alba: věci, které se stanou jen někdy.
const MOMENTS := {
	"duha": "Duha po dešti",
	"svetlusky": "Světlušky za soumraku",
	"zapad": "Západ slunce",
	"rybka": "Vyskočila rybka",
	"brod": "Přes potůček v sedle",
	"listi": "Padající listí",
}

## Tvary pro 1, 2–4 a 5+ kusů (ve 4. pádě: „máš 1 podkovu“).
const ITEM_FORMS := {
	"apple": ["jablko", "jablka", "jablek"],
	"flower": ["kytičku", "kytičky", "kytiček"],
	"horseshoe": ["podkovu", "podkovy", "podkov"],
	"carrot": ["mrkev", "mrkve", "mrkví"],
}

## Barvy pro adopci nového koníka.
const COATS := [
	["Hnědák", "c8834a", false],
	["Ryzák", "d0602e", false],
	["Bělouš", "eeeae4", false],
	["Vraník", "4a3a36", false],
	["Plavák", "e8c06a", false],
	["Strakáč", "8a5a3c", true],
]
const MANES := ["f2d16b", "3a2a20", "ffffff", "ff8fc8", "b58cff", "6fc3ff"]
const PONY_NAMES := ["Hvězdička", "Šimon", "Lucinka", "Blesk", "Karamelka", "Fanda", "Mráček", "Bonbonek", "Duhovka", "Uhlík", "Sněženka", "Ořech"]

## Ozdoby: cena v nasbíraných věcech, kde se ukazují.
const SHOP := {
	"bow": {"name": "Mašle do hřívy", "cost": {"flower": 3}},
	"blanket": {"name": "Barevná deka", "cost": {"apple": 5}},
	"crown": {"name": "Věneček z kytek", "cost": {"flower": 6}},
	"rainbow": {"name": "Duhová hříva", "cost": {"horseshoe": 4, "flower": 2}},
	"window_flowers": {"name": "Kytky do okna stáje", "cost": {"flower": 4}},
	"lucky_shoe": {"name": "Podkova pro štěstí", "cost": {"horseshoe": 3}},
}

## Ozdoby z pokladů se nekupují, najdou se na procházce.
const TREASURE_REWARDS := {
	"golden_hooves": "Zlaté podkovy",
	"star_blanket": "Hvězdná deka",
	"lantern": "Lucerna do stáje",
	"crystal": "Krystal do stáje",
}


static func count_text(item: String, n: int) -> String:
	var forms: Array = ITEM_FORMS[item]
	var form: String = forms[0] if n == 1 else (forms[1] if n >= 2 and n <= 4 else forms[2])
	return "%d %s" % [n, form]
