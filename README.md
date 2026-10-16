# Koníčci

Dětská hra pro Android (6–11 let) o péči o koníčky a procházkách barevným světem.

- Herní návrh a plán: [docs/herni-navrh.md](docs/herni-navrh.md)

## Spuštění

1. Stáhni [Godot 4.4](https://godotengine.org/download) (standardní verze, ne .NET).
2. V Godotu otevři `project.godot` a stiskni F5.

Zatím je ve hře úvodní obrazovka, stáj (krmení, voda, česání, úklid koblížků) a procházka s pohledem shora (vodění i jízda, potůček s mostkem, sbírání jablek, kytiček a podkov). Grafika je zatím jen zástupná, kreslená kódem.

## Instalace do tabletu

Po každém nahrání změn GitHub sám sestaví instalační soubor:

1. Na GitHubu otevři záložku **Actions**, vyber poslední běh „Sestavení APK“.
2. Dole v části **Artifacts** stáhni `konicci-apk` (je to zip, uvnitř je `konicci.apk`).
3. Soubor přenes do tabletu a otevři ho. Android se zeptá na povolení instalace z neznámých zdrojů, to je potřeba povolit.

Aktualizace se instaluje stejně, uložená hra zůstane zachována.

## Test

```
godot --headless --script res://tests/smoke_test.gd
```
