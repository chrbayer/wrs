# Planung: FUT-19 (Defensive Shield Lines) & FUT-20 (Raumstationen)

> Stand: 2026-02-12 — Phase 1 bewertet, Phase 2 geplant (alle Entscheidungen getroffen)

## Motivation

Batterien sind aktuell eine rein lokale Verteidigung — sie schützen nur das einzelne System. Ein Spieler mit gut platzierten Batterien hat keinen Einfluss auf feindliche Flotten, die an seinen Systemen **vorbei** fliegen. Eroberungen hinter der "Frontlinie" sind ungehindert möglich.

**Ziel:** Batterien sollen über die Einzelsystem-Verteidigung hinaus eine **territoriale** Dimension bekommen. Zwei benachbarte, befestigte Systeme bilden eine Schildlinie, die feindliche Flotten beim Durchqueren schädigt oder blockiert.

---

## Phase 1 — FUT-19: Defensive Shield Lines

### Kernidee

```
Ohne Shield Lines:              Mit Shield Lines (Ring):

  [A]--feindl.Flotte-->[B]       [A]===SCHILD===[B]
  (Bat.)  (ungehindert)           |    +12%      |
                                SCHILD  [X]+25%  SCHILD
                                  |   (innen!)   |
                                 [D]===SCHILD===[C]
                                     +12%
                                  Feindflotte
                                  durch Ring
                                  --> blockiert!
```

- **Flottenbewegung bleibt frei** — Spieler bewegen ihre Schiffe weiterhin punkt-zu-punkt
- Zwei **eigene** Systeme mit Batterien ≥ 2 können eine **Schildlinie** dazwischen aktivieren
- **Feindliche** Flotten, deren Reisepfad diese Linie kreuzt, erleiden Verluste oder werden blockiert
- Die Stärke der Schildlinie hängt **invers von der Distanz** zwischen den beiden Systemen ab:
  - Kurze Distanz (nahe MIN_SYSTEM_DISTANCE): sehr stark, fast undurchdringlich
  - Lange Distanz (nahe MAX_SYSTEM_DISTANCE): schwach, nur geringe Verluste
- **Manuelle Aktivierung** — Schildlinien entstehen NICHT automatisch, sondern werden bewusst über einen neuen Produktionsmodus (`SHIELD_ACTIVATE`) aktiviert. Beide Systeme sind während der Aktivierung (2 Runden) blockiert
- **Strukturen begrenzt** — Max **2 unabhängige Schildstrukturen** (Ringe oder Ketten) pro Spieler, max **2 Linien pro System** (garantiert einfache Ringe für Polygon-Erkennung)
- **Ring-Produktionsbonus** — Geschlossene Ringe aus Schildlinien gewähren eingeschlossenen Sternen **+25%** und Ring-Sternen **+12%** Produktionsbonus (Erkennung per Polygon-Test / Ray Casting)
- **Bevorzugt kleine Reiche** — Kompakte Reiche können mit wenigen Linien geschlossene Ringe bilden und den Bonus voll ausschöpfen. Große Reiche haben zu viele Lücken für nur 2 Strukturen

### Konzept im Detail

#### Was bildet eine Schildlinie?

- Zwei Systeme des **gleichen Spielers**
- Beide mit **mindestens 2 Batterien**
- Innerhalb von `MAX_SYSTEM_DISTANCE` voneinander
- **Manuelle Aktivierung** durch neuen Produktionsmodus `SHIELD_ACTIVATE`
- Max **2 Schildlinien pro System**

#### Wann wird eine Flotte betroffen?

- Die Flugbahn (Linie von Quell- zu Zielsystem) schneidet die Schildlinie (Linie zwischen den zwei befestigten Systemen)
- **Geometrischer Test:** Liniensegment-Schnitt (2D line-segment intersection)
- **Nur feindliche Flotten** — eigene und neutrale Flotten passieren ungehindert

#### Aktivierung

```
Schildlinien-Aktivierung:
├── Neuer Produktionsmodus: SHIELD_ACTIVATE (5. Option im Produktionsmenü)
├── Voraussetzung: System hat ≥ 2 Batterien, hat < 2 aktive Schildlinien
├── Spieler wählt Zielsystem (muss auch ≥ 2 Batterien haben, in Reichweite)
├── BEIDE Systeme wechseln in SHIELD_ACTIVATE Modus
├── Aktivierungsdauer: 2 Runden (auf beiden Systemen)
├── Während Aktivierung: keine Schiff-/Batterie-Produktion auf beiden Systemen
├── Nach Aktivierung: Schildlinie permanent aktiv, skaliert automatisch mit Batterien
└── Deaktivierung: NICHT manuell möglich
```

**Schildlinie bricht automatisch wenn:**
- Ein System wird erobert
- Rebellion macht ein System neutral
- Batterien eines Systems fallen unter 2 (durch Eroberung → 50% Verlust)

#### Wie stark ist der Effekt?

Stärke skaliert mit zwei Faktoren:

1. **Distanz zwischen den Schildsystemen** (invers):
   - `shield_density = 1.0 - (distance - MIN_SYSTEM_DISTANCE) / (MAX_SYSTEM_DISTANCE - MIN_SYSTEM_DISTANCE)`
   - Bei `MIN_SYSTEM_DISTANCE` (120px): density = 1.0 (maximale Stärke)
   - Bei `MAX_SYSTEM_DISTANCE` (250px): density = 0.0 (keine Wirkung)
   - Praktisch nutzbar im Bereich 120–200px

2. **Batterie-Level beider Systeme (Zwei-Formeln-System):**
   - Blockade: `min(batteries_a, batteries_b)` — schwächstes Glied bestimmt Durchlässigkeit
   - Schaden: `batteries_a + batteries_b` — Gesamtfeuerkraft bestimmt Verluste

3. **Batterie-Unterstützung bei Verteidigung:**
   - Verbundene Nachbarn über Schildlinien feuern mit: `Nachbar-Batterien × density × 0.5`
   - Nur Nachbarn des gleichen Besitzers tragen bei
   - Effektive Batterie-Zahl wird auf ganzzahligen Wert gerundet (abgerundet)
   - Beispiel: 5 eigene Bat. + Nachbar (5 Bat., Dichte 1.0) = 5 + 2 = 7 effektive Batterien

#### Was passiert mit der Flotte?

