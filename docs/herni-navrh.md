# Koníčci – herní návrh (v0.1)

Dětská hra pro Android o péči o koníčky: stáj, krmení, napájení, úklid a procházky barevným světem s lesíky a potůčky.

> Stav: plánovací fáze. Otevřené otázky jsou na konci dokumentu.

## 1. Vize v jedné větě

Útulná, klidná hra, ve které se dítě stará o své koníčky ve stáji a vyráží s nimi na procházky do barevného kreslené krajiny, kde objevuje poklady, zvířátka a nová místa.

## 2. Cílová skupina a principy

Předpoklad: děti cca 4–8 let (viz otázky).

- **Žádný stres, žádné prohry.** Koník nikdy neumře ani neonemocní vážně. Když je hladový nebo stáj špinavá, je jen smutnější a „prosí“, ale nic se nezkazí natrvalo.
- **Ovládání jedním prstem.** Ťuknutí a táhnutí, velká tlačítka, žádné drobné ikonky.
- **Minimum textu.** Vše srozumitelné z obrázků, ikon a zvuků; text jen pro rodiče. Hlasový komentář volitelně.
- **Krátké seance.** Smysluplná hra za 5–10 minut, aby se dala ukončit bez slz.
- **Bezpečnost.** Offline, bez reklam, bez nákupů v aplikaci, bez sběru dat (kvůli Google Play „Designed for Families“ a klidu rodičů).

## 3. Herní smyčka

```
Stáj (péče)  ──►  Procházka (objevování)  ──►  Odměny  ──►  zpět do stáje
   ▲                                                         │
   └──────── nové doplňky, krmení, koníci, místa ◄───────────┘
```

1. Dítě přijde do stáje, vidí náladu koníků (bublinky s ikonkou: mrkev = hlad, kapka = žízeň, hromádka = uklidit, srdíčko = chce pohladit).
2. Postará se o ně: nakrmí, napojí, vyčistí box, učeše.
3. Spokojený koník se může vydat na procházku.
4. Na procházce sbírá věci (jablka, kytičky, podkovičky, kamínky), potkává zvířátka a odemyká nová místa.
5. Za nasbírané věci si dítě v „obchůdku“ (bez skutečných peněz) pořídí ozdoby do stáje, deky, mašle, nové krmení – a časem i nového koníka.

## 4. Mechaniky

### 4.1 Potřeby koníka

| Potřeba | Ukazatel | Jak ji splnit | Rychlost poklesu |
|---|---|---|---|
| Hlad | mrkev | přetáhnout seno / mrkev / jablko do žlabu | pomalu |
| Žízeň | kapka | napumpovat vodu pumpou a nalít do kýblu (mini-hra) | pomalu |
| Čistota boxu | koblížek | hrábě: přejet prstem přes koblížky, odvézt kolečkem na hnojiště | po každém jídle |
| Upravenost | hřeben | kartáč/hřbílko: hladit prstem po srsti, třpytky | po procházce |
| Radost | srdíčko | hlazení, mrkev, procházka, hračka | odvozeno od ostatních |

- Potřeby klesají **jen během hraní a velmi mírně mezi seancemi** (např. max. na „trochu hladový“ i po týdnu). Nastavitelné v rodičovském menu.
- Kadění je hravý moment: koník po jídle udělá koblížky (s legračním zvukem), úklid je odměněný hvězdičkami a růstem kytiček na hnojišti → zeleninová zahrádka (bonusové mrkve).

### 4.2 Procházka

- Dítě vede koníka **tažením prstu** (koník jde za prstem) nebo ťukáním na místo. Na vyšší úrovni možnost „jízdy“ (rychlejší).
- Svět je složený z **oblastí** propojených cestičkami: Louka u stáje → Březový lesík → Potůček s mostkem → Rybníček → Kopec s větrným mlýnem → Kouzelný les (odemykatelné).
- Interakce: přeskočit kládu, přebrodit potůček (šplouchání), napít se z potůčku (splní žízeň), pást se na louce, schovaný zajíček/ježek, motýli, sbírat věci.
- Počasí a denní doba jako atmosféra (ráno, západ slunce, letní déšť s duhou) – čistě vizuální.
- Koník se na procházce trochu unaví a ušpiní → návrat do stáje dává důvod k péči (uzavírá smyčku).

### 4.3 Odměny a postup

- **Sběratelské věci** (jablíčka, kytičky, podkovy) = měkká měna pro obchůdek.
- **Album objevů**: každé nové zvířátko/místo/kytička se zapíše obrázkem do alba.
- **Odemykání**: nové oblasti světa podle počtu procházek, nové doplňky, noví koníci (různá plemena a barvy: hnědák, bělouš, strakáček, poník shetland, hříbě…).
- **Pojmenování koníka** a výběr barvy hřívy při adopci.
- Žádné časovače „čekej 4 hodiny“, žádné tlačení k návratu.

## 5. Obrazovky

1. **Úvod** – velké tlačítko „Hrát“, ikonka zámku pro rodiče (podržet 3 s / jednoduchý příklad).
2. **Dvůr statku** (hub) – stáj, pastvina, hnojiště, zahrádka, branka do světa, obchůdek.
3. **Stáj – interiér** – boxy s koníky (začátek 1 koník, max. např. 4–6), žlab, kýbl, nářadí na zdi.
4. **Detail koníka** – hlazení, česání, krmení z ruky, ozdoby.
5. **Mapa světa** – kreslená mapa oblastí, odemčená místa svítí.
6. **Procházka** – boční (2D side-scroll) nebo shora (top-down) pohled na oblast (viz otázky).
7. **Obchůdek / Šatník** – výměna nasbíraných věcí za doplňky.
8. **Album** – sbírka objevů.
9. **Rodičovské menu** – zvuk, hlas, rychlost potřeb, časový limit hraní, reset.

