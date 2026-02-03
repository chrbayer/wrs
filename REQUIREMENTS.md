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
| S-09 | Star system size shall indicate its production rate (larger = higher production) | ✅ Done |
| S-10 | Each star system shall display its name below the star                           | ✅ Done |

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
| F-07 | Fleets shall require a minimum of 1 turn travel time                 | ✅ Done |

---

## Combat

| ID   | Requirement                                                                  | Status |
|------|------------------------------------------------------------------------------|--------|
| C-01 | Defenders shall receive a combat bonus (1.5x effectiveness)                  | ✅ Done |
| C-02 | Combat outcome probability shall be based on attacking vs defending fighters | ✅ Done |
| C-03 | The winner of combat shall control the star system                           | ✅ Done |
| C-04 | Surviving fighters shall remain at the system after combat                   | ✅ Done |
| C-05 | Combat reports shall be shown to involved players, one at a time, with the relevant system highlighted | ✅ Done |
| C-06 | When multiple fleets arrive simultaneously, they attack in order of size (largest first) | ✅ Done |
| C-07 | Reinforcements shall be processed before any combat occurs                   | ✅ Done |
| C-08 | If both sides are eliminated in combat, the system shall become neutral      | ✅ Done |

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
| UI-03 | The travel time to a target system shall be displayed before sending and visualized by arrow color (cyan=1, green=2, yellow=3, orange=4, red=5+ turns) | ✅ Done |
| UI-04 | The current turn number shall be visible                           | ✅ Done |
| UI-05 | The current player's total ship count shall be visible             | ✅ Done |
| UI-06 | An "End Turn" button shall advance the game                        | ✅ Done |
| UI-07 | A "Play Again" option shall be available after game over           | ✅ Done |
| UI-08 | A "Send All" button shall allow sending all fighters at once       | ✅ Done |
| UI-09 | The current player's owned star count shall be visible             | ✅ Done |
| UI-10 | The current player's total production rate shall be visible        | ✅ Done |
| UI-11 | The number of fleets in transit shall be visible                   | ✅ Done |
| UI-12 | A setup screen shall allow player count selection before game start | ✅ Done |
| UI-13 | A cancel button shall allow aborting the fleet sending dialog      | ✅ Done |
| UI-14 | Hovering over any visible system shows its name, owner, and production rate | ✅ Done |
| UI-15 | Send fleet dialog shall be positioned near the source system without obscuring stars or the fleet arrow | ✅ Done |
| UI-16 | Combat report dialog shall be positioned near the relevant system  | ✅ Done |
| UI-17 | During combat report display, only the close button shall be interactive | ✅ Done |

---

## Future Requirements (Not in Original Spec)

| ID     | Requirement                                                                                        | Status            |
|--------|----------------------------------------------------------------------------------------------------|-------------------|
| FUT-01 | Save and load game state                                                                           | ❌ Not implemented |
| FUT-02 | Show fleets in transit to their owner on the map                                                   | ❌ Not implemented |
| FUT-03 | Sound effects for combat and UI actions                                                            | ❌ Not implemented |
| FUT-04 | Optional AI opponents for single-player mode                                                       | ❌ Not implemented |
| FUT-05 | Visual effects for fleet movement on the map                                                       | ❌ Not implemented |
| FUT-06 | Game settings (combat balance, universe size, etc.)                                                | ❌ Not implemented |
| FUT-07 | Second ship type (Bomber): half speed, 2/3 defense strength, 3/2 attack strength, half production rate | ❌ Not implemented |
| FUT-08 | Conquering an enemy system reduces its production rate by 1 (exception: neutral systems)           | ❌ Not implemented |
| FUT-09 | Instead of producing fighters, a system can slowly increase its production rate (max 8)            | ❌ Not implemented |
| FUT-10 | Instead of ships or production, build defense batteries: strong vs fighters, weaker vs bombers (max 3 per system). Presence visible to all, strength only to owner | ❌ Not implemented |
| FUT-11 | Maintaining or repairing defense batteries requires skipping ship production and production rate upgrades | ❌ Not implemented |
| FUT-12 | Bomber attacks cause greater production rate loss on conquest and can reduce production even on failed attacks. Damage scales with attacker/defender strength ratio | ❌ Not implemented |
| FUT-13 | Production rate cannot fall below 1 | ❌ Not implemented |
| FUT-14 | Mixed fleets (fighters + bombers) are allowed. Fleet speed is determined by slowest ship type | ❌ Not implemented |

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