**Blockade + Attrition:**
- Blockade wenn `min(bat_a, bat_b) × density ≥ 2.5` (Fighter) bzw. `≥ 5.0` (Bomber)
- Vor dem Senden: Send-Dialog verhindert Senden bei Blockade
- Flotte unterwegs + nachträgliche Blockade: Schiffe gehen verloren (Bomber ggf. durch bei halber Blockade)
- Unterhalb Blockade-Schwellwert: Attrition-Verluste basierend auf Summe × density × Faktor

### Design-Entscheidungen (final)

| Frage | Entscheidung | Begründung |
|-------|-------------|------------|
| Batterie-Schwelle | **Ab Level 2** | Level 1 = lokal + 20% Rebellionsreduktion, ab Level 2 territoriale Dimension |
| Aktivierung | **Manuell** (neuer Produktionsmodus) | Bewusste strategische Entscheidung, nicht zufälliger Nebeneffekt |
| Aktivierungsdauer | **2 Runden** (beide Systeme blockiert) | 4 Systemrunden Kosten — signifikant aber nicht prohibitiv |
| Max Linien pro System | **2** | Garantiert einfache Ringe (keine Hubs/Kreuzungen), Polygon-Test korrekt |
| Max Strukturen pro Spieler | **2 unabhängige** (Ringe oder Ketten) | Jede Struktur beliebig lang, aber max 2 getrennte. Bevorzugt kleine Reiche |
| Deaktivierung | **Nicht manuell möglich** | Permanent bis System erobert/Rebellion/Batterien < 2. Commitment-Entscheidung |
| Ring-Bonus (innere Sterne) | **Voller Produktionsbonus** | Sterne vollständig umschlossen von geschlossenem Ring |
| Ring-Bonus (Ring-Sterne) | **Halber Produktionsbonus** | Ring-Sterne tragen Kosten (Batterien), verdienen Belohnung |
| Umschlossen-Erkennung | **Polygon-Test** (Ray Casting) | Geschlossener Ring = Polygon, Punkt-in-Polygon für jeden Stern |
| Blockade-Berechnung | **min(bat_a, bat_b) × density** | Schwächstes Glied bestimmt Durchlässigkeit |
| Schaden-Berechnung | **(bat_a + bat_b) × density × Faktor** | Gesamtfeuerkraft bestimmt Verluste |
| Effekt auf Flotte | **Blockade + Attrition** | Blockade ab Schwellwert, sonst Verluste |
| Blockierte Flotte (vor Senden) | **Send-Dialog verhindert Senden** | UI-Schutz vor sicherem Verlust |
| Blockierte Flotte (unterwegs) | **Schiffe gehen verloren** | Fighter zerstört, Bomber ggf. durchgelassen |
| Mehrere Schildlinien | **Kumulativ** | Jede Linie einzeln berechnet, Defense in Depth belohnt |
| Wellen-Split | **Jede Welle einzeln** betroffen | Konsistent mit Batterie-Verhalten |
| Bomber vs Schild | **50% Resistenz** | Halber Schaden, doppelter Blockade-Schwellwert |
| Eigene Flotten | **Immer frei** | Nur feindliche Schildlinien schaden |
| Sichtbarkeit | **Sichtbar für alle** wenn Endpunkte sichtbar | Fair, Spieler kann Risiko einschätzen |
| Fog-of-War Memory | **Ja, graue Erinnerung** | Konsistent mit FUT-16a |
| Send-Dialog | **Verlustvorschau** anzeigen | Informierte Entscheidungen ermöglichen |

### Parameter (final)

| Parameter | Wert | Beschreibung |
|-----------|------|--------------|
| `SHIELD_MIN_BATTERIES` | 2 | Mindest-Batterien pro System für Schildlinie |
| `SHIELD_DAMAGE_FACTOR` | 0.04 (4%) | Basisverlust pro Shield-Power-Punkt × Density |
| `SHIELD_BLOCKADE_THRESHOLD` | 2.5 | Fighter blockiert wenn min × density ≥ 2.5 |
| `SHIELD_BOMBER_RESISTANCE` | 0.5 | Bomber: halber Schaden, Blockade erst ab min × density ≥ 5.0 |
| `SHIELD_ACTIVATE_TIME` | 2 | Runden für Aktivierung (beide Systeme blockiert) |
| `MAX_SHIELD_LINES_PER_SYSTEM` | 2 | Maximale Schildlinien pro System (garantiert einfache Ringe) |
| `MAX_SHIELD_STRUCTURES` | 2 | Max unabhängige Schildstrukturen pro Spieler |
| `SHIELD_RING_BONUS_INNER` | 0.25 (25%) | Produktionsbonus für Sterne innerhalb eines geschlossenen Rings |
| `SHIELD_RING_BONUS_RING` | 0.12 (12%) | Produktionsbonus für Sterne auf dem Ring selbst |

### Beispielrechnungen

```
Szenario 1: Starke Schildlinie
├── System A: 3 Batterien, System B: 3 Batterien
├── Abstand: 130px → density = (250-130)/(250-120) = 0.92
├── shield_power = min(3,3) = 3
├── Effektive Stärke = 0.92 × 3 × 0.05 = 0.138 (13.8% Verluste)
├── Feindflotte mit 40 Fightern: verliert ~6 Fighter, 34 kommen an
└── Mit Blockade-Modell: unter 0.8 → Attrition, keine Blockade

Szenario 2: Enge Festung
├── System A: 5 Batterien, System B: 5 Batterien
├── Abstand: 120px (Minimum) → density = 1.0
├── shield_power = min(5,5) = 5
├── Effektive Stärke = 1.0 × 5 × 0.05 = 0.25 (25% Verluste)
├── Feindflotte mit 40 Fightern: verliert 10 Fighter
└── Oder mit höherem SHIELD_DAMAGE_FACTOR: stärkere Blockade

Szenario 3: Schwache, weit entfernte Linie
├── System A: 2 Batterien, System B: 1 Batterie
├── Abstand: 220px → density = (250-220)/(250-120) = 0.23
├── shield_power = min(2,1) = 1
├── Effektive Stärke = 0.23 × 1 × 0.05 = 0.012 (1.2% Verluste)
└── Praktisch wirkungslos → lohnt sich nicht
```

### Visualisierung

```
Schildlinien auf der Karte:
├── Dünne, leuchtende Linie in Spielerfarbe zwischen den zwei Systemen
├── Stärke visuell dargestellt (Helligkeit/Dicke proportional zu shield_density)
├── Schwache Linien: dünn, transparent
├── Starke Linien: dick, leuchtend
├── Fog of War: nur sichtbar wenn mindestens ein Endpunkt sichtbar
└── Animation: subtiles Pulsieren (wie Schildenergie)
```

