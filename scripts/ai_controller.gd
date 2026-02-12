class_name AiController
extends RefCounted

## AI controller that makes decisions for computer-controlled players.
## Uses only fog-of-war information (system_memory) — no cheating.
##
## State dictionary keys:
##   player_id, tactic, owned_systems, known_systems, my_fleets, all_systems


## Main entry point: returns {"production_changes": [...], "fleet_orders": [...], "station_actions": [...]}
static func execute_turn(player_id: int, tactic: int,
						 p_systems: Array, fleets: Array,
						 p_system_memory: Dictionary,
						 p_shield_lines: Array = [],
						 p_shield_activations: Array = [],
						 p_stations: Array = []) -> Dictionary:
	var state = _build_state(player_id, tactic, p_systems, fleets, p_system_memory,
							 p_shield_lines, p_shield_activations, p_stations)

	var result: Dictionary
	if _should_early_expand(state):
		result = _execute_early_expansion(state)
	elif tactic == Player.AiTactic.RUSH:
		result = _execute_rush(state)
	elif tactic == Player.AiTactic.FORTRESS:
		result = _execute_fortress(state)
	elif tactic == Player.AiTactic.ECONOMY:
		result = _execute_economy(state)
	elif tactic == Player.AiTactic.BOMBER:
		result = _execute_bomber(state)
	elif tactic == Player.AiTactic.BALANCED:
		result = _execute_balanced(state)
	else:
		result = {"production_changes": [], "fleet_orders": []}

	# Add station-related orders (all tactics)
	if not result.has("station_actions"):
		result["station_actions"] = []
	_add_station_orders(state, result)

	return result


## Build state dictionary from raw game data
static func _build_state(player_id: int, tactic: int,
						 p_systems: Array, fleets: Array,
						 p_system_memory: Dictionary,
						 p_shield_lines: Array = [],
						 p_shield_activations: Array = [],
						 p_stations: Array = []) -> Dictionary:
	var owned: Array = []
	for system in p_systems:
		if system.owner_id == player_id:
			owned.append(system)

	var known: Array = []
	var player_mem = p_system_memory.get(player_id, {})
	for system_id in player_mem:
		var mem = player_mem[system_id]
		var sys = p_systems[system_id]
		if sys.owner_id != player_id:
			known.append({
				"system_id": system_id,
				"owner_id": mem.get("owner_id", -1),
				"fighter_count": mem.get("fighter_count", "?"),
				"bomber_count": mem.get("bomber_count", 0),
				"battery_count": mem.get("battery_count", -1),
				"has_batteries": mem.get("has_batteries", false),
				"position": sys.global_position,
				"production_rate": sys.production_rate,
			})

	var my_fleets: Array = []
	for fleet in fleets:
		if fleet.owner_id == player_id:
			my_fleets.append(fleet)

	# Categorize stations
	var own_stations: Array = []
	var enemy_stations: Array = []
	for station in p_stations:
		if station["owner_id"] == player_id:
			own_stations.append(station)
		elif player_id in station["discovered_by"]:
			enemy_stations.append(station)

	return {
		"player_id": player_id,
		"tactic": tactic,
		"owned_systems": owned,
		"known_systems": known,
		"my_fleets": my_fleets,
		"all_systems": p_systems,
		"all_stations": p_stations,
		"shield_lines": p_shield_lines,
		"shield_activations": p_shield_activations,
		"own_stations": own_stations,
		"enemy_stations": enemy_stations,
	}


# ── Helper functions ──────────────────────────────────────────────

static func _find_nearest(source_pos: Vector2, candidates: Array) -> Dictionary:
	var best: Dictionary = {}
	var best_dist: float = INF
	for c in candidates:
		var pos: Vector2 = c["position"] if c is Dictionary else c.global_position
		var dist: float = source_pos.distance_to(pos)
		if dist < best_dist:
			best_dist = dist
			best = c
	return best


static func _get_known_neutrals(state: Dictionary) -> Array:
	var result: Array = []
	for known in state["known_systems"]:
		if known["owner_id"] < 0:
			result.append(known)
	return result


static func _get_known_enemies(state: Dictionary) -> Array:
	var result: Array = []
	for known in state["known_systems"]:
		if known["owner_id"] >= 0 and known["owner_id"] != state["player_id"]:
			result.append(known)
	return result


