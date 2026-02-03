extends Node2D

## Main game controller

signal turn_ended
signal game_over(winner_id: int)

# Game configuration
var player_count: int = 2
var system_count: int = 20
var current_turn: int = 1
var current_player: int = 0
var game_started: bool = false
var game_ended: bool = false

# Game state
var players: Array[Player] = []
var systems: Array[StarSystem] = []
var fleets_in_transit: Array[Fleet] = []
var selected_system: StarSystem = null

# Scenes
var star_system_scene: PackedScene = preload("res://scenes/star_system.tscn")

# UI references
@onready var hud: CanvasLayer = $HUD
@onready var systems_container: Node2D = $SystemsContainer
@onready var turn_label: Label = $HUD/TopBar/TurnLabel
@onready var player_label: Label = $HUD/TopBar/PlayerLabel
@onready var star_count_label: Label = $HUD/TopBar/StarCountLabel
@onready var ship_count_label: Label = $HUD/TopBar/ShipCountLabel
@onready var production_label: Label = $HUD/TopBar/ProductionLabel
@onready var end_turn_button: Button = $HUD/TopBar/EndTurnButton
@onready var fleet_info_label: Label = $HUD/BottomBar/FleetInfoLabel
@onready var system_info_label: Label = $HUD/BottomBar/SystemInfoLabel
@onready var send_panel: Panel = $HUD/SendPanel
@onready var send_slider: HSlider = $HUD/SendPanel/VBox/SendSlider
@onready var send_count_label: Label = $HUD/SendPanel/VBox/CountLabel
@onready var send_button: Button = $HUD/SendPanel/VBox/SendButtonContainer/SendButton
@onready var send_all_button: Button = $HUD/SendPanel/VBox/SendButtonContainer/SendAllButton
@onready var cancel_button: Button = $HUD/SendPanel/VBox/CancelButton

# Player transition screen (in separate CanvasLayer to avoid rendering issues)
@onready var transition_screen: Control = $TransitionLayer/TransitionScreen
@onready var transition_label: Label = $TransitionLayer/TransitionScreen/TransitionLabel
@onready var continue_button: Button = $TransitionLayer/TransitionScreen/ContinueButton

# Setup screen
@onready var setup_screen: Panel = $HUD/SetupScreen
@onready var player_count_option: OptionButton = $HUD/SetupScreen/VBox/PlayerCountOption
@onready var start_game_button: Button = $HUD/SetupScreen/VBox/StartGameButton

# Combat report screen
@onready var combat_report_screen: Panel = $HUD/CombatReportScreen
@onready var report_label: Label = $HUD/CombatReportScreen/VBox/ScrollContainer/ReportLabel
@onready var close_report_button: Button = $HUD/CombatReportScreen/VBox/CloseReportButton

# Game over screen
@onready var game_over_screen: Panel = $HUD/GameOverScreen
@onready var winner_label: Label = $HUD/GameOverScreen/VBox/WinnerLabel
@onready var restart_button: Button = $HUD/GameOverScreen/VBox/RestartButton

# Send fleet state
var send_source_system: StarSystem = null
var send_target_system: StarSystem = null
var show_fleet_arrow: bool = false

# Arrow drawing constants
const ARROW_WIDTH: float = 3.0
const ARROW_HEAD_SIZE: float = 15.0
# Distinct colors for each travel time
const ARROW_COLORS: Array[Color] = [
	Color(0.0, 1.0, 1.0, 0.9),   # 1 turn: Cyan
	Color(0.0, 1.0, 0.3, 0.9),   # 2 turns: Green
	Color(1.0, 1.0, 0.0, 0.9),   # 3 turns: Yellow
	Color(1.0, 0.6, 0.0, 0.9),   # 4 turns: Orange
	Color(1.0, 0.2, 0.0, 0.9),   # 5+ turns: Red
]

# Combat reports (player_id -> Array of {report: String, system_id: int})
var pending_combat_reports: Dictionary = {}
var current_report_index: int = 0
var combat_report_system: StarSystem = null


func _ready() -> void:
	_setup_ui_connections()
	_show_setup_screen()


