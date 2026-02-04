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

# Production rates (batch delivery)
const FIGHTER_PRODUCTION_RATE: float = 0.5  # Batch every 2 turns (6 turns with maintenance)
const BOMBER_PRODUCTION_RATE: float = 0.5  # Batch every 2 turns (6 turns with maintenance)

# Battery constants
const MAX_BATTERIES: int = 5
const BATTERY_VS_FIGHTER: float = 1.0  # Full effectiveness vs fighters
const BATTERY_VS_BOMBER: float = 0.5  # Reduced effectiveness vs bombers
const BATTERY_DAMAGE_PER_ROUND: float = 2.0  # Damage dealt per battery per round
const BATTERY_DECAY_PER_TURN: int = 1  # Battery points lost per turn without maintenance
# Note: Battery build time now scales with level (1 turn for 1st, 2 for 2nd, etc.)
const MAINTENANCE_PRODUCTION_MULTIPLIER: float = 1.0 / 3.0  # Production rate when maintaining batteries (1/3)

# Production rate limits
const MIN_PRODUCTION_RATE: int = 1
const MAX_PRODUCTION_RATE: int = 8

# Conquest penalty
const CONQUEST_PRODUCTION_LOSS: int = 1


## Get the travel speed for a fleet based on composition
static func get_fleet_speed(fighter_count: int, bomber_count: int) -> float:
	if bomber_count > 0:
		return BOMBER_SPEED
	return FIGHTER_SPEED
