class_name Combat
extends RefCounted

## Handles combat resolution between fleets and systems

const DEFENDER_BONUS: float = 1.5  # Defenders are 1.5x more effective
const HIT_CHANCE: float = 0.3  # Base chance to destroy enemy fighter per round
const MAX_COMBAT_ROUNDS: int = 100  # Safety limit

## Combat result structure
class CombatResult:
	var winner_id: int  # -1 for neutral, player id otherwise
	var remaining_fighters: int
	var remaining_bombers: int
	var attacker_fighter_losses: int
	var attacker_bomber_losses: int
	var defender_fighter_losses: int
	var defender_bomber_losses: int
	var battery_kills: int  # Ships destroyed by batteries
	var production_damage: int  # Production rate reduction from bomber attack
	var conquest_occurred: bool  # Whether ownership changed

	func _init(winner: int, rem_fighters: int, rem_bombers: int,
			   att_f_losses: int, att_b_losses: int,
			   def_f_losses: int, def_b_losses: int) -> void:
		winner_id = winner
		remaining_fighters = rem_fighters
		remaining_bombers = rem_bombers
		attacker_fighter_losses = att_f_losses
		attacker_bomber_losses = att_b_losses
		defender_fighter_losses = def_f_losses
		defender_bomber_losses = def_b_losses
		battery_kills = 0
		production_damage = 0
		conquest_occurred = false

	func get_attacker_total_losses() -> int:
		return attacker_fighter_losses + attacker_bomber_losses

	func get_defender_total_losses() -> int:
		return defender_fighter_losses + defender_bomber_losses


## Calculate effective attack power for a force
static func calculate_attack_power(fighters: int, bombers: int, fighter_morale: float = 1.0) -> float:
	return fighters * ShipTypes.FIGHTER_ATTACK * fighter_morale + bombers * ShipTypes.BOMBER_ATTACK


## Calculate effective defense power for a force
static func calculate_defense_power(fighters: int, bombers: int) -> float:
	return fighters * ShipTypes.FIGHTER_DEFENSE + bombers * ShipTypes.BOMBER_DEFENSE


## Process battery combat phase
## Returns Dictionary with "fighter_kills" and "bomber_kills"
static func resolve_battery_combat(battery_count: int, attacker_fighters: int, attacker_bombers: int) -> Dictionary:
	var result = {"fighter_kills": 0, "bomber_kills": 0}

	if battery_count <= 0:
		return result

	# Each battery deals damage each round
	var total_battery_damage = battery_count * ShipTypes.BATTERY_DAMAGE_PER_ROUND

	# Batteries prioritize fighters (more effective against them)
	# Allocate damage: prefer fighters first
	var fighters_remaining = attacker_fighters
	var bombers_remaining = attacker_bombers

	# Damage to fighters (full effectiveness)
	var fighter_damage = min(total_battery_damage * ShipTypes.BATTERY_VS_FIGHTER, fighters_remaining)
	result["fighter_kills"] = int(fighter_damage)
	var remaining_damage = total_battery_damage - fighter_damage

	# Remaining damage goes to bombers (reduced effectiveness)
	if remaining_damage > 0 and bombers_remaining > 0:
		var effective_bomber_damage = remaining_damage * ShipTypes.BATTERY_VS_BOMBER
		result["bomber_kills"] = int(min(effective_bomber_damage, bombers_remaining))

	return result