static func _estimate_strength(known: Dictionary) -> float:
	var fighters = known.get("fighter_count", "?")
	var bombers = known.get("bomber_count", 0)
	var bat = known.get("battery_count", -1)
	var has_bat: bool = known.get("has_batteries", false)

	var strength: float = 0.0
	if fighters is int:
		strength += fighters
	else:
		strength += known.get("production_rate", 3) * 3.0
	if bombers is int:
		strength += bombers * 1.5
	if bat >= 0:
		strength += bat * ShipTypes.BATTERY_DAMAGE_PER_ROUND
	elif has_bat:
		strength += 6.0
	return strength


static func _is_frontier(system: StarSystem, state: Dictionary) -> bool:
	for other in state["all_systems"]:
		if other.system_id == system.system_id:
			continue
		if other.owner_id == state["player_id"]:
			continue
		if system.global_position.distance_to(other.global_position) <= UniverseGenerator.MAX_SYSTEM_DISTANCE:
			return true
	return false


static func _has_fleet_targeting(state: Dictionary, target_id: int) -> bool:
	for fleet in state["my_fleets"]:
		if fleet.target_system_id == target_id:
			return true
	return false


static func _has_fleet_targeting_from(state: Dictionary, source_id: int) -> bool:
	for fleet in state["my_fleets"]:
		if fleet.source_system_id == source_id:
			return true
	return false


static func _weakest_enemy_player(state: Dictionary) -> int:
	var enemy_counts: Dictionary = {}
	for known in state["known_systems"]:
		var oid: int = known["owner_id"]
		if oid >= 0 and oid != state["player_id"]:
			enemy_counts[oid] = enemy_counts.get(oid, 0) + 1
	var weakest_id: int = -1
	var fewest: float = INF
	for eid in enemy_counts:
		if enemy_counts[eid] < fewest:
			fewest = enemy_counts[eid]
			weakest_id = eid
	return weakest_id


static func _avg_production(state: Dictionary) -> float:
	var owned: Array = state["owned_systems"]
	if owned.is_empty():
		return 0.0
	var total: float = 0.0
	for sys in owned:
		total += sys.production_rate
	return total / owned.size()


static func _all_upgraded(state: Dictionary) -> bool:
	for sys in state["owned_systems"]:
		if sys.production_rate < ShipTypes.MAX_PRODUCTION_RATE:
			return false
	return true


static func _total_fighters(state: Dictionary) -> int:
	var total: int = 0
	for sys in state["owned_systems"]:
		total += sys.fighter_count
	return total


static func _total_bombers(state: Dictionary) -> int:
	var total: int = 0
	for sys in state["owned_systems"]:
		total += sys.bomber_count
	return total


static func _build_fleet_order(source: StarSystem, target_id: int,
							   fighter_fraction: float, bomber_fraction: float = 0.0,
							   min_garrison: int = 4) -> Dictionary:
	var available_fighters: int = max(0, source.fighter_count - min_garrison)
	var send_fighters: int = int(available_fighters * fighter_fraction)
	var send_bombers: int = int(source.bomber_count * bomber_fraction)
	if send_fighters <= 0 and send_bombers <= 0:
		return {}
	return {
		"source_id": source.system_id,
		"target_id": target_id,
		"fighters": send_fighters,
		"bombers": send_bombers,
	}


static func _find_nearest_untargeted(source_pos: Vector2, candidates: Array, state: Dictionary) -> Dictionary:
	var best: Dictionary = {}
	var best_dist: float = INF
	for c in candidates:
		var sid: int = c["system_id"] if c is Dictionary else c.system_id
		if _has_fleet_targeting(state, sid):
			continue
		var pos: Vector2 = c["position"] if c is Dictionary else c.global_position
		var dist: float = source_pos.distance_to(pos)
		if dist < best_dist:
			best_dist = dist
			best = c
	return best


## Like _find_nearest_untargeted but penalizes targets behind enemy shield lines.
static func _find_nearest_untargeted_shield_aware(source_pos: Vector2, candidates: Array, state: Dictionary) -> Dictionary:
	var best: Dictionary = {}
	var best_score: float = INF
	for c in candidates:
		var sid: int = c["system_id"] if c is Dictionary else c.system_id
		if _has_fleet_targeting(state, sid):
			continue
		var pos: Vector2 = c["position"] if c is Dictionary else c.global_position
		var dist: float = source_pos.distance_to(pos)
		var shield_cost = _ai_path_shield_cost(state, source_pos, pos)
		var score: float = dist * shield_cost
		if score < best_score:
			best_score = score
			best = c
	return best


# ── Common early expansion phase ─────────────────────────────────

