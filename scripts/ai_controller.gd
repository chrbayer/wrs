class_name AiController
extends RefCounted

## AI controller that makes decisions for computer-controlled players.
## Uses only fog-of-war information (system_memory) — no cheating.
##
## State dictionary keys:
##   player_id, tactic, owned_systems, known_systems, my_fleets, all_systems


## Main entry point: returns {"production_changes": [...], "fleet_orders": [...]}
static func execute_turn(player_id: int, tactic: int,
						 p_systems: Array, fleets: Array,
						 p_system_memory: Dictionary) -> Dictionary:
	var state = _build_state(player_id, tactic, p_systems, fleets, p_system_memory)

	if _should_early_expand(state):
		return _execute_early_expansion(state)

	if tactic == Player.AiTactic.RUSH:
		return _execute_rush(state)
	elif tactic == Player.AiTactic.FORTRESS:
		return _execute_fortress(state)
	elif tactic == Player.AiTactic.ECONOMY:
		return _execute_economy(state)
	elif tactic == Player.AiTactic.BOMBER:
		return _execute_bomber(state)
	elif tactic == Player.AiTactic.BALANCED:
		return _execute_balanced(state)

	return {"production_changes": [], "fleet_orders": []}


## Build state dictionary from raw game data
static func _build_state(player_id: int, tactic: int,
						 p_systems: Array, fleets: Array,
						 p_system_memory: Dictionary) -> Dictionary:
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

	return {
		"player_id": player_id,
		"tactic": tactic,
		"owned_systems": owned,
		"known_systems": known,
		"my_fleets": my_fleets,
		"all_systems": p_systems,
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
		if sys.maintaining_batteries:
			production_changes.append({"system_id": sys.system_id, "maintain": false})

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
		if sys.maintaining_batteries:
			production_changes.append({"system_id": sys.system_id, "maintain": false})

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
				target = _find_nearest_untargeted(sys.global_position, weak_enemies, state)
		if target.is_empty():
			continue

		var order: Dictionary = _build_fleet_order(sys, target["system_id"], 0.6, 0.0, 4)
		if not order.is_empty():
			fleet_orders.append(order)

	return {"production_changes": production_changes, "fleet_orders": fleet_orders}


static func _execute_fortress(state: Dictionary) -> Dictionary:
	var production_changes: Array = []
	var fleet_orders: Array = []

	for sys in state["owned_systems"]:
		var is_front: bool = _is_frontier(sys, state)
		if is_front:
			if sys.battery_count < ShipTypes.MAX_BATTERIES and sys.production_mode != StarSystem.ProductionMode.BATTERY_BUILD:
				production_changes.append({"system_id": sys.system_id, "mode": StarSystem.ProductionMode.BATTERY_BUILD})
			elif sys.battery_count >= ShipTypes.MAX_BATTERIES and sys.production_mode != StarSystem.ProductionMode.FIGHTERS:
				production_changes.append({"system_id": sys.system_id, "mode": StarSystem.ProductionMode.FIGHTERS})
			if sys.battery_count > 0 and not sys.maintaining_batteries:
				production_changes.append({"system_id": sys.system_id, "maintain": true})
		else:
			if sys.production_rate < ShipTypes.MAX_PRODUCTION_RATE and sys.production_mode != StarSystem.ProductionMode.UPGRADE:
				production_changes.append({"system_id": sys.system_id, "mode": StarSystem.ProductionMode.UPGRADE})
			elif sys.production_rate >= ShipTypes.MAX_PRODUCTION_RATE and sys.production_mode != StarSystem.ProductionMode.FIGHTERS:
				production_changes.append({"system_id": sys.system_id, "mode": StarSystem.ProductionMode.FIGHTERS})
			if sys.maintaining_batteries and sys.battery_count == 0:
				production_changes.append({"system_id": sys.system_id, "maintain": false})

	var neutrals: Array = _get_known_neutrals(state)
	var enemies: Array = _get_known_enemies(state)
	var max_dist: float = UniverseGenerator.MAX_SYSTEM_DISTANCE * 1.5

	for sys in state["owned_systems"]:
		if sys.fighter_count <= 10:
			continue
		for target in neutrals:
			if _has_fleet_targeting(state, target["system_id"]):
				continue
			var dist: float = sys.global_position.distance_to(target["position"])
			if dist > max_dist:
				continue
			if sys.fighter_count - 10 >= _estimate_strength(target) * 2.0:
				var order: Dictionary = _build_fleet_order(sys, target["system_id"], 0.5, 0.0, 10)
				if not order.is_empty():
					fleet_orders.append(order)
				break
		for target in enemies:
			if _has_fleet_targeting(state, target["system_id"]):
				continue
			var dist: float = sys.global_position.distance_to(target["position"])
			if dist > max_dist:
				continue
			if sys.fighter_count - 10 >= _estimate_strength(target) * 2.5:
				var order: Dictionary = _build_fleet_order(sys, target["system_id"], 0.5, 0.0, 10)
				if not order.is_empty():
					fleet_orders.append(order)
				break

	return {"production_changes": production_changes, "fleet_orders": fleet_orders}


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
		if sys.maintaining_batteries and sys.battery_count == 0:
			production_changes.append({"system_id": sys.system_id, "maintain": false})

	var neutrals: Array = _get_known_neutrals(state)
	var enemies: Array = _get_known_enemies(state)
	var weakest: int = _weakest_enemy_player(state)

	if not attack_mode:
		for sys in state["owned_systems"]:
			if sys.fighter_count <= 8:
				continue
			if neutrals.size() > 0:
				var near: Dictionary = _find_nearest_untargeted(sys.global_position, neutrals, state)
				if not near.is_empty():
					var dist: float = sys.global_position.distance_to(near["position"])
					if dist <= UniverseGenerator.MAX_SYSTEM_DISTANCE:
						var order: Dictionary = _build_fleet_order(sys, near["system_id"], 0.5, 0.0, 8)
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
		if sys.maintaining_batteries and sys.battery_count == 0:
			production_changes.append({"system_id": sys.system_id, "maintain": false})

	var enemies: Array = _get_known_enemies(state)
	var neutrals: Array = _get_known_neutrals(state)
	enemies.sort_custom(func(a, b): return a.get("production_rate", 1) > b.get("production_rate", 1))
	var targets: Array = enemies + neutrals

	for sys in state["owned_systems"]:
		if sys.fighter_count <= 6 and sys.bomber_count <= 0:
			continue
		for target in targets:
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
			if sys.battery_count > 0 and not sys.maintaining_batteries:
				production_changes.append({"system_id": sys.system_id, "maintain": true})
		elif sys.production_rate < ShipTypes.MAX_PRODUCTION_RATE:
			if sys.production_mode != StarSystem.ProductionMode.UPGRADE:
				production_changes.append({"system_id": sys.system_id, "mode": StarSystem.ProductionMode.UPGRADE})
		elif sys.production_mode != StarSystem.ProductionMode.FIGHTERS:
			production_changes.append({"system_id": sys.system_id, "mode": StarSystem.ProductionMode.FIGHTERS})

	var neutrals: Array = _get_known_neutrals(state)
	for sys in state["owned_systems"]:
		if sys.fighter_count <= 8:
			continue
		if neutrals.size() > 0:
			var near: Dictionary = _find_nearest_untargeted(sys.global_position, neutrals, state)
			if not near.is_empty():
				var dist: float = sys.global_position.distance_to(near["position"])
				if dist <= UniverseGenerator.MAX_SYSTEM_DISTANCE * 1.2:
					var order: Dictionary = _build_fleet_order(sys, near["system_id"], 0.5, 0.0, 8)
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