## Resolve combat between attackers and defenders with full ship type support
## Returns CombatResult with detailed outcome
static func resolve_combat(att_fighters: int, att_bombers: int, attacker_id: int,
						   def_fighters: int, def_bombers: int, defender_id: int,
						   battery_count: int = 0, attacker_fighter_morale: float = 1.0) -> CombatResult:
	var attackers_f = att_fighters
	var attackers_b = att_bombers
	var defenders_f = def_fighters
	var defenders_b = def_bombers

	var initial_att_f = attackers_f
	var initial_att_b = attackers_b
	var initial_def_f = defenders_f
	var initial_def_b = defenders_b

	var battery_kills = 0

	# Phase 1: Battery combat (before ship-to-ship)
	if battery_count > 0:
		var battery_result = resolve_battery_combat(battery_count, attackers_f, attackers_b)
		attackers_f = max(0, attackers_f - battery_result["fighter_kills"])
		attackers_b = max(0, attackers_b - battery_result["bomber_kills"])
		battery_kills = battery_result["fighter_kills"] + battery_result["bomber_kills"]

	# Phase 2: Ship-to-ship combat
	var round_count = 0

	while (attackers_f + attackers_b) > 0 and (defenders_f + defenders_b) > 0 and round_count < MAX_COMBAT_ROUNDS:
		round_count += 1

		# Calculate attack power for this round (attacker morale affects fighter attack only)
		var attacker_power = calculate_attack_power(attackers_f, attackers_b, attacker_fighter_morale)
		var defender_power = calculate_defense_power(defenders_f, defenders_b) * DEFENDER_BONUS

		# Attackers fire - calculate hits
		var attacker_hits = 0
		for i in range(int(attacker_power)):
			if randf() < HIT_CHANCE:
				attacker_hits += 1

		# Defenders fire with bonus
		var defender_hits = 0
		for i in range(int(defender_power)):
			if randf() < HIT_CHANCE:
				defender_hits += 1

		# Apply attacker hits to defenders (prefer hitting bombers first - they're weaker defense)
		var att_hits_remaining = attacker_hits
		if defenders_b > 0 and att_hits_remaining > 0:
			var bomber_kills = min(defenders_b, att_hits_remaining)
			defenders_b -= bomber_kills
			att_hits_remaining -= bomber_kills
		if defenders_f > 0 and att_hits_remaining > 0:
			var fighter_kills = min(defenders_f, att_hits_remaining)
			defenders_f -= fighter_kills

		# Apply defender hits to attackers (prefer hitting bombers - weaker defense)
		var def_hits_remaining = defender_hits
		if attackers_b > 0 and def_hits_remaining > 0:
			var bomber_kills = min(attackers_b, def_hits_remaining)
			attackers_b -= bomber_kills
			def_hits_remaining -= bomber_kills
		if attackers_f > 0 and def_hits_remaining > 0:
			var fighter_kills = min(attackers_f, def_hits_remaining)
			attackers_f -= fighter_kills

	# Determine winner
	var winner: int
	var rem_fighters: int
	var rem_bombers: int

	if (attackers_f + attackers_b) > 0:
		winner = attacker_id
		rem_fighters = attackers_f
		rem_bombers = attackers_b
	elif (defenders_f + defenders_b) > 0:
		winner = defender_id
		rem_fighters = defenders_f
		rem_bombers = defenders_b
	else:
		# Draw - defender wins with 0 ships (system becomes neutral)
		winner = -1
		rem_fighters = 0
		rem_bombers = 0

	var result = CombatResult.new(
		winner,
		rem_fighters,
		rem_bombers,
		initial_att_f - attackers_f,
		initial_att_b - attackers_b,
		initial_def_f - defenders_f,
		initial_def_b - defenders_b
	)
	result.battery_kills = battery_kills

	return result


## Merge multiple fleets arriving at the same time
## Returns Dictionary: owner_id -> {"fighters": int, "bombers": int, "fighter_morale": float}
static func merge_fleets_by_owner(fleets: Array) -> Dictionary:
	var merged: Dictionary = {}

	for fleet in fleets:
		var owner = fleet.owner_id
		if not merged.has(owner):
			merged[owner] = {"fighters": 0, "bombers": 0, "fighter_morale_weighted": 0.0}
		merged[owner]["fighters"] += fleet.fighter_count
		# Weighted morale: fighter_count × morale per fleet
		merged[owner]["fighter_morale_weighted"] += fleet.fighter_count * fleet.get_fighter_morale()
		merged[owner]["bombers"] += fleet.bomber_count

	# Calculate weighted average morale per owner
	for owner in merged:
		var total_fighters = merged[owner]["fighters"]
		if total_fighters > 0:
			merged[owner]["fighter_morale"] = merged[owner]["fighter_morale_weighted"] / total_fighters
		else:
			merged[owner]["fighter_morale"] = 1.0
		merged[owner].erase("fighter_morale_weighted")

	return merged