### Interaktion mit bestehenden Mechaniken

| Mechanik | Interaktion |
|----------|-------------|
| Batterien (FUT-10) | Vierfach-Nutzen: Lokale Verteidigung + Rebellionsreduktion + Schildlinien + Ring-Produktionsbonus |
| Rebellion (FUT-18) | Systeme mit Batterien < max können rebellieren → Schildlinien brechen zusammen (strategisch verheerend) |
| Bomber (FUT-07/12) | 50% Resistenz gegen Schilder: halbe Verluste, doppelter Blockade-Schwellwert (5.0 statt 2.5). Bomber als Schild-Brecher |
| Fighter-Moral (FUT-17) | Moral-Malus + Schildverluste kumulieren sich → Fernangriffe durch Schildlinien extrem teuer |
| Wellen-Splitting (C-20) | Jede Welle einzeln betroffen — große Flotten doppelt bestraft (Schild + Batterien bei Ankunft) |
| Fortress-AI | Natürlicher Vorteil: baut Batterien → kann Schildlinien aktivieren |
| Rush-AI | Natürlicher Nachteil: keine Batterien → kein Schild → verwundbar gegen territoriale Spieler |
| Bomber-AI | Aufgewertet: Bomber durchdringen Schilder leichter, strategischer Wert steigt |
| Eroberung (FUT-08) | Erobertes Schildsystem: Batterien auf 50% → Schildlinie bricht wenn unter 2. Eroberer muss neu aufbauen |
| Send-Dialog | Verlustvorschau bei Schildlinien-Kreuzung, Blockade verhindert Senden |
| Fog of War (FUT-16a) | Schildlinien sichtbar wenn Endpunkte sichtbar, graue Erinnerung bei FoW |

### Betroffene Systeme

| Datei | Änderung |
|-------|----------|
| `ship_types.gd` | Neue Konstanten: `SHIELD_*` Parameter, `MAX_SHIELD_LINES_PER_SYSTEM`, `MAX_SHIELD_STRUCTURES`, Ring-Bonus-Werte |
| `star_system.gd` | Neuer Produktionsmodus `SHIELD_ACTIVATE`, Schildlinien-Daten pro System (aktive Linien, Aktivierungsstatus, Partner-ID) |
| `main.gd` Datenmodell | Schildlinien-Liste (Paare aktiver Systeme), Struktur-Tracking (welche Linien bilden zusammenhängende Strukturen) |
| `main.gd` Produktionsmenü | Neue Option "Schildlinie aktivieren" im ActionPanel, Partnersystem-Auswahl-UI |
| `main.gd` `_draw()` | Schildlinien zeichnen (Spielerfarbe, Stärke visuell nach Density), Ring-Visualisierung |
| `main.gd` Flotten-Logik | Liniensegment-Schnitttest bei Flottenankunft, Attrition/Blockade berechnen, Kreuzungstest auch pre-send |
| `main.gd` Send-Dialog | Warnung + Verlustvorschau, Blockade-Check verhindert Senden |
| `main.gd` Produktion | Ring-Erkennung (Polygon-Test), Produktionsbonus für Ring-/innere Sterne berechnen |
| `main.gd` Zugrunde | Schildlinien-Bruch bei Eroberung/Rebellion/Batterieverlust prüfen |
| `combat.gd` | Attrition-Berechnung als separate Funktion (shield_density × damage_factor × ship_count) |
| `ai_controller.gd` | Schildlinien-Aktivierung entscheiden, Schildlinien bei Zielauswahl berücksichtigen (Pfade meiden oder Bomber einsetzen) |
| `fleet.gd` | Quell-/Zielposition für Kreuzungsberechnung bei Ankunft speichern |
| `scenes/main.tscn` | Neuer Button im ActionPanel für Schildlinien-Aktivierung |

### Implementierungsschritte (grob)

**Phase A — Datenmodell & Aktivierung:**
1. `ship_types.gd`: Alle `SHIELD_*` Konstanten definieren
2. `star_system.gd`: Neuer Produktionsmodus `SHIELD_ACTIVATE`, Linien-Daten (Partner-IDs, Aktivierungscountdown)
3. `main.gd`: Schildlinien-Datenstruktur (Array von `{system_a, system_b, owner_id}`)
4. `main.gd`: Aktivierungs-UI im ActionPanel (Button → Partnersystem-Auswahl → Validierung: Batterien ≥ 2, < 2 Linien, in Reichweite, < 2 Strukturen)
5. `main.gd`: Aktivierungs-Countdown in `_process_production()` — nach 2 Runden Schildlinie in aktive Liste aufnehmen

**Phase B — Geometrie & Kampf:**
6. Liniensegment-Schnitttest implementieren (2D line-segment intersection)
7. `shield_density` Berechnung: `1.0 - (dist - MIN) / (MAX - MIN)`
8. Blockade-Check: `min(bat_a, bat_b) × density` vs Schwellwert (2.5 Fighter / 5.0 Bomber)
9. Attrition-Berechnung: `(bat_a + bat_b) × density × SHIELD_DAMAGE_FACTOR × ship_count`
10. In Flotten-Ankunft integrieren: alle gekreuzten Schildlinien prüfen, kumulativ anwenden

**Phase C — UI & Vorschau:**
11. Send-Dialog: Pre-Send Blockade-Check (verhindert Senden), Verlustvorschau anzeigen
12. Visualisierung: Schildlinien in `_draw()` (Spielerfarbe, Dicke/Helligkeit nach Density)
13. Sichtbarkeit: nur zeichnen wenn Endpunkte für aktuellen Spieler sichtbar, FoW-Memory (grau)

**Phase D — Ringe & Bonus:**
14. Struktur-Erkennung: zusammenhängende Schildlinien-Graphen identifizieren (Union-Find oder BFS)
15. Ring-Erkennung: geschlossener Pfad = Polygon → Ray-Casting Punkt-in-Polygon-Test
16. Produktionsbonus berechnen: innere Sterne +25%, Ring-Sterne +12%, in `_process_production()` anwenden
17. Ring-Visualisierung: dezente Einfärbung des umschlossenen Bereichs

