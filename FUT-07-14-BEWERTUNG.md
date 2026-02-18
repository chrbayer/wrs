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

Automatisches Weiterbauen:
├── Upgrade Production: bleibt aktiv bis mindestens Level 3 erreicht
├── Build Battery: bleibt aktiv bis mindestens 2 Batterien gebaut
└── Danach automatischer Wechsel zu Fighters

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

---

## Nachtrag: C-20 - Flottengröße und Wellen-Splitting

> Datum: 2026-02-11

### Requirement

**C-20:** Merged fleets exceeding MAX_FLEET_SIZE (50) are split into waves. Each wave faces batteries independently.

### Parameter

| Parameter | Wert | Beschreibung |
|-----------|------|--------------|
| `MAX_FLEET_SIZE` | 50 | Maximale Schiffe pro Kampfwelle |

### Mechanik

```
Flotten-Ankunft am Zielsystem:

1. Merge: Alle Flotten desselben Besitzers zusammenführen
2. Split: Überschuss in Wellen à MAX_FLEET_SIZE aufteilen
   ├── Fighter/Bomber-Verhältnis wird beibehalten
   └── Moral wird beibehalten
3. Batterie-Phase: Jede Welle wird separat beschossen
4. Kampf-Phase: Wellen kämpfen einzeln (stärkste zuerst)
   ├── Gewonnene Welle → nächste Welle desselben Besitzers verstärkt
   └── Verlorene Welle → nächste Welle kämpft gegen Verteidiger-Rest
```

### Beispiel

```
Spieler A schickt 3 Flotten (20+20+30 = 70 Fighter) → System mit 3 Batterien

Ohne Wave-Splitting:
├── Merge: 70 Fighter
├── Batterien: 9 Kills (3 × 3.0)
├── 61 Fighter vs Verteidiger
└── Batterien feuern nur 1× auf gesamte Flotte

Mit Wave-Splitting (MAX=50):
├── Merge: 70 Fighter
├── Split: Welle 1 (50F) + Welle 2 (20F)
├── Batterien vs Welle 1: 9 Kills → 41F
├── Batterien vs Welle 2: 9 Kills → 11F
├── Gesamt: 52F nach Batterien (statt 61F)
├── Welle 1 kämpft, Welle 2 verstärkt falls Welle 1 gewinnt
└── Batterien feuern 2× → doppelt so effektiv
```

### Strategische Implikationen

| Aspekt | Bewertung | Begründung |
|--------|-----------|------------|
| Anti-Deathball | ★★★★★ | Große Flotten werden durch mehrfaches Batterie-Feuer bestraft |
| Batterie-Aufwertung | ★★★★★ | Batterien feuern pro Welle → Effektivität skaliert mit Angreifergröße |
| Kleine Flotten | ★★★★☆ | Koordinierte Angriffe bis 50 Schiffe bleiben voll effektiv |
| Taktische Tiefe | ★★★★★ | Entscheidung: viele kleine vs. eine große Flotte |
| Komplexität | ★★★★★ | Transparent für Spieler, automatisch im Hintergrund |

### Fazit

Das Wellen-Splitting löst elegant das Deathball-Problem: Batterien werden gegen große Flotten deutlich effektiver, da sie jede Welle separat beschießen. Gleichzeitig bleiben koordinierte Angriffe mit bis zu 50 Schiffen unverändert möglich. Die Mechanik ist für Spieler transparent — sie sehen separate Kampfberichte pro Welle.

---

## Nachtrag: FUT-18 - Rebellions-Mechanik

> Datum: 2026-02-12

### Requirement

**FUT-18:** Rebellion mechanic: systems of dominant players may spontaneously rebel, spawning neutral fighters that attack the garrison. Asymmetric anti-snowball mechanic.

### Problem: Snowball-Effekt

```
Ohne Rebellion:
├── Spieler A erobert mehr Systeme
├── Mehr Systeme → mehr Produktion
├── Mehr Produktion → noch mehr Eroberungen
├── Symmetrische Mechaniken (Batterien, Verteidigerbonus) helfen dem Führer genauso
└── Führung wird uneinholbar
```

### Lösung: Asymmetrische Rebellion