static func _should_early_expand(state: Dictionary) -> bool:
	var neutrals: Array = _get_known_neutrals(state)
	var enemies: Array = _get_known_enemies(state)
	return neutrals.size() > 0 and enemies.size() == 0


static func _execute_early_expansion(state: Dictionary) -> Dictionary:
	var production_changes: Array = []
	var fleet_orders: Array = []

	for sys in state["owned_systems"]:
		if sys.production_mode != StarSystem.ProductionMode.FIGHTERS:
			production_changes.append({"system_id": sys.system_id, "mode": StarSystem.ProductionMode.FIGHTERS})

	var neutrals: Array = _get_known_neutrals(state)
	for sys in state["owned_systems"]:
		if sys.fighter_count <= 4:
			continue
		var target: Dictionary = _find_nearest_untargeted(sys.global_position, neutrals, state)
		if not target.is_empty():
			var order: Dictionary = _build_fleet_order(sys, target["system_id"], 0.6, 0.0, 4)
			if not order.is_empty():
				fleet_orders.append(order)

	return {"production_changes": production_changes, "fleet_orders": fleet_orders}


# ── Tactic implementations ───────────────────────────────────────

static func _execute_rush(state: Dictionary) -> Dictionary:
	var production_changes: Array = []
	var fleet_orders: Array = []

	for sys in state["owned_systems"]:
		if sys.production_mode != StarSystem.ProductionMode.FIGHTERS:
			production_changes.append({"system_id": sys.system_id, "mode": StarSystem.ProductionMode.FIGHTERS})

	var neutrals: Array = _get_known_neutrals(state)
	var enemies: Array = _get_known_enemies(state)
	var weakest: int = _weakest_enemy_player(state)

	for sys in state["owned_systems"]:
		if sys.fighter_count <= 4:
			continue
		if _has_fleet_targeting_from(state, sys.system_id):
			continue

		var target: Dictionary = {}
		if neutrals.size() > 0:
			target = _find_nearest_untargeted(sys.global_position, neutrals, state)
		if target.is_empty() and enemies.size() > 0 and weakest >= 0:
			var weak_enemies: Array = enemies.filter(func(e): return e["owner_id"] == weakest)
			if weak_enemies.size() > 0:
				target = _find_nearest_untargeted_shield_aware(sys.global_position, weak_enemies, state)
		if target.is_empty():
			continue

		var order: Dictionary = _build_fleet_order(sys, target["system_id"], 0.6, 0.0, 4)
		if not order.is_empty():
			fleet_orders.append(order)

	return {"production_changes": production_changes, "fleet_orders": fleet_orders}


static func _execute_fortress(state: Dictionary) -> Dictionary:
	var production_changes: Array = []
	var fleet_orders: Array = []

	# Fortress: try to activate shields on frontier systems with >= 2 batteries
	var shield_partner = _find_fortress_shield_partner(state)

	for sys in state["owned_systems"]:
		# Skip systems being used for shield activation
		if shield_partner.has("source") and (sys.system_id == shield_partner["source"] or sys.system_id == shield_partner["target"]):
			continue
		var is_front: bool = _is_frontier(sys, state)
		if is_front:
			if sys.battery_count < ShipTypes.MAX_BATTERIES and sys.production_mode != StarSystem.ProductionMode.BATTERY_BUILD:
				production_changes.append({"system_id": sys.system_id, "mode": StarSystem.ProductionMode.BATTERY_BUILD})
			elif sys.battery_count >= ShipTypes.MAX_BATTERIES and sys.production_mode != StarSystem.ProductionMode.FIGHTERS:
				production_changes.append({"system_id": sys.system_id, "mode": StarSystem.ProductionMode.FIGHTERS})
		else:
			if sys.production_rate < ShipTypes.MAX_PRODUCTION_RATE and sys.production_mode != StarSystem.ProductionMode.UPGRADE:
				production_changes.append({"system_id": sys.system_id, "mode": StarSystem.ProductionMode.UPGRADE})
			elif sys.production_rate >= ShipTypes.MAX_PRODUCTION_RATE and sys.production_mode != StarSystem.ProductionMode.FIGHTERS:
				production_changes.append({"system_id": sys.system_id, "mode": StarSystem.ProductionMode.FIGHTERS})

	# Include shield_partner in production_changes if found
	if shield_partner.has("source"):
		production_changes.append({"system_id": shield_partner["source"], "shield_partner": shield_partner["target"]})

	var neutrals: Array = _get_known_neutrals(state)
	var enemies: Array = _get_known_enemies(state)
	var max_dist: float = UniverseGenerator.MAX_SYSTEM_DISTANCE * 1.5

	for sys in state["owned_systems"]:
		if sys.fighter_count <= 4:
			continue
		# Neutrals: expand aggressively
		if neutrals.size() > 0:
			var target: Dictionary = _find_nearest_untargeted(sys.global_position, neutrals, state)
			if not target.is_empty():
				var order: Dictionary = _build_fleet_order(sys, target["system_id"], 0.6, 0.0, 4)
				if not order.is_empty():
					fleet_orders.append(order)
					continue
		# Enemies: cautious (fortress style), avoid shield crossings
		if sys.fighter_count <= 10:
			continue
		for target in enemies:
			if _has_fleet_targeting(state, target["system_id"]):
				continue
			var dist: float = sys.global_position.distance_to(target["position"])
			if dist > max_dist:
				continue
			var shield_cost = _ai_path_shield_cost(state, sys.global_position, target["position"])
			if shield_cost > 2.0:
				continue  # Too costly to cross enemy shields
			if sys.fighter_count - 10 >= _estimate_strength(target) * 2.5 * shield_cost:
				var order: Dictionary = _build_fleet_order(sys, target["system_id"], 0.5, 0.0, 10)
				if not order.is_empty():
					fleet_orders.append(order)
				break

	return {"production_changes": production_changes, "fleet_orders": fleet_orders}