**Phase E — Bruch & AI:**
18. Schildlinien-Bruch: bei Eroberung, Rebellion, Batterien < 2 automatisch entfernen, Ring-Status aktualisieren
19. AI: Schildlinien-Aktivierung (Fortress: priorisieren, andere: situativ)
20. AI: Schildlinien bei Angriffsplanung berücksichtigen (Kosten einrechnen, Bomber bevorzugen, Umwege suchen)
21. Balancing und Parameter-Tuning

---

## Phase 2 — FUT-20: Raumstationen

> Voraussetzung: FUT-19 muss stabil implementiert sein.

### Kernidee

Raumstationen sind **primär ein offensives Werkzeug**. Sie ermöglichen Angriffen auf Sterne, die hinter feindlichen Schildlinien liegen und sonst nicht mehr erreichbar wären. Sekundär können sie auch eigene Schildlinien verstärken.

Stationen sind für Feinde **unsichtbar**, bis deren Schiffe erstmals in die Nähe kommen — was Überraschungsangriffe ermöglicht.

Die **begrenzte Anzahl pro Spieler** (z.B. max 3) begünstigt kleinere Reiche: Ein Spieler mit wenigen, gut verteidigten Systemen kann seine 3 Stationen gezielt einsetzen, um den überlegenen Gegner an mehreren Stellen zu durchbrechen. Ein großes Reich mit langen Schildlinien hat mehr Lücken als 3 Stationen schließen können.

```
Problem — Schildlinien blockieren Angriffe:

  Spieler B               Spieler A (Schildwall)
  [X]  [Y]           [A]====SCHILD====[B]====SCHILD====[C]
                           ×                 ×
                      Flotte von X       Flotte von Y
                      wird geschädigt    wird geschädigt
                      → Angriff auf D    → Angriff auf E
                        unmöglich          unmöglich
                           [D]                [E]
                        (hinter dem Schild, sicher)

Lösung — Station hinter feindlichem Schild:

  Spieler B                Spieler A (Schildwall)
  [X]  [Y]           [A]====SCHILD====[B]====SCHILD====[C]
         \
          → [Station] ← unsichtbar für A!
               |
               → Angriff auf [D] OHNE Schildkreuzung
                 (Station liegt hinter dem Schild)
```

### Doppelrolle: Offensiv + Defensiv

| Einsatz | Beschreibung |
|---------|-------------|
| **Offensiv (primär)** | Station hinter feindlichem Schildwall platzieren → Flotten können von Station aus feindliche Systeme angreifen, ohne Schildlinien zu kreuzen |
| **Offensiv (Staging)** | Station als Sammel-/Startpunkt für koordinierte Angriffe in feindlichem Gebiet |
| **Defensiv** | Station schließt Lücke im eigenen Schildnetzwerk (mit Batterien) |
| **Aufklärung/Scan** | Operative Station scannt volle Sichtweite passiv — deckt Scan-Lücken zwischen Sternen ab, entdeckt feindliche versteckte Stationen |

### Balance-Aspekt: Begünstigt kleine Reiche

```
Großes Reich (15 Systeme, langer Schildwall):
├── Viele Schildlinien → viele potenzielle Lücken
├── 3 Stationen können nicht alle Lücken schließen
├── Feind kann mit Stationen an verschiedenen Stellen eindringen
└── Nachteil: Mehr zu verteidigen als Stationen schützen können

Kleines Reich (5 Systeme, kompakter Schildwall):
├── Wenige, starke Schildlinien (kurze Distanzen = hohe Density)
├── 3 Stationen reichen um gezielt hinter feindliche Linien zu kommen
├── Qualitativ gleiches Offensiv-Potential wie großes Reich
└── Vorteil: Wenig zu verteidigen, volle Station-Kapazität für Angriff
```

### Konzept im Detail

#### Bau-Mechanik

```
Stationsbau — Material + Bauzeit verschmolzen:

Schritt 1: Bauplatz bestimmen
├── Spieler aktiviert "Station bauen" im HUD
├── Karte wechselt in Platzierungsmodus
├── Spieler klickt gültige Position:
│   ├── Innerhalb MAX_SYSTEM_DISTANCE eines beliebigen Sterns ODER eigener Station
│   ├── Mindestabstand zu Sternen/Stationen (MIN_SYSTEM_DISTANCE)
│   └── Spieler hat < 3 aktive Stationen/Baumarker
└── Baumarker wird gesetzt → erscheint als Flottenziel im Send-Dialog

Schritt 2: Material liefern + Bau
├── Spieler schickt Flotten zum Baumarker (normaler Send-Ablauf)
├── Fighter + Bomber werden als Material gezählt (1 Bomber = 2 FÄ)
├── Pro Runde: 8 FÄ verbraucht wenn verfügbar → 1 Baufortschritt
├── Material < 8 FÄ → Bau PAUSIERT (Material wartet auf nächste Lieferung)
├── Gesamt: 24 FÄ = 3 Baurunden (bei durchgängiger Versorgung)
└── Nach 3 Baurunden: Station operativ
```

**Keine dritte Schiffsart** — Fighter und Bomber sind das Baumaterial. Umrechnungsfaktor: 1 Bomber = 2 Fighter-Äquivalent (FÄ).

#### Batterie-Ausbau auf Stationen

```
Batterie-Bau auf Station (gleiche Mechanik wie Stationsbau):
├── Material per Flotte liefern (Fighter/Bomber als FÄ)
├── Verbrauch: 4 FÄ pro Baurunde
├── Level 1: 1 Runde = 4 FÄ
├── Level 2: 2 Runden = 8 FÄ
├── Pausiert bei fehlendem Material
├── Max: 2 Batterien pro Station
└── Batterien ermöglichen Schildlinien-Anbindung (konsistent mit FUT-19)

Gesamtkosten voll ausgebaute Station:
├── Station:     24 FÄ (3 Runden)
├── Batterie 1:   4 FÄ (1 Runde)
├── Batterie 2:   8 FÄ (2 Runden)
└── Gesamt:      36 FÄ = 18 Bomber (6 Runden Minimum)
```

#### Sichtbarkeit & Entdeckung

