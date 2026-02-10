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
| FUT-17  | Fighter-Moral-Malus: Kampfkraft sinkt bei langen Reisen (>2 Turns)                 |

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
| Sichtbarkeit/Fog of War | Komplett | Batterien-Präsenz sichtbar, Stärke verborgen, Kampfintelligenz gemerkt |
| Limits/Caps | Komplett | Max Produktion 8, Min 1, Max Batterien 5 |

---

## Offene Punkte (keine Blocker)

| Thema | Status | Empfehlung |
|-------|--------|------------|
| ~~Batterie-Stärke (konkrete Werte)~~ | ~~Offen~~ | Erledigt: 2.0 Schaden/Batterie, 1.0× vs Fighter, 0.5× vs Bomber |
| ~~Bomber-Produktionsschaden (Formel)~~ | ~~Offen~~ | Erledigt: Bomber/Verteidiger-Verhältnis, max 3 Produktionsschaden |
| ~~UI für gemischte Flotten~~ | ~~Offen~~ | Erledigt: Zwei separate Slider (Fighter + Bomber) |

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

| Modus | Maintenance OFF | Maintenance ON (33%) |
|-------|-----------------|----------------------|
| Fighters | +rate/turn | +rate×0.33/turn |
| Bombers | +rate alle 2 Runden | +rate alle ~6 Runden |
| Upgrade | Normal | 3× langsamer |
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
- Schiffanzahl (nur "?" für fremde Systeme, außer nach Kampf)
- Bomber-Anzahl (nach Kampf bekannt)
- Batterie-Anzahl (nach Kampf bekannt, sonst nur Präsenz ja/nein)

### Kampfintelligenz (FUT-16a)

Nach einem Kampf lernen alle beteiligten Spieler den genauen Zustand:
- Verbleibende Fighter/Bomber-Zahlen
- Verbleibende Batterie-Anzahl
- Diese Werte werden in Klammern angezeigt: `(15/3) [(2)]`
- Bei Besitzerwechsel werden veraltete Werte zurückgesetzt

### Visuelle Darstellung

- **Farbe:** Abgedunkelt (50%) und entsättigt (70%)
- **Label:** Schiffanzahl in Klammern, z.B. "(12)" oder "(15/3)" mit Bombern
- **Batterien:** Bekannt: "[(N)]", unbekannt: "[?]"
- **Name:** Grau gefärbt
- **Hover-Info:** Zeigt "last seen" an, mit bekannten Werten falls vorhanden

### Strategische Implikationen

| Aspekt | Bewertung | Begründung |
|--------|-----------|------------|
| Kartenübersicht | ★★★★★ | Spieler verliert nicht die Orientierung |
| Informationswert | ★★★★☆ | Veraltete Info kann irreführend sein |
| Taktische Tiefe | ★★★★★ | Gegner kann sich hinter veralteten Infos verstecken |
| Benutzerfreundlichkeit | ★★★★★ | Intuitiv verständlich |

### Fazit

Quality-of-Life Feature, das die Spielerfahrung verbessert ohne Balance zu beeinflussen.

---

## Nachtrag: Bomber Batch-Produktion

> Datum: 2026-02-04

### Änderung

| Aspekt | Vorher | Nachher |
|--------|--------|---------|
| Produktionsmodell | Fraktional (halbe Rate pro Runde) | Batch (volle Rate alle 2 Runden) |
| Beispiel (Rate 3) | 1 Bomber Runde 1, 2 Bomber Runde 2 | 0 Bomber Runde 1, 3 Bomber Runde 2 |
| Beispiel (Rate 5) | 2 Bomber Runde 1, 3 Bomber Runde 2 | 0 Bomber Runde 1, 5 Bomber Runde 2 |

### Begründung

Das fraktionale Modell hatte Probleme mit ungeraden Produktionsraten:
- Rate 3: 1.5 Bomber/Runde → Rundungsfehler
- Rate 5: 2.5 Bomber/Runde → Inkonsistente Lieferung

### Neues Verhalten