## Find a valid shield partner for Fortress AI to activate a shield line.
## Returns {"source": id, "target": id} or empty dict.
static func _find_fortress_shield_partner(state: Dictionary) -> Dictionary:
	if not _ai_can_add_structure(state):
		return {}

	# Find frontier systems with >= 2 batteries that aren't already activating or maxed on lines
	var candidates: Array = []
	for sys in state["owned_systems"]:
		if not _is_frontier(sys, state):
			continue
		if sys.battery_count < ShipTypes.SHIELD_MIN_BATTERIES:
			continue
		if sys.production_mode == StarSystem.ProductionMode.SHIELD_ACTIVATE:
			continue
		if _count_ai_shield_lines(state, sys.system_id) >= ShipTypes.MAX_SHIELD_LINES_PER_SYSTEM:
			continue
		candidates.append(sys)

	# Try to pair candidates with neighbors
	for source in candidates:
		for target in candidates:
			if source.system_id >= target.system_id:
				continue  # Avoid duplicates
			var dist = source.global_position.distance_to(target.global_position)
			if dist > UniverseGenerator.MAX_SYSTEM_DISTANCE:
				continue
			if _ai_shield_line_exists(state, source.system_id, target.system_id):
				continue
			return {"source": source.system_id, "target": target.system_id}

	# Try pairing with non-frontier owned systems that have batteries
	for source in candidates:
		for other in state["owned_systems"]:
			if other.system_id == source.system_id:
				continue
			if other.battery_count < ShipTypes.SHIELD_MIN_BATTERIES:
				continue
			if other.production_mode == StarSystem.ProductionMode.SHIELD_ACTIVATE:
				continue
			if _count_ai_shield_lines(state, other.system_id) >= ShipTypes.MAX_SHIELD_LINES_PER_SYSTEM:
				continue
			var dist = source.global_position.distance_to(other.global_position)
			if dist > UniverseGenerator.MAX_SYSTEM_DISTANCE:
				continue
			if _ai_shield_line_exists(state, source.system_id, other.system_id):
				continue
			return {"source": source.system_id, "target": other.system_id}

	return {}


