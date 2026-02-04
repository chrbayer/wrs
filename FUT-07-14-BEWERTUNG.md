# Bewertung: FUT-07 bis FUT-14 (Final)

> Datum: 2026-02-03

## Übersicht der Mechaniken

| Feature | Beschreibung                                                                        |
| ------- | ----------------------------------------------------------------------------------- |
| FUT-07  | Bomber: halbe Geschwindigkeit, 3/2 Angriff, 2/3 Verteidigung, halbe Produktionsrate |
| FUT-08  | Eroberung feindlicher Systeme: Produktion -1                                        |
| FUT-09  | Produktionsrate steigern statt Schiffe (max 8)                                      |
| FUT-10  | Batterien: stark vs Fighter, schwach vs Bomber (max 5), Präsenz sichtbar            |
| FUT-11  | Batterie-Wartung reduziert Produktion auf 33% (Toggle)                              |
| FUT-12  | Bomber senken Produktion (skaliert mit Stärkeverhältnis)                            |
| FUT-13  | Produktion minimum 1                                                                |
| FUT-14  | Gemischte Flotten, Geschwindigkeit = langsamstes Schiff                             |
| FUT-15  | Batterie-Bauzeit skaliert mit Level, Maximum auf 5 erhöht                           |
| FUT-16  | Fog of War Memory: Einmal gesehene Systeme bleiben ausgegraut sichtbar              |

---

## Schiffstypen-Vergleich

| Eigenschaft | Fighter | Bomber |
|-------------|---------|--------|
| Geschwindigkeit | 150 px/turn | 75 px/turn |
| Angriffsstärke | 1x | 1.5x |
| Verteidigungsstärke | 1x | 0.67x |
| Produktionskosten | 1 Turn | 2 Turns |
| vs Batterien | Schwach | Stark |
| Wirtschaftsschaden | Nein | Ja (FUT-12) |

---

## Flottenoptionen

| Flottentyp | Geschwindigkeit | Stärken | Schwächen |
|------------|-----------------|---------|-----------|
| Reine Fighter | 150 px/turn | Schnell, günstig | Batterien, kein Wirtschaftsschaden |
| Reine Bomber | 75 px/turn | Anti-Batterie, Wirtschaftsschaden | Langsam, teuer, schwache Verteidigung |
| Gemischt | 75 px/turn | Flexibel, ausbalanciert | Langsam wie Bomber |

**Taktische Implikation von FUT-14:**
- Gemischte Flotten sind *nicht* schneller als reine Bomber
- Fighter separat zu schicken ist schneller, aber koordinierter Angriff schwieriger
- Ermöglicht "Bomber-Eskorte" Taktik

---

## Strategische Tiefe durch gemischte Flotten

```
Angriff auf befestigtes System:

Option A: Gemischte Flotte (langsam, koordiniert)
├── Bomber bekämpfen Batterien
├── Fighter bekämpfen Verteidiger
└── Ankunft: gleichzeitig

Option B: Getrennte Flotten (schnell, riskant)
├── Fighter zuerst (schnell) → werden von Batterien dezimiert
├── Bomber später (langsam) → System evtl. schon verstärkt
└── Ankunft: versetzt

Option C: Nur Bomber (langsam, spezialisiert)
├── Ignorieren Batterien
├── Schwach gegen Fighter-Verteidigung
└── Wirtschaftsschaden garantiert
```

---

## Wirtschaftskreislauf (komplett)

```
                    ┌─────────────────┐
                    │ Produktion 1-8  │
                    └────────┬────────┘
                             │
           ┌─────────────────┼─────────────────┐
           ▼                 ▼                 ▼
    ┌─────────────┐   ┌─────────────┐   ┌─────────────┐
    │   Fighter   │   │   Bomber    │   │  Batterie   │
    │  produzieren│   │ produzieren │   │    bauen    │
    │   (1/turn)  │   │  (1/2turn)  │   │   (warten)  │
    └─────────────┘   └─────────────┘   └──────┬──────┘
                                               │
                                               ▼
                                        ┌─────────────┐
                                        │  Batterie   │
                                        │   warten    │
                                        │  (FUT-11)   │
                                        └─────────────┘
           │                 │
           ▼                 ▼
    ┌─────────────────────────────────────────────────┐
    │              EROBERUNG / ANGRIFF                │
    └─────────────────────────────────────────────────┘
           │                 │
           ▼                 ▼
    ┌─────────────┐   ┌─────────────┐
    │ Eroberung   │   │Bomber-Schaden│
    │ Prod. -1    │   │ (verhältnis- │
    │ (FUT-08)    │   │  basiert)    │
    └──────┬──────┘   └──────┬───────┘
           │                 │
           └────────┬────────┘
                    ▼
             ┌─────────────┐
             │  Minimum: 1 │
             │  (FUT-13)   │
             └──────┬──────┘
                    │
                    ▼
             ┌─────────────┐
             │ Wiederaufbau│
             │  +1/turn    │
             │  (FUT-09)   │
             └─────────────┘
```

