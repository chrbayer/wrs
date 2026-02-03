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
	var attacker_losses: int
	var defender_losses: int

	func _init(winner: int, remaining: int, att_losses: int, def_losses: int) -> void:
		winner_id = winner
		remaining_fighters = remaining
		attacker_losses = att_losses
		defender_losses = def_losses


## Resolve combat between attackers and defenders
## Returns CombatResult with outcome
static func resolve_combat(attacker_count: int, attacker_id: int,
						   defender_count: int, defender_id: int) -> CombatResult:
	var attackers = attacker_count
	var defenders = defender_count
	var initial_attackers = attackers
	var initial_defenders = defenders

	var round_count = 0

	while attackers > 0 and defenders > 0 and round_count < MAX_COMBAT_ROUNDS:
		round_count += 1

		# Calculate hits this round
		var attacker_hits = 0
		var defender_hits = 0

		# Attackers fire
		for i in range(attackers):
			if randf() < HIT_CHANCE:
				attacker_hits += 1

		# Defenders fire with bonus
		for i in range(defenders):
			if randf() < HIT_CHANCE * DEFENDER_BONUS:
				defender_hits += 1

		# Apply damage simultaneously
		attackers = max(0, attackers - defender_hits)
		defenders = max(0, defenders - attacker_hits)

	# Determine winner
	var winner: int
	var remaining: int

	if attackers > 0:
		winner = attacker_id
		remaining = attackers
	elif defenders > 0:
		winner = defender_id
		remaining = defenders
	else:
		# Draw - defender wins with 0 ships (system becomes neutral)
		winner = -1
		remaining = 0

	return CombatResult.new(
		winner,
		remaining,
		initial_attackers - attackers,
		initial_defenders - defenders
	)


## Merge multiple fleets arriving at the same time
static func merge_fleets_by_owner(fleets: Array) -> Dictionary:
	var merged: Dictionary = {}  # owner_id -> total_fighters

	for fleet in fleets:
		var owner = fleet.owner_id
		if not merged.has(owner):
			merged[owner] = 0
		merged[owner] += fleet.fighter_count

	return merged


## Resolve combat when multiple fleets arrive at a system
static func resolve_system_combat(system_owner: int, system_fighters: int,
								  arriving_fleets: Dictionary) -> Dictionary:
	# Result contains: winner, remaining_fighters, combat_log
	var result = {
		"winner": system_owner,
		"remaining": system_fighters,
		"log": []
	}

	# If system owner has arriving reinforcements, add them first
	if arriving_fleets.has(system_owner):
		result["remaining"] += arriving_fleets[system_owner]
		result["log"].append("Reinforcements arrived: +%d fighters" % arriving_fleets[system_owner])
		arriving_fleets.erase(system_owner)

	# Process each attacking force
	for attacker_id in arriving_fleets:
		var attacker_count = arriving_fleets[attacker_id]

		if result["remaining"] == 0 and result["winner"] == -1:
			# Empty neutral system - attacker takes it
			result["winner"] = attacker_id
			result["remaining"] = attacker_count
			result["log"].append("Player %d claims empty system with %d fighters" % [attacker_id + 1, attacker_count])
		else:
			# Combat!
			var combat_result = resolve_combat(
				attacker_count, attacker_id,
				result["remaining"], result["winner"]
			)

			result["log"].append("Combat: %d attackers vs %d defenders" % [attacker_count, result["remaining"]])
			result["log"].append("Result: %d attacker losses, %d defender losses" % [combat_result.attacker_losses, combat_result.defender_losses])

			result["winner"] = combat_result.winner_id
			result["remaining"] = combat_result.remaining_fighters

	return result