static func _execute_economy(state: Dictionary) -> Dictionary:
	var production_changes: Array = []
	var fleet_orders: Array = []
	var avg_prod: float = _avg_production(state)
	var attack_mode: bool = _all_upgraded(state) or avg_prod >= 5.0

	for sys in state["owned_systems"]:
		if not attack_mode:
			if sys.production_rate < ShipTypes.MAX_PRODUCTION_RATE and sys.production_mode != StarSystem.ProductionMode.UPGRADE:
				production_changes.append({"system_id": sys.system_id, "mode": StarSystem.ProductionMode.UPGRADE})
			elif sys.production_rate >= ShipTypes.MAX_PRODUCTION_RATE and sys.production_mode != StarSystem.ProductionMode.FIGHTERS:
				production_changes.append({"system_id": sys.system_id, "mode": StarSystem.ProductionMode.FIGHTERS})
		else:
			if sys.production_mode != StarSystem.ProductionMode.FIGHTERS:
				production_changes.append({"system_id": sys.system_id, "mode": StarSystem.ProductionMode.FIGHTERS})

	var neutrals: Array = _get_known_neutrals(state)
	var enemies: Array = _get_known_enemies(state)
	var weakest: int = _weakest_enemy_player(state)

	if not attack_mode:
		for sys in state["owned_systems"]:
			if sys.fighter_count <= 4:
				continue
			# Neutrals: expand aggressively
			if neutrals.size() > 0:
				var near: Dictionary = _find_nearest_untargeted(sys.global_position, neutrals, state)
				if not near.is_empty():
					var order: Dictionary = _build_fleet_order(sys, near["system_id"], 0.6, 0.0, 4)
					if not order.is_empty():
						fleet_orders.append(order)
	else:
		var targets: Array = []
		if weakest >= 0:
			targets = enemies.filter(func(e): return e["owner_id"] == weakest)
		if targets.is_empty():
			targets = enemies
		targets += neutrals
		for sys in state["owned_systems"]:
			if sys.fighter_count <= 6:
				continue
			if targets.size() > 0:
				var target: Dictionary = _find_nearest_untargeted(sys.global_position, targets, state)
				if not target.is_empty():
					var order: Dictionary = _build_fleet_order(sys, target["system_id"], 0.7, 0.5, 6)
					if not order.is_empty():
						fleet_orders.append(order)

	return {"production_changes": production_changes, "fleet_orders": fleet_orders}


static func _execute_bomber(state: Dictionary) -> Dictionary:
	var production_changes: Array = []
	var fleet_orders: Array = []
	var tf: int = _total_fighters(state)
	var tb: int = _total_bombers(state)

	for sys in state["owned_systems"]:
		if sys.production_rate < 4 and sys.production_mode != StarSystem.ProductionMode.UPGRADE:
			production_changes.append({"system_id": sys.system_id, "mode": StarSystem.ProductionMode.UPGRADE})
		else:
			var need_bombers: bool = tb * 2 < tf and tf > 6
			if need_bombers and sys.production_mode != StarSystem.ProductionMode.BOMBERS:
				production_changes.append({"system_id": sys.system_id, "mode": StarSystem.ProductionMode.BOMBERS})
			elif not need_bombers and sys.production_mode != StarSystem.ProductionMode.FIGHTERS:
				production_changes.append({"system_id": sys.system_id, "mode": StarSystem.ProductionMode.FIGHTERS})

	var enemies: Array = _get_known_enemies(state)
	var neutrals: Array = _get_known_neutrals(state)

	for sys in state["owned_systems"]:
		if sys.fighter_count <= 4 and sys.bomber_count <= 0:
			continue
		# Neutrals: expand aggressively with fighters
		if neutrals.size() > 0:
			var near: Dictionary = _find_nearest_untargeted(sys.global_position, neutrals, state)
			if not near.is_empty():
				var order: Dictionary = _build_fleet_order(sys, near["system_id"], 0.6, 0.0, 4)
				if not order.is_empty():
					fleet_orders.append(order)
					continue
		# Enemies: bomber strikes on high-value targets
		if sys.fighter_count <= 6 and sys.bomber_count <= 0:
			continue
		enemies.sort_custom(func(a, b): return a.get("production_rate", 1) > b.get("production_rate", 1))
		for target in enemies:
			if _has_fleet_targeting(state, target["system_id"]):
				continue
			var order: Dictionary = _build_fleet_order(sys, target["system_id"], 0.6, 0.8, 6)
			if not order.is_empty():
				fleet_orders.append(order)
			break

	return {"production_changes": production_changes, "fleet_orders": fleet_orders}


static func _execute_balanced(state: Dictionary) -> Dictionary:
	var neutrals: Array = _get_known_neutrals(state)

	if neutrals.size() > 0:
		return _execute_balanced_mid(state)
	else:
		return _execute_balanced_late(state)



