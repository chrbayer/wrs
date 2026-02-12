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
| ~~S-02~~ | ~~Each neutral star system shall start with a random number of defending fighters~~  | ~~Done~~ |
| S-02a | Neutral systems start with random fighters scaled by production rate (rate×2 to rate×5) | ✅ Done |
| ~~S-03~~ | ~~Player starting systems shall have a guaranteed minimum distance between them~~ | ~~Done~~ |
| S-03a | Player starting systems shall be placed to maximize distance between them (greedy selection) | ✅ Done |
| S-04 | All star systems except player starting systems shall be neutral at game start   | ✅ Done |
| S-04a | Starting fighters are distributed from a fixed pool (`FIGHTERS_PER_PLAYER` × player count), inversely proportional to neutral neighbor count (compensation: fewer neighbors → more fighters, clamped to `MIN_START_FIGHTERS`–`MAX_START_FIGHTERS`) | ✅ Done |
| ~~S-05~~ | ~~Conquered star systems shall produce fighters each turn based on production rate~~ | ~~Done~~ |
| S-05a | Owned star systems shall produce ships based on production rate and selected production mode | ✅ Done |
| S-06 | Each star system shall display its fighter count to its owner                    | ✅ Done |
| S-07 | Star systems shall display "?" for fighter counts to non-owners (fog of war)     | ✅ Done |
| ~~S-08~~ | ~~Star systems shall only be visible if within range of an owned system~~    | ~~Done~~ |
| S-08a | Previously seen systems remain visible (grayed out) with last known info when out of range | ✅ Done |
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
| F-03a | Mixed fleet speed shall be determined by the slowest ship type (`BOMBER_SPEED`) | ✅ Done |
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
| ~~ST-04~~ | ~~Fighters shall be produced at `FIGHTER_PRODUCTION_RATE` per production point per turn~~ | ~~Done~~ |
| ~~ST-04a~~ | ~~Fighters are delivered every 1/`FIGHTER_PRODUCTION_RATE` turns (batch size: production_rate/`FIGHTER_PRODUCTION_RATE`)~~ | ~~Done~~ |
| ST-04b | Fighters are produced at `production_rate` per turn (immediate delivery) | ✅ Done |
| ST-05 | Bombers shall have reduced speed (`BOMBER_SPEED`)                       | ✅ Done |
| ST-06 | Bombers shall have increased attack power (`BOMBER_ATTACK`)             | ✅ Done |
| ST-07 | Bombers shall have reduced defense power (`BOMBER_DEFENSE`)             | ✅ Done |
| ~~ST-08~~ | ~~Bombers shall be produced at `BOMBER_PRODUCTION_RATE` per production point per turn~~ | ~~Done~~ |
| ~~ST-08a~~ | ~~Bombers are delivered every 1/`BOMBER_PRODUCTION_RATE` turns (batch size: production_rate, half overall rate)~~ | ~~Done~~ |
| ST-08b | Bombers are delivered in full batches (`production_rate`) every 2 turns | ✅ Done |
| ST-09 | Bombers participating in attacks shall cause production damage to the target system | ✅ Done |
| ST-10 | Production damage from bombers shall scale with attacker/defender ratio (max 3) | ✅ Done |
| ST-11 | Fighter morale decreases on long travel (>`FIGHTER_MORALE_THRESHOLD` turns), reducing attack power by `FIGHTER_MORALE_PENALTY` per turn (min `FIGHTER_MORALE_MIN`) | ✅ Done |
| ST-12 | Bomber morale is unaffected by travel distance | ✅ Done |

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
| ~~DB-08~~ | ~~Batteries require continuous maintenance to remain operational~~          | ~~Removed~~ |
| ~~DB-09~~ | ~~Maintaining batteries blocks all other production~~               | ~~Removed~~ |
| ~~DB-09a~~ | ~~Maintaining batteries reduces production by `MAINTENANCE_PRODUCTION_MULTIPLIER`~~ | ~~Removed~~ |
| ~~DB-09b~~ | ~~Maintaining batteries has no production cost (toggle only prevents decay)~~ | ~~Removed~~ |
| ~~DB-10~~ | ~~Batteries decay by `BATTERY_DECAY_PER_TURN` per turn when not building or maintaining~~ | ~~Removed~~ |
| ~~DB-11~~ | ~~Building one battery requires `BATTERY_BUILD_TURNS` turns~~       | ~~Done~~ |
| DB-11a | Battery build time scales with target level (like production upgrade) | ✅ Done |
| DB-12 | On conquest, batteries are reduced to 50% (rounded down) | ✅ Done |