```
Bomber-Produktion (Batch-Modell):
├── Runde 1: Progress += 0.5 → 50% → 0 Bomber
├── Runde 2: Progress += 0.5 → 100% → Rate Bomber geliefert
├── Progress reset auf 0
└── Zyklus wiederholt sich
```

### Auswirkung mit Maintenance (33%)

| Runde | Progress (ohne) | Progress (mit 1/3) |
|-------|-----------------|-------------------|
| 1 | 50% | 16.7% |
| 2 | 100% → Lieferung | 33.3% |
| 3 | 50% | 50% |
| 4 | 100% → Lieferung | 66.7% |
| 5 | 50% | 83.3% |
| 6 | 100% → Lieferung | 100% → Lieferung |

**Effekt:** Mit Maintenance dauert ein Bomber-Batch 6 Runden statt 2.

### Strategische Implikationen

| Aspekt | Bewertung | Begründung |
|--------|-----------|------------|
| Vorhersagbarkeit | ★★★★★ | Klare Lieferzyklen, keine Rundungsfehler |
| Burst-Dynamik | ★★★★☆ | Große Bomber-Wellen statt stetiger Strom |
| Timing-Relevanz | ★★★★★ | Angriff vor/nach Lieferung wichtiger |
| Konsistenz | ★★★★★ | Alle Produktionsraten verhalten sich gleich |

### Fazit

Die Batch-Produktion löst das Rundungsproblem elegant und fügt taktische Tiefe hinzu: Spieler müssen den Lieferzyklus berücksichtigen.

---

## Nachtrag: Fighter Batch-Produktion

> Datum: 2026-02-04

### Änderung

| Aspekt | Vorher | Nachher |
|--------|--------|---------|
| Produktionsmodell | Sofortige Lieferung (int(rate × multiplier)) | Batch (volle Rate alle 2 Runden) |
| FIGHTER_PRODUCTION_RATE | 1.0 | 0.5 |
| Normale Produktion | rate Fighter pro Runde | rate Fighter alle 2 Runden |
| Mit Maintenance | int(rate × 0.33) pro Runde | rate Fighter alle 6 Runden |

### Problem

Das vorherige Modell hatte zwei Probleme:

**1. Rundungsproblem bei Maintenance (33% Multiplikator):**

| Production Rate | Vorher (int(rate × 0.33)) | Problem |
|-----------------|---------------------------|---------|
| 1 | 0 Fighter/Runde | Keine Produktion! |
| 2 | 0 Fighter/Runde | Keine Produktion! |
| 3 | 0 Fighter/Runde | Keine Produktion! |
| 4 | 1 Fighter/Runde | Nur 25% statt 33% |
| 6 | 1 Fighter/Runde | Nur 17% statt 33% |
| 8 | 2 Fighter/Runde | Nur 25% statt 33% |

**2. Fehlende Burst-Dynamik:** Bomber hatten Burst-Produktion (alle 2 Runden), Fighter nicht.

### Neues Verhalten

```
Fighter-Produktion (Batch-Modell, RATE = 0.5):
├── Normal (rate_multiplier = 1.0):
│   ├── Runde 1: Progress += 0.5 → 50% → 0 Fighter
│   ├── Runde 2: Progress += 0.5 → 100% → rate Fighter geliefert
│   └── Progress reset auf 0%, Zyklus wiederholt (alle 2 Runden)
│
└── Mit Maintenance (rate_multiplier = 1/3):
    ├── Runde 1: Progress += 1/6 → 16.7% → 0 Fighter
    ├── Runde 2: Progress += 1/6 → 33.3% → 0 Fighter
    ├── Runde 3: Progress += 1/6 → 50% → 0 Fighter
    ├── Runde 4: Progress += 1/6 → 66.7% → 0 Fighter
    ├── Runde 5: Progress += 1/6 → 83.3% → 0 Fighter
    ├── Runde 6: Progress += 1/6 → 100% → rate Fighter geliefert
    └── Progress reset auf 0%, Zyklus wiederholt (alle 6 Runden)
```