## Split a force into waves of MAX_FLEET_SIZE, preserving fighter/bomber ratio
static func split_into_waves(owner_id: int, fighters: int, bombers: int, fighter_morale: float) -> Array:
	var total = fighters + bombers
	var max_size = ShipTypes.MAX_FLEET_SIZE
	if total <= max_size:
		return [{"id": owner_id, "fighters": fighters, "bombers": bombers, "fighter_morale": fighter_morale}]

	var waves: Array = []
	var remaining_f = fighters
	var remaining_b = bombers

	while remaining_f + remaining_b > 0:
		var remaining_total = remaining_f + remaining_b
		var wave_size = mini(remaining_total, max_size)

		# Preserve fighter/bomber ratio from remaining ships
		var wave_f: int = int(round(float(remaining_f) / float(remaining_total) * wave_size))
		var wave_b: int = wave_size - wave_f
		# Clamp to available
		wave_f = mini(wave_f, remaining_f)
		wave_b = mini(wave_b, remaining_b)
		# Fill remainder from whichever has surplus
		var shortfall = wave_size - wave_f - wave_b
		if shortfall > 0:
			var extra_f = mini(shortfall, remaining_f - wave_f)
			wave_f += extra_f
			shortfall -= extra_f
		if shortfall > 0:
			wave_b += mini(shortfall, remaining_b - wave_b)

		waves.append({"id": owner_id, "fighters": wave_f, "bombers": wave_b, "fighter_morale": fighter_morale})
		remaining_f -= wave_f
		remaining_b -= wave_b

	return waves


## Test if two 2D line segments (p1-p2) and (p3-p4) intersect.
## Uses cross-product method. Excludes near-endpoint intersections (epsilon).
static func segments_intersect(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2) -> bool:
	var d1 = p2 - p1
	var d2 = p4 - p3
	var cross = d1.x * d2.y - d1.y * d2.x

	if abs(cross) < 0.0001:
		return false  # Parallel or collinear

	var d3 = p3 - p1
	var t = (d3.x * d2.y - d3.y * d2.x) / cross
	var u = (d3.x * d1.y - d3.y * d1.x) / cross

	# Exclude near-endpoint hits (epsilon = 0.01) to avoid false positives
	# when fleet path starts/ends at a shield endpoint system
	var eps = 0.01
	return t > eps and t < (1.0 - eps) and u > eps and u < (1.0 - eps)


## Calculate shield density based on distance between two shield systems.
## Returns 0.0 (weak, at MAX_SYSTEM_DISTANCE) to 1.0 (strong, at MIN_SYSTEM_DISTANCE).
static func calculate_shield_density(distance: float) -> float:
	var min_dist = UniverseGenerator.MIN_SYSTEM_DISTANCE
	var max_dist = UniverseGenerator.MAX_SYSTEM_DISTANCE
	if max_dist <= min_dist:
		return 1.0
	var density = 1.0 - (distance - min_dist) / (max_dist - min_dist)
	return clampf(density, 0.0, 1.0)