```
Mit Rebellion:
├── Spieler A dominiert (Power Score > Durchschnitt × 1.3)
├── Ungeschützte Systeme rebellieren (Chance proportional zur Dominanz)
├── Rebellen = Produktionsrate × 3 + desertierte Garrison-Fighter
├── Desertion: floor(garrison_f × clamp(excess × 0.5, 0, 0.5)) — Bomber loyal
├── Kein Defender-Bonus: Rebellen sind die Einheimischen (1.0× statt 1.5×)
├── Bei Rebel-Sieg: System wird Rebellenplanet (is_rebel = true)
│   ├── Produziert jede Runde Fighter: max(1, prod_rate - decay)
│   ├── decay steigt um 2 pro Runde → Rate sinkt bis Untergrenze 1
│   └── Zeitdruck: Je länger unbezwungen, desto mehr Fighter sammeln sich
├── Bei Rückeroberung: -2 Produktion (normal -1 + Rebel-Malus -1)
└── Nur der Führende wird gebremst → asymmetrisch
```

### Parameter

| Parameter | Wert | Beschreibung |
|-----------|------|--------------|
| `REBELLION_DOMINANCE_FACTOR` | 1.3 | Auslöser: Spieler besitzt > Durchschnitt × 1.3 |
| `REBELLION_CHANCE_PER_DOMINANCE` | 0.3 (30%) | Chance pro System = (power_ratio - DOMINANCE_FACTOR) × Wert |
| `REBELLION_STRENGTH_FACTOR` | 3 | Rebellen = Produktionsrate × 3 |
| `REBELLION_PRODUCTION_DECAY` | 2 | Ratenabbau/Runde für Rebellenplaneten (Untergrenze: 1) |
| `REBELLION_DEFECTION_FACTOR` | 0.5 | Desertionsanteil = dominance_excess × Wert (Bomber immun) |
| `REBELLION_DEFECTION_MAX` | 0.5 (50%) | Maximale Desertion der Garnisons-Fighter |

### Beispielrechnung

```
4 Spieler, 30 Systeme insgesamt besetzt:
├── Durchschnitt: 30/4 = 7.5
├── Schwelle: 7.5 × 1.3 = 9.75 → ab 10 Systemen
│
├── Spieler A: 14 Systeme
│   ├── Überschuss: 14 - 7.5 = 6.5
│   ├── Rebellion-Chance: 6.5 × 0.05 = 32.5% pro System
│   ├── Immune: Heimatsystem + Systeme mit max Batterien (5)
│   ├── Reduziert: Batterien senken Chance um 20% pro Level
│   └── Pro System ohne max Batterien: 32.5% × (1 - Level/5)
│
├── System mit Rate 3: Rebellen = 3 × 3 = 9 Fighter
├── System mit Rate 5: Rebellen = 5 × 3 = 15 Fighter
└── System mit Rate 8: Rebellen = 8 × 3 = 24 Fighter
```

### Immunität

| Bedingung | Immun? | Begründung |
|-----------|--------|------------|
| Heimatsystem (letztes System) | ✅ Ja | Indirekte Elimination verhindern |
| Max Batterien (5) | ✅ Ja | Vollständige militärische Kontrolle |
| Teilweise Batterien (1–4) | ✅ Reduziert | Chance sinkt um 20% pro Level |
| Alle anderen | ❌ Nein | Ungeschützte Systeme können rebellieren |

### Strategische Implikationen

| Aspekt | Bewertung | Begründung |
|--------|-----------|------------|
| Anti-Snowball | ★★★★★ | Nur der Führende wird gebremst — asymmetrisch |
| Batterie-Aufwertung | ★★★★★ | Batterien reduzieren Rebellionschance (20%/Level, immun erst bei max) |
| Garnisonen | ★★★★★ | Dominanter Spieler muss Systeme garnisionieren |
| Strategische Tiefe | ★★★★★ | Expansion hat jetzt Kosten (Garnisonen/Batterien nötig) |
| Fairness | ★★★★★ | Trifft nur den Führenden, nicht alle |
| Komplexität | ★★★★☆ | Neue Regel, aber intuitiv (überdehnte Imperien rebellieren) |

### Neue Taktiken

```
Dominanter Spieler — Rebellion-Management:
├── Batterien an Grenz-Systemen (Doppelschutz: vs Angriff + reduziert Rebellion)
├── Garnisonen: Mindestens rate×3 Fighter pro System
├── Selektive Expansion: Nur hochproduktive Systeme besetzen
├── Rebellensysteme SOFORT zurückeroben — je länger gewartet, desto mehr Fighter
└── Kontrolle: Weniger Systeme, aber besser geschützt

Verfolger — Rebellion ausnutzen:
├── Rebellen-Systeme produzieren Fighter → werden stärker, je länger sie neutral bleiben
├── Rebellen-Systeme angreifen bevor Fighter zu viel werden (nur rate/turn anfangs)
├── Oder warten: decay lässt Rebellen auf min. Rate schrumpfen, dann leichter
├── Führender verliert Produktion bei Rückeroberung (-2 statt -1) → dauerhafte Schwächung
├── Timing: Angriff wenn Rebellionen den Führer schwächen
└── Indirekte Hilfe: Rebellionen öffnen Flanken
```

