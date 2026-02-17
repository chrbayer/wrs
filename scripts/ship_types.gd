class_name ShipTypes
extends RefCounted

## Ship type constants for Weltraumschlacht

enum Type { FIGHTER, BOMBER }

# Movement speeds (pixels per turn)
const FIGHTER_SPEED: float = 150.0
const BOMBER_SPEED: float = 75.0  # Half of fighter speed

# Combat multipliers
const FIGHTER_ATTACK: float = 1.0
const BOMBER_ATTACK: float = 1.5  # 3/2 attack power
const FIGHTER_DEFENSE: float = 1.0
const BOMBER_DEFENSE: float = 0.67  # 2/3 defense

# Production rates
const BOMBER_PRODUCTION_MULTIPLIER: float = 0.5  # Bombers produce at half rate (FUT-07)

# Battery constants
const MAX_BATTERIES: int = 5
const BATTERY_VS_FIGHTER: float = 1.0  # Full effectiveness vs fighters
const BATTERY_VS_BOMBER: float = 0.5  # Reduced effectiveness vs bombers
const BATTERY_DAMAGE_PER_ROUND: float = 3.0  # Damage dealt per battery per round
# Note: Battery build time now scales with level (1 turn for 1st, 2 for 2nd, etc.)

# Production rate limits
const MIN_PRODUCTION_RATE: int = 1
const MAX_PRODUCTION_RATE: int = 8

# Fighter morale (long travel penalty)
const FIGHTER_MORALE_THRESHOLD: int = 2  # Travel turns without penalty
const FIGHTER_MORALE_PENALTY: float = 0.2  # Attack reduction per turn beyond threshold
const FIGHTER_MORALE_MIN: float = 0.5  # Minimum morale (attack power floor)

# Conquest penalty
const CONQUEST_PRODUCTION_LOSS: int = 1

# Fleet size limit — fleets exceeding this are split into waves for combat
const MAX_FLEET_SIZE: int = 40

# Rebellion mechanic
const REBELLION_DOMINANCE_FACTOR: float = 1.3
const REBELLION_DOMINANCE_WEIGHT_SYSTEMS: float = 4.0
const REBELLION_DOMINANCE_WEIGHT_COMBAT: float = 0.1
const REBELLION_DOMINANCE_WEIGHT_PRODUCTION: float = 0.5
const REBELLION_CHANCE_PER_DOMINANCE: float = 0.3
const REBELLION_STRENGTH_FACTOR: int = 3

# Shield line constants (FUT-19)
const SHIELD_MIN_BATTERIES: int = 2
const SHIELD_DAMAGE_FACTOR: float = 0.04
const SHIELD_BLOCKADE_THRESHOLD: float = 2.5
const SHIELD_BOMBER_RESISTANCE: float = 0.5
const SHIELD_ACTIVATE_TIME: int = 2
const MAX_SHIELD_LINES_PER_SYSTEM: int = 2
const MAX_SHIELD_STRUCTURES: int = 2
const SHIELD_RING_BONUS_INNER: float = 0.25
const SHIELD_RING_BONUS_RING: float = 0.12
const SHIELD_BATTERY_SUPPORT_FACTOR: float = 0.5  # Neighbor battery contribution scaled by density

# Space station constants (FUT-20)
const STATION_BUILD_COST: int = 24       # Total FÄ to build station
const STATION_BUILD_PER_ROUND: int = 8   # FÄ consumed per build round
const STATION_BUILD_ROUNDS: int = 3      # Rounds at full supply
const MAX_STATIONS_PER_PLAYER: int = 3   # Max stations (including under construction)
const STATION_MAX_BATTERIES: int = 2     # Max batteries per station
const STATION_BATTERY_PER_ROUND: int = 4 # FÄ consumed per battery build round
const STATION_PASSIVE_SCAN_RANGE: float = 200.0   # Star passive scan range for detecting stations (px)
const STATION_FLEET_SCAN_MAX: float = 60.0       # Max fleet scan range (px)
const STATION_FLEET_SCAN_THRESHOLD: int = 5      # Fleets <= this have no scan
const STATION_FLEET_SCAN_PER_SHIP: float = 3.0   # Scan range per ship above threshold
const STATION_PARTIAL_SCAN_MULTIPLIER: float = 0.5  # Under-construction scan range factor
const STATION_PARTIAL_SCAN_MIN_PROGRESS: int = 2    # Min build progress for partial scanning
const STATION_SIGNATURE_PER_SHIP: float = 10.0      # Weapon signature range per garrisoned ship (px)
const STATION_BUILD_SIGNATURE: float = 30.0         # Detection range for stations under construction (px)


## Get the travel speed for a fleet based on composition
static func get_fleet_speed(fighter_count: int, bomber_count: int) -> float:
	if bomber_count > 0:
		return BOMBER_SPEED
	return FIGHTER_SPEED
