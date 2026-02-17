# Weltraumschlacht

Ein rundenbasiertes Strategiespiel, entwickelt mit [Godot 4.6](https://godotengine.org/) und GDScript.

## Spielprinzip

2–4 Spieler kämpfen um die Vorherrschaft in einem zufällig generierten 2D-Universum aus Sternsystemen. Ziel ist es, alle Systeme zu erobern.

- **Sternsysteme** produzieren jede Runde Fighter – je nach Produktionsrate unterschiedlich schnell.
- **Fighter** können als Flotten zu anderen Systemen geschickt werden. Die Reisezeit hängt von der Entfernung ab.
- **Kampf**: Verteidiger erhalten einen Bonus (1,5×). Der Ausgang wird probabilistisch anhand der Flottenstärken berechnet.
- **Fog of War**: Nur Systeme in Reichweite eigener Sterne sind sichtbar. Feindliche Truppenstärken bleiben verborgen.

## Features

- Zufällig generiertes Universum mit variabler Sternanzahl
- Rundenbasiertes Hot-Seat-Multiplayer für 2–4 Spieler
- Fog of War und verdeckte Information
- Kampfberichte mit Systemhervorhebung
- Flottenentsendung mit Reisezeitanzeige (farbcodierte Pfeile)
- Setup-Screen zur Spieleranzahl-Auswahl

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