func _draw() -> void:
	if show_fleet_arrow and send_source_system and send_target_system:
		var start_pos = send_source_system.global_position
		var end_pos = send_target_system.global_position

		# Calculate travel time for color
		var distance = send_source_system.get_distance_to(send_target_system)
		var travel_turns = max(1, ceili(distance / Fleet.TRAVEL_SPEED))

		# Determine arrow color based on travel time
		# 1=cyan, 2=green, 3=yellow, 4=orange, 5+=red
		var color_index = min(travel_turns - 1, ARROW_COLORS.size() - 1)
		var arrow_color = ARROW_COLORS[color_index]

		# Calculate direction and shorten arrow to not overlap with stars
		var direction = (end_pos - start_pos).normalized()
		var source_radius = send_source_system._get_radius() + 10
		var target_radius = send_target_system._get_radius() + 10

		var arrow_start = start_pos + direction * source_radius
		var arrow_end = end_pos - direction * target_radius

		# Draw line
		draw_line(arrow_start, arrow_end, arrow_color, ARROW_WIDTH)

		# Draw arrow head
		var arrow_dir = (arrow_end - arrow_start).normalized()
		var perpendicular = Vector2(-arrow_dir.y, arrow_dir.x)
		var head_base = arrow_end - arrow_dir * ARROW_HEAD_SIZE
		var head_left = head_base + perpendicular * ARROW_HEAD_SIZE * 0.5
		var head_right = head_base - perpendicular * ARROW_HEAD_SIZE * 0.5

		var head_points = PackedVector2Array([arrow_end, head_left, head_right])
		draw_colored_polygon(head_points, arrow_color)