### Interaktion mit bestehenden Mechaniken

| Mechanik | Interaktion |
|----------|-------------|
| Batterien (FUT-10) | Doppelter Nutzen: Verteidigung + Rebellionsreduktion (immun erst bei max) |
| Fortress-KI | Natürlicher Vorteil: baut ohnehin Batterien |
| Rush-KI | Natürlicher Nachteil: viele Systeme, wenig Batterien; Rebellenplaneten häufen Fighter an |
| Economy-KI | Gemischt: hohe Produktion = starke Rebellen anfangs, aber decay begrenzt Bedrohung |
| Fighter-Moral (FUT-17) | Garnisonen haben volle Moral (Verteidiger); Rebellenfighter haben volle Moral |
| Rückeroberung (FUT-08) | Rebel-Rückeroberung kostet -2 Produktionspunkte (statt -1) als Kriegsschaden |
| Bomber als Garnison | Bomber desertieren nicht → Bomber-Garnison ist rebellionsresistenter; neuer Vorteil für defensive Bomber-Nutzung |

### Fazit

FUT-18 löst das zentrale Balance-Problem des Spiels: den Snowball-Effekt. Als **asymmetrische** Mechanik trifft sie nur den dominierenden Spieler und gibt Verfolgern eine Chance. Batterien reduzieren die Rebellionschance graduell (20% pro Level), erst bei maximalem Ausbau (Level 5) ist ein System vollständig immun. Das macht Expansion teuer — entweder voll ausbauen oder Rebellionsrisiko akzeptieren. Für FUT-19 bedeutet das: Schildlinien auf nicht voll ausgebauten Systemen können durch Rebellion zusammenbrechen.

**Erweiterung (2026-02-18): Rebellensysteme produzieren Fighter.** Rebel-gewonnene Systeme (is_rebel = true) produzieren jede Runde `max(1, prod_rate - rebel_production_decay)` Fighter. `rebel_production_decay` wächst um 2 pro Runde. Das schafft Zeitdruck: Der dominante Spieler muss schnell zurückerobern, sonst sammeln sich Fighter. Bei Rückeroberung verliert das System -2 Produktionspunkte statt -1 (Kriegsschaden). Verfolger können zwischen "sofort kontern" (System noch schwach) und "warten" (decay begrenzt Bedrohung) wählen — oder das System selbst als "geborgten Vorposten" nutzen.

---

## Bewertung: FUT-19 — Defensive Shield Lines

> Datum: 2026-02-12

### Requirement

**FUT-19:** Defensive shield lines: Two owned battery-equipped systems (min. 2 batteries each) within range can be manually linked to form a visible border barrier. Enemy fleets crossing this line suffer attrition or are blocked. Effect scales inversely with distance. Extension of battery mechanics.

### Grundprinzip

```
Batterien bekommen eine vierte Funktion:

Batterie-Funktionen (aktuell):          Batterie-Funktionen (mit FUT-19):
├── Lokale Verteidigung (FUT-10)         ├── Lokale Verteidigung (FUT-10)
├── Rebellionsreduktion (FUT-18)         ├── Rebellionsreduktion (FUT-18)
└── (das war's)                          ├── Schildlinien (FUT-19) ← NEU
                                         └── Territoriale Kontrolle

Neuer Produktionsmodus: SHIELD_ACTIVATE
├── 5. Option im Produktionsmenü (neben Fighters/Bombers/Upgrade/Battery)
├── Spieler wählt Partnersystem → BEIDE Systeme wechseln in Aktivierungsmodus
├── 2 Runden Aktivierungszeit (keine Produktion auf beiden Systemen)
├── Max 2 Schildlinien pro System
└── Permanent aktiv bis System erobert/Rebellion (auch bei Bat. < max!)/Batterien < 2
```

### Schildlinien-Entstehung

| Bedingung | Erforderlich? |
|-----------|--------------|
| Zwei eigene Systeme | ✅ Ja |
| Beide mit mindestens 2 Batterien | ✅ Ja (Level 1 = nur lokal + Rebellion) |
| Innerhalb MAX_SYSTEM_DISTANCE (250px) | ✅ Ja |
| Manuelle Aktivierung (SHIELD_ACTIVATE) | ✅ Ja — bewusste Entscheidung |
| Max 2 Linien pro System | ✅ Ja — verhindert Schild-Spam |
| Aktivierungsdauer | 2 Runden (beide Systeme blockiert) |
| Deaktivierung | ❌ Nicht manuell — permanent bis natürlicher Abbruch |