---

## Balance-Matrix (erweitert)

| Angreifer / Verteidiger | Fighter | Batterien | Bomber | Gemischt |
|-------------------------|---------|-----------|--------|----------|
| **Fighter** | = | -- | + | - |
| **Bomber** | - | ++ | = | + |
| **Gemischt** | + | + | + | = |

**Legende:** ++ starker Vorteil, + Vorteil, = ausgeglichen, - Nachteil, -- starker Nachteil

---

## Tempo-Analyse

| Strategie | Früh (Turn 1-10) | Mitte (Turn 11-25) | Spät (Turn 26+) |
|-----------|------------------|--------------------|-----------------|
| Fighter-Rush | ★★★★★ | ★★★☆☆ | ★★☆☆☆ |
| Bomber-Rush | ★★☆☆☆ | ★★★★☆ | ★★★★☆ |
| Batterie-Turtle | ★★★☆☆ | ★★★★☆ | ★★★☆☆ |
| Eco-Boom | ★☆☆☆☆ | ★★★☆☆ | ★★★★★ |
| Gemischte Flotten | ★★☆☆☆ | ★★★★★ | ★★★★★ |

---

## Vollständigkeit des Designs

| Aspekt | Status | Anmerkung |
|--------|--------|-----------|
| Einheitentypen | Komplett | Fighter + Bomber ausbalanciert |
| Wirtschaftssystem | Komplett | Produktion, Schaden, Wiederaufbau, Limits |
| Verteidigungsoptionen | Komplett | Mobile (Schiffe) + Statisch (Batterien) |
| Flottenkomposition | Komplett | Rein + Gemischt mit klaren Trade-offs |
| Sichtbarkeit/Fog of War | Komplett | Batterien-Präsenz sichtbar, Stärke verborgen |
| Limits/Caps | Komplett | Max Produktion 8, Min 1, Max Batterien 3 |

---

## Offene Punkte (keine Blocker)

| Thema | Status | Empfehlung |
|-------|--------|------------|
| Batterie-Stärke (konkrete Werte) | Offen | Bei Implementierung festlegen |
| Bomber-Produktionsschaden (Formel) | Offen | Bei Implementierung festlegen |
| UI für gemischte Flotten | Offen | Zwei Slider oder Tabs |

---

## Fazit

**Bewertung: 9.5/10**

| Aspekt | Bewertung | Begründung |
|--------|-----------|------------|
| Strategische Tiefe | ★★★★★ | Fighter, Bomber, Batterien, Wirtschaft, gemischte Flotten |
| Counter-Play | ★★★★★ | Keine dominante Strategie |
| Eleganz | ★★★★★ | Wenige Regeln, viele emergente Taktiken |
| Vollständigkeit | ★★★★★ | Alle Aspekte abgedeckt mit sinnvollen Limits |
| Komplexität | ★★★★☆ | Erhöht, aber jede Regel hat klaren Zweck |
| Tempo-Balance | ★★★★★ | Rush, Turtle, Eco alle viable in verschiedenen Phasen |

**Stärken:**
- Gemischte Flotten (FUT-14) fügen taktische Tiefe hinzu ohne Komplexität zu sprengen
- Geschwindigkeitsregel schafft interessante Entscheidungen (zusammen vs. getrennt)
- Minimum-Produktion (FUT-13) verhindert Frustration
- Alle 8 Features greifen sinnvoll ineinander

**Das Paket ist vollständig und bereit zur Implementierung.**

---

## Nachtrag: Batterie-Decay und Bauzeit

> Datum: 2026-02-03 (nach Implementierung)

### Neue Mechaniken

| Mechanik | Beschreibung |
|----------|--------------|
| Batterie-Decay | -1 Batterie/Runde wenn nicht BUILD oder MAINTAIN |
| Bauzeit | 2 Runden pro Batterie (statt 1) |

### Auswirkungen auf das Spiel