---

## Production System

| ID   | Requirement                                                              | Status |
|------|--------------------------------------------------------------------------|--------|
| PR-01 | Each owned system shall have a selectable production mode               | ✅ Done |
| ~~PR-02~~ | ~~Production modes shall be: Fighters, Bombers, Upgrade, Build Battery, Maintain Batteries~~ | ~~Done~~ |
| PR-02a | Production modes shall be: Fighters, Bombers, Upgrade, Build Battery | ✅ Done |
| ~~PR-03~~ | ~~Fighter production mode shall produce fighters at full rate~~     | ~~Done~~ |
| ~~PR-03a~~ | ~~Fighter production uses batch delivery per ST-04a~~ | ~~Done~~ |
| PR-03b | Fighter production delivers `production_rate` fighters per turn | ✅ Done |
| ~~PR-04~~ | ~~Bomber production mode shall produce bombers at `BOMBER_PRODUCTION_RATE`~~ | ~~Done~~ |
| ~~PR-04a~~ | ~~Bomber production uses batch delivery per ST-08a~~ | ~~Done~~ |
| PR-04b | Bomber production delivers `production_rate` bombers every 2 turns (batch, half rate per FUT-07) | ✅ Done |
| PR-05 | Upgrade mode shall gradually increase production rate (slower at higher rates) | ✅ Done |
| PR-06 | Production rate shall have a maximum of `MAX_PRODUCTION_RATE`           | ✅ Done |
| PR-07 | Production rate shall have a minimum of `MIN_PRODUCTION_RATE`           | ✅ Done |
| ~~PR-08~~ | ~~Build Battery mode shall add one battery per turn (max 3)~~       | ~~Done~~ |
| ~~PR-08a~~ | ~~Build Battery mode shall add one battery every `BATTERY_BUILD_TURNS` turns (max `MAX_BATTERIES`)~~ | ~~Done~~ |
| PR-08b | Battery build time scales with target level (1 turn for 1st, 2 for 2nd, etc.), max `MAX_BATTERIES` | ✅ Done |
| ~~PR-09~~ | ~~After building a battery, production mode shall switch to Maintain Batteries~~ | ~~Removed~~ |
| ~~PR-09a~~ | ~~After building a battery, maintenance toggle shall be enabled automatically~~ | ~~Removed~~ |
| ~~PR-13~~ | ~~Battery maintenance is an independent toggle, orthogonal to production mode~~ | ~~Removed~~ |
| PR-10 | Conquering an enemy system shall reduce its production rate by `CONQUEST_PRODUCTION_LOSS` | ✅ Done |
| PR-11 | Conquest penalty shall not apply to neutral systems                     | ✅ Done |
| PR-12 | Production rate reductions shall respect `MIN_PRODUCTION_RATE`          | ✅ Done |
| PR-14 | On conquest, production mode shall reset to Fighters                    | ✅ Done |

---

## Combat