### Auswirkung Normal vs. Maintenance

| Runde | Progress (normal) | Progress (Maintenance) |
|-------|-------------------|------------------------|
| 1 | 50% | 16.7% |
| 2 | 100% → Lieferung | 33.3% |
| 3 | 50% | 50% |
| 4 | 100% → Lieferung | 66.7% |
| 5 | 50% | 83.3% |
| 6 | 100% → Lieferung | 100% → Lieferung |

**Effekt:** Identischer Rhythmus wie Bomber (2 Runden normal, 6 Runden mit Maintenance).

### Vergleich mit Bomber

| Aspekt | Fighter | Bomber |
|--------|---------|--------|
| PRODUCTION_RATE | 0.5 | 0.5 |
| Normaler Zyklus | 2 Runden | 2 Runden |
| Mit Maintenance | 6 Runden | 6 Runden |
| Menge pro Batch | 2 × production_rate | 1 × production_rate |
| Gesamtrate/Runde | production_rate | production_rate / 2 |

**Fighter-Batch:** `production_rate / FIGHTER_PRODUCTION_RATE` = `2 × rate` (volle Rate)
**Bomber-Batch:** `production_rate` (halbe Rate gemäß FUT-07)

**Rhythmus-Symmetrie:** Gleicher Lieferzyklus (2/6 Runden), aber Bomber mit halber Gesamtproduktion.

### Strategische Implikationen

| Aspekt | Bewertung | Begründung |
|--------|-----------|------------|
| Konsistenz | ★★★★★ | Identisches Modell für Fighter und Bomber |
| Maintenance-Fairness | ★★★★★ | Alle Production Rates produzieren mit 33% |
| Burst-Dynamik | ★★★★★ | Immer Burst, synchron mit Bomber |
| Timing-Relevanz | ★★★★★ | Angriffszeitpunkt immer taktisch relevant |
| Anfangsphase | ★★★☆☆ | Erste Fighter erst nach 2 Runden |
| Taktische Tiefe | ★★★★★ | Lieferzyklus muss berücksichtigt werden |

### Fazit

Die Batch-Produktion für Fighter mit RATE 0.5 schafft vollständige Symmetrie mit der Bomber-Produktion. Der Lieferzyklus ist nun immer taktisch relevant - Angriffe kurz vor einer Lieferung können entscheidend sein. Der langsamere Start (erste Fighter nach 2 Runden) betrifft alle Spieler gleich und erhöht die strategische Tiefe.

---

## Nachtrag: Eroberungsverhalten (DB-12, PR-14)

> Datum: 2026-02-04

### Requirements

**DB-12:** On conquest, batteries are reduced to 50% (rounded down) and maintenance is enabled.

**PR-14:** On conquest, production mode shall reset to Fighters.

### Verhalten

| Aspekt | Verhalten | Requirement |
|--------|-----------|-------------|
| Batterie-Schaden | 50% Verlust (abgerundet) | DB-12 |
| Maintenance | Automatisch aktiviert | DB-12 |
| Produktionsmodus | Auf Fighters gesetzt | PR-14 |

### Beispiele

| Batterien vorher | Batterien nachher |
|------------------|-------------------|
| 1 | 0 |
| 2 | 1 |
| 3 | 1 |
| 4 | 2 |
| 5 | 2 |

### Begründung

Kompromiss zwischen zwei Extremen:
- **Volle Übernahme:** Zu starker Anreiz, befestigte Systeme zu erobern
- **Volle Zerstörung:** Eroberung wird bestraft, Defensive zu stark

### Strategische Implikationen

| Aspekt | Bewertung | Begründung |
|--------|-----------|------------|
| Balance | ★★★★★ | Eroberung lohnt sich, aber mit Kosten |
| Realismus | ★★★★☆ | Kampfschäden an Anlagen sind plausibel |
| Spielfluss | ★★★★★ | Eroberer muss nicht sofort Entscheidungen treffen (Auto-Maintenance) |
| Strategie | ★★★★★ | Defensive hat Wert, aber ist nicht unüberwindbar |