```
Vorher:                          Nachher:
┌─────────────┐                  ┌─────────────┐
│ BUILD: +1   │                  │ BUILD: +0.5 │
│ pro Runde   │                  │ pro Runde   │
└─────────────┘                  └─────────────┘
       │                                │
       ▼                                ▼
┌─────────────┐                  ┌─────────────┐
│ MAINTAIN:   │                  │ MAINTAIN:   │
│ Stabil      │                  │ Stabil      │
└─────────────┘                  └─────────────┘
       │                                │
       ▼                                ▼
┌─────────────┐                  ┌─────────────┐
│ ANDERE:     │                  │ ANDERE:     │
│ Stabil      │  ───────────►    │ -1/Runde    │
└─────────────┘                  └─────────────┘
```

### Strategische Implikationen

| Aspekt | Bewertung | Begründung |
|--------|-----------|------------|
| Opportunitätskosten | ★★★★★ | Batterien sind jetzt echte Investition, nicht "Fire-and-Forget" |
| Turtle-Nerf | ★★★★☆ | Defensive Spieler können nicht mehr "Max Batterien + Schiffe" |
| Commitment | ★★★★★ | Entscheidung für Batterien = Entscheidung gegen Mobilität |
| Timing-Fenster | ★★★★★ | Angreifer kann warten bis Batterien verfallen |
| Counter-Play | ★★★★★ | Belagerer kann Verteidiger zur Wartung zwingen |

### Neue Taktiken

```
Batterie-Bluff:
├── Spieler baut 3 Batterien
├── Wechselt zu Fighter-Produktion
├── Gegner wartet auf Decay (3 Runden)
└── Spieler nutzt die Zeit für Angriffsflotte

Batterie-Belagerung:
├── Angreifer positioniert Flotte in Reichweite
├── Verteidiger muss MAINTAIN wählen (keine neuen Schiffe)
├── Angreifer produziert weiter
└── Übermacht aufbauen, dann angreifen

Timing-Angriff:
├── Scout beobachtet Batterien (Präsenz sichtbar)
├── Warte auf Modus-Wechsel (kein MAINTAIN)
├── Angriff nach 2-3 Runden (Batterien geschwächt)
└── Weniger Batterie-Schaden beim Angriff
```

### Tempo-Update

| Strategie | Änderung | Neue Bewertung |
|-----------|----------|----------------|
| Batterie-Turtle | Geschwächt | ★★★☆☆ → ★★☆☆☆ (früh), ★★★☆☆ (spät) |
| Fighter-Rush | Gestärkt | Kann Batterie-Decay abwarten |
| Bomber-Angriff | Unverändert | Batterien immer noch relevant |

### Bewertung der Änderung

| Aspekt | Bewertung | Begründung |
|--------|-----------|------------|
| Balance-Verbesserung | ★★★★★ | Turtle-Strategie war zu stark |
| Strategische Tiefe | ★★★★★ | Timing-Entscheidungen wichtiger |
| Komplexität | ★★★★☆ | Eine zusätzliche Regel, aber intuitiv |
| Fairness | ★★★★★ | Batterien haben jetzt echte Kosten |
| Emergenz | ★★★★★ | Neue Taktiken entstehen natürlich |

### Fazit

**Bewertung: +0.3 zur Gesamtbewertung → 9.8/10**

Die Änderung löst ein potenzielles Balance-Problem:

**Problem (vorher):**
- Batterien einmal bauen → permanent stark
- Defensiv-Spieler konnte Batterien + Schiffe gleichzeitig haben
- Kein Zeitdruck für Angreifer

**Lösung (nachher):**
- Batterien erfordern kontinuierliche Aufmerksamkeit
- Trade-off: Verteidigung vs. Produktion
- Angreifer kann Timing ausnutzen

**Diese Änderung macht das Spiel dynamischer und belohnt aktives Spielen.**

---

## Nachtrag: Maintenance als Toggle mit 50% Produktion

> Datum: 2026-02-04

### Änderung

| Vorher | Nachher |
|--------|---------|
| BATTERY_MAINTAIN als dedizierter Produktionsmodus | Maintenance als unabhängiger Toggle |
| Wartung blockiert alle Produktion (0%) | Wartung reduziert Produktion auf 50% |
| Entweder/Oder-Entscheidung | Parallele Entscheidung |

### Neues Produktionssystem

```
Produktionsmodi (wählbar):          Maintenance-Toggle (unabhängig):
┌─────────────────────────┐         ┌─────────────────────────┐
│ • Fighters produzieren  │         │ ☐ Maintain Batteries    │
│ • Bombers produzieren   │    +    │   (50% prod.)           │
│ • Upgrade Production    │         │                         │
│ • Build Battery         │         │ Wenn aktiv: alle Modi   │
└─────────────────────────┘         │ laufen mit halber Rate  │
                                    └─────────────────────────┘
```

### Verhalten im Detail