```
Sichtbarkeitsstufen:

1. Unsichtbar (Bauphase + operativ ohne Garnison):
   ├── Keine Waffensignatur → nicht ortbar
   ├── Kann NUR durch Scan entdeckt werden (siehe unten)
   └── Schützt Station während verletzlicher Bauphase

2. Passiver Scan — Sterne & Stationen (jede Runde, IMMER erfolgreich):
   ├── Eigene besetzte Sterne:       200px Scanradius (STATION_PASSIVE_SCAN_RANGE)
   ├── Eigene operative Stationen:   volle Sichtweite als Scanradius (250px)
   ├── Deterministisch — keine Zufallskomponente
   └── Entdeckt: feindliche Station wird permanent sichtbar

3. Flotten-Scan (bewegungsbasiert, ABHÄNGIG VON FLOTTENGRÖßE):
   ├── Scan-Reichweite = min(60, max(0, (fleet_size - 5) × 3))
   │   ├──  1-5 Schiffe:   0px (kein Scan — zu wenige Sensoren)
   │   ├──  6 Schiffe:     3px
   │   ├── 10 Schiffe:    15px
   │   ├── 15 Schiffe:    30px
   │   ├── 20 Schiffe:    45px
   │   └── 25+ Schiffe:   60px (Maximum)
   ├── Prüfung: kürzeste Distanz Flugpfad ↔ versteckte Station
   └── Entdeckt: feindliche Station wird permanent sichtbar

4. Sichtbar für alle (kein Scan nötig):
   └── Station hat Kampfschiffe stationiert → Waffensignatur ortbar

Wichtig: Batterie-Bau allein macht Station NICHT sichtbar

Strategische Konsequenz:
├── Eigene Sterne decken ihren Bereich passiv ab (kostenlos)
├── Eigene Stationen erweitern die Scan-Abdeckung (kostet 1 von 3 Slots)
├── Große Flotten auf normalen Routen scannen nebenbei
├── Kleine Flotten (≤5 Schiffe) haben keinen Scan → entdecken versteckte Stationen nicht
├── Blinde Flecken existieren, sind aber durch Station-Platzierung kontrollierbar
└── Kein "Patrol in den leeren Raum" nötig — bestehende Mechaniken reichen
```

#### Kampf & Zerstörung

- Entdeckte Stationen sind **angreifbar wie Sterne** (Flotten können dorthin gesendet werden)
- **Verteidiger-Bonus** gilt (Garnison verteidigt)
- Nach **Eroberung wird die Station zerstört** (nicht übernommen)
- **Flotten unterwegs zu zerstörter Station gehen verloren** (Ziel existiert nicht mehr)
- Bei **Spieler-Eliminierung** werden alle Stationen des Spielers zerstört

#### Kettenbildung

```
Station-Ketten erlauben Reichweiten-Erweiterung:

  [Eigener Stern]---MAX_DIST---[Station A]---MAX_DIST---[Station B]
                                                              |
                                              Angriff auf weit entfernten
                                              feindlichen Stern möglich!

Regeln:
├── Neuer Bauplatz muss in MAX_SYSTEM_DISTANCE eines Sterns ODER eigener Station sein
├── Operative Stationen zählen als Ankerpunkt für weitere Stationen
├── Baumarker (im Bau) zählen NICHT als Ankerpunkt
└── Max 3 Stationen begrenzt die Kettenlänge natürlich
```

#### UI-Ablauf

```
Station bauen:
1. [Station bauen] Button im HUD (oder Tastenkürzel)
2. Platzierungsmodus: gültige Zone wird angezeigt
   ├── Kreis um jeden Stern (MAX_SYSTEM_DISTANCE)
   ├── Kreis um eigene operative Stationen (MAX_SYSTEM_DISTANCE)
   └── Ausschlusszone um Sterne/Stationen (MIN_SYSTEM_DISTANCE)
3. Klick → Baumarker gesetzt
4. Baumarker erscheint im Send-Dialog als Ziel
5. Spieler sendet Flotten zum Baumarker (normaler Ablauf)

Station verwalten:
├── Klick auf eigene Station → ActionPanel (wie bei Sternen)
├── Optionen: Schildlinie aktivieren (wenn Batterien ≥ 2)
├── Send-Dialog: Schiffe von Station weiter senden
└── Info: Material-Status, Batterie-Level, Garnison
```

### Design-Entscheidungen (final)

| Frage | Entscheidung | Begründung |
|-------|-------------|------------|
| Baukosten | **24 FÄ** (8 FÄ/Runde, 3 Runden) | Signifikante Investition, sauber durch Bomber teilbar (= 12 Bomber) |
| Baumechanik | **Material + Bauzeit verschmolzen** | 8 FÄ/Runde verbraucht, pausiert bei Mangel. Tempo = Lieferhäufigkeit |
| Bau-Initiierung | **Bauplatz auf Karte → Flotten senden** | Baumarker wird Flottenziel, kein spezielles Bauschiff nötig |
| Schiffstypen | **Fighter + Bomber** (1 Bomber = 2 FÄ) | Keine 3. Schiffsart — unnötige Komplexität |
| Platzierung | **MAX_SYSTEM_DISTANCE zu Stern ODER eigener Station** | Erlaubt Ketten, verhindert absurde Platzierungen |
| Max Stationen | **3 pro Spieler** (hart begrenzt) | Begünstigt kleine Reiche, erzwingt strategische Auswahl |
| Produktion | **Keine** | Reine Infrastruktur, alles muss geliefert werden |
| Batterien | **Max 2** (4 FÄ/Baurunde, gleiche Mechanik) | Konsistent mit FUT-19, ermöglicht Schildlinien-Anbindung |
| Stationen angreifbar | **Ja, wie Sterne** mit Verteidiger-Bonus | Entdeckte Stationen können zerstört werden |
| Nach Eroberung | **Station wird zerstört** (nicht übernommen) | Verhindert Stations-Flipping, Slot wird frei |
| Flotten zu zerstörter Station | **Gehen verloren** | Strategisches Risiko, belohnt Timing der Zerstörung |
| Vom Besitzer zerstörbar | **Nein** | Commitment-Entscheidung (wie Schildlinien) |
| Spieler eliminiert | **Stationen werden zerstört** | Kein herrenloses Infrastruktur-Artefakt |
| Station als Flottenziel | **Ja** | Zentral für offensiven Einsatz (Staging) |
| Flotten von Station senden | **Ja** | Nötig als Staging-Punkt |
| Sichtbarkeit im Bau | **Unsichtbar** (keine Waffensignatur) | Schützt Bauphase |
| Sichtbarkeit operativ | **Unsichtbar bis Kampfschiffe stationiert** | Waffensignaturen erst bei Garnison ortbar |
| Passiver Scan | **Eigene Sterne (200px) + Stationen (250px)** | Immer erfolgreich, deterministisch |
| Flotten-Scan | **Abhängig von Flottengröße** (0-60px) | `min(60, max(0, (fleet_size-5)×3))` — große Flotten scannen nebenbei, kleine nicht |
| Einmal entdeckt | **Permanent sichtbar** für Entdecker | Kein "Verstecken" nach Entdeckung |