| ID   | Requirement                                                                  | Status |
|------|------------------------------------------------------------------------------|--------|
| C-01 | Defenders shall receive a combat bonus (`DEFENDER_BONUS` effectiveness)      | ✅ Done |
| C-02 | Combat outcome probability shall be based on attacking vs defending fighters | ✅ Done |
| C-03 | The winner of combat shall control the star system                           | ✅ Done |
| C-04 | Surviving fighters shall remain at the system after combat                   | ✅ Done |
| C-05 | Combat reports shall be shown to involved players, one at a time, with the relevant system highlighted | ✅ Done |
| ~~C-06~~ | ~~When multiple fleets arrive simultaneously, they attack in order of size (largest first)~~ | ~~Done~~ |
| C-06a | When multiple fleets arrive simultaneously, they attack in order of summed attack value (`fighters × FIGHTER_ATTACK + bombers × BOMBER_ATTACK`, largest first) | ✅ Done |
| C-07 | Reinforcements shall be processed before any combat occurs                   | ✅ Done |
| C-08 | If both sides are eliminated in combat, the system shall become neutral      | ✅ Done |
| C-09 | Combat shall apply attack/defense multipliers based on ship type            | ✅ Done |
| ~~C-10~~ | ~~Defense batteries shall engage attackers before ship-to-ship combat~~         | ~~Done~~ |
| C-10a | Defense batteries shall engage each enemy fleet (largest summed attack value first) in a pre-combat phase before attack order is determined. Each fleet receives full battery damage. Batteries do not fire again during individual ship-to-ship combat. | ✅ Done |
| C-11 | Combat shall target ships with lower defense first (bombers before fighters) | ✅ Done |
| C-12 | Combat reports shall show bomber participation and losses                    | ✅ Done |
| ~~C-13~~ | ~~Combat reports shall show battery kills~~                                      | ~~Done~~ |
| ~~C-13a~~ | ~~Combat reports shall show battery kills and battery status before/after combat~~ | ~~Done~~ |
| C-13b | Combat reports shall show battery kills by type (F/B) when kills > 0 | ✅ Done |
| C-14 | Combat reports shall show production damage from bomber attacks              | ✅ Done |
| C-15 | Combat reports shall indicate if conquest occurred and the associated penalty | ✅ Done |
| C-15a | Combat reports shall show fighter morale when below 100% | ✅ Done |
| C-16 | Combat shall apply fighter morale penalty to attacker's attack power based on fleet travel time | ✅ Done |
| C-17 | When multiple attackers engage the same system, each engagement shall produce a separate combat report (per-stage reports) | ✅ Done |
| C-18 | Attacker losses in combat reports shall be the total ship count (battery kills + combat losses combined) | ✅ Done |
| C-19 | Combat reports shall omit zero fighter/bomber counts (no "0 F" or "0 B") | ✅ Done |
| C-20 | Merged fleets exceeding `MAX_FLEET_SIZE` shall be split into waves. Each wave faces batteries independently and fights as a separate combat stage. Waves from the same owner reinforce if a prior wave already holds the system. | ✅ Done |

---

## Rebellion

| ID   | Requirement                                                              | Status |
|------|--------------------------------------------------------------------------|--------|
| RB-01 | Systems of dominant players may rebel (dominance = owns > avg × `REBELLION_DOMINANCE_FACTOR`) | ✅ Done |
| RB-02 | Rebellion chance per system = (own_systems - average) × `REBELLION_CHANCE_PER_EXCESS` | ✅ Done |
| RB-03 | Rebels spawn `production_rate` × `REBELLION_STRENGTH_FACTOR` neutral fighters | ✅ Done |
| RB-04 | Rebels attack garrison using standard combat (garrison gets `DEFENDER_BONUS`) | ✅ Done |
| RB-05 | Home systems are immune to rebellion | ✅ Done |
| RB-06 | Batteries reduce rebellion chance proportionally (1/MAX per level), only max batteries = immune | ✅ Done |
| RB-07 | Rebel-won systems become neutral with remaining rebel fighters | ✅ Done |
| RB-08 | Rebellion reports shown to system owner with dedicated format | ✅ Done |
| RB-09 | Rebellions are processed after production, before fleet arrival | ✅ Done |
| RB-10 | A player's last remaining system is immune to rebellion | ✅ Done |

---

## Players & Turns