## Calculate the shield effect on a fleet crossing a shield line.
## Returns Dictionary with fighter_losses, bomber_losses, fighter_blocked, bomber_blocked, density, blockade_value.
static func calculate_shield_effect(bat_a: int, bat_b: int, distance: float,
									fighters: int, bombers: int) -> Dictionary:
	var density = calculate_shield_density(distance)
	var min_bat = mini(bat_a, bat_b)
	var sum_bat = bat_a + bat_b
	var blockade_value = min_bat * density

	var fighter_blocked = blockade_value >= ShipTypes.SHIELD_BLOCKADE_THRESHOLD
	# Bombers need double the blockade threshold (resistance)
	var bomber_blocked = blockade_value >= (ShipTypes.SHIELD_BLOCKADE_THRESHOLD / ShipTypes.SHIELD_BOMBER_RESISTANCE)

	# Attrition: sum(bat) * density * damage_factor * ship_count
	var fighter_losses = 0
	var bomber_losses = 0
	if not fighter_blocked and fighters > 0:
		var loss_rate = sum_bat * density * ShipTypes.SHIELD_DAMAGE_FACTOR
		fighter_losses = int(loss_rate * fighters)
	if not bomber_blocked and bombers > 0:
		var loss_rate = sum_bat * density * ShipTypes.SHIELD_DAMAGE_FACTOR * ShipTypes.SHIELD_BOMBER_RESISTANCE
		bomber_losses = int(loss_rate * bombers)

	return {
		"fighter_losses": fighter_losses,
		"bomber_losses": bomber_losses,
		"fighter_blocked": fighter_blocked,
		"bomber_blocked": bomber_blocked,
		"density": density,
		"blockade_value": blockade_value,
	}