### Parameter (final)

| Parameter | Wert | Beschreibung |
|-----------|------|--------------|
| `STATION_BUILD_COST` | 24 FÄ | Gesamtkosten Stationsbau |
| `STATION_BUILD_PER_ROUND` | 8 FÄ | Materialverbrauch pro Baurunde |
| `STATION_BUILD_ROUNDS` | 3 | Baurunden bei durchgängiger Versorgung |
| `MAX_STATIONS_PER_PLAYER` | 3 | Maximum Stationen (inkl. Baumarker) pro Spieler |
| `STATION_MAX_BATTERIES` | 2 | Maximale Batterien pro Station |
| `STATION_BATTERY_PER_ROUND` | 4 FÄ | Materialverbrauch pro Batterie-Baurunde |
| `STATION_FLEET_SCAN_MAX` | 60px | Maximale Scan-Reichweite vorbeifliegender Flotten (bei 25+ Schiffen) |
| `STATION_FLEET_SCAN_THRESHOLD` | 5 | Flotten mit ≤ 5 Schiffen haben keinen Scan |
| `STATION_FLEET_SCAN_PER_SHIP` | 3px | Scan-Reichweite pro Schiff über Threshold |
| `STATION_GARRISON` | 0 | Keine Startverteidigung |

### Beispielrechnungen

```
Szenario 1: Schnellbau (alles auf einmal)
├── Rate-5-Planet produziert 5 Fighter/Runde → 5 Runden für 25 Fighter
├── Flotte (24 Fighter) fliegt 2 Runden zum Baumarker
├── Runde 1 nach Ankunft: 24 FÄ vorhanden, 8 verbraucht → Rest 16
├── Runde 2: 8 verbraucht → Rest 8
├── Runde 3: 8 verbraucht → Rest 0 → STATION FERTIG
├── Gesamtzeit: 5 (Produktion) + 2 (Reise) + 3 (Bau) = 10 Runden
└── Produktionsausfall: 25 Fighter (5 Runden × Rate 5)

Szenario 2: Tröpfchenbau (verteilt die Last)
├── Rate-3-Planet sendet jede Runde 3 Fighter, Reisezeit 2 Runden
├── Runde 3: erste 3 FÄ ankommen → < 8 → PAUSE
├── Runde 4: +3 = 6 FÄ → < 8 → PAUSE
├── Runde 5: +3 = 9 FÄ → Bau! 8 verbraucht → Rest 1
├── Runde 6: +3 = 4 FÄ → < 8 → PAUSE
├── Runde 7: +3 = 7 FÄ → < 8 → PAUSE
├── Runde 8: +3 = 10 FÄ → Bau! 8 verbraucht → Rest 2
├── Runde 9: +3 = 5 FÄ → < 8 → PAUSE
├── Runde 10: +3 = 8 FÄ → Bau! 8 verbraucht → STATION FERTIG
└── Gesamtzeit: 10 Runden (aber Produktion auf Planet weiterhin teils nutzbar)

Szenario 3: Bomber-Express
├── Rate-5-Planet produziert Bomber: 5 alle 2 Runden = 10 FÄ/2 Runden
├── 2 Bomber-Wellen (je 6 Bomber = 12 FÄ) → 24 FÄ gesamt
├── Welle 1 ankommt: 12 FÄ → Bau (8), Rest 4
├── Welle 2 ankommt: 4+12 = 16 → Bau (8), Rest 8 → Bau (8) → FERTIG
└── Bomber sind langsamer aber pro Schiff doppelt so effizient

Szenario 4: Voll ausgebaute Station
├── Station: 24 FÄ, 3 Baurunden
├── Batterie 1: 4 FÄ, 1 Baurunde
├── Batterie 2: 8 FÄ, 2 Baurunden
├── Gesamt: 36 FÄ = 18 Bomber, 6 Baurunden
├── Vergleich: Batterie 1-5 auf Rate-3-Planet = 45 Fighter, 15 Runden
└── Station mit 2 Batterien ist günstiger, aber ohne Produktion/Rebellionsschutz
```

### Visualisierung

```
Stationen auf der Karte:

Im Bau (nur für Besitzer sichtbar):
├── Kleines Baumarker-Symbol (z.B. Raute/Diamant, halbtransparent)
├── Fortschrittsanzeige (Ring oder Balken)
└── Spielerfarbe, aber dezent/transparent

Operativ ohne Garnison (nur für Besitzer sichtbar):
├── Station-Symbol (z.B. Raute/Diamant, Spielerfarbe)
├── Batterie-Anzeige (wie bei Sternen)
└── Kein Schiff-Counter sichtbar

Operativ mit Garnison (sichtbar für alle):
├── Station-Symbol in Spielerfarbe (voll sichtbar)
├── Schiff-Counter (Fighter/Bomber)
├── Batterie-Anzeige
└── Schildlinien zu verbundenen Systemen/Stationen

Entdeckt aber leer (sichtbar für Entdecker):
├── Station-Symbol, aber ohne Schiff-Info
└── Spieler weiß: "dort ist eine Station", aber nicht ob/wie stark besetzt

Fog of War Memory:
└── Grau dargestellt wenn nicht mehr in Sichtweite (konsistent mit FUT-16a)
```

### Interaktion mit bestehenden Mechaniken

| Mechanik | Interaktion |
|----------|-------------|
| Schildlinien (FUT-19) | Station mit ≥ 2 Batterien kann Schildlinien zu Sternen/Stationen bilden. Zerstörung bricht Schildlinien |
| Batterien (FUT-10) | Batterie-Ausbau auf Station durch Material-Lieferung statt Produktion. Max 2, konsistent mit Schildlinien |
| Rebellion (FUT-18) | Stationen können NICHT rebellieren (keine Bevölkerung). Aber Rebellion kann Schildlinien zu Stationen brechen |
| Bomber (FUT-07/12) | Bomber als Baumaterial (1 = 2 FÄ). Bomber-Angriff auf Station: keine Produktionsreduktion (keine Produktion) |
| Fighter-Moral (FUT-17) | Staging-Vorteil: Flotten auf Station haben volle Moral für nahegelegene Ziele |
| Wellen-Splitting (C-20) | Gilt auch bei Station-Angriff: Wellen treffen einzeln auf Garnison + Batterien |
| Eroberung (FUT-08) | Station wird nach Eroberung zerstört (nicht übernommen). Verteidiger-Bonus gilt |
| Fog of War (FUT-16a) | Sichtbarkeitsstufen: unsichtbar → entdeckt → permanent sichtbar. FoW-Memory grau |
| Fortress-AI | Nutzt Stationen defensiv (Schildnetzwerk-Lücken schließen) |
| Rush-AI | Nutzt Stationen offensiv (schneller Staging-Punkt hinter feindlichen Linien) |
| Bomber-AI | Kann Stationen für Bomber-Staging nutzen (Moral-Vorteil) |

