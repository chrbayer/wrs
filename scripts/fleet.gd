class_name Fleet
extends RefCounted

## Represents a fleet traveling between star systems

var owner_id: int
var fighter_count: int
var source_system_id: int
var target_system_id: int
var departure_turn: int
var arrival_turn: int

## Travel speed: units per turn
const TRAVEL_SPEED: float = 150.0


func _init(owner: int, fighters: int, source: int, target: int,
		   current_turn: int, distance: float) -> void:
	owner_id = owner
	fighter_count = fighters
	source_system_id = source
	target_system_id = target
	departure_turn = current_turn

	# Calculate arrival turn based on distance
	var travel_time = ceili(distance / TRAVEL_SPEED)
	arrival_turn = current_turn + max(1, travel_time)


func get_turns_remaining(current_turn: int) -> int:
	return max(0, arrival_turn - current_turn)


func has_arrived(current_turn: int) -> bool:
	return current_turn >= arrival_turn


func get_info_string(current_turn: int) -> String:
	return "%d fighters, arrives in %d turns" % [fighter_count, get_turns_remaining(current_turn)]
