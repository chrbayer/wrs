class_name UniverseGenerator
extends RefCounted

## Generates a universe with star systems

const MIN_SYSTEM_DISTANCE: float = 120.0
const MAX_SYSTEM_DISTANCE: float = 250.0  # Max distance for visibility/connectivity
const MAP_EDGE_MARGIN: float = 100.0  # Minimum distance from viewport edges
const PLAYER_START_MIN_DISTANCE: float = 400.0
const MAX_PLACEMENT_ATTEMPTS: int = 100

## Star name components for procedural generation
const STAR_PREFIXES = ["Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta",
					   "Nova", "Proxima", "Sirius", "Vega", "Rigel", "Altair"]
const STAR_SUFFIXES = ["Prime", "Major", "Minor", "I", "II", "III", "IV", "V"]


## Generate star system positions
static func generate_system_positions(count: int, bounds: Rect2,
									  player_count: int) -> Dictionary:
	var positions: Array[Vector2] = []
	var player_start_indices: Array[int] = []

	# Generate positions with minimum distance constraint
	for i in range(count):
		var pos = _find_valid_position(positions, bounds)
		if pos != Vector2.INF:
			positions.append(pos)

	# Select player starting positions (spread apart)
	player_start_indices = _select_player_starts(positions, player_count)

	return {
		"positions": positions,
		"player_starts": player_start_indices
	}


static func _find_valid_position(existing: Array[Vector2], bounds: Rect2) -> Vector2:
	var margin = MIN_SYSTEM_DISTANCE

	for _attempt in range(MAX_PLACEMENT_ATTEMPTS):
		var pos = Vector2(
			randf_range(bounds.position.x + margin, bounds.end.x - margin),
			randf_range(bounds.position.y + margin, bounds.end.y - margin)
		)

		var valid = true
		var has_neighbor = existing.is_empty()  # First star doesn't need neighbor

		for existing_pos in existing:
			var dist = pos.distance_to(existing_pos)
			if dist < MIN_SYSTEM_DISTANCE:
				valid = false
				break
			if dist <= MAX_SYSTEM_DISTANCE:
				has_neighbor = true

		if valid and has_neighbor:
			return pos

	return Vector2.INF  # Failed to find position


static func _select_player_starts(positions: Array[Vector2], player_count: int) -> Array[int]:
	if positions.size() < player_count:
		push_error("Not enough systems for players!")
		return []

	var selected: Array[int] = []
	var available = range(positions.size())

	# Pick first player randomly
	var first_idx = available.pick_random()
	selected.append(first_idx)
	available.erase(first_idx)

	# Pick remaining players maximizing distance from others
	for _p in range(player_count - 1):
		var best_idx = -1
		var best_min_dist = 0.0

		for idx in available:
			var min_dist = INF
			for sel_idx in selected:
				var dist = positions[idx].distance_to(positions[sel_idx])
				min_dist = min(min_dist, dist)

			if min_dist > best_min_dist:
				best_min_dist = min_dist
				best_idx = idx

		if best_idx >= 0:
			selected.append(best_idx)
			available.erase(best_idx)

	return selected


## Generate a random star name
static func generate_star_name() -> String:
	var prefix = STAR_PREFIXES.pick_random()
	if randf() > 0.5:
		return prefix + " " + STAR_SUFFIXES.pick_random()
	return prefix


## Generate random production rate
static func generate_production_rate() -> int:
	return randi_range(1, 5)


## Generate random initial fighter count based on production rate
## Higher production = more defenders on average
static func generate_initial_fighters(production_rate: int) -> int:
	var min_fighters = production_rate * 2
	var max_fighters = production_rate * 5
	return randi_range(min_fighters, max_fighters)


## Generate starting fighters distributed by home world connectivity (compensation model).
## Players with fewer/weaker neutral neighbors get more fighters to offset their weaker position.
## Scoring considers both neighbor count and their production rates.
## Total pool is fixed (FIGHTERS_PER_PLAYER × player_count), distributed inversely to score.
const FIGHTERS_PER_PLAYER: int = 30
const MIN_START_FIGHTERS: int = 20
const MAX_START_FIGHTERS: int = 40

static func generate_player_start_fighters(positions: Array, player_starts: Array,
										   production_rates: Array = []) -> Array[int]:
	var player_count: int = player_starts.size()
	var total_pool: int = FIGHTERS_PER_PLAYER * player_count

	# Score each player's starting position by neighbor count weighted by production rate
	var position_scores: Array[float] = []
	for p_idx in range(player_count):
		var home_pos: Vector2 = positions[player_starts[p_idx]]
		var score: float = 0.0
		for i in range(positions.size()):
			if i in player_starts:
				continue
			if home_pos.distance_to(positions[i]) <= MAX_SYSTEM_DISTANCE:
				var prod_rate: float = production_rates[i] if production_rates.size() > i else 3.0
				score += prod_rate
		position_scores.append(maxf(1.0, score))

	# Inverse proportional distribution: lower score → larger share
	var inverse_sum: float = 0.0
	for score in position_scores:
		inverse_sum += 1.0 / score

	var fighter_counts: Array[int] = []
	var assigned_total: int = 0
	for p_idx in range(player_count):
		var share: float = (1.0 / position_scores[p_idx]) / inverse_sum
		var fighters: int = clampi(roundi(share * total_pool), MIN_START_FIGHTERS, MAX_START_FIGHTERS)
		fighter_counts.append(fighters)
		assigned_total += fighters

	# Distribute remainder (or remove excess) to keep total_pool exact
	var remainder: int = total_pool - assigned_total
	while remainder != 0:
		if remainder > 0:
			var min_idx: int = 0
			for i in range(1, player_count):
				if fighter_counts[i] < fighter_counts[min_idx]:
					min_idx = i
			if fighter_counts[min_idx] < MAX_START_FIGHTERS:
				fighter_counts[min_idx] += 1
				remainder -= 1
			else:
				break
		else:
			var max_idx: int = 0
			for i in range(1, player_count):
				if fighter_counts[i] > fighter_counts[max_idx]:
					max_idx = i
			if fighter_counts[max_idx] > MIN_START_FIGHTERS:
				fighter_counts[max_idx] -= 1
				remainder += 1
			else:
				break

	return fighter_counts
