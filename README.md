# Weltraumschlacht

Ein rundenbasiertes Strategiespiel, entwickelt mit [Godot 4.6](https://godotengine.org/) und GDScript.

## Spielprinzip

2–4 Spieler (Mensch oder KI) kämpfen um die Vorherrschaft in einem zufällig generierten 2D-Universum aus Sternsystemen. Ziel ist es, alle Systeme zu erobern.

- **Sternsysteme** produzieren jede Runde Schiffe – je nach Produktionsrate und Produktionsmodus.
- **Fighter** sind schnelle Kampfschiffe, deren Moral bei langen Reisen sinkt.
- **Bomber** sind langsamer, treffen dafür härter, widerstehen Schilden und beschädigen die feindliche Produktion.
- **Kampf**: Verteidiger erhalten einen Bonus (1,5×). Batterien feuern vor dem Schiffskampf. Große Flotten werden in Wellen aufgeteilt.
- **Fog of War**: Nur Systeme in Reichweite eigener Sterne/Stationen sind sichtbar. Zuvor gesehene Systeme bleiben ausgegraut in Erinnerung.

## Features

- Zufällig generiertes Universum mit variabler Sternanzahl
- Rundenbasiertes Hot-Seat-Multiplayer für 2–4 Spieler
- **KI-Gegner** mit 5 wählbaren Taktiken (Rush, Fortress, Economy, Bomber, Balanced)
- Zwei Schiffstypen: Fighter und Bomber mit gemischten Flotten
- Produktionssystem: Fighter, Bomber, Upgrades, Batteriebau, Schildaktivierung
- Verteidigungsbatterien (bis zu 5 pro System) mit Vorkampf-Phase
- **Schildlinien**: Territoriale Verteidigung zwischen Systemen mit Attrition, Blockade und Ring-Produktionsbonus
- **Raumstationen**: Offensive Vorposten hinter feindlichen Linien, gebaut durch Materiallieferung (Fighter/Bomber als FÄ)
- Graduierte Stations-Sichtbarkeit: Waffensignatur skaliert mit Garnisonsgröße
- Rebellionsmechanik als Anti-Snowball
- Fighter-Moral bei Fernangriffen
- Fog of War mit Erinnerungssystem und Kampf-Intel
- Kampfberichte mit Systemhervorhebung
- Flottenentsendung mit Reisezeitanzeige (farbcodierte Pfeile)
- Schildkreuzungs-Vorschau im Flottenentsende-Dialog

## Starten

Das Projekt in Godot 4.6 öffnen und die Hauptszene (`scenes/main.tscn`) starten.

## Projektstruktur

```
scenes/       Godot-Szenen (.tscn)
scripts/      GDScript-Quelldateien (.gd)
assets/       Grafiken und Ressourcen
```

## Lizenz

Siehe Repository für Lizenzinformationen.