**Warum manuell?** Automatische Schildlinien wären ein unkontrollierbarer Nebeneffekt des Batteriebaus. Manuelle Aktivierung macht Schildlinien zu einer **bewussten strategischen Entscheidung**: Wo will ich meine Grenze ziehen? Welche 2 Nachbarn verbinde ich? Die Kosten (2 Runden auf beiden Systemen = 4 Systemrunden) erzwingen Priorisierung.

**Warum max 2?** Verhindert, dass ein zentrales System zum "Schild-Hub" wird. Spieler muss wählen, welche zwei Verbindungen die wichtigsten sind.

**Warum Level 2?** Die erste Batterie schützt nur lokal + reduziert Rebellion um 20%. Ab der zweiten entsteht die territoriale Dimension. Das macht den Batterie-Ausbau zu einer bewussten Entscheidung mit klarem Stufensprung:

```
Batterie-Progression:
├── Level 0: Kein Schutz
├── Level 1: Lokale Verteidigung + 20% Rebellionsreduktion (1 Runde Build)
├── Level 2: + Schildlinien-Berechtigung (1+2 = 3 Runden Build)
│   └── Aktivierung: +2 Runden auf BEIDEN Systemen (4 Systemrunden)
│       → Gesamtkosten für erste Schildlinie: 3+3 Build + 4 Aktivierung = 10 Systemrunden
├── Level 3-5: Stärkere Schilder + stärkere lokale Verteidigung (automatisch)
└── Max 2 Linien pro System — bewusste Wahl der Verbindungen
```

### Zwei-Formeln-System

Schildlinien verwenden zwei getrennte Berechnungen:

#### 1. Blockade-Check (basierend auf Minimum)

```
blockade_value = min(batteries_a, batteries_b) × density

Fighter blockiert wenn: blockade_value ≥ SHIELD_BLOCKADE_THRESHOLD (2.5)
Bomber  blockiert wenn: blockade_value ≥ SHIELD_BLOCKADE_THRESHOLD / SHIELD_BOMBER_RESISTANCE (5.0)
```

**Logik:** Das schwächste Glied bestimmt, ob die Linie **dicht** genug ist. Beide Systeme müssen stark sein.

#### 2. Attrition-Schaden (basierend auf Summe)

```
attrition = density × (batteries_a + batteries_b) × SHIELD_DAMAGE_FACTOR

Fighter-Verluste = fleet_fighters × attrition
Bomber-Verluste  = fleet_bombers  × attrition × SHIELD_BOMBER_RESISTANCE (0.5)
```

**Logik:** Die Gesamtfeuerkraft beider Systeme bestimmt den Schaden. Auch asymmetrische Aufstellungen (5+1) verursachen Schaden.

#### Density-Formel

```
density = 1.0 - (distance - MIN_SYSTEM_DISTANCE) / (MAX_SYSTEM_DISTANCE - MIN_SYSTEM_DISTANCE)

Beispiele:
├── 120px (Minimum): density = 1.0
├── 150px:           density = 0.77
├── 185px:           density = 0.50
├── 220px:           density = 0.23
└── 250px (Maximum): density = 0.0 (keine Wirkung)
```

### Parameter

| Parameter | Wert | Beschreibung |
|-----------|------|--------------|
| `SHIELD_MIN_BATTERIES` | 2 | Mindest-Batterien pro System für Schildlinie |
| `SHIELD_ACTIVATE_TIME` | 2 | Runden für Aktivierung (beide Systeme blockiert) |
| `MAX_SHIELD_LINES_PER_SYSTEM` | 2 | Maximale Schildlinien pro System |
| `SHIELD_DAMAGE_FACTOR` | 0.04 (4%) | Basisverlust pro Shield-Power-Punkt × Density |
| `SHIELD_BLOCKADE_THRESHOLD` | 2.5 | Fighter blockiert wenn min × density ≥ Wert |
| `SHIELD_BOMBER_RESISTANCE` | 0.5 | Bomber: halber Schaden, doppelter Blockade-Schwellwert |

### Blockade-Matrix

Wann werden Fighter/Bomber blockiert? (`min(bat_a, bat_b) × density ≥ Schwellwert`)