## 6. Svět a atmosféra

- Malebná česká krajina: louky, březové a smrkové lesíky, potůčky s kameny, rybníček s kachnami, polní cesty, větrný mlýn, včelíny.
- Každá oblast má vlastní barevnou paletu a hudební motiv.
- Živost: mraky se pohybují, tráva se vlní, ptáčci, světlušky večer, odlesky na vodě.

## 7. Výtvarný a zvukový směr

- **Styl:** 2D cartoon, oblé tvary, silné syté barvy, měkké stíny, výrazné obrysy. Koníci s velkýma očima a výraznou mimikou (radost, hlad, ospalost).
- **Animace:** skeletální 2D animace (Godot `Skeleton2D` / Spine-like) pro koníky – plynulé a levné na tvorbu variant (jiná barva = jiná textura/shader, stejná kostra).
- **Paralaxa** ve 2–4 vrstvách pro hloubku na procházkách.
- **UI:** velké kulaté ikony, vše animované při dotyku (pružení, jiskřičky).
- **Zvuk:** hravá akustická hudba (ukulele, xylofon, flétna), ržání, dupání, šplouchání, ptáci, vítr. Každá akce má zvukovou odezvu.
- **Zdroje grafiky:** kombinace vlastní tvorby, licencovaných assetů (např. itch.io, Kenney CC0 jako placeholder) a případně AI-asistovaných konceptů s ručním dotažením – rozhodne se podle otázky č. 4.

## 8. Technologie (doporučení)

**Godot 4.x (GDScript), 2D renderer „Compatibility“ / Mobile.**

Proč:
- Zdarma, open-source, bez licenčních poplatků; export na Android (APK/AAB) přímo z editoru.
- Výborný 2D engine (TileMap, Skeleton2D, AnimationPlayer, shadery, částice) – přesně pro cartoon hru.
- Malé výsledné balíčky, běží i na levnějších tabletech.
- GDScript je jednoduchý, rychlý vývoj; projekt je dobře verzovatelný v gitu (textové `.tscn`).

Alternativy zvažované: Unity (silnější ekosystém, ale licenční složitost a těžší build), Flutter + Flame (dobré pro jednoduché 2D, slabší nástroje pro scény a animace).

### Struktura projektu (návrh)

```
project.godot
scenes/
  main_menu/  farm/  stable/  pony_detail/  world_map/  walk/  shop/  album/  parents/
scripts/
  autoload/  game_state.gd   # potřeby koníků, inventář, odemčení
             save_system.gd   # uložení do user:// (JSON)
             audio.gd
  pony/      pony.gd  needs.gd
assets/
  art/  audio/  fonts/
docs/
```

- Stav hry v jednom autoload singletonu, ukládání lokálně do JSON (žádný server).
- Cílové zařízení: Android 8+ (API 26+), primárně tablety, orientace na šířku.
- CI: GitHub Actions s exportem Godot do debug APK pro snadné testování na tabletu.

## 9. Plán vývoje (roadmapa)

### Fáze 0 – Základ (1. milník)
- Godot projekt, struktura složek, CI build APK.
- Placeholder grafika, jedna scéna se stájí a jedním koníkem.

### Fáze 1 – MVP „Můj první koník“
- Stáj s 1 koníkem: krmení, napájení, úklid koblížků, hlazení/česání.
- Ukazatele potřeb a mimika koníka.
- Jedna oblast pro procházku (Louka + potůček) se sbíráním jablíček.
- Ukládání hry, základní zvuky a hudba.
- **Cíl:** hratelné na tabletu, otestovat s dítětem.

### Fáze 2 – Svět a sbírání
- Mapa světa se 3–4 oblastmi (lesík, potůček, rybníček).
- Album objevů, zvířátka, denní doba.
- Obchůdek s ozdobami do stáje a pro koníka.

### Fáze 3 – Více koníků a obsahu
- Adopce dalších koníků (barvy, plemena, jméno), hříbě.
- Zahrádka z hnojiště, počasí, další oblasti.
- Rodičovské menu, hlasový komentář.

### Fáze 4 – Vyladění a vydání
- Finální grafika a animace, optimalizace výkonu.
- Lokalizace (CZ, případně EN).
- Google Play: „Designed for Families“, zásady ochrany soukromí, testování.

## 10. Otevřené otázky

1. **Věk dítěte** – pro kolik let hru děláme (např. 4–6 nebo 7–10)? Ovlivní složitost, množství textu a mini-her.
2. **Pohled na procházce** – boční pohled (side-scroll, jednodušší, „pohádkový“) nebo shora/izometrický (volnější pohyb po světě)? Doporučení: boční pohled pro MVP.
3. **Vedení vs. jízda** – chodí dítě vedle koníka, nebo na něm jezdí?
4. **Grafika** – kreslí někdo vlastní obrázky, nebo počítáme s hotovými/licencovanými assety (případně AI koncepty)?
5. **Rozsah** – je to hra pro vlastní dítě/rodinu, nebo plánujete vydání na Google Play?
6. **Jazyk** – jen čeština, nebo i angličtina?