### Fazit

Elegante Lösung: Batterien behalten teilweise ihren Wert, ohne dass Eroberung zu attraktiv oder zu bestrafend wird.

---

## Nachtrag: FUT-17 - Fighter-Moral-Malus

> Datum: 2026-02-10

### Requirement

**FUT-17:** Fighter morale malus on long travel: fighters lose attack power on journeys beyond 2 turns, with bombers unaffected.

### Parameter

| Parameter | Wert | Beschreibung |
|-----------|------|--------------|
| `FIGHTER_MORALE_THRESHOLD` | 2 Turns | Reisezeit ohne Strafe |
| `FIGHTER_MORALE_PENALTY` | 0.2 (20%) | Angriffsreduktion pro Turn über Threshold |
| `FIGHTER_MORALE_MIN` | 0.5 (50%) | Untergrenze der Moral |

### Auswirkung nach Reisedauer

| Reisedauer | Fighter-Moral | Effektiver Angriff | Bomber-Angriff |
|------------|---------------|--------------------:|---------------:|
| 1 Turn | 100% | 1.0× | 1.5× |
| 2 Turns | 100% | 1.0× | 1.5× |
| 3 Turns | 80% | 0.8× | 1.5× |
| 4 Turns | 60% | 0.6× | 1.5× |
| 5 Turns | 50% (Min) | 0.5× | 1.5× |
| 6+ Turns | 50% (Min) | 0.5× | 1.5× |

### Strategische Analyse

```
Nahangriff (1-2 Turns):
├── Kein Moral-Malus
├── Fighter in voller Stärke
├── Reine Fighter-Flotten optimal
└── Standard-Eroberungstaktik

Mittelstrecke (3-4 Turns):
├── Fighter mit 80-60% Moral
├── Gemischte Flotten bevorzugt
├── Bomber gleichen Moral-Verlust aus
└── Mehr Schiffe nötig für gleichen Effekt

Fernangriff (5+ Turns):
├── Fighter nur noch 50% effektiv
├── Bomber dominieren den Angriffswert
├── Reine Bomber-Flotten erwägenswert
└── Fighter eher als "Kanonenfutter" / Verteidigung
```

### Interaktion mit bestehenden Mechaniken

| Mechanik | Interaktion mit Moral |
|----------|----------------------|
| Batterien | Batterien-Sortierung nach effektivem Angriffswert (mit Moral) |
| Gemischte Flotten | Bomber-Anteil wird bei langen Strecken wichtiger |
| Geschwindigkeitsdifferenz | Fighter allein: schnell + volle Moral. Gemischt: langsam + Moral-Malus |
| Flotten-Merge | Gewichtete Durchschnitts-Moral bei zusammengeführten Flotten |
| Verteidigerbonus | Verteidiger-Fighter haben immer 100% Moral |
| Fog of War | Moral im Sendedialog und Kampfbericht sichtbar |

### Taktische Implikationen

```
Entscheidung bei langem Angriff:

Option A: Reine Fighter (schnell, geschwächt)
├── Reisezeit: 3 Turns (150 px/turn)
├── Moral: 80%
├── Effektiver Angriff: 0.8 pro Fighter
└── Vorteil: Schnelle Ankunft

Option B: Gemischte Flotte (langsam, ausgeglichen)
├── Reisezeit: 6 Turns (75 px/turn)
├── Fighter-Moral: 50%
├── Bomber unverändert: 1.5× Angriff
└── Vorteil: Bombers kompensieren Fighter-Schwäche

Option C: Reine Bomber (langsam, konstant)
├── Reisezeit: 6 Turns (75 px/turn)
├── Kein Moral-Malus
├── Angriff: 1.5× pro Bomber
└── Vorteil: Wirtschaftsschaden, volle Stärke
```

### Balance-Bewertung