static func _execute_balanced_mid(state: Dictionary) -> Dictionary:
	var production_changes: Array = []
	var fleet_orders: Array = []

	for sys in state["owned_systems"]:
		var is_front: bool = _is_frontier(sys, state)
		if is_front and sys.battery_count < 2:
			if sys.production_mode != StarSystem.ProductionMode.BATTERY_BUILD:
				production_changes.append({"system_id": sys.system_id, "mode": StarSystem.ProductionMode.BATTERY_BUILD})
		elif sys.production_rate < ShipTypes.MAX_PRODUCTION_RATE:
			if sys.production_mode != StarSystem.ProductionMode.UPGRADE:
				production_changes.append({"system_id": sys.system_id, "mode": StarSystem.ProductionMode.UPGRADE})
		elif sys.production_mode != StarSystem.ProductionMode.FIGHTERS:
			production_changes.append({"system_id": sys.system_id, "mode": StarSystem.ProductionMode.FIGHTERS})

	var neutrals: Array = _get_known_neutrals(state)
	var enemies: Array = _get_known_enemies(state)
	for sys in state["owned_systems"]:
		if sys.fighter_count <= 4:
			continue
		# Neutrals: expand aggressively
		if neutrals.size() > 0:
			var near: Dictionary = _find_nearest_untargeted(sys.global_position, neutrals, state)
			if not near.is_empty():
				var order: Dictionary = _build_fleet_order(sys, near["system_id"], 0.6, 0.0, 4)
				if not order.is_empty():
					fleet_orders.append(order)
					continue
		# Enemies: moderate aggression
		if enemies.size() > 0 and sys.fighter_count > 8:
			var target: Dictionary = _find_nearest_untargeted(sys.global_position, enemies, state)
			if not target.is_empty():
				var order: Dictionary = _build_fleet_order(sys, target["system_id"], 0.5, 0.0, 8)
				if not order.is_empty():
					fleet_orders.append(order)

	return {"production_changes": production_changes, "fleet_orders": fleet_orders}


static func _execute_balanced_late(state: Dictionary) -> Dictionary:
	var production_changes: Array = []
	var fleet_orders: Array = []
	var tf: int = _total_fighters(state)
	var tb: int = _total_bombers(state)

	for sys in state["owned_systems"]:
		var need_bombers: bool = tb * 2 < tf and tf > 10
		if need_bombers and sys.production_mode != StarSystem.ProductionMode.BOMBERS:
			production_changes.append({"system_id": sys.system_id, "mode": StarSystem.ProductionMode.BOMBERS})
		elif not need_bombers and sys.production_mode != StarSystem.ProductionMode.FIGHTERS:
			production_changes.append({"system_id": sys.system_id, "mode": StarSystem.ProductionMode.FIGHTERS})

	var enemies: Array = _get_known_enemies(state)
	var neutrals: Array = _get_known_neutrals(state)
	var weakest: int = _weakest_enemy_player(state)
	var targets: Array = []
	if weakest >= 0:
		targets = enemies.filter(func(e): return e["owner_id"] == weakest)
	if targets.is_empty():
		targets = enemies
	if targets.is_empty():
		targets = neutrals

	for sys in state["owned_systems"]:
		if sys.fighter_count <= 6 and sys.bomber_count <= 0:
			continue
		if targets.size() > 0:
			var target: Dictionary = _find_nearest_untargeted(sys.global_position, targets, state)
			if not target.is_empty():
				var order: Dictionary = _build_fleet_order(sys, target["system_id"], 0.6, 0.8, 6)
				if not order.is_empty():
					fleet_orders.append(order)

	return {"production_changes": production_changes, "fleet_orders": fleet_orders}


# ── Shield helpers (FUT-19) ──────────────────────────────────────

static func _count_ai_shield_lines(state: Dictionary, system_id: int) -> int:
	var count: int = 0
	for line in state["shield_lines"]:
		if line["system_a"] == system_id or line["system_b"] == system_id:
			count += 1
	for act in state["shield_activations"]:
		if act["system_a"] == system_id or act["system_b"] == system_id:
			count += 1
	return count


static func _ai_shield_line_exists(state: Dictionary, id_a: int, id_b: int) -> bool:
	for line in state["shield_lines"]:
		if (line["system_a"] == id_a and line["system_b"] == id_b) or \
		   (line["system_a"] == id_b and line["system_b"] == id_a):
			return true
	for act in state["shield_activations"]:
		if (act["system_a"] == id_a and act["system_b"] == id_b) or \
		   (act["system_a"] == id_b and act["system_b"] == id_a):
			return true
	return false