func _setup_ui_connections() -> void:
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	send_button.pressed.connect(_on_send_confirmed)
	send_all_button.pressed.connect(_on_send_all_confirmed)
	cancel_button.pressed.connect(_on_send_cancelled)
	send_slider.value_changed.connect(_on_send_slider_changed)
	continue_button.pressed.connect(_on_continue_pressed)
	start_game_button.pressed.connect(_on_start_game_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	close_report_button.pressed.connect(_on_close_report_pressed)


func _show_setup_screen() -> void:
	setup_screen.visible = true
	transition_screen.visible = false
	game_over_screen.visible = false
	combat_report_screen.visible = false
	send_panel.visible = false
	# Hide game UI during setup
	$HUD/TopBar.visible = false
	$HUD/BottomBar.visible = false

	# Setup player count options
	player_count_option.clear()
	for i in range(2, 5):
		player_count_option.add_item("%d Players" % i, i)


func _on_start_game_pressed() -> void:
	player_count = player_count_option.get_selected_id()
	system_count = 15 + (player_count * 5)  # Scale with players
	setup_screen.visible = false
	# Show game UI
	$HUD/TopBar.visible = true
	$HUD/BottomBar.visible = true
	_start_game()


func _start_game() -> void:
	# Clear previous game
	for system in systems:
		system.queue_free()
	systems.clear()
	fleets_in_transit.clear()
	players.clear()

	# Initialize players
	for i in range(player_count):
		players.append(Player.new(i))

	# Generate universe
	_generate_universe()

	# Start game
	current_turn = 1
	current_player = 0
	game_started = true
	game_ended = false

	# Show transition to first player
	_show_player_transition()


func _generate_universe() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	# Fallback to project settings if viewport not ready
	if viewport_size.x <= 0 or viewport_size.y <= 0:
		viewport_size = Vector2(
			ProjectSettings.get_setting("display/window/size/viewport_width"),
			ProjectSettings.get_setting("display/window/size/viewport_height")
		)
	var bounds = Rect2(100, 100, viewport_size.x - 200, viewport_size.y - 300)

	var gen_result = UniverseGenerator.generate_system_positions(
		system_count, bounds, player_count
	)

	var positions: Array = gen_result["positions"]
	var player_starts: Array = gen_result["player_starts"]

	# Create systems
	for i in range(positions.size()):
		var system = star_system_scene.instantiate() as StarSystem
		system.system_id = i
		system.system_name = UniverseGenerator.generate_star_name()
		system.position = positions[i]

		# Check if this is a player start
		var player_start_idx = player_starts.find(i)
		if player_start_idx >= 0:
			system.owner_id = player_start_idx
			system.fighter_count = UniverseGenerator.generate_player_start_fighters()
			system.production_rate = 3  # Standard production for home systems
		else:
			system.owner_id = -1  # Neutral
			system.fighter_count = UniverseGenerator.generate_initial_fighters()
			system.production_rate = UniverseGenerator.generate_production_rate()

		# Connect signals
		system.system_clicked.connect(_on_system_clicked)
		system.system_hover_started.connect(_on_system_hover_started)
		system.system_hover_ended.connect(_on_system_hover_ended)

		systems_container.add_child(system)
		systems.append(system)

	_update_fog_of_war()


func _update_fog_of_war() -> void:
	# First, determine which systems are visible to current player
	var owned_systems: Array[StarSystem] = []
	for system in systems:
		if system.owner_id == current_player:
			owned_systems.append(system)

	# Update visibility based on current player
	for system in systems:
		var system_visible = false

		# Check if system is owned by current player
		if system.owner_id == current_player:
			system_visible = true
		else:
			# Check if any owned system is within visibility range
			for owned in owned_systems:
				if system.global_position.distance_to(owned.global_position) <= UniverseGenerator.MAX_SYSTEM_DISTANCE:
					system_visible = true
					break

		if system_visible:
			system.show_system()
			system.update_visuals()
			if system.owner_id == current_player:
				system.show_fighter_count()
			else:
				system.show_hidden_info()
		else:
			system.hide_system()


func _show_player_transition() -> void:
	transition_screen.visible = true
	transition_label.text = "Player %d's Turn\n\n%s\n\nClick Continue when ready" % [
		current_player + 1,
		players[current_player].player_name
	]

	# Deselect any selected system
	if selected_system:
		selected_system.set_selected(false)
		selected_system = null
	send_panel.visible = false


func _on_continue_pressed() -> void:
	transition_screen.visible = false
	_update_fog_of_war()
	_update_ui()

	# Show combat reports if this player was involved in battles
	current_report_index = 0
	if pending_combat_reports.has(current_player) and pending_combat_reports[current_player].size() > 0:
		_show_combat_report()


func _update_ui() -> void:
	turn_label.text = "Turn: %d" % current_turn
	player_label.text = players[current_player].player_name
	player_label.add_theme_color_override("font_color", players[current_player].color)

	# Update star, ship, and production count
	var owned_systems = systems.filter(func(s): return s.owner_id == current_player)
	var total_stars = owned_systems.size()
	var total_ships = _get_player_total_ships(current_player)
	var total_production = 0
	for system in owned_systems:
		total_production += system.production_rate
	star_count_label.text = "Stars: %d" % total_stars
	ship_count_label.text = "Ships: %d" % total_ships
	production_label.text = "Production: +%d" % total_production

	# Update fleet info
	var my_fleets = fleets_in_transit.filter(func(f): return f.owner_id == current_player)
	if my_fleets.size() > 0:
		var fleet_text = "Fleets in transit: %d" % my_fleets.size()
		fleet_info_label.text = fleet_text
	else:
		fleet_info_label.text = "No fleets in transit"

	system_info_label.text = ""


func _get_player_total_ships(player_id: int) -> int:
	var total = 0
	# Ships in owned systems
	for system in systems:
		if system.owner_id == player_id:
			total += system.fighter_count
	# Ships in transit
	for fleet in fleets_in_transit:
		if fleet.owner_id == player_id:
			total += fleet.fighter_count
	return total


func _on_system_clicked(system: StarSystem) -> void:
	if game_ended or transition_screen.visible or combat_report_screen.visible:
		return

	# If we have a source selected and click a different system, that's the target
	if selected_system and selected_system != system:
		if selected_system.owner_id == current_player and selected_system.fighter_count > 0:
			_start_send_fleet(selected_system, system)
		return

	# Toggle selection
	if selected_system == system:
		system.set_selected(false)
		selected_system = null
		send_panel.visible = false
		show_fleet_arrow = false
		queue_redraw()
	else:
		if selected_system:
			selected_system.set_selected(false)
		selected_system = system
		system.set_selected(true)

		# Show system info
		if system.owner_id == current_player:
			system_info_label.text = "%s - Fighters: %d, Production: +%d/turn" % [
				system.system_name, system.fighter_count, system.production_rate
			]
		else:
			system_info_label.text = "%s - Enemy/Neutral Territory" % system.system_name


func _on_system_hover_started(system: StarSystem) -> void:
	if combat_report_screen.visible:
		return
	if system.owner_id == current_player:
		system_info_label.text = "%s - %d fighters (+%d/turn)" % [
			system.system_name, system.fighter_count, system.production_rate
		]
	elif system.owner_id < 0:
		system_info_label.text = "%s - Neutral (+%d/turn)" % [
			system.system_name, system.production_rate
		]
	else:
		system_info_label.text = "%s - %s (+%d/turn)" % [
			system.system_name, players[system.owner_id].player_name, system.production_rate
		]


func _on_system_hover_ended(_system: StarSystem) -> void:
	if combat_report_screen.visible:
		return
	if selected_system and selected_system.owner_id == current_player:
		system_info_label.text = "%s - Fighters: %d" % [
			selected_system.system_name, selected_system.fighter_count
		]
	else:
		system_info_label.text = ""


func _start_send_fleet(source: StarSystem, target: StarSystem) -> void:
	send_source_system = source
	send_target_system = target

	send_slider.max_value = source.fighter_count
	send_slider.value = ceili(source.fighter_count / 2.0)
	send_panel.visible = true
	show_fleet_arrow = true
	queue_redraw()

	# Position panel to not obscure stars or arrow
	_position_send_panel()

	_on_send_slider_changed(send_slider.value)


func _position_send_panel() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	var panel_size = send_panel.size
	var margin = 20.0
	var star_margin = 60.0  # Distance from star center

	var source_pos = send_source_system.global_position
	var target_pos = send_target_system.global_position
	var source_radius = send_source_system._get_radius()

	# Direction from source to target (we want to place panel away from this direction)
	var to_target = (target_pos - source_pos).normalized()

	# Try positions around the source star (away from target direction)
	var positions = []

	# Perpendicular directions (left and right of the arrow)
	var perp = Vector2(-to_target.y, to_target.x)

	# Position candidates: perpendicular left, perpendicular right, behind source
	var offsets = [
		perp * (source_radius + star_margin + panel_size.x / 2),  # Left of arrow
		-perp * (source_radius + star_margin + panel_size.x / 2),  # Right of arrow
		-to_target * (source_radius + star_margin + panel_size.y / 2),  # Behind source
	]

	for offset in offsets:
		var panel_center = source_pos + offset
		var panel_pos = panel_center - panel_size / 2.0

		# Clamp to viewport bounds
		panel_pos.x = clamp(panel_pos.x, margin, viewport_size.x - panel_size.x - margin)
		panel_pos.y = clamp(panel_pos.y, margin + 50, viewport_size.y - panel_size.y - margin)  # +50 for top bar

		positions.append(panel_pos)

	# Find position that doesn't overlap with target star or arrow
	var best_pos = positions[0]
	var best_score = -INF

	for pos in positions:
		var panel_rect = Rect2(pos, panel_size)
		var panel_center = pos + panel_size / 2.0

		# Check distance to target star
		var dist_target = panel_center.distance_to(target_pos)

		# Check distance to arrow line
		var line_dir = to_target
		var to_panel = panel_center - source_pos
		var projection = to_panel.dot(line_dir)
		var closest_on_line = source_pos + line_dir * clamp(projection, 0, source_pos.distance_to(target_pos))
		var dist_line = panel_center.distance_to(closest_on_line)

		# Score: prefer positions far from target and arrow, but close to source
		var dist_source = panel_center.distance_to(source_pos)
		var score = min(dist_target, dist_line) - dist_source * 0.3

		if score > best_score:
			best_score = score
			best_pos = pos

	send_panel.position = best_pos


func _on_send_slider_changed(value: float) -> void:
	var count = int(value)
	var distance = send_source_system.get_distance_to(send_target_system)
	var travel_time = ceili(distance / Fleet.TRAVEL_SPEED)
	send_count_label.text = "Send %d fighters (arrives in %d turns)" % [count, max(1, travel_time)]


func _on_send_all_confirmed() -> void:
	send_slider.value = send_slider.max_value
	_on_send_confirmed()


func _on_send_confirmed() -> void:
	var count = int(send_slider.value)
	if count <= 0:
		send_panel.visible = false
		show_fleet_arrow = false
		queue_redraw()
		return

	# Create fleet
	var distance = send_source_system.get_distance_to(send_target_system)
	var fleet = Fleet.new(
		current_player,
		count,
		send_source_system.system_id,
		send_target_system.system_id,
		current_turn,
		distance
	)

	# Remove fighters from source
	send_source_system.remove_fighters(count)
	fleets_in_transit.append(fleet)

	# Update UI
	send_panel.visible = false
	show_fleet_arrow = false
	queue_redraw()
	_update_ui()

	# Deselect system if all fighters were sent
	if selected_system and selected_system.fighter_count == 0:
		selected_system.set_selected(false)
		selected_system = null
		system_info_label.text = ""
	elif selected_system:
		system_info_label.text = "%s - Fighters: %d" % [
			selected_system.system_name, selected_system.fighter_count
		]


func _on_send_cancelled() -> void:
	send_panel.visible = false
	show_fleet_arrow = false
	queue_redraw()
	send_source_system = null
	send_target_system = null


func _on_end_turn_pressed() -> void:
	# Deselect
	if selected_system:
		selected_system.set_selected(false)
		selected_system = null
	send_panel.visible = false

	# Move to next player
	current_player += 1

	if current_player >= player_count:
		# All players have taken their turn, process end of round
		_process_turn_end()
		current_player = 0
		current_turn += 1

	# Check for game over
	if _check_victory():
		return

	# Show transition to next player (combat report shown after transition)
	_show_player_transition()


func _show_combat_report() -> void:
	if not pending_combat_reports.has(current_player):
		return
	var player_reports = pending_combat_reports[current_player]
	if current_report_index >= player_reports.size():
		return

	var report_data = player_reports[current_report_index]
	report_label.text = report_data["report"]

	# Highlight the system this report is about
	if combat_report_system:
		combat_report_system.set_selected(false)
	combat_report_system = systems[report_data["system_id"]]
	combat_report_system.set_selected(true)

	# Position the panel near the system
	_position_combat_report_panel()

	combat_report_screen.visible = true
	end_turn_button.disabled = true


func _position_combat_report_panel() -> void:
	if not combat_report_system:
		return

	var viewport_size = get_viewport().get_visible_rect().size
	var panel_size = combat_report_screen.size
	var margin = 20.0
	var star_margin = 60.0

	var system_pos = combat_report_system.global_position
	var system_radius = combat_report_system._get_radius()

	# Try positions around the system (right, left, below, above)
	var offsets = [
		Vector2(system_radius + star_margin + panel_size.x / 2, 0),  # Right
		Vector2(-(system_radius + star_margin + panel_size.x / 2), 0),  # Left
		Vector2(0, system_radius + star_margin + panel_size.y / 2),  # Below
		Vector2(0, -(system_radius + star_margin + panel_size.y / 2)),  # Above
	]

	var best_pos = Vector2.ZERO
	var best_score = -INF

	for offset in offsets:
		var panel_center = system_pos + offset
		var panel_pos = panel_center - panel_size / 2.0

		# Clamp to viewport bounds
		panel_pos.x = clamp(panel_pos.x, margin, viewport_size.x - panel_size.x - margin)
		panel_pos.y = clamp(panel_pos.y, margin + 50, viewport_size.y - panel_size.y - margin)

		# Score: prefer positions that keep panel fully visible
		var clamped_center = panel_pos + panel_size / 2.0
		var dist_from_ideal = clamped_center.distance_to(panel_center)
		var score = -dist_from_ideal  # Less clamping = better

		if score > best_score:
			best_score = score
			best_pos = panel_pos

	combat_report_screen.position = best_pos


func _on_close_report_pressed() -> void:
	# Deselect the highlighted system
	if combat_report_system:
		combat_report_system.set_selected(false)
		combat_report_system = null

	# Move to next report
	current_report_index += 1

	# Check if there are more reports for this player
	if pending_combat_reports.has(current_player):
		var player_reports = pending_combat_reports[current_player]
		if current_report_index < player_reports.size():
			_show_combat_report()
			return

	# No more reports - close and re-enable UI
	combat_report_screen.visible = false
	end_turn_button.disabled = false
	current_report_index = 0

	# Check for game over after closing all reports
	_check_victory()


func _process_turn_end() -> void:
	# Clear previous combat reports
	pending_combat_reports.clear()

	# 1. Production in owned systems
	for system in systems:
		if system.owner_id >= 0:
			system.produce_fighters()

	# 2. Process arriving fleets
	var arriving_fleets: Dictionary = {}  # system_id -> Array[Fleet]
	var remaining_fleets: Array[Fleet] = []

	for fleet in fleets_in_transit:
		if fleet.has_arrived(current_turn + 1):  # +1 because turn increments after this
			var target_id = fleet.target_system_id
			if not arriving_fleets.has(target_id):
				arriving_fleets[target_id] = []
			arriving_fleets[target_id].append(fleet)
		else:
			remaining_fleets.append(fleet)

	fleets_in_transit = remaining_fleets

	# 3. Resolve combats
	for system_id in arriving_fleets:
		var system = systems[system_id]
		var fleets_here = arriving_fleets[system_id]
		var old_owner = system.owner_id
		var old_fighters = system.fighter_count

		var merged = Combat.merge_fleets_by_owner(fleets_here)
		var result = Combat.resolve_system_combat(
			system.owner_id, system.fighter_count, merged
		)

		system.owner_id = result["winner"]
		system.fighter_count = result["remaining"]
		system.update_visuals()

		# Build combat report
		if result["log"].size() > 0:
			var report_text = "=== %s ===\n" % system.system_name
			report_text += "Defender: %s (%d fighters)\n" % [_get_owner_name(old_owner), old_fighters]
			for log_entry in result["log"]:
				report_text += log_entry + "\n"
			report_text += "Outcome: %s controls with %d fighters" % [_get_owner_name(result["winner"]), result["remaining"]]

			var report_data = {
				"report": report_text,
				"system_id": system_id
			}

			# Add report for all involved players (defender + attackers)
			var involved_players: Array[int] = []
			if old_owner >= 0:
				involved_players.append(old_owner)
			for attacker_id in merged.keys():
				if attacker_id not in involved_players:
					involved_players.append(attacker_id)

			for player_id in involved_players:
				if not pending_combat_reports.has(player_id):
					pending_combat_reports[player_id] = []
				pending_combat_reports[player_id].append(report_data)


func _get_owner_name(owner_id: int) -> String:
	if owner_id < 0:
		return "Neutral"
	return players[owner_id].player_name


func _check_victory() -> bool:
	# Count systems per player
	var system_counts: Dictionary = {}
	for i in range(player_count):
		system_counts[i] = 0

	for system in systems:
		if system.owner_id >= 0:
			system_counts[system.owner_id] += 1

	# Check if only one player has systems
	var players_with_systems: Array[int] = []
	for player_id in system_counts:
		if system_counts[player_id] > 0:
			players_with_systems.append(player_id)

	# Also check if players have fleets
	for fleet in fleets_in_transit:
		if fleet.owner_id not in players_with_systems:
			players_with_systems.append(fleet.owner_id)

	if players_with_systems.size() == 1:
		_show_game_over(players_with_systems[0])
		return true

	return false


func _show_game_over(winner_id: int) -> void:
	game_ended = true
	game_over_screen.visible = true
	winner_label.text = "%s Wins!" % players[winner_id].player_name
	winner_label.add_theme_color_override("font_color", players[winner_id].color)


func _on_restart_pressed() -> void:
	game_over_screen.visible = false
	_show_setup_screen()