| Aspekt | Bewertung | Begründung |
|--------|-----------|------------|
| Strategische Tiefe | ★★★★★ | Entfernung wird zu strategischem Faktor |
| Bomber-Aufwertung | ★★★★★ | Bomber für Fernangriffe attraktiver |
| Fighter-Balance | ★★★★☆ | Fighter weiterhin stark auf kurze Distanz |
| Verteidigungsvorteil | ★★★★★ | Verteidiger hat immer volle Moral |
| Komplexität | ★★★★☆ | Einfache Regel, klare Auswirkung |
| Kartenrelevanz | ★★★★★ | Systemposition und Nachbarschaft wichtiger |

### Fazit

FUT-17 fügt eine elegante strategische Dimension hinzu: **Entfernung kostet**. Fighter verlieren auf langen Reisen an Kampfkraft, was Bomber für Fernangriffe aufwertet und die Kartenposition strategisch relevanter macht. Die Regel ist intuitiv (müde Piloten), einfach zu verstehen (% Anzeige im UI) und schafft interessante Trade-offs bei der Flottenkomposition.

---

## Nachtrag: FUT-04a - KI-Gegner mit wählbaren Taktiken

> Datum: 2026-02-10

### Requirement

**FUT-04a:** AI opponents with selectable tactics (Rush, Fortress, Economy, Bomber, Balanced).

### 5 Taktiken

| Taktik | Produktion | Flotten | Stärke | Schwäche |
|--------|-----------|---------|--------|----------|
| **Rush** | Nur Fighter, kein Upgrade | 60% zum nächsten Ziel | Schnelle Expansion | Niedrige Produktion |
| **Fortress** | Batterien an Grenze, Upgrade im Hinterland | Nur bei 2:1+ Übermacht | Starke Verteidigung | Langsame Expansion |
| **Economy** | Upgrade auf Max, dann Fighter | Vorsichtig früh, überwältigend spät | Endgame-Dominanz | Verletzlich früh |
| **Bomber** | Upgrade bis Rate 4, dann 1:2 Bomber:Fighter | Gemischt auf hochproduktive Feinde | Wirtschaftsschaden | Langsamer Aufbau |
| **Balanced** | Phasenabhängig (Rush→Eco→Bomber) | Adaptiv nach Spielphase | Flexibel | Kein klarer Vorteil |

### Strategische Analyse

```
Matchup-Matrix (Erwartete Stärken):

            vs Rush  vs Fortress  vs Economy  vs Bomber  vs Balanced
Rush          =         --          ++          +           +
Fortress      ++         =           -          -           =
Economy       --         +           =          +           =
Bomber        -          +           -          =           -
Balanced      -          =           =          +           =
```

### Design-Entscheidungen

| Aspekt | Entscheidung | Begründung |
|--------|-------------|------------|
| Fair Play | Nur Fog-of-War-Daten | Keine Allwissenheit, gleiche Regeln wie Spieler |
| Kein Cheating | system_memory als Datenbasis | KI sieht nur was sie erkundet hat |
| Statische Taktik | Keine Taktikwechsel mid-game | Vorhersagbar und erlernbar für Spieler |
| Balanced-Adaptivität | Phasen-basiert (Turn + Prod) | Einzige "dynamische" Taktik |

### Bewertung

| Aspekt | Bewertung | Begründung |
|--------|-----------|------------|
| Spielerfahrung | ★★★★★ | Einzelspieler-Modus endlich möglich |
| Taktik-Vielfalt | ★★★★★ | 5 distinkte, erlernbare Spielstile |
| Fairness | ★★★★★ | Gleiche Fog-of-War-Regeln wie Spieler |
| Herausforderung | ★★★★☆ | Kompetent aber nicht unschlagbar |
| Zuschauer-Modus | ★★★★☆ | Reine KI-Spiele als Demonstration |

### Fazit

FUT-04a transformiert das Spiel von einem reinen Hot-Seat-Multiplayer zu einem vollwertigen Einzelspieler-Erlebnis. Die 5 Taktiken decken das gesamte strategische Spektrum ab und bieten unterschiedliche Herausforderungen.