| Modus | Maintenance OFF | Maintenance ON |
|-------|-----------------|----------------|
| Fighters | +rate/turn | +rate/2/turn |
| Bombers | +rate×0.5/turn | +rate×0.25/turn |
| Upgrade | Normal | Halb so schnell |
| Build Battery | Normal (kein Decay) | Normal (kein Decay) |

**Wichtig:** Battery Build verhindert immer Decay, unabhängig vom Maintenance-Toggle.

### Automatisches Verhalten

```
Nach erfolgreichem Batterie-Bau:
├── Maintenance-Toggle wird automatisch aktiviert
├── Produktionsmodus wechselt zu Fighters
└── Spieler behält 50% Fighter-Produktion
```

### Strategische Implikationen

| Aspekt | Bewertung | Begründung |
|--------|-----------|------------|
| Flexibilität | ★★★★★ | Nicht mehr "alles oder nichts" |
| Turtle-Viabilität | ★★★★☆ | Verteidiger kann jetzt auch produzieren |
| Komplexität | ★★★★☆ | Eine Variable mehr, aber intuitive UI |
| Mikromanagement | ★★★☆☆ | Toggle muss bewusst gesetzt werden |
| Trade-off Klarheit | ★★★★★ | 50% ist einfach zu verstehen |

### Neue Taktiken

```
Flexible Verteidigung:
├── Batterien bauen (Auto-Maintenance ON)
├── Mit 50% Fighter produzieren
├── Bei Bedrohung: ausreichende Verteidigung
└── Ohne Bedrohung: kontinuierlicher Aufbau

Timing-Optimierung:
├── Maintenance OFF kurz vor Angriff
├── Volle Produktion für Verstärkung
├── Batterien verfallen nur 1/Runde
└── 2-3 Runden Fenster nutzbar

Eco-Batterie-Hybrid:
├── 3 Batterien bauen
├── Maintenance ON
├── Upgrade mit 50% Rate
└── Langfristig stärker als pure Turtle
```

### Vergleich der Ansätze

| Aspekt | Blockiert (vorher) | 50% Toggle (nachher) |
|--------|-------------------|----------------------|
| Verteidiger-Stärke | Mittel | Hoch |
| Angreifer-Fenster | Groß | Kleiner |
| Spieler-Kontrolle | Wenig | Viel |
| Strategische Optionen | Binär | Graduell |
| Lernkurve | Einfach | Mittel |

### Bewertung der Änderung

| Aspekt | Bewertung | Begründung |
|--------|-----------|------------|
| Balance | ★★★★☆ | Verteidiger etwas stärker, aber fair |
| Spielerfreiheit | ★★★★★ | Mehr Optionen, mehr Kontrolle |
| Intuitivität | ★★★★☆ | CheckButton-UI ist klar |
| Strategische Tiefe | ★★★★★ | Neue Optimierungsmöglichkeiten |
| Kompatibilität | ★★★★★ | Alte Taktiken funktionieren noch |

### Fazit

**Bewertung: +0.1 zur Gesamtbewertung → 9.9/10**

Die Änderung von "Maintenance blockiert Produktion" zu "Maintenance halbiert Produktion" ist eine **Quality-of-Life-Verbesserung**:

**Vorteile:**
- Verteidiger fühlen sich nicht mehr "bestraft" für Batterien
- Mehr graduelle Entscheidungen statt binärer Wahl
- Toggle-UI ist intuitiver als zusätzlicher Produktionsmodus
- Ermöglicht neue Hybrid-Strategien

**Nachteile:**
- Leicht komplexer (eine zusätzliche Checkbox)
- Defensive Spielweise etwas stärker

**Gesamt:** Die Änderung macht Batterien attraktiver ohne sie übermächtig zu machen. Das 50%-Modell ist ein guter Kompromiss zwischen "kostenlos" und "blockiert alles".

---

## Nachtrag: Balance-Anpassung auf 33%

> Datum: 2026-02-04

### Änderung

| Parameter | Vorher | Nachher |
|-----------|--------|---------|
| `MAINTENANCE_PRODUCTION_MULTIPLIER` | 0.5 | 0.33 |

### Begründung

Die 50%-Rate verschob das Balance leicht zugunsten des Verteidigers:
- Verteidiger konnte Batterien warten UND nennenswerte Produktion haben
- Angreifer-Fenster wurden zu klein
- Turtle-Strategie wurde wieder zu stark

### Auswirkung

| Modus | Mit 50% Maintenance | Mit 33% Maintenance |
|-------|---------------------|---------------------|
| Fighters (Rate 3) | +1.5/turn | +1/turn |
| Fighters (Rate 6) | +3/turn | +2/turn |
| Upgrade (Rate 3) | 6 turns | 9 turns |