| min(Bat) | Density | Blockade-Wert | Fighter blockiert? | Bomber blockiert? |
|----------|---------|---------------|--------------------:|------------------:|
| 2 | 1.0 (120px) | 2.0 | ❌ Nein | ❌ Nein |
| 3 | 0.77 (150px) | 2.31 | ❌ Nein | ❌ Nein |
| 3 | 0.85 (139px) | 2.55 | ✅ **Ja** | ❌ Nein |
| 3 | 1.0 (120px) | 3.0 | ✅ **Ja** | ❌ Nein |
| 4 | 0.65 (166px) | 2.60 | ✅ **Ja** | ❌ Nein |
| 4 | 1.0 (120px) | 4.0 | ✅ **Ja** | ❌ Nein |
| 5 | 0.50 (185px) | 2.50 | ✅ **Ja** | ❌ Nein |
| 5 | 1.0 (120px) | 5.0 | ✅ **Ja** | ✅ **Ja** |

**Ergebnis:** Fighter-Blockade ab 3+ Batterien bei enger Nachbarschaft. Bomber-Blockade nur bei Maximal-Ausbau (5+5) auf Minimaldistanz — extrem selten.

### Attrition-Matrix

Verluste einer 40-Fighter-Flotte bei Durchquerung:

| Bat A | Bat B | Summe | Density | Attrition | Fighter-Verluste | Bomber-Verluste (40er) |
|-------|-------|-------|---------|-----------|------------------:|-----------------------:|
| 2 | 2 | 4 | 1.0 | 16% | 6 | 3 |
| 2 | 2 | 4 | 0.5 | 8% | 3 | 2 |
| 3 | 3 | 6 | 0.8 | 19.2% | 8 | 4 |
| 3 | 1 | 4 | 0.8 | 12.8% | 5 | 3 |
| 5 | 5 | 10 | 1.0 | 40% | 16 | 8 |
| 5 | 5 | 10 | 0.5 | 20% | 8 | 4 |
| 5 | 1 | 6 | 1.0 | 24% | 10 | 5 |

### Zeitpunkt-abhängiges Verhalten

| Zeitpunkt | Blockade existiert? | Verhalten |
|-----------|--------------------:|-----------|
| **Vor dem Senden** | Ja → Blockade | Send-Dialog verhindert das Senden (Button deaktiviert) |
| **Vor dem Senden** | Ja → Nur Attrition | Send-Dialog zeigt Verlustvorschau, Senden erlaubt |
| **Flotte unterwegs** | Blockade entsteht nachträglich | **Schiffe gehen verloren** (Fighter zerstört, Bomber ggf. durchgelassen bei halber Blockade) |
| **Flotte unterwegs** | Attrition entsteht nachträglich | Verluste werden bei Kreuzung der Linie berechnet |

```
Beispiel — nachträgliche Blockade mit Bomber-Durchlass:

Flotte unterwegs: 30 Fighter + 10 Bomber
Feind errichtet Schildlinie: min=3, density=0.9 → blockade_value = 2.7

Fighter: 2.7 ≥ 2.5 → BLOCKIERT → 30 Fighter zerstört
Bomber:  2.7 ≥ 5.0 → nicht blockiert → Bomber kommen durch
         Attrition: 0.9 × 6 × 0.04 × 0.5 = 10.8% → 1 Bomber Verlust
         → 9 Bomber erreichen das Ziel
```

### Stacking und Wellen

| Regel | Entscheidung | Begründung |
|-------|-------------|------------|
| Mehrere Schildlinien gekreuzt | **Kumulativ** — jede Linie einzeln berechnet | Belohnt dichte Verteidigung, "Defense in Depth" |
| Wellen (MAX_FLEET_SIZE Split) | **Jede Welle einzeln** betroffen | Konsistent mit Batterie-Verhalten, große Flotten stärker bestraft |

```
Beispiel — doppelte Schildlinie:

Flotte mit 40 Fightern kreuzt 2 Schildlinien:
├── Linie 1: Summe 6, density 0.8 → 19.2% → 8 Verluste → 32 Fighter übrig
├── Linie 2: Summe 4, density 0.6 → 9.6% → 3 Verluste → 29 Fighter übrig
└── Gesamt: 11 Fighter verloren (27.5% Gesamtverluste)
```

### Visualisierung

| Element | Darstellung |
|---------|-------------|
| Aktive Schildlinie | Leuchtende Linie in Spielerfarbe zwischen den Systemen |
| Stärke | Dicke/Helligkeit proportional zu density |
| Blockade-fähig | Zusätzlicher visueller Indikator (z.B. dickere Linie, Partikeleffekt) |
| Fog of War | Sichtbar wenn beide Endpunkte sichtbar |
| FoW Memory | Graue Erinnerungslinie wenn Systeme außer Reichweite (konsistent mit FUT-16a) |
| Send-Dialog | Verlustvorschau: "Schildlinie: ~8 Fighter, ~4 Bomber Verluste" oder "BLOCKIERT" |

