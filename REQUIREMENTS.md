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
| ~~S-05~~ | ~~Conquered star systems shall produce fighters each turn based on production rate~~ | ~~Done~~ |
| S-05a | Owned star systems shall produce ships based on production rate and selected production mode | ✅ Done |
| S-06 | Each star system shall display its fighter count to its owner                    | ✅ Done |
| S-07 | Star systems shall display "?" for fighter counts to non-owners (fog of war)     | ✅ Done |
| S-08 | Star systems shall only be visible if within range of an owned system            | ✅ Done |
| S-09 | Star system size shall indicate its production rate (larger = higher production) | ✅ Done |
| S-10 | Each star system shall display its name below the star                           | ✅ Done |

---

## Ships & Fleets

| ID   | Requirement                                                              | Status |
|------|--------------------------------------------------------------------------|--------|
| ~~F-01~~ | ~~There shall be only one ship type: Fighters~~                      | ~~Done~~ |
| F-01a | There shall be two ship types: Fighters and Bombers                     | ✅ Done |
| ~~F-02~~ | ~~Players shall be able to send groups of fighters from one system to another~~ | ~~Done~~ |
| ~~F-02a~~ | ~~Players shall be able to send mixed fleets containing both fighters and bombers~~ | ~~Done~~ |
| F-02b | Players shall be able to send fleets (fighters, bombers, or mixed) from one system to another | ✅ Done |
| F-03 | Fleet travel time shall depend on the distance between systems           | ✅ Done |
| F-03a | Mixed fleet speed shall be determined by the slowest ship type (bombers = half speed) | ✅ Done |
| F-04 | Fleets in transit shall not be visible to any player                     | ✅ Done |
| F-05 | Fleets in transit cannot be redirected until they arrive                 | ✅ Done |
| F-06 | Arriving fleets shall reinforce friendly systems or attack enemy/neutral | ✅ Done |
| F-07 | Fleets shall require a minimum of 1 turn travel time                 | ✅ Done |

---

## Ship Types

| ID   | Requirement                                                              | Status |
|------|--------------------------------------------------------------------------|--------|
| ST-01 | Fighters shall have standard speed (`FIGHTER_SPEED`)                    | ✅ Done |
| ST-02 | Fighters shall have standard attack power (`FIGHTER_ATTACK`)            | ✅ Done |
| ST-03 | Fighters shall have standard defense power (`FIGHTER_DEFENSE`)          | ✅ Done |
| ST-04 | Fighters shall be produced at `FIGHTER_PRODUCTION_RATE` per production point per turn | ✅ Done |
| ST-05 | Bombers shall have reduced speed (`BOMBER_SPEED`)                       | ✅ Done |
| ST-06 | Bombers shall have increased attack power (`BOMBER_ATTACK`)             | ✅ Done |
| ST-07 | Bombers shall have reduced defense power (`BOMBER_DEFENSE`)             | ✅ Done |
| ST-08 | Bombers shall be produced at `BOMBER_PRODUCTION_RATE` per production point per turn | ✅ Done |
| ST-09 | Bombers participating in attacks shall cause production damage to the target system | ✅ Done |
| ST-10 | Production damage from bombers shall scale with attacker/defender ratio (max 3) | ✅ Done |

---

## Defense Batteries

| ID   | Requirement                                                              | Status |
|------|--------------------------------------------------------------------------|--------|
| DB-01 | Star systems may have up to `MAX_BATTERIES` defense batteries           | ✅ Done |
| DB-02 | Batteries shall attack before ship-to-ship combat begins                | ✅ Done |
| DB-03 | Batteries shall be fully effective against fighters (`BATTERY_VS_FIGHTER`) | ✅ Done |
| DB-04 | Batteries shall be less effective against bombers (`BATTERY_VS_BOMBER`) | ✅ Done |
| DB-05 | Batteries shall prioritize targeting fighters over bombers              | ✅ Done |
| DB-06 | Battery presence shall be visible to all players                        | ✅ Done |
| DB-07 | Battery count shall only be visible to the system owner                 | ✅ Done |
| DB-08 | Batteries require continuous maintenance to remain operational          | ✅ Done |
| ~~DB-09~~ | ~~Maintaining batteries blocks all other production~~               | ~~Done~~ |
| DB-09a | Maintaining batteries reduces production by `MAINTENANCE_PRODUCTION_MULTIPLIER` | ✅ Done |
| DB-10 | Batteries decay by `BATTERY_DECAY_PER_TURN` per turn when not building or maintaining | ✅ Done |
| DB-11 | Building one battery requires `BATTERY_BUILD_TURNS` turns               | ✅ Done |

