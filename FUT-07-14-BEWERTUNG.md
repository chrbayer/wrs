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
| Produktionsrate | rate/Turn | rate alle 2 Turns |
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

| Strategie | Früh (nur Neutrale) | Mitte (Neutrale + Feinde) | Spät (nur Feinde) |
|-----------|---------------------|--------------------------|-------------------|
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
Batterie-Festung:
├── Spieler baut 3+ Batterien
├── Wechselt zu Fighter-Produktion
├── Batterien sind permanent (kein Decay)
└── Verteidigung + volle Produktion gleichzeitig

Batterie-Belagerung:
├── Angreifer positioniert Flotte in Reichweite
├── Verteidiger produziert weiter (kein Maintenance-Malus)
├── Angreifer muss Übermacht aufbauen
└── Batterien bleiben bis zur Eroberung aktiv
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

## Nachtrag: Maintenance komplett entfernt

> Datum: 2026-02-11

### Änderung

| Vorher | Nachher |
|--------|---------|
| BATTERY_MAINTAIN als dedizierter Produktionsmodus | ~~Maintenance als unabhängiger Toggle~~ → **Komplett entfernt** |
| Wartung reduzierte Produktion (erst 50%, dann 33%) | **Batterien sind permanent, kein Decay** |
| Maintenance-Toggle im Produktionsmenü | **Kein UI-Element mehr nötig** |

### Produktionssystem

```
Produktionsmodi (wählbar):
┌─────────────────────────┐
│ • Fighters produzieren  │
│ • Bombers produzieren   │
│ • Upgrade Production    │
│ • Build Battery         │
└─────────────────────────┘

Batterien sind permanent — kein Decay, kein Maintenance-Toggle.
```

### Begründung

1. Maintenance ohne Produktionskosten war ein sinnloser Toggle — es gab keinen Grund, ihn zu deaktivieren.
2. Battery Decay ohne Gegenmaßnahme (kein UI-Toggle mehr) wäre unfair.
3. Vereinfachung: weniger UI-Elemente, weniger Spielmechanik-Komplexität.

### Neues Balance

| Aspekt | Bewertung | Begründung |
|--------|-----------|------------|
| Rush vs Fortress | ★★★★★ | Fortress produziert gleich viele Schiffe + hat permanente Batterien |
| Batterie-Kosten | ★★★★☆ | Einzige Kosten: Bauzeit (keine Produktion während BATTERY_BUILD) |
| Strategische Vielfalt | ★★★★★ | Alle 5 AI-Taktiken haben Chancen |

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
├── Permanente Verteidigung (kein Maintenance nötig)
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

## Nachtrag: Vereinfachte Produktion (Batch-System entfernt)

> Datum: 2026-02-11

### Änderung

| Aspekt | Vorher (Batch) | Nachher (direkt) |
|--------|----------------|------------------|
| Fighter | Alle 2 Runden: 2×rate | Jede Runde: +rate |
| Bomber | Alle 2 Runden: rate | Jede Runde: +rate×0.5 (akkumuliert) |

### Begründung

Das Batch-System wurde ursprünglich eingeführt, um Rundungsprobleme mit dem Maintenance-Multiplikator zu lösen (z.B. `int(rate × 0.33) = 0` bei niedrigen Raten). Mit dem kompletten Wegfall von Maintenance und Battery Decay ist das Batch-System überflüssig.

### Neues Verhalten

```
Fighter-Produktion:
└── Jede Runde: +production_rate Fighter (sofort)

Bomber-Produktion (halbe Rate, FUT-07):
├── Batch-Lieferung alle 2 Runden
├── Liefermenge: production_rate Bomber
└── Thematisch: komplexe Schiffe brauchen Bauzeit
    Beispiel Rate 3: 0, 3, 0, 3, ... (Ø 1.5/Runde)
    Beispiel Rate 5: 0, 5, 0, 5, ... (Ø 2.5/Runde)
```

### Vorteile

| Aspekt | Bewertung | Begründung |
|--------|-----------|------------|
| Einfachheit | ★★★★★ | Fighter sofort, Bomber alle 2 Runden |
| Vorhersagbarkeit | ★★★★★ | Fighter: immer rate/Runde, kein Warten |
| Anfangsphase | ★★★★★ | Fighter ab Runde 1 (vorher erst ab Runde 2) |
| Thematik | ★★★★★ | Bomber als komplexe Schiffe brauchen Bauzeit |

---

## Nachtrag: Eroberungsverhalten (DB-12, PR-14)

> Datum: 2026-02-04

### Requirements

**DB-12:** On conquest, batteries are reduced to 50% (rounded down).

**PR-14:** On conquest, production mode shall reset to Fighters.

### Verhalten

| Aspekt | Verhalten | Requirement |
|--------|-----------|-------------|
| Batterie-Schaden | 50% Verlust (abgerundet) | DB-12 |
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
| Spielfluss | ★★★★★ | Eroberer muss nicht sofort Entscheidungen treffen |
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
| **Balanced** | Phasenabhängig (Expand→Eco→Bomber) | Adaptiv nach Spielzustand | Flexibel | Kein klarer Vorteil |

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
| Gemeinsame Frühphase | Alle Taktiken expandieren identisch ohne Feindkontakt | Faire Startbedingungen |
| Zustandsbasierte Phasen | Früh/Mitte/Spät durch Sichtbarkeit (Neutrale/Feinde), nicht Rundennummer | Adaptiv an Spielsituation |

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
