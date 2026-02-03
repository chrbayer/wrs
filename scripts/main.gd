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

# Combat reports (player_id -> Array of report strings)
var pending_combat_reports: Dictionary = {}


func _ready() -> void:
	_setup_ui_connections()
	_show_setup_screen()


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
	# Update visibility based on current player
	for system in systems:
		system.update_visuals()
		if system.owner_id == current_player:
			system.show_fighter_count()
		else:
			system.show_hidden_info()


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

	# Show combat report if this player was involved in battles
	if pending_combat_reports.has(current_player) and pending_combat_reports[current_player].size() > 0:
		_show_combat_report()


func _update_ui() -> void:
	turn_label.text = "Turn: %d" % current_turn
	player_label.text = players[current_player].player_name
	player_label.add_theme_color_override("font_color", players[current_player].color)

	# Update star and ship count
	var total_stars = systems.filter(func(s): return s.owner_id == current_player).size()
	var total_ships = _get_player_total_ships(current_player)
	star_count_label.text = "Stars: %d" % total_stars
	ship_count_label.text = "Ships: %d" % total_ships

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
	if game_ended or transition_screen.visible:
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
	if system.owner_id == current_player:
		system_info_label.text = "%s - %d fighters (+%d/turn)" % [
			system.system_name, system.fighter_count, system.production_rate
		]


func _on_system_hover_ended(_system: StarSystem) -> void:
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

	_on_send_slider_changed(send_slider.value)


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
	_update_ui()

	if selected_system:
		system_info_label.text = "%s - Fighters: %d" % [
			selected_system.system_name, selected_system.fighter_count
		]


func _on_send_cancelled() -> void:
	send_panel.visible = false
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
	var full_report = ""
	for report in player_reports:
		full_report += report + "\n\n"
	report_label.text = full_report.strip_edges()
	combat_report_screen.visible = true


func _on_close_report_pressed() -> void:
	combat_report_screen.visible = false
	# Don't clear reports here - other players may still need to see theirs
	# Reports are cleared at the start of _process_turn_end()

	# Check for game over after closing report
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
			var report = "=== %s ===\n" % system.system_name
			report += "Defender: %s (%d fighters)\n" % [_get_owner_name(old_owner), old_fighters]
			for log_entry in result["log"]:
				report += log_entry + "\n"
			report += "Outcome: %s controls with %d fighters" % [_get_owner_name(result["winner"]), result["remaining"]]

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
				pending_combat_reports[player_id].append(report)


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