### Betroffene Systeme (zusätzlich zu FUT-19)

| Datei | Änderung |
|-------|----------|
| Neue Szene `station.tscn` | Station-Node: Position, owner_id, Garnison (fighter/bomber), Batterien, build_progress, material_stockpile, discovered_by[] |
| `ship_types.gd` | Neue Konstanten: `STATION_*` Parameter |
| `main.gd` Platzierung-UI | Platzierungsmodus: gültige Zonen anzeigen, Baumarker setzen, Validierung |
| `main.gd` Send-Dialog | Baumarker/Stationen als Flottenziele, Material-Lieferung |
| `main.gd` Bau-Logik | Pro Runde Material verbrauchen (8 FÄ), Fortschritt tracken, Station aktivieren |
| `main.gd` Batterie-Bau | Material-basierter Batterie-Ausbau (4 FÄ/Runde), Fortschritt tracken |
| `main.gd` Kampf | Station-Angriff wie Stern (Verteidiger-Bonus), Zerstörung nach Eroberung |
| `main.gd` Flotten-Logik | Flotten zu zerstörter Station → verloren. Flotten von Station senden |
| `main.gd` Sichtbarkeit | Scan-Logik: passiv (eigene Sterne+Stationen, volle Sichtweite), Flotten-Scan (größenabhängig 0-60px), Garnison-Sichtbarkeit |
| `main.gd` `_draw()` | Station-Symbole, Baufortschritt, Batterie-Anzeige, Schildlinien zu Stationen |
| `main.gd` Schildlinien | Stationen als Knoten im Schildnetzwerk, Zerstörung bricht Linien |
| `main.gd` Eliminierung | Stationen zerstören bei Spieler-Eliminierung |
| `ai_controller.gd` | Stationsbau-Entscheidungen: offensiv (hinter Schild), defensiv (Scan-Lücken schließen), Stations-Angriff |
| `scenes/main.tscn` | "Station bauen" Button im HUD, Platzierungsmodus-UI |

### Implementierungsschritte (grob)

**Phase A — Datenmodell & Platzierung:**
1. `ship_types.gd`: Alle `STATION_*` Konstanten definieren
2. Station-Datenstruktur: position, owner_id, build_progress, material_stockpile, fighter_count, bomber_count, battery_count, battery_build_progress, battery_material, discovered_by[], operative
3. `main.gd`: Baumarker-Array und Stations-Array verwalten
4. Platzierungs-UI: Modus aktivieren, gültige Zonen berechnen/anzeigen, Klick-Handler, Validierung
5. Baumarker als Flottenziel registrieren (im Send-Dialog auswählbar)

**Phase B — Bau & Material-Logik:**
6. Flotten-Ankunft an Baumarker: Schiffe in Material umwandeln (FÄ berechnen)
7. Pro Runde: Material verbrauchen (8 FÄ), Baufortschritt erhöhen, pausieren bei Mangel
8. Nach 3 Baurunden: Baumarker → operative Station umwandeln
9. Batterie-Bau: Material-Lieferung, 4 FÄ/Baurunde, Level-Progression

**Phase C — Station als Flottenziel & Staging:**
10. Operative Station als Flottenziel im Send-Dialog
11. Flotten-Ankunft an Station: Garnison aufstocken
12. Flotten von Station senden: Send-Dialog auf Station, Schiffe abziehen
13. Station-ActionPanel: Batterie-Bau starten, Schildlinie aktivieren (wenn ≥ 2 Bat.)

**Phase D — Kampf & Zerstörung:**
14. Station-Angriff: wie Stern-Kampf (Garnison + Batterien + Verteidiger-Bonus)
15. Eroberung → Station zerstören, Slot freigeben
16. Flotten unterwegs zu zerstörter Station: bei Ankunft verloren (Ziel prüfen)
17. Spieler-Eliminierung: alle Stationen zerstören

**Phase E — Sichtbarkeit & Scan:**
18. Sichtbarkeits-State pro Spieler: unsichtbar / entdeckt / sichtbar (Garnison)
19. Passiver Scan: eigene Sterne scannen 200px, eigene Stationen scannen 250px (immer erfolgreich, deterministisch)
20. Flotten-Scan: `scan_range = min(60, max(0, (fleet_size - 5) × 3))` — kürzeste Distanz Pfad↔Station prüfen
21. Garnison-Sichtbarkeit: Station mit Kampfschiffen → sichtbar für alle
22. Einmal entdeckt → permanent sichtbar, Fog-of-War-Memory (grau)
23. Station-Symbole in `_draw()`: Baumarker, operativ, entdeckt, FoW-Memory

**Phase F — Schildnetzwerk-Integration:**
24. Stationen als Knoten für Schildlinien (konsistent mit FUT-19)
25. Schildlinien-Aktivierung von/zu Stationen (SHIELD_ACTIVATE Modus)
26. Schildlinien-Bruch bei Station-Zerstörung

**Phase G — AI:**
27. AI: Stationsbau-Entscheidung (wann, wo, offensiv vs defensiv)
28. AI: Material-Logistik (welcher Planet liefert an welche Station)
29. AI: Scan-Auswertung (eigene Sterne/Stationen decken welche Bereiche ab? Wo sind Lücken?)
30. AI: Stations-Angriff priorisieren (entdeckte feindliche Stationen zerstören)
31. Balancing und Parameter-Tuning

---

## Strategische Gesamtbewertung

### Was sich ändert

```
Vorher (aktuell):
├── Batterien = lokale Verteidigung eines einzelnen Systems
├── Flottenbewegung = frei, nur Distanz zählt
├── Kartengeometrie = nur für Reisezeit relevant
└── Territorium = kein echtes Konzept, nur "wem gehört welcher Stern"

Nachher (FUT-19 + FUT-20):
├── Batterien = lokale Verteidigung + territoriale Schildlinien + Rebellionsreduktion
├── Flottenbewegung = frei, ABER durch feindliche Schildlinien teuer
├── Kartengeometrie = strategisch zentral (Engpässe, Schilddichte)
└── Territorium = sichtbare Grenzen mit verteidigbaren Schildlinien
```