| ID   | Requirement                                                           | Status |
|------|-----------------------------------------------------------------------|--------|
| ~~P-01~~ | ~~The game shall support 2 to 4 human players~~                   | ~~Done~~ |
| P-01a | The game shall support 2-4 players, any combination of human and AI | ✅ Done |
| ~~P-02~~ | ~~There shall be no computer-controlled players~~                 | ~~Done~~ |
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
| V-04 | Human players shall see all pending combat reports before the victory screen is shown | ✅ Done |

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
| ~~UI-08~~ | ~~A "Send All" button shall allow sending all fighters at once~~ | ~~Done~~ |
| ~~UI-08a~~ | ~~A "Send Max" button shall allow sending all available ships at once~~  | ~~Done~~ |
| UI-08b | A "Send Max" button shall send up to `MAX_FLEET_SIZE` ships (preserving fighter/bomber ratio) | ✅ Done |
| UI-09 | The current player's owned star count shall be visible             | ✅ Done |
| UI-10 | The current player's total production rate shall be visible        | ✅ Done |
| UI-11 | The number of fleets in transit shall be visible                   | ✅ Done |
| UI-12 | A setup screen shall allow player count selection before game start | ✅ Done |
| UI-13 | A cancel button shall allow aborting the fleet sending dialog      | ✅ Done |
| ~~UI-14~~ | ~~Hovering over any visible system shows its name, owner, production rate, and travel time from selected system~~ | ~~Done~~ |
| UI-14a | Hovering over systems shows name, owner, production rate; owned systems also show production mode | ✅ Done |
| UI-15 | Send fleet dialog shall be positioned near the source system without obscuring stars or the fleet arrow | ✅ Done |
| UI-16 | Combat report dialog shall be positioned near the relevant system  | ✅ Done |
| UI-17 | During combat report display, only the close button shall be interactive | ✅ Done |
| UI-18 | Send fleet dialog shall have separate sliders for fighters and bombers   | ✅ Done |
| UI-19 | Bomber slider shall only be visible when bombers are available           | ✅ Done |
| ~~UI-20~~ | ~~An action panel shall allow setting production mode for owned systems~~    | ~~Done~~ |
| UI-20a | An action panel shall allow setting production mode for owned systems, opened by double-clicking the system (single click selects only) | ✅ Done |
| UI-21 | Action panel buttons shall be disabled when not applicable (e.g., max batteries reached) | ✅ Done |
| UI-22 | Star labels shall show fighter/bomber counts (e.g., "10/5")              | ✅ Done |
| UI-23 | Star labels shall show battery indicator (e.g., "[2]")                   | ✅ Done |
| ~~UI-24~~ | ~~Non-owners shall see "[?]" for battery presence (not count)~~              | ~~Done~~ |
| UI-24a | Non-owners shall see "[?]" for battery presence; after combat, known battery count is shown as "[(N)]" | ✅ Done |
| UI-25 | Hover info shall show both fighter-only and mixed fleet travel times     | ✅ Done |
| UI-26 | Fleet info shall show total fighters and bombers in transit              | ✅ Done |
| ~~UI-27~~ | ~~System info shall show current production mode and progress~~              | ~~Done~~ |
| UI-27a | System info shall show current production mode with progress as completed/total turns (e.g., "2/5") | ✅ Done |
| UI-28 | Visibility range of owned systems shall be subtly indicated on the map   | ✅ Done |
| UI-29 | ESC key shall close the topmost open dialog (combat report, send fleet, or action panel) | ✅ Done |
| UI-30 | Send fleet dialog shall display fighter morale when below 100% | ✅ Done |
| UI-31 | Setup screen allows per-player Human/AI selection with tactic choice | ✅ Done |
| UI-32 | In all-AI spectator mode, Space key toggles pause/resume with "PAUSED" indicator | ✅ Done |
| UI-33 | Setup screen shall restore previous game's settings (player count, human/AI, tactics) on restart | ✅ Done |

---

## Future Requirements (Not in Original Spec)