### Interaktion mit bestehenden Mechaniken

| Mechanik | Interaktion |
|----------|-------------|
| Batterien (FUT-10) | Vierfach-Nutzen: Lokal + Rebellionsreduktion + Schildlinie + territorialer Wert |
| Rebellion (FUT-18) | Rebellion kann trotz Batterien < max auftreten → Schildlinien brechen zusammen (strategisch verheerend) |
| Bomber (FUT-07/12) | Bomber als Schild-Brecher: halbe Verluste, praktisch nie blockiert |
| Fighter-Moral (FUT-17) | Moral + Schildverluste kumulieren → Fernangriffe durch Schilder extrem teuer |
| Wellen-Splitting (C-20) | Jede Welle einzeln betroffen → große Flotten doppelt bestraft (Schild + Batterien) |
| Eroberung (FUT-08) | Erobertes System: Batterien auf 50% → Schildlinien werden schwächer oder brechen |
| Fortress-AI | Natürlicher Vorteil: baut Batterien → hat automatisch Schildlinien |
| Rush-AI | Natürlicher Nachteil: keine Batterien → kein Schild → verwundbar |
| Bomber-AI | Aufgewertet: Bomber durchdringen Schilder leichter |

### Strategische Analyse

```
Entscheidungsbaum für Schildlinien:

Schritt 1: Batterien bauen (Voraussetzung)
├── Level 1 (1 Runde): Lokaler Schutz + 20% Rebellionsreduktion
├── Level 2 (1+2 = 3 Runden): Schildlinien-BERECHTIGUNG
└── Level 3+ (6+ Runden): Stärkere Schilder bei Aktivierung

Schritt 2: Schildlinie aktivieren (bewusste Entscheidung)
├── SHIELD_ACTIVATE auf System A wählen → Partnersystem B anklicken
├── BEIDE Systeme 2 Runden blockiert (keine Produktion)
├── Max 2 Linien pro System → "Welche 2 Nachbarn sind mir am wichtigsten?"
└── Permanent — Commitment-Entscheidung

Gesamtkosten für eine Schildlinie (2 Systeme je Rate 3):
├── Batterie-Bau: 2×3 Runden = 6 Systemrunden (je 2 Batterien)
├── Aktivierung: 2×2 Runden = 4 Systemrunden
├── Gesamt: 10 Systemrunden = 30 Fighter Opportunitätskosten
└── → Eine Schildlinie kostet so viel wie eine mittlere Flotte!

Wann lohnt es sich?
├── Grenz-Systeme mit engem Abstand (hohe Density → starker Schild)
├── Kritische Engpässe zwischen zwei Reichen
├── Wenn Verteidigung wichtiger ist als Expansion
└── NICHT lohnenswert: weit entfernte Systeme (niedrige Density)
```

### Tempo-Analyse (aktualisiert)

| Strategie | Früh | Mitte | Spät | Änderung durch FUT-19 |
|-----------|------|-------|------|-----------------------|
| Fighter-Rush | ★★★★★ | ★★★☆☆ | ★★☆☆☆ | Geschwächt: Schildlinien stoppen Rush |
| Bomber-Rush | ★★☆☆☆ | ★★★★☆ | ★★★★★ | **Gestärkt**: Bomber durchdringen Schilder |
| Batterie-Turtle | ★★★☆☆ | ★★★★★ | ★★★★☆ | **Stark gestärkt**: Schildlinien = Festungswände |
| Eco-Boom | ★☆☆☆☆ | ★★★☆☆ | ★★★★★ | Gestärkt: Schilder schützen während Upgrade |
| Gemischte Flotten | ★★☆☆☆ | ★★★★★ | ★★★★★ | Unverändert: Fighter + Bomber-Mix bleibt stark |

### Neue Taktiken