---

## Production System

| ID   | Requirement                                                              | Status |
|------|--------------------------------------------------------------------------|--------|
| PR-01 | Each owned system shall have a selectable production mode               | ✅ Done |
| ~~PR-02~~ | ~~Production modes shall be: Fighters, Bombers, Upgrade, Build Battery, Maintain Batteries~~ | ~~Done~~ |
| PR-02a | Production modes shall be: Fighters, Bombers, Upgrade, Build Battery | ✅ Done |
| PR-03 | Fighter production mode shall produce fighters at full rate             | ✅ Done |
| PR-04 | Bomber production mode shall produce bombers at half rate               | ✅ Done |
| PR-05 | Upgrade mode shall gradually increase production rate (slower at higher rates) | ✅ Done |
| PR-06 | Production rate shall have a maximum of `MAX_PRODUCTION_RATE`           | ✅ Done |
| PR-07 | Production rate shall have a minimum of `MIN_PRODUCTION_RATE`           | ✅ Done |
| ~~PR-08~~ | ~~Build Battery mode shall add one battery per turn (max 3)~~       | ~~Done~~ |
| PR-08a | Build Battery mode shall add one battery every `BATTERY_BUILD_TURNS` turns (max `MAX_BATTERIES`) | ✅ Done |
| ~~PR-09~~ | ~~After building a battery, production mode shall switch to Maintain Batteries~~ | ~~Done~~ |
| PR-09a | After building a battery, maintenance toggle shall be enabled automatically | ✅ Done |
| PR-13 | Battery maintenance is an independent toggle, orthogonal to production mode | ✅ Done |
| PR-10 | Conquering an enemy system shall reduce its production rate by `CONQUEST_PRODUCTION_LOSS` | ✅ Done |
| PR-11 | Conquest penalty shall not apply to neutral systems                     | ✅ Done |
| PR-12 | Production rate reductions shall respect `MIN_PRODUCTION_RATE`          | ✅ Done |

---

## Combat

