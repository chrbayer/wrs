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
@onready var fighter_slider: HSlider = $HUD/SendPanel/VBox/FighterSlider
@onready var bomber_slider: HSlider = $HUD/SendPanel/VBox/BomberSlider
@onready var send_count_label: Label = $HUD/SendPanel/VBox/CountLabel
@onready var send_button: Button = $HUD/SendPanel/VBox/SendButtonContainer/SendButton
@onready var send_all_button: Button = $HUD/SendPanel/VBox/SendButtonContainer/SendAllButton
@onready var cancel_button: Button = $HUD/SendPanel/VBox/CancelButton

# Production action panel
@onready var action_panel: Panel = $HUD/ActionPanel
@onready var produce_fighters_btn: Button = $HUD/ActionPanel/VBox/ProduceFightersBtn
@onready var produce_bombers_btn: Button = $HUD/ActionPanel/VBox/ProduceBombersBtn
@onready var upgrade_btn: Button = $HUD/ActionPanel/VBox/UpgradeBtn
@onready var build_battery_btn: Button = $HUD/ActionPanel/VBox/BuildBatteryBtn
@onready var maintain_battery_btn: CheckButton = $HUD/ActionPanel/VBox/MaintainBatteryBtn
@onready var action_close_btn: Button = $HUD/ActionPanel/VBox/CloseBtn

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
@onready var combat_report_title: Label = $HUD/CombatReportScreen/VBox/TitleLabel
@onready var report_label: Label = $HUD/CombatReportScreen/VBox/ContentBox/ReportLabel
@onready var close_report_button: Button = $HUD/CombatReportScreen/VBox/ContentBox/CloseReportButton

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

		# Calculate travel time for color based on current slider values
		var distance = send_source_system.get_distance_to(send_target_system)
		var fighters = int(fighter_slider.value) if fighter_slider else 0
		var bombers = int(bomber_slider.value) if bomber_slider else 0
		var travel_turns = Fleet.calculate_travel_time(distance, fighters, bombers)

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
	fighter_slider.value_changed.connect(_on_fighter_slider_changed)
	bomber_slider.value_changed.connect(_on_bomber_slider_changed)
	continue_button.pressed.connect(_on_continue_pressed)
	start_game_button.pressed.connect(_on_start_game_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	close_report_button.pressed.connect(_on_close_report_pressed)

	# Action panel connections
	produce_fighters_btn.pressed.connect(_on_produce_fighters_pressed)
	produce_bombers_btn.pressed.connect(_on_produce_bombers_pressed)
	upgrade_btn.pressed.connect(_on_upgrade_pressed)
	build_battery_btn.pressed.connect(_on_build_battery_pressed)
	maintain_battery_btn.pressed.connect(_on_maintain_battery_pressed)
	action_close_btn.pressed.connect(_on_action_close_pressed)


func _show_setup_screen() -> void:
	setup_screen.visible = true
	transition_screen.visible = false
	game_over_screen.visible = false
	combat_report_screen.visible = false
	send_panel.visible = false
	action_panel.visible = false
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
	action_panel.visible = false


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
		var total_fighters = 0
		var total_bombers = 0
		for fleet in my_fleets:
			total_fighters += fleet.fighter_count
			total_bombers += fleet.bomber_count
		var fleet_text = "Fleets: %d (%d fighters" % [my_fleets.size(), total_fighters]
		if total_bombers > 0:
			fleet_text += ", %d bombers" % total_bombers
		fleet_text += ")"
		fleet_info_label.text = fleet_text
	else:
		fleet_info_label.text = "No fleets in transit"

	system_info_label.text = ""


func _get_player_total_ships(player_id: int) -> int:
	var total = 0
	# Ships in owned systems
	for system in systems:
		if system.owner_id == player_id:
			total += system.fighter_count + system.bomber_count
	# Ships in transit
	for fleet in fleets_in_transit:
		if fleet.owner_id == player_id:
			total += fleet.fighter_count + fleet.bomber_count
	return total


func _on_system_clicked(system: StarSystem) -> void:
	if game_ended or transition_screen.visible or combat_report_screen.visible:
		return

	# If we have a source selected and click a different system, that's the target
	if selected_system and selected_system != system:
		if selected_system.owner_id == current_player and selected_system.get_total_ships() > 0:
			_start_send_fleet(selected_system, system)
		return

	# Toggle selection
	if selected_system == system:
		system.set_selected(false)
		selected_system = null
		send_panel.visible = false
		action_panel.visible = false
		show_fleet_arrow = false
		queue_redraw()
	else:
		if selected_system:
			selected_system.set_selected(false)
		selected_system = system
		system.set_selected(true)

		# Show system info
		if system.owner_id == current_player:
			_show_owned_system_info(system)
			_show_action_panel(system)
		else:
			system_info_label.text = "%s - Enemy/Neutral Territory" % system.system_name
			action_panel.visible = false


func _show_owned_system_info(system: StarSystem) -> void:
	var info = "%s - F:%d B:%d (+%d/turn)" % [
		system.system_name, system.fighter_count, system.bomber_count, system.production_rate
	]
	if system.battery_count > 0:
		info += " [%d batteries]" % system.battery_count
	info += "\n%s" % system.get_production_mode_string()
	system_info_label.text = info


func _show_action_panel(system: StarSystem) -> void:
	# Update button states based on system state
	produce_fighters_btn.disabled = (system.production_mode == StarSystem.ProductionMode.FIGHTERS)
	produce_bombers_btn.disabled = (system.production_mode == StarSystem.ProductionMode.BOMBERS)
	upgrade_btn.disabled = (system.production_rate >= ShipTypes.MAX_PRODUCTION_RATE or
						   system.production_mode == StarSystem.ProductionMode.UPGRADE)
	build_battery_btn.disabled = (system.battery_count >= ShipTypes.MAX_BATTERIES or
								 system.production_mode == StarSystem.ProductionMode.BATTERY_BUILD)

	# Maintain battery toggle: disabled only if no batteries
	maintain_battery_btn.disabled = (system.battery_count == 0)
	maintain_battery_btn.button_pressed = system.maintaining_batteries

	# Update button text to show current state
	var rate_suffix = " (50%)" if system.maintaining_batteries else ""
	produce_fighters_btn.text = "Produce Fighters" + rate_suffix
	produce_bombers_btn.text = "Produce Bombers" + rate_suffix
	upgrade_btn.text = "Upgrade Production (%d/%d)" % [system.production_rate, ShipTypes.MAX_PRODUCTION_RATE] + rate_suffix
	build_battery_btn.text = "Build Battery (%d/%d)" % [system.battery_count, ShipTypes.MAX_BATTERIES]

	# Position action panel
	_position_action_panel()
	action_panel.visible = true


func _position_action_panel() -> void:
	if not selected_system:
		return

	var viewport_size = get_viewport().get_visible_rect().size
	var panel_size = action_panel.size
	var margin = 20.0
	var star_margin = 60.0

	var system_pos = selected_system.global_position
	var system_radius = selected_system._get_radius()

	# Try to position to the right of the system
	var panel_pos = Vector2(
		system_pos.x + system_radius + star_margin,
		system_pos.y - panel_size.y / 2.0
	)

	# Clamp to viewport
	panel_pos.x = clamp(panel_pos.x, margin, viewport_size.x - panel_size.x - margin)
	panel_pos.y = clamp(panel_pos.y, margin + 50, viewport_size.y - panel_size.y - margin)

	action_panel.position = panel_pos


func _on_produce_fighters_pressed() -> void:
	if selected_system and selected_system.owner_id == current_player:
		selected_system.set_production_mode(StarSystem.ProductionMode.FIGHTERS)
		_show_owned_system_info(selected_system)
		_show_action_panel(selected_system)


func _on_produce_bombers_pressed() -> void:
	if selected_system and selected_system.owner_id == current_player:
		selected_system.set_production_mode(StarSystem.ProductionMode.BOMBERS)
		_show_owned_system_info(selected_system)
		_show_action_panel(selected_system)


func _on_upgrade_pressed() -> void:
	if selected_system and selected_system.owner_id == current_player:
		selected_system.set_production_mode(StarSystem.ProductionMode.UPGRADE)
		_show_owned_system_info(selected_system)
		_show_action_panel(selected_system)


func _on_build_battery_pressed() -> void:
	if selected_system and selected_system.owner_id == current_player:
		selected_system.set_production_mode(StarSystem.ProductionMode.BATTERY_BUILD)
		_show_owned_system_info(selected_system)
		_show_action_panel(selected_system)


func _on_maintain_battery_pressed() -> void:
	if selected_system and selected_system.owner_id == current_player:
		# Toggle maintaining_batteries
		selected_system.maintaining_batteries = !selected_system.maintaining_batteries
		_show_owned_system_info(selected_system)
		_show_action_panel(selected_system)


func _on_action_close_pressed() -> void:
	action_panel.visible = false


func _on_system_hover_started(system: StarSystem) -> void:
	if combat_report_screen.visible:
		return

	var info_text: String
	if system.owner_id == current_player:
		info_text = "%s - F:%d B:%d (+%d/turn)" % [
			system.system_name, system.fighter_count, system.bomber_count, system.production_rate
		]
		if system.battery_count > 0:
			info_text += " [%d bat]" % system.battery_count
	elif system.owner_id < 0:
		info_text = "%s - Neutral (+%d/turn)" % [
			system.system_name, system.production_rate
		]
		if system.battery_count > 0:
			info_text += " [batteries]"
	else:
		info_text = "%s - %s (+%d/turn)" % [
			system.system_name, players[system.owner_id].player_name, system.production_rate
		]
		if system.battery_count > 0:
			info_text += " [batteries]"

	# Show travel time if another system is selected
	if selected_system and selected_system != system:
		var distance = selected_system.get_distance_to(system)
		# Show both fighter-only and mixed fleet travel times
		var fighter_time = Fleet.calculate_travel_time(distance, 1, 0)
		var bomber_time = Fleet.calculate_travel_time(distance, 1, 1)
		if fighter_time != bomber_time:
			info_text += " [F:%d B:%d turns]" % [fighter_time, bomber_time]
		else:
			info_text += " [%d turns]" % fighter_time

	system_info_label.text = info_text


func _on_system_hover_ended(_system: StarSystem) -> void:
	if combat_report_screen.visible:
		return
	if selected_system and selected_system.owner_id == current_player:
		_show_owned_system_info(selected_system)
	else:
		system_info_label.text = ""


func _start_send_fleet(source: StarSystem, target: StarSystem) -> void:
	send_source_system = source
	send_target_system = target

	# Setup fighter slider
	fighter_slider.max_value = source.fighter_count
	fighter_slider.value = ceili(source.fighter_count / 2.0)

	# Setup bomber slider
	bomber_slider.max_value = source.bomber_count
	bomber_slider.value = ceili(source.bomber_count / 2.0) if source.bomber_count > 0 else 0
	bomber_slider.visible = source.bomber_count > 0

	# Find and update bomber label visibility
	var bomber_label = $HUD/SendPanel/VBox/BomberLabel
	if bomber_label:
		bomber_label.visible = source.bomber_count > 0

	send_panel.visible = true
	action_panel.visible = false
	show_fleet_arrow = true
	queue_redraw()

	# Position panel to not obscure stars or arrow
	_position_send_panel()

	_update_send_count_label()


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


func _on_fighter_slider_changed(_value: float) -> void:
	_update_send_count_label()
	queue_redraw()  # Update arrow color based on fleet composition


func _on_bomber_slider_changed(_value: float) -> void:
	_update_send_count_label()
	queue_redraw()  # Update arrow color based on fleet composition


func _update_send_count_label() -> void:
	var fighters = int(fighter_slider.value)
	var bombers = int(bomber_slider.value) if bomber_slider.visible else 0
	var distance = send_source_system.get_distance_to(send_target_system)
	var travel_time = Fleet.calculate_travel_time(distance, fighters, bombers)

	var text = "Send %d fighters" % fighters
	if bombers > 0:
		text += ", %d bombers" % bombers
	text += " (arrives in %d turns)" % max(1, travel_time)
	send_count_label.text = text


func _on_send_all_confirmed() -> void:
	fighter_slider.value = fighter_slider.max_value
	bomber_slider.value = bomber_slider.max_value
	_on_send_confirmed()


func _on_send_confirmed() -> void:
	var fighters = int(fighter_slider.value)
	var bombers = int(bomber_slider.value) if bomber_slider.visible else 0

	if fighters <= 0 and bombers <= 0:
		send_panel.visible = false
		show_fleet_arrow = false
		queue_redraw()
		return

	# Create fleet
	var distance = send_source_system.get_distance_to(send_target_system)
	var fleet = Fleet.new(
		current_player,
		fighters,
		send_source_system.system_id,
		send_target_system.system_id,
		current_turn,
		distance,
		bombers
	)

	# Remove ships from source
	send_source_system.remove_fighters(fighters)
	send_source_system.remove_bombers(bombers)
	fleets_in_transit.append(fleet)

	# Update UI
	send_panel.visible = false
	show_fleet_arrow = false
	queue_redraw()
	_update_ui()

	# Deselect system if all ships were sent
	if selected_system and selected_system.get_total_ships() == 0:
		selected_system.set_selected(false)
		selected_system = null
		action_panel.visible = false
		system_info_label.text = ""
	elif selected_system:
		_show_owned_system_info(selected_system)
		_show_action_panel(selected_system)


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
	action_panel.visible = false

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

	# Set title to system name with decorative lines
	combat_report_title.text = "━━━ %s ━━━" % report_data["system_name"]

	# Build structured report text
	var report_text = ""
	report_text += "DEFENDER\n"
	report_text += "%s  •  %d F / %d B\n\n" % [
		report_data["defender_name"],
		report_data["defender_fighters"],
		report_data["defender_bombers"]
	]
	report_text += "ATTACKER\n"
	report_text += "%s  •  %d F / %d B\n\n" % [
		report_data["attacker_name"],
		report_data["attacker_fighters"],
		report_data["attacker_bombers"]
	]

	if report_data["battery_kills"] > 0:
		report_text += "BATTERIES\n"
		report_text += "Destroyed %d attackers\n\n" % report_data["battery_kills"]

	report_text += "BATTLE\n"
	report_text += "Attacker losses: %d F / %d B\n" % [
		report_data["attacker_fighter_losses"],
		report_data["attacker_bomber_losses"]
	]
	report_text += "Defender losses: %d F / %d B\n\n" % [
		report_data["defender_fighter_losses"],
		report_data["defender_bomber_losses"]
	]

	if report_data["production_damage"] > 0:
		report_text += "BOMBER DAMAGE\n"
		report_text += "Production reduced by %d\n\n" % report_data["production_damage"]

	if report_data["conquest_occurred"]:
		report_text += "CONQUEST\n"
		report_text += "Production reduced by %d\n\n" % ShipTypes.CONQUEST_PRODUCTION_LOSS

	report_text += "OUTCOME\n"
	report_text += "%s wins with %d F / %d B" % [
		report_data["winner_name"],
		report_data["remaining_fighters"],
		report_data["remaining_bombers"]
	]

	report_label.text = report_text

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
			system.process_production()

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
		var old_bombers = system.bomber_count

		var merged = Combat.merge_fleets_by_owner(fleets_here)
		var result = Combat.resolve_system_combat(system, merged)

		# Apply results to system
		system.owner_id = result["winner"]
		system.fighter_count = result["remaining_fighters"]
		system.bomber_count = result["remaining_bombers"]

		# Apply conquest penalty (FUT-08)
		if result["conquest_occurred"] and result["winner"] >= 0:
			system.apply_conquest_penalty()

		# Apply production damage from bombers (FUT-12)
		if result["production_damage"] > 0:
			system.apply_production_damage(result["production_damage"])

		system.update_visuals()

		# Build combat report data
		if result["log"].size() > 0:
			# Calculate attacker info
			var attacker_id = -1
			var attacker_fighters = 0
			var attacker_bombers = 0
			for aid in merged.keys():
				if aid != old_owner:
					attacker_id = aid
					attacker_fighters = merged[aid]["fighters"]
					attacker_bombers = merged[aid]["bombers"]
					break

			var report_data = {
				"system_name": system.system_name,
				"system_id": system_id,
				"defender_name": _get_owner_name(old_owner),
				"defender_fighters": old_fighters,
				"defender_bombers": old_bombers,
				"defender_fighter_losses": result["defender_fighter_losses"],
				"defender_bomber_losses": result["defender_bomber_losses"],
				"attacker_name": _get_owner_name(attacker_id),
				"attacker_fighters": attacker_fighters,
				"attacker_bombers": attacker_bombers,
				"attacker_fighter_losses": result["attacker_fighter_losses"],
				"attacker_bomber_losses": result["attacker_bomber_losses"],
				"winner_name": _get_owner_name(result["winner"]),
				"remaining_fighters": result["remaining_fighters"],
				"remaining_bombers": result["remaining_bombers"],
				"battery_kills": result["battery_kills"],
				"production_damage": result["production_damage"],
				"conquest_occurred": result["conquest_occurred"]
			}

			# Add report for all involved players (defender + attackers)
			var involved_players: Array[int] = []
			if old_owner >= 0:
				involved_players.append(old_owner)
			for involved_id in merged.keys():
				if involved_id not in involved_players:
					involved_players.append(involved_id)

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