## Resolve combat when multiple fleets arrive at a system
## Returns detailed result dictionary
## effective_battery_count includes shield line neighbor support (if -1, uses system.battery_count)
static func resolve_system_combat(system: StarSystem, arriving_fleets: Dictionary, effective_battery_count: int = -1) -> Dictionary:
	var system_owner = system.owner_id
	var system_fighters = system.fighter_count
	var system_bombers = system.bomber_count

	# Result contains detailed combat information
	var result = {
		"winner": system_owner,
		"remaining_fighters": system_fighters,
		"remaining_bombers": system_bombers,
		"log": [],
		"conquest_occurred": false,
		"production_damage": 0,
		"battery_kills": 0,
		"attacker_fighter_losses": 0,
		"attacker_bomber_losses": 0,
		"defender_fighter_losses": 0,
		"defender_bomber_losses": 0,
		"attacker_fighter_morale": 1.0,
		"stages": []
	}

	# If system owner has arriving reinforcements, add them first
	if arriving_fleets.has(system_owner):
		result["remaining_fighters"] += arriving_fleets[system_owner]["fighters"]
		result["remaining_bombers"] += arriving_fleets[system_owner]["bombers"]
		arriving_fleets.erase(system_owner)

	# Split each attacker's force into waves of MAX_FLEET_SIZE
	var waves: Array = []
	for attacker_id in arriving_fleets:
		var force = arriving_fleets[attacker_id]
		var owner_waves = split_into_waves(attacker_id, force["fighters"], force["bombers"], force["fighter_morale"])
		waves.append_array(owner_waves)

	# Store pre-battery snapshot in each wave
	for wave in waves:
		wave["pre_fighters"] = wave["fighters"]
		wave["pre_bombers"] = wave["bombers"]
		wave["bat_fighter_kills"] = 0
		wave["bat_bomber_kills"] = 0

	# Battery pre-combat phase: batteries engage each wave independently (largest attack value first)
	var bat_count = effective_battery_count if effective_battery_count >= 0 else system.battery_count
	if bat_count > 0 and waves.size() > 0:
		waves.sort_custom(func(a, b):
			return calculate_attack_power(a["fighters"], a["bombers"], a["fighter_morale"]) > calculate_attack_power(b["fighters"], b["bombers"], b["fighter_morale"])
		)

		for wave in waves:
			var battery_result = resolve_battery_combat(bat_count, wave["fighters"], wave["bombers"])
			wave["fighters"] = max(0, wave["fighters"] - battery_result["fighter_kills"])
			wave["bombers"] = max(0, wave["bombers"] - battery_result["bomber_kills"])
			wave["bat_fighter_kills"] = battery_result["fighter_kills"]
			wave["bat_bomber_kills"] = battery_result["bomber_kills"]
			var kills = battery_result["fighter_kills"] + battery_result["bomber_kills"]
			result["battery_kills"] += kills
			if kills > 0:
				result["log"].append("Batteries destroyed %d ships from Player %d's wave" % [kills, wave["id"] + 1])

		# Remove waves reduced to 0 ships; create stages for eliminated waves
		var surviving_waves: Array = []
		for wave in waves:
			if wave["fighters"] + wave["bombers"] > 0:
				surviving_waves.append(wave)
			else:
				result["stages"].append({
					"attacker_id": wave["id"],
					"attacker_fighters": wave["pre_fighters"],
					"attacker_bombers": wave["pre_bombers"],
					"attacker_fighter_morale": wave["fighter_morale"],
					"defender_id": system_owner,
					"defender_fighters": result["remaining_fighters"],
					"defender_bombers": result["remaining_bombers"],
					"battery_fighter_kills": wave["bat_fighter_kills"],
					"battery_bomber_kills": wave["bat_bomber_kills"],
					"attacker_fighter_losses": wave["bat_fighter_kills"],
					"attacker_bomber_losses": wave["bat_bomber_kills"],
					"defender_fighter_losses": 0,
					"defender_bomber_losses": 0,
					"batteries_before": system.battery_count,
					"batteries_after": system.battery_count,
					"stage_winner": system_owner,
					"remaining_fighters": result["remaining_fighters"],
					"remaining_bombers": result["remaining_bombers"],
				})
		waves = surviving_waves

	# Sort surviving waves by attack value (largest first)
	waves.sort_custom(func(a, b):
		return calculate_attack_power(a["fighters"], a["bombers"], a["fighter_morale"]) > calculate_attack_power(b["fighters"], b["bombers"], b["fighter_morale"])
	)

	var original_owner = system_owner
	var total_attacker_bombers = 0  # Track bombers for production damage

	# Process each wave (largest first)
	for wave in waves:
		var attacker_id = wave["id"]
		var att_fighters = wave["fighters"]
		var att_bombers = wave["bombers"]
		var att_morale = wave["fighter_morale"]
		total_attacker_bombers += att_bombers

		# Track attacker morale for report (use first/largest attacker's morale)
		if result["attacker_fighter_morale"] == 1.0 and att_morale < 1.0:
			result["attacker_fighter_morale"] = att_morale

		# If this wave's owner already holds the system, reinforce instead of fight
		if attacker_id == result["winner"]:
			result["remaining_fighters"] += att_fighters
			result["remaining_bombers"] += att_bombers
			result["log"].append("Player %d's wave reinforces with %d fighters, %d bombers" % [
				attacker_id + 1, att_fighters, att_bombers
			])
			continue

		# Snapshot defender state before this stage
		var def_fighters_before = result["remaining_fighters"]
		var def_bombers_before = result["remaining_bombers"]
		var defender_id_before = result["winner"]

		if result["remaining_fighters"] == 0 and result["remaining_bombers"] == 0 and result["winner"] == -1:
			# Empty system - wave takes it
			result["winner"] = attacker_id
			result["remaining_fighters"] = att_fighters
			result["remaining_bombers"] = att_bombers
			# Only count as conquest if previously owned by a player (PR-11: no penalty for neutrals)
			if original_owner >= 0:
				result["conquest_occurred"] = true
			result["log"].append("Player %d claims empty system with %d fighters, %d bombers" % [
				attacker_id + 1, att_fighters, att_bombers
			])

			# Stage: claim empty system (no combat losses)
			result["stages"].append({
				"attacker_id": attacker_id,
				"attacker_fighters": wave["pre_fighters"],
				"attacker_bombers": wave["pre_bombers"],
				"attacker_fighter_morale": att_morale,
				"defender_id": defender_id_before,
				"defender_fighters": 0,
				"defender_bombers": 0,
				"battery_fighter_kills": wave["bat_fighter_kills"],
				"battery_bomber_kills": wave["bat_bomber_kills"],
				"attacker_fighter_losses": wave["bat_fighter_kills"],
				"attacker_bomber_losses": wave["bat_bomber_kills"],
				"defender_fighter_losses": 0,
				"defender_bomber_losses": 0,
				"batteries_before": system.battery_count,
				"batteries_after": system.battery_count,
				"stage_winner": attacker_id,
				"remaining_fighters": att_fighters,
				"remaining_bombers": att_bombers,
			})
		else:
			# Combat!
			# Batteries already fired in pre-combat phase, pass 0
			var combat_result = resolve_combat(
				att_fighters, att_bombers, attacker_id,
				result["remaining_fighters"], result["remaining_bombers"], result["winner"],
				0, att_morale
			)

			result["log"].append("Combat: %d/%d attackers vs %d/%d defenders" % [
				att_fighters, att_bombers,
				result["remaining_fighters"], result["remaining_bombers"]
			])

			if combat_result.battery_kills > 0:
				result["log"].append("Batteries destroyed %d attackers" % combat_result.battery_kills)
				result["battery_kills"] += combat_result.battery_kills

			result["log"].append("Result: %d/%d attacker losses, %d/%d defender losses" % [
				combat_result.attacker_fighter_losses, combat_result.attacker_bomber_losses,
				combat_result.defender_fighter_losses, combat_result.defender_bomber_losses
			])

			# Track losses
			result["attacker_fighter_losses"] += combat_result.attacker_fighter_losses
			result["attacker_bomber_losses"] += combat_result.attacker_bomber_losses
			result["defender_fighter_losses"] += combat_result.defender_fighter_losses
			result["defender_bomber_losses"] += combat_result.defender_bomber_losses

			# Check if conquest occurred
			if combat_result.winner_id != result["winner"] and combat_result.winner_id != -1:
				if result["winner"] != -1:  # Was owned, now conquered
					result["conquest_occurred"] = true

			result["winner"] = combat_result.winner_id
			result["remaining_fighters"] = combat_result.remaining_fighters
			result["remaining_bombers"] = combat_result.remaining_bombers

			# Stage: full combat engagement
			result["stages"].append({
				"attacker_id": attacker_id,
				"attacker_fighters": wave["pre_fighters"],
				"attacker_bombers": wave["pre_bombers"],
				"attacker_fighter_morale": att_morale,
				"defender_id": defender_id_before,
				"defender_fighters": def_fighters_before,
				"defender_bombers": def_bombers_before,
				"battery_fighter_kills": wave["bat_fighter_kills"],
				"battery_bomber_kills": wave["bat_bomber_kills"],
				"attacker_fighter_losses": combat_result.attacker_fighter_losses + wave["bat_fighter_kills"],
				"attacker_bomber_losses": combat_result.attacker_bomber_losses + wave["bat_bomber_kills"],
				"defender_fighter_losses": combat_result.defender_fighter_losses,
				"defender_bomber_losses": combat_result.defender_bomber_losses,
				"batteries_before": system.battery_count,
				"batteries_after": system.battery_count,
				"stage_winner": combat_result.winner_id,
				"remaining_fighters": combat_result.remaining_fighters,
				"remaining_bombers": combat_result.remaining_bombers,
			})

	# Calculate production damage from bomber attack (FUT-12)
	if total_attacker_bombers > 0 and original_owner >= 0:
		# Damage based on ratio of attacker bombers to original defenders
		var original_defenders = system_fighters + system_bombers
		if original_defenders > 0:
			var damage_ratio = float(total_attacker_bombers) / float(original_defenders)
			# Cap at reasonable values (max 3 production damage)
			damage_ratio = min(damage_ratio, 3.0)
			result["production_damage"] = int(ceil(damage_ratio))
			if result["production_damage"] > 0:
				result["log"].append("Bomber attack damages production by %d" % result["production_damage"])

	return result