static func _ai_can_add_structure(state: Dictionary) -> bool:
	# Build adjacency from existing lines + activations for this owner
	var pid = state["player_id"]
	var adj: Dictionary = {}
	for line in state["shield_lines"]:
		if line["owner_id"] != pid:
			continue
		var a = line["system_a"]
		var b = line["system_b"]
		if not adj.has(a):
			adj[a] = []
		if not adj.has(b):
			adj[b] = []
		adj[a].append(b)
		adj[b].append(a)
	for act in state["shield_activations"]:
		if act["owner_id"] != pid:
			continue
		var a = act["system_a"]
		var b = act["system_b"]
		if not adj.has(a):
			adj[a] = []
		if not adj.has(b):
			adj[b] = []
		adj[a].append(b)
		adj[b].append(a)

	# Count connected components
	if adj.is_empty():
		return true
	var visited: Dictionary = {}
	var count: int = 0
	for node in adj:
		if visited.has(node):
			continue
		count += 1
		var queue: Array = [node]
		visited[node] = true
		while queue.size() > 0:
			var current = queue.pop_front()
			for neighbor in adj.get(current, []):
				if not visited.has(neighbor):
					visited[neighbor] = true
					queue.append(neighbor)
	return count < ShipTypes.MAX_SHIELD_STRUCTURES


## Calculate a penalty cost for sending to a target that crosses enemy shield lines.
## Returns a multiplier >= 1.0 (higher = more penalized).
static func _ai_path_shield_cost(state: Dictionary, source_pos: Vector2, target_pos: Vector2) -> float:
	var cost: float = 1.0
	for line in state["shield_lines"]:
		if line["owner_id"] == state["player_id"]:
			continue
		var sys_a = state["all_systems"][line["system_a"]]
		var sys_b = state["all_systems"][line["system_b"]]
		if Combat.segments_intersect(source_pos, target_pos,
									 sys_a.global_position, sys_b.global_position):
			var distance = sys_a.global_position.distance_to(sys_b.global_position)
			var density = Combat.calculate_shield_density(distance)
			cost += density * 3.0  # Significant penalty per crossing
	return cost


# ── Station helpers (FUT-20) ─────────────────────────────────────

const STATION_ID_OFFSET: int = 1000


## Add station-related fleet orders and actions to the result.
## Handles material delivery, enemy station attacks, and station building.
static func _add_station_orders(state: Dictionary, result: Dictionary) -> void:
	var pid = state["player_id"]
	var own_stations: Array = state["own_stations"]
	var enemy_stations: Array = state["enemy_stations"]

	# 1. Send material to stations under construction
	for station in own_stations:
		if station["operative"]:
			continue
		var station_target_id = station["id"] + STATION_ID_OFFSET
		if _has_fleet_targeting(state, station_target_id):
			continue
		# Find nearest system with enough fighters to send
		var best_sys: StarSystem = null
		var best_dist: float = INF
		for sys in state["owned_systems"]:
			if sys.fighter_count <= 8:
				continue
			var dist = sys.global_position.distance_to(station["position"])
			if dist < best_dist:
				best_dist = dist
				best_sys = sys
		if best_sys:
			var send_count = min(best_sys.fighter_count - 4, ShipTypes.STATION_BUILD_PER_ROUND)
			if send_count > 0:
				result["fleet_orders"].append({
					"source_id": best_sys.system_id,
					"target_id": station_target_id,
					"fighters": send_count,
					"bombers": 0,
				})

	# 2. Send material to stations building batteries
	for station in own_stations:
		if not station["operative"] or not station["building_battery"]:
			continue
		var station_target_id = station["id"] + STATION_ID_OFFSET
		if _has_fleet_targeting(state, station_target_id):
			continue
		var best_sys: StarSystem = null
		var best_dist: float = INF
		for sys in state["owned_systems"]:
			if sys.fighter_count <= 6:
				continue
			var dist = sys.global_position.distance_to(station["position"])
			if dist < best_dist:
				best_dist = dist
				best_sys = sys
		if best_sys:
			var send_count = min(best_sys.fighter_count - 4, ShipTypes.STATION_BATTERY_PER_ROUND)
			if send_count > 0:
				result["fleet_orders"].append({
					"source_id": best_sys.system_id,
					"target_id": station_target_id,
					"fighters": send_count,
					"bombers": 0,
				})

	# 3. Attack enemy stations with garrison or nearby threat
	for station in enemy_stations:
		if not station["operative"]:
			continue
		var station_target_id = station["id"] + STATION_ID_OFFSET
		if _has_fleet_targeting(state, station_target_id):
			continue
		var garrison = station["fighter_count"] + station["bomber_count"]
		for sys in state["owned_systems"]:
			if sys.fighter_count <= 8:
				continue
			var dist = sys.global_position.distance_to(station["position"])
			if dist > UniverseGenerator.MAX_SYSTEM_DISTANCE * 2:
				continue
			# Need enough to overcome garrison + batteries
			var needed = garrison + station["battery_count"] * 3 + 5
			if sys.fighter_count - 6 >= needed:
				result["fleet_orders"].append({
					"source_id": sys.system_id,
					"target_id": station_target_id,
					"fighters": min(sys.fighter_count - 6, needed + 4),
					"bombers": 0,
				})
				break

	# 4. Station building (Fortress, Economy, Balanced — if tactic benefits from it)
	var tactic = state["tactic"]
	if tactic == Player.AiTactic.FORTRESS or tactic == Player.AiTactic.ECONOMY or tactic == Player.AiTactic.BALANCED:
		_ai_consider_station_build(state, result)

	# 5. Station battery building for operative stations without batteries (Fortress)
	if tactic == Player.AiTactic.FORTRESS:
		for station in own_stations:
			if station["operative"] and station["battery_count"] < ShipTypes.STATION_MAX_BATTERIES and not station["building_battery"]:
				result["station_actions"].append({"type": "build_battery", "station_id": station["id"]})
				break  # One at a time


