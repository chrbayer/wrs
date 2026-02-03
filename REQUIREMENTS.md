# Requirements for Space Battle (Weltraumschlacht)

> Based on `Spezifikation.md` and current implementation state.
> Status: ✅ Done | 🔧 Partial | ❌ Not implemented

---

## Universe & Map

| ID   | Requirement                                                        | Status |
|------|--------------------------------------------------------------------|--------|
| U-01 | The game shall generate a 2D universe with star systems at game start | ✅ Done |
| U-02 | Star systems shall maintain a minimum distance from each other     | ✅ Done |
| U-03 | The universe shall fill a rectangular area                         | ✅ Done |
| U-04 | The number of star systems shall scale with the number of players  | ✅ Done |
| U-05 | Star systems shall maintain a minimum distance from the map edges  | ✅ Done |
| U-06 | Each star system shall have at least one neighbor within visibility range | ✅ Done |

---

## Star Systems

| ID   | Requirement                                                                      | Status |
|------|----------------------------------------------------------------------------------|--------|
| S-01 | Each star system shall have a randomly assigned production rate                  | ✅ Done |
| S-02 | Each neutral star system shall start with a random number of defending fighters  | ✅ Done |
| S-03 | Player starting systems shall have a guaranteed minimum distance between them    | ✅ Done |
| S-04 | All star systems except player starting systems shall be neutral at game start   | ✅ Done |
| S-05 | Conquered star systems shall produce fighters each turn based on production rate | ✅ Done |
| S-06 | Each star system shall display its fighter count to its owner                    | ✅ Done |
| S-07 | Star systems shall display "?" for fighter counts to non-owners (fog of war)     | ✅ Done |
| S-08 | Star systems shall only be visible if within range of an owned system            | ✅ Done |

---

## Ships & Fleets

| ID   | Requirement                                                              | Status |
|------|--------------------------------------------------------------------------|--------|
| F-01 | There shall be only one ship type: Fighters                              | ✅ Done |
| F-02 | Players shall be able to send groups of fighters from one system to another | ✅ Done |
| F-03 | Fleet travel time shall depend on the distance between systems           | ✅ Done |
| F-04 | Fleets in transit shall not be visible to any player                     | ✅ Done |
| F-05 | Fleets in transit cannot be redirected until they arrive                 | ✅ Done |
| F-06 | Arriving fleets shall reinforce friendly systems or attack enemy/neutral | ✅ Done |

---

## Combat

| ID   | Requirement                                                                  | Status |
|------|------------------------------------------------------------------------------|--------|
| C-01 | Defenders shall receive a combat bonus (1.5x effectiveness)                  | ✅ Done |
| C-02 | Combat outcome probability shall be based on attacking vs defending fighters | ✅ Done |
| C-03 | The winner of combat shall control the star system                           | ✅ Done |
| C-04 | Surviving fighters shall remain at the system after combat                   | ✅ Done |
| C-05 | Combat reports shall be shown to involved players                            | ✅ Done |
| C-06 | When multiple fleets arrive simultaneously, they attack in order of size (largest first) | ✅ Done |

---

## Players & Turns

| ID   | Requirement                                                           | Status |
|------|-----------------------------------------------------------------------|--------|
| P-01 | The game shall support 2 to 4 human players                           | ✅ Done |
| P-02 | There shall be no computer-controlled players                         | ✅ Done |
| P-03 | The game shall be turn-based with each player taking turns sequentially | ✅ Done |
| P-04 | A transition screen shall show whose turn it is                       | ✅ Done |
| P-05 | Each player shall have a unique color                                 | ✅ Done |

---

## Victory Conditions

| ID   | Requirement                                                                  | Status |
|------|------------------------------------------------------------------------------|--------|
| V-01 | A player wins by controlling all star systems                                | ✅ Done |
| V-02 | A player is eliminated when they control no systems and have no fleets       | ✅ Done |
| V-03 | The game shall display a victory screen when a player wins                   | ✅ Done |

---

## User Interface

| ID    | Requirement                                                        | Status |
|-------|--------------------------------------------------------------------|--------|
| UI-01 | Players shall select systems by clicking on them                   | ✅ Done |
| UI-02 | A slider shall allow players to choose how many fighters to send   | ✅ Done |
| UI-03 | The travel time to a target system shall be displayed before sending | ✅ Done |
| UI-04 | The current turn number shall be visible                           | ✅ Done |
| UI-05 | The current player's total ship count shall be visible             | ✅ Done |
| UI-06 | An "End Turn" button shall advance the game                        | ✅ Done |
| UI-07 | A "Play Again" option shall be available after game over           | ✅ Done |
| UI-08 | A "Send All" button shall allow sending all fighters at once       | ✅ Done |

---

## Future Requirements (Not in Original Spec)

| ID     | Requirement                                              | Status         |
|--------|----------------------------------------------------------|----------------|
| FUT-01 | Save and load game state                                 | ❌ Not implemented |
| FUT-02 | Show fleets in transit to their owner on the map         | ❌ Not implemented |
| FUT-03 | Sound effects for combat and UI actions                  | ❌ Not implemented |
| FUT-04 | Optional AI opponents for single-player mode             | ❌ Not implemented |
| FUT-05 | Visual effects for fleet movement on the map             | ❌ Not implemented |
| FUT-06 | Game settings (combat balance, universe size, etc.)      | ❌ Not implemented |

---

## Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| MIN_SYSTEM_DISTANCE | 120 px | Minimum distance between star systems |
| MAX_SYSTEM_DISTANCE | 250 px | Maximum distance for visibility and connectivity |
| PLAYER_START_MIN_DISTANCE | 400 px | Minimum distance between player starting systems |
| MAP_EDGE_MARGIN | 100 px | Minimum distance from map edges |
| SYSTEM_COUNT | 15 + (players × 5) | Number of star systems based on player count |
| PRODUCTION_RATE | 1–5 | Random production rate per turn for neutral systems |
| HOME_PRODUCTION_RATE | 3 | Production rate for player home systems |
| INITIAL_FIGHTERS_NEUTRAL | 5–20 | Random starting fighters for neutral systems |
| INITIAL_FIGHTERS_HOME | 30 | Starting fighters for player home systems |
| TRAVEL_SPEED | 150 px/turn | Fleet movement speed |
| DEFENDER_BONUS | 1.5× | Combat effectiveness multiplier for defenders |
| HIT_CHANCE | 30% | Base chance to destroy one enemy fighter per round |
| MAX_COMBAT_ROUNDS | 100 | Safety limit for combat resolution |

---

## Notes

- Requirements derived from German specification: `Spezifikation.md`
- **These requirements take precedence over the original specification.**
- Implementation language: GDScript (Godot 4.6)
- All core requirements from the original specification are complete.
- ~~Strikethrough requirements~~ are no longer valid (applies only to completed requirements).
- If a completed requirement needs to be changed, the old requirement shall be struck through and a new requirement shall be created.