```
Festungswall:
├── Batterien an 2-3 Grenz-Systemen → Schildlinien bilden sich
├── Feindliche Fighter-Flotten verlieren 15-25% beim Durchqueren
├── Bei engem Abstand: Fighter komplett blockiert
├── Innere Systeme sicher für Eco/Upgrade
└── Counter: Bomber-Flotten (halbe Verluste, nie blockiert)

Schildbrecher-Taktik:
├── Schritt 1: Bomber-Angriff auf ein Schild-System
│   ├── Bomber durchdringen Schildlinie mit halben Verlusten
│   └── Bomber senken Produktion, Batterien fallen bei Eroberung auf 50%
├── Schritt 2: Schildlinie bricht zusammen oder schwächt sich
├── Schritt 3: Fighter-Folgeflotte stößt ungehindert durch
└── Erfordert: Koordination, Investment in Bomber

Falle stellen:
├── Voraussetzung: 2 Systeme mit je 2+ Batterien, noch nicht verbunden
├── Gegner schickt große Flotte los (Pfad kreuzt potenzielle Schildlinie)
├── Sofort SHIELD_ACTIVATE starten (2 Runden Aktivierung)
├── Wenn Aktivierung vor Flottenankunft fertig → Blockade!
│   └── Fighter der Flotte gehen verloren, Bomber kommen ggf. durch
├── Erfordert: Vorausschauendes Batterie-Building + schnelle Reaktion
└── Counter: Bomber-Flotten (fast nie blockiert) oder kurze Reisedistanzen

Defense in Depth:
├── Mehrere parallele Schildlinien hintereinander
├── Feind muss alle kreuzen → kumulative Verluste
├── 3 Linien à 15% = ~38% Gesamtverluste
└── Teuer (viele Batterien nötig), aber extrem effektiv
```

### Balance-Bewertung

| Aspekt | Bewertung | Begründung |
|--------|-----------|------------|
| Strategische Tiefe | ★★★★★ | Territoriale Dimension, Entscheidungen bei Batterie-Platzierung |
| Batterie-Aufwertung | ★★★★★ | Vierfach-Nutzen macht Batterien zu einer zentralen Entscheidung |
| Bomber-Relevanz | ★★★★★ | Bomber als Schild-Brecher klar aufgewertet |
| Counter-Play | ★★★★★ | Schilder stark, aber Bomber + Stationen (FUT-20) als Counter |
| Kartenrelevanz | ★★★★★ | Systemposition und Nachbarschaft strategisch zentral |
| Fairness | ★★★★☆ | Fortress-AI bevorzugt, Rush-AI benachteiligt — Ausgleich durch FUT-20 |
| Komplexität | ★★★★☆ | Zwei Formeln + Aktivierungsmechanik, aber intuitiv (Schildlinie = Mauer) |
| Visuelle Klarheit | ★★★★☆ | Schildlinien sichtbar, Verlustvorschau im Dialog |
| Turtle-Risiko | ★★★★☆ | Aktivierungskosten (10 Systemrunden) + max 2 Linien begrenzen Turtle |
| Implementierungs-Aufwand | ★★★☆☆ | Geometrie (Linienschnitt), neuer Produktionsmodus, UI, AI |

### Risiko: Turtle-Meta

**Problem:** Schildlinien stärken die Defensive. Turtle-Gefahr?

**Eingebaute Bremsen:**
1. **Manuelle Aktivierung** — Schildlinien kosten 4 Systemrunden (2 Runden × 2 Systeme). Jede Linie = ~30 Fighter Opportunitätskosten
2. **Max 2 Linien pro System** — begrenzt die Schildabdeckung, erzwingt Lücken
3. **Bomber** durchdringen Schilder mit halben Verlusten und werden praktisch nie blockiert
4. **FUT-20 Stationen** ermöglichen Angriffe hinter die Schildlinie
5. **Rebellion (FUT-18)** bestraft den Führenden — Systeme mit Batterien < max können rebellieren → Schildlinien brechen
6. **Permanent** — falsch platzierte Linien können nicht umkonfiguriert werden

### Strukturen, Ringe und Produktionsbonus

#### Struktur-Limit

Schildlinien werden nicht einzeln gezählt, sondern als **zusammenhängende Strukturen:**

```
Struktur = zusammenhängende Kette oder Ring von Schildlinien

Beispiele für 2 Strukturen:

  Struktur 1 (Ring):          Struktur 2 (Kette):
  [A]====[B]                   [F]====[G]====[H]
   |      |                    (3 Sterne, 2 Linien, offen)
  [D]====[C]
  (4 Sterne, 4 Linien, geschlossen)
```

| Regel | Wert | Begründung |
|-------|------|------------|
| Max Strukturen pro Spieler | **2** | Jede beliebig lang, aber nur 2 unabhängige |
| Max Linien pro System | **2** | Garantiert einfache Ringe (kein Hub-System) |

**Warum max 2 Strukturen?** Gleiche Anzahl für alle Spieler — kleines Reich kann mit 2 Strukturen alles abdecken, großes Reich nicht.

#### Produktionsbonus für geschlossene Ringe

Wenn eine Struktur einen **geschlossenen Ring** bildet, erhalten umschlossene Sterne einen Produktionsbonus:

