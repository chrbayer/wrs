class_name Player
extends RefCounted

## Represents a player in the game

enum AiTactic { NONE, RANDOM, RUSH, FORTRESS, ECONOMY, BOMBER, BALANCED }

var id: int
var player_name: String
var color: Color
var is_eliminated: bool = false
var is_ai: bool = false
var ai_tactic: AiTactic = AiTactic.NONE

# Player colors for up to 4 players
const PLAYER_COLORS = [
	Color(0.2, 0.6, 1.0),   # Blue - Player 1
	Color(1.0, 0.3, 0.3),   # Red - Player 2
	Color(0.3, 1.0, 0.3),   # Green - Player 3
	Color(1.0, 1.0, 0.3),   # Yellow - Player 4
]

const NEUTRAL_COLOR = Color(0.5, 0.5, 0.5)  # Gray for neutral systems


const TACTIC_NAMES = {
	AiTactic.NONE: "",
	AiTactic.RANDOM: "Random",
	AiTactic.RUSH: "Rush",
	AiTactic.FORTRESS: "Fortress",
	AiTactic.ECONOMY: "Economy",
	AiTactic.BOMBER: "Bomber",
	AiTactic.BALANCED: "Balanced",
}

const CONCRETE_TACTICS = [AiTactic.RUSH, AiTactic.FORTRESS, AiTactic.ECONOMY, AiTactic.BOMBER, AiTactic.BALANCED]


func _init(player_id: int, name: String = "", p_is_ai: bool = false, p_ai_tactic: AiTactic = AiTactic.NONE) -> void:
	id = player_id
	is_ai = p_is_ai
	# Resolve RANDOM to a concrete tactic
	if p_ai_tactic == AiTactic.RANDOM:
		ai_tactic = CONCRETE_TACTICS.pick_random()
	else:
		ai_tactic = p_ai_tactic
	if name != "":
		player_name = name
	elif is_ai:
		player_name = "AI %d (%s)" % [player_id + 1, TACTIC_NAMES[ai_tactic]]
	else:
		player_name = "Player %d" % (player_id + 1)
	if player_id >= 0 and player_id < PLAYER_COLORS.size():
		color = PLAYER_COLORS[player_id]
	else:
		color = NEUTRAL_COLOR


static func get_neutral_color() -> Color:
	return NEUTRAL_COLOR


static func get_player_color(player_id: int) -> Color:
	if player_id >= 0 and player_id < PLAYER_COLORS.size():
		return PLAYER_COLORS[player_id]
	return NEUTRAL_COLOR