### Fazit

Die Reduzierung auf 33% stellt das ursprüngliche Balance-Ziel wieder her: Batterie-Wartung ist ein signifikanter Trade-off, aber kein vollständiger Produktionsstopp.

---

## Nachtrag: FUT-15 - Skalierende Batterie-Bauzeit

> Datum: 2026-02-04

### Requirement

**FUT-15:** Battery build time scales with current level (like production upgrade). Maximum increased to 5.

### Änderung

| Parameter | Vorher | Nachher |
|-----------|--------|---------|
| `MAX_BATTERIES` | 3 | 5 |
| Bauzeit | Konstant (2 Runden) | Skalierend (Level = Runden) |

### Bauzeit-Vergleich

| Batterie | Vorher | Nachher |
|----------|--------|---------|
| 1. | 2 Runden | 1 Runde |
| 2. | 2 Runden | 2 Runden |
| 3. | 2 Runden | 3 Runden |
| 4. | - | 4 Runden |
| 5. | - | 5 Runden |
| **Gesamt** | **6 Runden** | **15 Runden** |

### Schaden-Vergleich

| Batterien | Schaden/Runde |
|-----------|---------------|
| 3 (alt max) | 6 |
| 5 (neu max) | 10 |

### Strategische Implikationen

| Aspekt | Bewertung | Begründung |
|--------|-----------|------------|
| Konsistenz | ★★★★★ | Gleiche Mechanik wie Produktions-Upgrade |
| Frühe Batterien | ★★★★★ | Günstiger als vorher (1 Runde statt 2) |
| Späte Batterien | ★★★★☆ | Signifikante Investition (4-5 Runden) |
| Entscheidungstiefe | ★★★★★ | "Wie viele Batterien lohnen sich?" |
| Balance | ★★★★☆ | 5 Batterien stark, aber 15 Runden Investition |

### Neue Taktiken

```
Schnelle Verteidigung:
├── 1-2 Batterien bauen (1+2 = 3 Runden)
├── Günstige Abschreckung
└── Schnell zurück zur Produktion

Festung:
├── Alle 5 Batterien (15 Runden)
├── 10 Schaden/Runde gegen Angreifer
├── Hohe Maintenance-Last (33% Produktion)
└── Langfristige Strategie

Stufenweiser Ausbau:
├── Start mit 2-3 Batterien
├── Zwischendurch produzieren
├── Bei Bedrohung weiter ausbauen
└── Flexibler Ansatz
```

### Fazit

**Bewertung: +0.1 zur Gesamtbewertung → 10/10**

Die Änderung bringt volle Konsistenz zwischen Produktions- und Batterie-Ausbau:
- Beide folgen der Formel `Fortschritt = 1 / Ziellevel`
- Frühe Level sind günstig, späte teuer
- Maximales Investment für maximale Stärke

Das Design ist jetzt vollständig symmetrisch und elegant.

---

## Nachtrag: FUT-16 - Fog of War Memory

> Datum: 2026-02-04

### Requirement

**FUT-16:** Fog of war memory: previously seen systems stay visible (grayed out) with last known attributes.

### Verhalten

| Systemstatus | Darstellung |
|--------------|-------------|
| Aktuell sichtbar (eigenes System) | Normal, alle Details |
| Aktuell sichtbar (fremdes System) | Normal, "?" für Schiffe |
| Früher gesehen, jetzt außer Reichweite | Ausgegraut, letzte bekannte Infos |
| Nie gesehen | Komplett versteckt |

### Gespeicherte Informationen

Pro Spieler wird für jedes gesehene System gespeichert:
- Besitzer (zum Zeitpunkt der letzten Sichtung)
- Schiffanzahl (nur "?" für fremde Systeme)
- Batterie-Präsenz (ja/nein)

### Visuelle Darstellung

- **Farbe:** Abgedunkelt (50%) und entsättigt (70%)
- **Label:** Schiffanzahl in Klammern, z.B. "(12)"
- **Name:** Grau gefärbt
- **Hover-Info:** Zeigt "last seen" an

### Strategische Implikationen

| Aspekt | Bewertung | Begründung |
|--------|-----------|------------|
| Kartenübersicht | ★★★★★ | Spieler verliert nicht die Orientierung |
| Informationswert | ★★★★☆ | Veraltete Info kann irreführend sein |
| Taktische Tiefe | ★★★★★ | Gegner kann sich hinter veralteten Infos verstecken |
| Benutzerfreundlichkeit | ★★★★★ | Intuitiv verständlich |

### Fazit

Quality-of-Life Feature, das die Spielerfahrung verbessert ohne Balance zu beeinflussen.