| ID     | Requirement                                                                                        | Status            |
|--------|----------------------------------------------------------------------------------------------------|-------------------|
| FUT-01 | Save and load game state                                                                           | ❌ Not implemented |
| FUT-02 | Show fleets in transit to their owner on the map                                                   | ❌ Not implemented |
| FUT-03 | Sound effects for combat and UI actions                                                            | ❌ Not implemented |
| ~~FUT-04~~ | ~~Optional AI opponents for single-player mode~~                                               | ~~Not implemented~~ |
| FUT-04a | AI opponents with selectable tactics (Rush, Fortress, Economy, Bomber, Balanced)                  | ✅ Done |
| FUT-05 | Visual effects for fleet movement on the map                                                       | ❌ Not implemented |
| FUT-06 | Game settings (combat balance, universe size, etc.)                                                | ❌ Not implemented |
| FUT-07 | Second ship type (Bomber): half speed, 2/3 defense strength, 3/2 attack strength, half production rate | ✅ Done |
| FUT-08 | Conquering an enemy system reduces its production rate by 1 (exception: neutral systems)           | ✅ Done |
| FUT-09 | Instead of producing fighters, a system can slowly increase its production rate (max 8)            | ✅ Done |
| ~~FUT-10~~ | ~~Instead of ships or production, build defense batteries: strong vs fighters, weaker vs bombers (max 3 per system). Presence visible to all, strength only to owner~~ | ~~Done~~ |
| FUT-10a | Build defense batteries: strong vs fighters (`BATTERY_VS_FIGHTER`), weaker vs bombers (`BATTERY_VS_BOMBER`), max `MAX_BATTERIES`. Presence visible to all, count only to owner | ✅ Done |
| ~~FUT-11~~ | ~~Maintaining or repairing defense batteries requires skipping ship production and production rate upgrades~~ | ~~Removed~~ |
| ~~FUT-11a~~ | ~~Maintaining batteries reduces production by `MAINTENANCE_PRODUCTION_MULTIPLIER` (independent toggle)~~ | ~~Removed~~ |
| FUT-12 | Bomber attacks cause greater production rate loss on conquest and can reduce production even on failed attacks. Damage scales with attacker/defender strength ratio | ✅ Done |
| FUT-13 | Production rate cannot fall below 1                                                                | ✅ Done |
| FUT-14 | Mixed fleets (fighters + bombers) are allowed. Fleet speed is determined by slowest ship type      | ✅ Done |
| FUT-15 | Battery build time scales with current level (like production upgrade). Maximum increased to 5     | ✅ Done |
| ~~FUT-16~~ | ~~Fog of war memory: previously seen systems stay visible (grayed out) with last known attributes~~    | ~~Done~~ |
| FUT-16a | Fog of war memory: previously seen systems stay visible (grayed out) with last known attributes. Combat intel (ship counts, battery count) is remembered and shown in parentheses on non-owned systems | ✅ Done |
| FUT-17 | Fighter morale malus on long travel: fighters lose `FIGHTER_MORALE_PENALTY` attack power per turn beyond `FIGHTER_MORALE_THRESHOLD` (min `FIGHTER_MORALE_MIN`). Bombers unaffected. | ✅ Done |
| FUT-18 | Rebellion mechanic: systems of dominant players may spontaneously rebel, spawning neutral fighters that attack the garrison. Anti-snowball mechanic. | ✅ Done |
| FUT-19 | Defensive shield lines: Manually activated (`SHIELD_ACTIVATE`, 2 turns, both systems blocked) between two owned systems with 2+ batteries. Max 2 lines/system, max 2 independent structures/player. Attrition (sum-based) + blockade (min-based, threshold 2.5). Closed rings grant production bonus (inner +25%, ring +12%). Bombers: 50% resistance. Permanent. See `FUT-19-20-PLANUNG.md` | ❌ Not implemented |
| FUT-20 | Space stations: Built by sacrificing ships (24 FÄ, 8/round, 3 rounds) at designated build sites within MAX_SYSTEM_DISTANCE of any star or own station (chain building). No production — batteries (max 2) also require material delivery (4 FÄ/round). Invisible until combat ships garrisoned (weapon signatures). Detection: passive scan by own stars/stations (full visibility range, always succeeds), fleet scan (size-dependent: `min(60, max(0, (fleet_size-5)*3))` px, fleets ≤5 ships have no scan). Attackable like stars with defender bonus, destroyed on conquest. Max 3/player. Primarily offensive — enable attacks behind enemy shield lines. Requires FUT-19. See `FUT-19-20-PLANUNG.md` | ❌ Not implemented |

---

## Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| MIN_SYSTEM_DISTANCE | 120 px | Minimum distance between star systems |
| MAX_SYSTEM_DISTANCE | 250 px | Maximum distance for visibility and connectivity |
| ~~PLAYER_START_MIN_DISTANCE~~ | ~~400 px~~ | ~~Not enforced as minimum; distance is maximized via greedy selection~~ |
| MAP_EDGE_MARGIN | 100 px | Minimum distance from map edges |
| SYSTEM_COUNT | 15 + (players × 5) | Number of star systems based on player count |
| PRODUCTION_RATE | 1–5 | Random production rate per turn for neutral systems |
| HOME_PRODUCTION_RATE | 3 | Production rate for player home systems |
| INITIAL_FIGHTERS_NEUTRAL | rate×2 to rate×5 | Random starting fighters for neutral systems (scaled by production rate) |
| ~~INITIAL_FIGHTERS_HOME~~ | ~~30~~ | ~~Fixed starting fighters for player home systems~~ |
| FIGHTERS_PER_PLAYER | 30 | Starting fighter pool per player (total = value × player_count) |
| MIN_START_FIGHTERS | 15 | Minimum starting fighters per player |
| MAX_START_FIGHTERS | 45 | Maximum starting fighters per player |
| FIGHTER_SPEED | 150 px/turn | Fighter movement speed |
| BOMBER_SPEED | 75 px/turn | Bomber movement speed (half of fighter) |
| DEFENDER_BONUS | 1.5× | Combat effectiveness multiplier for defenders |
| HIT_CHANCE | 30% | Base chance to destroy one enemy fighter per round |
| MAX_COMBAT_ROUNDS | 100 | Safety limit for combat resolution |
| FIGHTER_ATTACK | 1.0× | Fighter attack power multiplier |
| BOMBER_ATTACK | 1.5× | Bomber attack power multiplier |
| FIGHTER_DEFENSE | 1.0× | Fighter defense power multiplier |
| BOMBER_DEFENSE | 0.67× | Bomber defense power multiplier |
| ~~FIGHTER_PRODUCTION_RATE~~ | ~~0.5~~ | ~~Removed: fighters now deliver instantly each turn~~ |
| BOMBER_PRODUCTION_MULTIPLIER | 0.5 | Bomber production rate multiplier (half of fighter rate) |
| MAX_BATTERIES | 5 | Maximum defense batteries per system |
| BATTERY_VS_FIGHTER | 1.0× | Battery effectiveness against fighters |
| BATTERY_VS_BOMBER | 0.5× | Battery effectiveness against bombers |
| BATTERY_DAMAGE_PER_ROUND | 3.0 | Damage dealt per battery per combat round |
| ~~BATTERY_BUILD_TURNS~~ | ~~2~~ | ~~Turns required to build one battery~~ (now scales with level) |
| ~~BATTERY_DECAY_PER_TURN~~ | ~~1~~ | ~~Removed: batteries no longer decay~~ |
| ~~MAINTENANCE_PRODUCTION_MULTIPLIER~~ | ~~1/2~~ | ~~Removed: maintenance removed entirely~~ |
| MIN_PRODUCTION_RATE | 1 | Minimum production rate |
| MAX_PRODUCTION_RATE | 8 | Maximum production rate |
| CONQUEST_PRODUCTION_LOSS | 1 | Production rate penalty on conquest |
| FIGHTER_MORALE_THRESHOLD | 2 turns | Travel time without morale penalty |
| FIGHTER_MORALE_PENALTY | 0.2 (20%) | Attack power reduction per turn beyond threshold |
| FIGHTER_MORALE_MIN | 0.5 (50%) | Minimum fighter morale (attack power floor) |
| MAX_FLEET_SIZE | 40 | Maximum ships per combat wave (merged fleets exceeding this are split) |
| REBELLION_DOMINANCE_FACTOR | 1.3 | Rebellion triggers when player owns > avg × this factor |
| REBELLION_CHANCE_PER_EXCESS | 0.05 (5%) | Rebellion chance per unprotected system, per excess system over average |
| REBELLION_STRENGTH_FACTOR | 3 | Rebels = production_rate × this factor |

---

## Notes

- Requirements derived from German specification: `Spezifikation.md`
- **These requirements take precedence over the original specification.**
- Implementation language: GDScript (Godot 4.6)
- All core requirements from the original specification are complete.
- ~~Strikethrough requirements~~ are no longer valid (applies only to completed requirements).
- If a completed requirement needs to be changed, the old requirement shall be struck through and a new requirement shall be created.
- **Update 2026-02:** FUT-07 through FUT-17 implemented, adding bombers, defense batteries, production modes, conquest mechanics, scaled battery building, fog of war memory, and fighter morale.
- **Update 2026-02:** FUT-04a implemented, adding AI opponents with 5 selectable tactics. P-01a replaces P-01 to allow any human/AI mix.
- **Update 2026-02:** AI phases are now purely state-based (no turn numbers). Early: only neutrals visible (all tactics expand identically). Mid: neutrals + enemies (tactic-specific, but all expand to neutrals). Late: only enemies (full attack mode).
- **Update 2026-02:** Combat reports reworked: per-stage reports (C-17), attacker losses include battery kills (C-18), battery kills shown by F/B type (C-13b), zero counts omitted (C-19). Victory screen deferred until all reports shown (V-04).
- **Update 2026-02:** Fleet wave splitting (C-20): merged fleets exceeding MAX_FLEET_SIZE (40) are split into waves, each facing batteries independently. Counters the "deathball" strategy by making batteries more effective against large forces.
- **Update 2026-02:** Rebellion mechanic (FUT-18): asymmetric anti-snowball mechanic. Dominant players' unprotected systems may rebel, spawning neutral fighters. Home systems immune. Batteries reduce rebellion chance proportionally (20% per level), only max batteries (5) = fully immune.