### Neue strategische Dimensionen

| Dimension | Beschreibung |
|-----------|-------------|
| Territorial Control | Schildlinien definieren sichtbare Grenzen |
| Fortification Planning | Wo platziere ich Batterien für optimale Schildabdeckung? |
| Flanking | Kann ich um die Schildlinie herum angreifen? |
| Shield Breaking | Lohnt es sich, zuerst ein Schild-System zu erobern, um die Linie zu brechen? |
| Stealth Infiltration | Station hinter feindlichem Schild → Angriff von innen (FUT-20) |
| Reichsgröße-Tradeoff | Großes Reich = mehr Schildlinien aber mehr Lücken. Kleines Reich = kompakt + volle Stations-Kapazität für Angriff (FUT-20) |

### Neue Taktiken

```
Festungswall (FUT-19):
├── Schildlinien bewusst an Grenz-Systemen aktivieren
├── Feindliche Flotten müssen durch den Schild → Verluste/Blockade
├── Innere Systeme sicher für Produktion/Upgrade (+25% Ring-Bonus)
└── Schwäche: statisch, kann durch Stationen umgangen werden

Schild-Brecher (FUT-19):
├── Erst ein Schild-System erobern (Batterien fallen auf 50%)
├── Schildlinie bricht zusammen
├── Zweite Flotte stößt durch die Lücke
└── Erfordert koordinierte Angriffe

Bomber-Durchbruch (FUT-19):
├── Bomber erleiden halbe Schildverluste (50% Resistenz)
├── Bomber senken Produktion des Schild-Systems
├── Langfristige Schwächung der Verteidigung
└── Konsistent mit Bomber-Rolle als "schwere Waffe"

Stealth-Infiltration (FUT-20 — offensiv):
├── Bauplatz hinter feindlicher Schildlinie bestimmen
│   └── Außerhalb passiver Scan-Reichweite feindlicher Sterne (200px) / Stationen (250px)!
├── Material-Flotten zum Baumarker senden (24 FÄ, mehrere Wellen)
├── Station bleibt unsichtbar (keine Waffensignatur im Bau)
├── Risiko: feindliche Flotten (>5 Schiffe) könnten Baustelle nebenbei entdecken
├── Garnison stationieren → Überraschungsangriff auf Sterne hinter dem Schild
├── ACHTUNG: Garnison macht Station sichtbar → Timing entscheidend
└── Counter: eigene Sterne/Stationen scannen passiv, große feindliche Flotten scannen nebenbei

Staging-Angriff (FUT-20 — offensiv):
├── Station als Sammelpunkt in feindlichem Gebiet
├── Mehrere kleine Flotten sammeln sich auf Station
├── Koordinierter Angriff mit voller Moral (kurze Distanz)
└── Besonders effektiv gegen weit entfernte Ziele (Moral-Vorteil)

Stations-Kette (FUT-20 — offensiv):
├── Station A in Reichweite eigener Sterne
├── Station B in Reichweite von Station A
├── Station C in Reichweite von Station B
├── Ermöglicht Angriffe über extreme Distanzen
└── Kostet alle 3 Stations-Slots, aber enormer Reichweiten-Vorteil

Underdog-Strategie (FUT-20 — kleine Reiche):
├── Kompaktes Reich mit starken Schildlinien (kurze Distanzen)
├── Alle 3 Stationen offensiv hinter feindlichen Linien
├── Großes Reich kann Stationen nicht überall abdecken
└── Qualitativ gleiches Angriffspotential trotz weniger Systeme

Stations-Jagd (FUT-20 — defensiv):
├── Eigene Sterne + Stationen scannen passiv (volle Sichtweite)
├── Scan-Abdeckung prüfen: wo sind blinde Flecken?
├── Option A: eigene Station in Lücke platzieren (1 von 3 Slots)
├── Option B: große Flotten (25+) auf Routen durch verdächtiges Gebiet
├── Option C: Risiko akzeptieren, auf Garnison-Sichtbarkeit warten
└── Entdeckte Station sofort angreifen bevor Garnison aufgebaut
```

---

## Risiken & Abhängigkeiten

| Risiko | Auswirkung | Mitigation |
|--------|------------|------------|
| Turtle-Meta | Schildlinien machen Verteidigung zu stark | Bomber-Resistenz gegen Schilder + Stationen zum Umgehen |
| Visuelle Überladung | Zu viele Schildlinien + Stationen auf der Karte | Nur starke Linien prominent, Stationen dezent bis garnisioniert |
| AI-Komplexität | AI muss Schildlinien + Stationsbau + Patrol verstehen | Schrittweise: erst Schilder meiden, dann Stationen bauen, dann Patrol |
| Geometrie-Bugs | Liniensegment-Schnitt + Punkt-zu-Linie-Distanz bei Edge Cases | Robuste Implementierung, ausgiebig testen |
| Balancing | Schildstärke/Stationskosten zu hoch/niedrig | Parameter iterativ anpassen, playtesten |
| Phase 2 ohne Phase 1 sinnlos | Stationen ergeben nur mit Schildlinien Sinn | Striktes Phasenmodell |
| Stations-Spam | Spieler baut sofort 3 Stationen ohne Nutzen | Hohe Kosten (24 FÄ) + nicht zerstörbar durch Besitzer → Commitment |
| Verlorene Flotten | Flotten zu zerstörter Station gehen verloren — frustrierend? | UI-Warnung wenn Station bedroht/zerstört (sofern sichtbar) |
| Scan-Lücken zu groß | Stationen praktisch nie auffindbar | Sterne + Stationen scannen volle Sichtweite, große Flotten scannen nebenbei, Garnison macht sichtbar |

---

## Offene Fragen

### Phase 1 (FUT-19) — alle geklärt

Alle Design-Entscheidungen für FUT-19 wurden in der Bewertung vom 2026-02-12 getroffen.
Siehe `FUT-07-14-BEWERTUNG.md` → Abschnitt "Bewertung: FUT-19 — Defensive Shield Lines" für Details.

### Phase 2 (FUT-20) — alle geklärt

Alle Design-Entscheidungen für FUT-20 wurden am 2026-02-12 getroffen.
Nächster Schritt: Vollständige Bewertung in `FUT-07-14-BEWERTUNG.md` durchführen.
