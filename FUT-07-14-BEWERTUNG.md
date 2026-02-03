# Bewertung: FUT-07 bis FUT-14 (Final)

> Datum: 2026-02-03

## Übersicht der Mechaniken

| Feature | Beschreibung |
|---------|--------------|
| FUT-07 | Bomber: halbe Geschwindigkeit, 3/2 Angriff, 2/3 Verteidigung, halbe Produktionsrate |
| FUT-08 | Eroberung feindlicher Systeme: Produktion -1 |
| FUT-09 | Produktionsrate steigern statt Schiffe (max 8) |
| FUT-10 | Batterien: stark vs Fighter, schwach vs Bomber (max 3), Präsenz sichtbar |
| FUT-11 | Batterie-Wartung blockiert andere Produktion |
| FUT-12 | Bomber senken Produktion (skaliert mit Stärkeverhältnis) |
| FUT-13 | Produktion minimum 1 |
| FUT-14 | Gemischte Flotten, Geschwindigkeit = langsamstes Schiff |

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