```
    [A]========[B]
     |          |
     |  [X][Y]  |       ← [X], [Y] liegen im Polygon A-B-C-D
     |          |          → Voller Bonus (+25% Produktion)
    [D]========[C]       ← [A],[B],[C],[D] sind Ring-Sterne
                            → Halber Bonus (+12% Produktion)

    [E]                  ← Außerhalb → kein Bonus
```

| Stern-Typ | Bonus | Erkennung |
|-----------|-------|-----------|
| Innerer Stern (vollständig umschlossen) | +25% Produktion | Polygon-Test (Ray Casting) |
| Ring-Stern (am Schild beteiligt) | +12% Produktion | Mitglied der Ring-Struktur |
| Außerhalb / offene Kette | Kein Bonus | — |

**Warum Polygon-Test?** Max 2 Linien pro System garantiert, dass jeder Ring ein einfaches Polygon ist (keine Kreuzungen, keine verschachtelten Zyklen). Ray Casting ist dann mathematisch korrekt und effizient.

#### Warum das kleine Reiche bevorzugt

```
Kleines Reich (6 Systeme):                Großes Reich (15 Systeme):
├── 1 Ring (5 Sterne) + 1 Kette          ├── 1 Ring (6 Sterne) + 1 Kette
├── Ring umschließt 1 inneren Stern       ├── Ring umschließt 2-3 innere Sterne
├── 5 Ring-Sterne × 12% + 1 inner × 25%  ├── 6 Ring × 12% + 3 inner × 25%
├── → 6/6 Systeme profitieren (100%)      ├── → 9/15 Systeme profitieren (60%)
└── Kompaktes Reich = starker Schild       └── 6 Systeme ohne Bonus (verstreut)
```

### Parameter (aktualisiert)

| Parameter | Wert | Beschreibung |
|-----------|------|--------------|
| `SHIELD_MIN_BATTERIES` | 2 | Mindest-Batterien pro System für Schildlinie |
| `SHIELD_ACTIVATE_TIME` | 2 | Runden für Aktivierung (beide Systeme blockiert) |
| `MAX_SHIELD_LINES_PER_SYSTEM` | 2 | Maximale Schildlinien pro System |
| `MAX_SHIELD_STRUCTURES` | 2 | Max unabhängige Schildstrukturen pro Spieler |
| `SHIELD_DAMAGE_FACTOR` | 0.04 (4%) | Basisverlust pro Shield-Power-Punkt × Density |
| `SHIELD_BLOCKADE_THRESHOLD` | 2.5 | Fighter blockiert wenn min × density ≥ Wert |
| `SHIELD_BOMBER_RESISTANCE` | 0.5 | Bomber: halber Schaden, doppelter Blockade-Schwellwert |
| `SHIELD_RING_BONUS_INNER` | 0.25 (25%) | Produktionsbonus für umschlossene Sterne |
| `SHIELD_RING_BONUS_RING` | 0.12 (12%) | Produktionsbonus für Ring-Sterne |

### Fazit

FUT-19 erweitert das Batteriesystem von einer lokalen zu einer **territorialen** Mechanik mit drei Schichten:

1. **Schildlinien** — Attrition und Blockade für feindliche Flotten
2. **Strukturen** — Max 2 zusammenhängende Schildnetzwerke, bewusst aktiviert
3. **Ring-Bonus** — Geschlossene Ringe belohnen mit Produktionsbonus, bevorzugt kompakte Reiche

Das Zwei-Formeln-System (Minimum für Blockade, Summe für Schaden) erzeugt interessante Asymmetrien:
- **Gleichmäßiger Ausbau** (3+3) ermöglicht Blockaden
- **Asymmetrischer Ausbau** (5+1) verursacht dennoch hohen Schaden
- **Bomber** sind der natürliche Counter — halbe Verluste, praktisch nie blockiert

Die manuelle Aktivierung + Struktur-Limit machen Schildlinien zu einer **echten strategischen Ebene**: Wo ziehe ich meine Grenzen? Schließe ich den Ring für den Bonus? Das zeitpunkt-abhängige Verhalten (Send-Dialog blockiert vs. nachträgliche Zerstörung) erzeugt zusätzliche taktische Tiefe.

**Anti-Snowball:** Der Produktionsbonus durch Ringe bevorzugt systematisch kleinere, kompakte Reiche — ein weiterer Mechanismus neben Rebellion (FUT-18), der den Führenden bremst.

**Kritisch:** FUT-19 allein birgt Turtle-Risiko. FUT-20 (Stationen) ist als Gegengewicht eingeplant und sollte zeitnah folgen.
