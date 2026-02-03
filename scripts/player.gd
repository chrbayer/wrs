class_name Player
extends RefCounted

## Represents a player in the game

var id: int
var player_name: String
var color: Color
var is_eliminated: bool = false

# Player colors for up to 4 players
const PLAYER_COLORS = [
	Color(0.2, 0.6, 1.0),   # Blue - Player 1
	Color(1.0, 0.3, 0.3),   # Red - Player 2
	Color(0.3, 1.0, 0.3),   # Green - Player 3
	Color(1.0, 1.0, 0.3),   # Yellow - Player 4
]

const NEUTRAL_COLOR = Color(0.5, 0.5, 0.5)  # Gray for neutral systems


func _init(player_id: int, name: String = "") -> void:
	id = player_id
	player_name = name if name != "" else "Player %d" % (player_id + 1)
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
