class_name Fleet
extends RefCounted

## Represents a fleet traveling between star systems

var owner_id: int
var fighter_count: int
var bomber_count: int
var source_system_id: int
var target_system_id: int
var departure_turn: int
var arrival_turn: int

## Legacy constant for backwards compatibility
const TRAVEL_SPEED: float = 150.0


func _init(owner: int, fighters: int, source: int, target: int,
		   current_turn: int, distance: float, bombers: int = 0) -> void:
	owner_id = owner
	fighter_count = fighters
	bomber_count = bombers
	source_system_id = source
	target_system_id = target
	departure_turn = current_turn

	# Calculate arrival turn based on distance and slowest ship
	var speed = get_fleet_speed()
	var travel_time = ceili(distance / speed)
	arrival_turn = current_turn + max(1, travel_time)


## Get the travel speed for this fleet (slowest ship determines speed)
func get_fleet_speed() -> float:
	return ShipTypes.get_fleet_speed(fighter_count, bomber_count)


## Calculate travel time for a given distance
func get_travel_time(distance: float) -> int:
	var speed = get_fleet_speed()
	return max(1, ceili(distance / speed))


## Static method to calculate travel time for a potential fleet
static func calculate_travel_time(distance: float, fighters: int, bombers: int) -> int:
	var speed = ShipTypes.get_fleet_speed(fighters, bombers)
	return max(1, ceili(distance / speed))


func get_turns_remaining(current_turn: int) -> int:
	return max(0, arrival_turn - current_turn)


func has_arrived(current_turn: int) -> bool:
	return current_turn >= arrival_turn


func get_total_ships() -> int:
	return fighter_count + bomber_count


func has_bombers() -> bool:
	return bomber_count > 0


func get_info_string(current_turn: int) -> String:
	var turns = get_turns_remaining(current_turn)
	if bomber_count > 0:
		return "%d fighters, %d bombers, arrives in %d turns" % [fighter_count, bomber_count, turns]
	return "%d fighters, arrives in %d turns" % [fighter_count, turns]