## AI decides whether to build a station and where.
static func _ai_consider_station_build(state: Dictionary, result: Dictionary) -> void:
	var pid = state["player_id"]
	var own_stations: Array = state["own_stations"]

	if own_stations.size() >= ShipTypes.MAX_STATIONS_PER_PLAYER:
		return

	# Only build if we have enough systems and surplus fighters
	if state["owned_systems"].size() < 3:
		return
	var total_f = _total_fighters(state)
	if total_f < 20:
		return

	# Find a good position: midpoint between frontier systems, extending territory
	var best_pos = _find_station_build_position(state)
	if best_pos != Vector2.ZERO:
		result["station_actions"].append({"type": "build_station", "position": best_pos})


## Find a good position for AI to build a station.
## Tries to place it between owned frontier systems and enemy territory.
static func _find_station_build_position(state: Dictionary) -> Vector2:
	var pid = state["player_id"]
	var all_systems = state["all_systems"]
	var all_stations = state["all_stations"]

	# Find frontier systems
	var frontier: Array = []
	for sys in state["owned_systems"]:
		if _is_frontier(sys, state):
			frontier.append(sys)

	if frontier.is_empty():
		return Vector2.ZERO

	# Try to find positions extending from frontier towards enemies
	var enemies = _get_known_enemies(state)
	if enemies.is_empty():
		return Vector2.ZERO

	# Pick the frontier system closest to an enemy
	var best_frontier: StarSystem = null
	var best_enemy_dist: float = INF
	for sys in frontier:
		for enemy in enemies:
			var dist = sys.global_position.distance_to(enemy["position"])
			if dist < best_enemy_dist:
				best_enemy_dist = dist
				best_frontier = sys

	if not best_frontier:
		return Vector2.ZERO

	# Find nearest enemy to this frontier system
	var nearest_enemy_pos = Vector2.ZERO
	var min_dist = INF
	for enemy in enemies:
		var dist = best_frontier.global_position.distance_to(enemy["position"])
		if dist < min_dist:
			min_dist = dist
			nearest_enemy_pos = enemy["position"]

	# Place station partway from frontier toward enemy
	var direction = (nearest_enemy_pos - best_frontier.global_position).normalized()
	var place_dist = UniverseGenerator.MAX_SYSTEM_DISTANCE * 0.8
	var candidate = best_frontier.global_position + direction * place_dist

	# Validate: minimum distance to all systems and stations
	for sys in all_systems:
		if candidate.distance_to(sys.global_position) < UniverseGenerator.MIN_SYSTEM_DISTANCE:
			return Vector2.ZERO
	for station in all_stations:
		if candidate.distance_to(station["position"]) < UniverseGenerator.MIN_SYSTEM_DISTANCE:
			return Vector2.ZERO

	# Validate: within range of own system or operative station
	var in_range = false
	for sys in state["owned_systems"]:
		if candidate.distance_to(sys.global_position) <= UniverseGenerator.MAX_SYSTEM_DISTANCE:
			in_range = true
			break
	if not in_range:
		for station in state["own_stations"]:
			if station["operative"] and candidate.distance_to(station["position"]) <= UniverseGenerator.MAX_SYSTEM_DISTANCE:
				in_range = true
				break
	if not in_range:
		return Vector2.ZERO

	return candidate
