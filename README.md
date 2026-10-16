# Koníčci

Dětská hra pro Android (6–11 let) o péči o koníčky a procházkách barevným světem.

- Herní návrh a plán: [docs/herni-navrh.md](docs/herni-navrh.md)

## Spuštění

1. Stáhni [Godot 4.4](https://godotengine.org/download) (standardní verze, ne .NET).
2. V Godotu otevři `project.godot` a stiskni F5.

Zatím je ve hře:

- **Stáj:** krmení, voda, česání, úklid koblížků; album objevů a obchůdek s ozdobami.
- **Mapa světa:** louka s potůčkem, březový lesík a rybníček (další místa se odemykají procházkami).
- **Procházka shora:** dítě koníka vede (jde vedle něj s vodítkem) nebo na něm jede, sbírá jablka, kytičky a podkovy a potkává zvířátka.

Grafika je zatím jen zástupná, kreslená kódem.

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