| ID   | Requirement                                                                  | Status |
|------|------------------------------------------------------------------------------|--------|
| C-01 | Defenders shall receive a combat bonus (`DEFENDER_BONUS` effectiveness)      | ✅ Done |
| C-02 | Combat outcome probability shall be based on attacking vs defending fighters | ✅ Done |
| C-03 | The winner of combat shall control the star system                           | ✅ Done |
| C-04 | Surviving fighters shall remain at the system after combat                   | ✅ Done |
| C-05 | Combat reports shall be shown to involved players, one at a time, with the relevant system highlighted | ✅ Done |
| C-06 | When multiple fleets arrive simultaneously, they attack in order of size (largest first) | ✅ Done |
| C-07 | Reinforcements shall be processed before any combat occurs                   | ✅ Done |
| C-08 | If both sides are eliminated in combat, the system shall become neutral      | ✅ Done |
| C-09 | Combat shall apply attack/defense multipliers based on ship type            | ✅ Done |
| C-10 | Defense batteries shall engage attackers before ship-to-ship combat         | ✅ Done |
| C-11 | Combat shall target ships with lower defense first (bombers before fighters) | ✅ Done |
| C-12 | Combat reports shall show bomber participation and losses                    | ✅ Done |
| C-13 | Combat reports shall show battery kills                                      | ✅ Done |
| C-14 | Combat reports shall show production damage from bomber attacks              | ✅ Done |
| C-15 | Combat reports shall indicate if conquest occurred and the associated penalty | ✅ Done |

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
| UI-14 | Hovering over any visible system shows its name, owner, production rate, and travel time from selected system | ✅ Done |
| UI-15 | Send fleet dialog shall be positioned near the source system without obscuring stars or the fleet arrow | ✅ Done |
| UI-16 | Combat report dialog shall be positioned near the relevant system  | ✅ Done |
| UI-17 | During combat report display, only the close button shall be interactive | ✅ Done |
| UI-18 | Send fleet dialog shall have separate sliders for fighters and bombers   | ✅ Done |
| UI-19 | Bomber slider shall only be visible when bombers are available           | ✅ Done |
| UI-20 | An action panel shall allow setting production mode for owned systems    | ✅ Done |
| UI-21 | Action panel buttons shall be disabled when not applicable (e.g., max batteries reached) | ✅ Done |
| UI-22 | Star labels shall show fighter/bomber counts (e.g., "10/5")              | ✅ Done |
| UI-23 | Star labels shall show battery indicator (e.g., "[2]")                   | ✅ Done |
| UI-24 | Non-owners shall see "[?]" for battery presence (not count)              | ✅ Done |
| UI-25 | Hover info shall show both fighter-only and mixed fleet travel times     | ✅ Done |
| UI-26 | Fleet info shall show total fighters and bombers in transit              | ✅ Done |
| UI-27 | System info shall show current production mode and progress              | ✅ Done |

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
| FUT-07 | Second ship type (Bomber): half speed, 2/3 defense strength, 3/2 attack strength, half production rate | ✅ Done |
| FUT-08 | Conquering an enemy system reduces its production rate by 1 (exception: neutral systems)           | ✅ Done |
| FUT-09 | Instead of producing fighters, a system can slowly increase its production rate (max 8)            | ✅ Done |
| FUT-10 | Instead of ships or production, build defense batteries: strong vs fighters, weaker vs bombers (max 3 per system). Presence visible to all, strength only to owner | ✅ Done |
| FUT-11 | Maintaining or repairing defense batteries requires skipping ship production and production rate upgrades | ✅ Done |
| FUT-12 | Bomber attacks cause greater production rate loss on conquest and can reduce production even on failed attacks. Damage scales with attacker/defender strength ratio | ✅ Done |
| FUT-13 | Production rate cannot fall below 1                                                                | ✅ Done |
| FUT-14 | Mixed fleets (fighters + bombers) are allowed. Fleet speed is determined by slowest ship type      | ✅ Done |

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
| FIGHTER_SPEED | 150 px/turn | Fighter movement speed |
| BOMBER_SPEED | 75 px/turn | Bomber movement speed (half of fighter) |
| DEFENDER_BONUS | 1.5× | Combat effectiveness multiplier for defenders |
| HIT_CHANCE | 30% | Base chance to destroy one enemy fighter per round |
| MAX_COMBAT_ROUNDS | 100 | Safety limit for combat resolution |
| FIGHTER_ATTACK | 1.0× | Fighter attack power multiplier |
| BOMBER_ATTACK | 1.5× | Bomber attack power multiplier |
| FIGHTER_DEFENSE | 1.0× | Fighter defense power multiplier |
| BOMBER_DEFENSE | 0.67× | Bomber defense power multiplier |
| FIGHTER_PRODUCTION_RATE | 1.0 | Fighters produced per production point per turn |
| BOMBER_PRODUCTION_RATE | 0.5 | Bombers produced per production point per turn |
| MAX_BATTERIES | 3 | Maximum defense batteries per system |
| BATTERY_VS_FIGHTER | 1.0× | Battery effectiveness against fighters |
| BATTERY_VS_BOMBER | 0.5× | Battery effectiveness against bombers |
| BATTERY_DAMAGE | 2.0 | Damage dealt per battery per combat round |
| BATTERY_BUILD_TURNS | 2 | Turns required to build one battery |
| BATTERY_DECAY_PER_TURN | 1 | Battery points lost per turn without maintenance |
| MAINTENANCE_PRODUCTION_MULTIPLIER | 0.33 | Production rate multiplier when maintaining batteries |
| MIN_PRODUCTION_RATE | 1 | Minimum production rate |
| MAX_PRODUCTION_RATE | 8 | Maximum production rate |
| CONQUEST_PRODUCTION_LOSS | 1 | Production rate penalty on conquest |

---

## Notes

- Requirements derived from German specification: `Spezifikation.md`
- **These requirements take precedence over the original specification.**
- Implementation language: GDScript (Godot 4.6)
- All core requirements from the original specification are complete.
- ~~Strikethrough requirements~~ are no longer valid (applies only to completed requirements).
- If a completed requirement needs to be changed, the old requirement shall be struck through and a new requirement shall be created.
- **Update 2026-02:** FUT-07 through FUT-14 implemented, adding bombers, defense batteries, production modes, and conquest mechanics.
