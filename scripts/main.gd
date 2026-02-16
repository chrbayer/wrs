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
var ai_paused: bool = false

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
@onready var send_max_button: Button = $HUD/SendPanel/VBox/SendButtonContainer/SendMaxButton
@onready var send_all_button: Button = $HUD/SendPanel/VBox/SendButtonContainer/SendAllButton
@onready var cancel_button: Button = $HUD/SendPanel/VBox/CancelButton

# Production action panel
@onready var action_panel: Panel = $HUD/ActionPanel
@onready var produce_fighters_btn: Button = $HUD/ActionPanel/VBox/ProduceFightersBtn
@onready var produce_bombers_btn: Button = $HUD/ActionPanel/VBox/ProduceBombersBtn
@onready var upgrade_btn: Button = $HUD/ActionPanel/VBox/UpgradeBtn
@onready var build_battery_btn: Button = $HUD/ActionPanel/VBox/BuildBatteryBtn
@onready var activate_shield_btn: Button = $HUD/ActionPanel/VBox/ActivateShieldBtn
@onready var action_close_btn: Button = $HUD/ActionPanel/VBox/CloseBtn

# Station UI
@onready var build_station_btn: Button = $HUD/TopBar/BuildStationButton
@onready var station_action_panel: Panel = $HUD/StationActionPanel
@onready var station_battery_btn: Button = $HUD/StationActionPanel/VBox/BuildBatteryBtn
@onready var station_shield_btn: Button = $HUD/StationActionPanel/VBox/ActivateShieldBtn
@onready var station_close_btn: Button = $HUD/StationActionPanel/VBox/CloseBtn
@onready var station_title_label: Label = $HUD/StationActionPanel/VBox/TitleLabel

# Player transition screen (in separate CanvasLayer to avoid rendering issues)
@onready var transition_screen: Control = $TransitionLayer/TransitionScreen
@onready var transition_label: Label = $TransitionLayer/TransitionScreen/TransitionLabel
@onready var continue_button: Button = $TransitionLayer/TransitionScreen/ContinueButton

# Setup screen
@onready var setup_screen: Panel = $HUD/SetupScreen
@onready var player_count_option: OptionButton = $HUD/SetupScreen/VBox/PlayerCountOption
@onready var player_config_container: VBoxContainer = $HUD/SetupScreen/VBox/PlayerConfigContainer
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

# Fog of war memory (player_id -> {system_id -> {owner_id, fighter_count, bomber_count, battery_count, has_batteries}})
var system_memory: Dictionary = {}

# Remember last setup for restart
var last_setup_player_count: int = 0
var last_setup_configs: Array = []  # [{is_ai, tactic}, ...]

# Cached visibility overlay texture
var visibility_texture: ImageTexture = null
const VISIBILITY_COLOR = Color(0.3, 0.6, 1.0, 0.08)

# Cached enemy scan zone texture (for station placement mode)
var enemy_scan_texture: ImageTexture = null
const ENEMY_SCAN_COLOR = Color(1.0, 0.2, 0.2, 0.10)

# Shield lines (FUT-19)
var shield_lines: Array = []           # [{system_a: int, system_b: int, owner_id: int}]
var shield_activations: Array = []     # [{system_a: int, system_b: int, owner_id: int, progress: int}]
var shield_select_source: StarSystem = null  # Partner selection mode
var shield_line_memory: Dictionary = {} # player_id -> Array of {system_a, system_b, owner_id}

# Space stations (FUT-20)
const STATION_ID_OFFSET: int = 1000
const STATION_CLICK_RADIUS: float = 20.0
const STATION_DIAMOND_SIZE: float = 12.0
var stations: Array = []               # Array of station Dictionaries
var station_placement_mode: bool = false
var next_station_id: int = 0
var selected_station_idx: int = -1     # Index into stations, -1 = none
var send_source_station_idx: int = -1  # Station as fleet source
var send_target_station_idx: int = -1  # Station as fleet target

# AI turn delay timer
var ai_delay_timer: Timer = null
const AI_TURN_DELAY: float = 0.3


func _ready() -> void:
	_setup_ui_connections()
	_show_setup_screen()


func _draw() -> void:
	# Draw cached visibility overlay texture
	if visibility_texture and not transition_screen.visible and not setup_screen.visible and not game_over_screen.visible:
		draw_texture(visibility_texture, Vector2.ZERO)

	# Draw shield lines after visibility overlay, before fleet arrow
	if game_started and not setup_screen.visible:
		_draw_shield_lines()
		_draw_stations()

	# Draw enemy scan zone overlay when in station placement mode
	if station_placement_mode and enemy_scan_texture:
		draw_texture(enemy_scan_texture, Vector2.ZERO)

	if show_fleet_arrow and (_get_send_source_pos() != Vector2.ZERO) and (_get_send_target_pos() != Vector2.ZERO):
		var start_pos = _get_send_source_pos()
		var end_pos = _get_send_target_pos()

		# Calculate travel time for color based on current slider values
		var distance = start_pos.distance_to(end_pos)
		var fighters = int(fighter_slider.value) if fighter_slider else 0
		var bombers = int(bomber_slider.value) if bomber_slider else 0
		var travel_turns = Fleet.calculate_travel_time(distance, fighters, bombers)

		# Determine arrow color based on travel time
		# 1=cyan, 2=green, 3=yellow, 4=orange, 5+=red
		var color_index = min(travel_turns - 1, ARROW_COLORS.size() - 1)
		var arrow_color = ARROW_COLORS[color_index]

		# Calculate direction and shorten arrow to not overlap with stars/stations
		var direction = (end_pos - start_pos).normalized()
		var source_radius: float = STATION_DIAMOND_SIZE + 5
		if send_source_system:
			source_radius = send_source_system._get_radius() + 10
		var target_radius: float = STATION_DIAMOND_SIZE + 5
		if send_target_system:
			target_radius = send_target_system._get_radius() + 10

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
	send_max_button.pressed.connect(_on_send_max_confirmed)
	send_all_button.pressed.connect(_on_send_all_confirmed)
	cancel_button.pressed.connect(_on_send_cancelled)
	fighter_slider.value_changed.connect(_on_fighter_slider_changed)
	bomber_slider.value_changed.connect(_on_bomber_slider_changed)
	continue_button.pressed.connect(_on_continue_pressed)
	player_count_option.item_selected.connect(_on_player_count_changed)
	start_game_button.pressed.connect(_on_start_game_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	close_report_button.pressed.connect(_on_close_report_pressed)

	# Action panel connections
	produce_fighters_btn.pressed.connect(_on_produce_fighters_pressed)
	produce_bombers_btn.pressed.connect(_on_produce_bombers_pressed)
	upgrade_btn.pressed.connect(_on_upgrade_pressed)
	build_battery_btn.pressed.connect(_on_build_battery_pressed)
	activate_shield_btn.pressed.connect(_on_activate_shield_pressed)
	action_close_btn.pressed.connect(_on_action_close_pressed)

	# Station UI connections
	build_station_btn.pressed.connect(_on_build_station_pressed)
	station_battery_btn.pressed.connect(_on_station_battery_pressed)
	station_shield_btn.pressed.connect(_on_station_shield_pressed)
	station_close_btn.pressed.connect(_on_station_close_pressed)

	# Create AI delay timer
	ai_delay_timer = Timer.new()
	ai_delay_timer.one_shot = true
	ai_delay_timer.wait_time = AI_TURN_DELAY
	add_child(ai_delay_timer)


func _show_setup_screen() -> void:
	setup_screen.visible = true
	transition_screen.visible = false
	game_over_screen.visible = false
	combat_report_screen.visible = false
	send_panel.visible = false
	action_panel.visible = false
	station_action_panel.visible = false
	# Hide game UI during setup
	$HUD/TopBar.visible = false
	$HUD/BottomBar.visible = false

	# Setup player count options
	player_count_option.clear()
	for i in range(2, 5):
		player_count_option.add_item("%d Players" % i, i)

	# Restore previous settings or use defaults
	var count = last_setup_player_count if last_setup_player_count > 0 else 2
	# Select the right player count in the dropdown (index = count - 2)
	player_count_option.select(count - 2)
	_rebuild_player_config(count)
	_resize_setup_screen()


func _on_player_count_changed(_index: int) -> void:
	var count = player_count_option.get_selected_id()
	_rebuild_player_config(count)
	_resize_setup_screen()


func _resize_setup_screen() -> void:
	var vbox = setup_screen.get_node("VBox")
	var padding = Vector2(60, 60)  # 30px on each side
	var needed = vbox.get_combined_minimum_size() + padding
	needed.x = max(needed.x, 560.0)
	setup_screen.offset_left = -needed.x / 2.0
	setup_screen.offset_right = needed.x / 2.0
	setup_screen.offset_top = -needed.y / 2.0
	setup_screen.offset_bottom = needed.y / 2.0


func _rebuild_player_config(count: int) -> void:
	# Clear existing config rows (free immediately to avoid stale children)
	for child in player_config_container.get_children():
		player_config_container.remove_child(child)
		child.queue_free()

	for i in range(count):
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)

		# Color indicator
		var color_rect = ColorRect.new()
		color_rect.custom_minimum_size = Vector2(24, 24)
		color_rect.color = Player.PLAYER_COLORS[i]
		row.add_child(color_rect)

		# Player label
		var label = Label.new()
		label.text = "Player %d:" % (i + 1)
		label.add_theme_font_size_override("font_size", 20)
		label.custom_minimum_size = Vector2(100, 0)
		row.add_child(label)

		# Human/AI option
		var type_option = OptionButton.new()
		type_option.add_theme_font_size_override("font_size", 20)
		type_option.add_item("Human", 0)
		type_option.add_item("AI", 1)
		type_option.name = "TypeOption_%d" % i
		type_option.custom_minimum_size = Vector2(100, 0)
		row.add_child(type_option)

		# Tactic option (only visible when AI is selected)
		var tactic_option = OptionButton.new()
		tactic_option.add_theme_font_size_override("font_size", 20)
		tactic_option.add_item("Random", Player.AiTactic.RANDOM)
		tactic_option.add_item("Rush", Player.AiTactic.RUSH)
		tactic_option.add_item("Fortress", Player.AiTactic.FORTRESS)
		tactic_option.add_item("Economy", Player.AiTactic.ECONOMY)
		tactic_option.add_item("Bomber", Player.AiTactic.BOMBER)
		tactic_option.add_item("Balanced", Player.AiTactic.BALANCED)
		tactic_option.name = "TacticOption_%d" % i
		tactic_option.custom_minimum_size = Vector2(120, 0)
		tactic_option.visible = false
		row.add_child(tactic_option)

		# Restore previous settings if available
		if i < last_setup_configs.size():
			var cfg = last_setup_configs[i]
			if cfg["is_ai"]:
				type_option.select(1)  # AI
				tactic_option.visible = true
				# Find tactic index by id
				for idx in range(tactic_option.item_count):
					if tactic_option.get_item_id(idx) == cfg["tactic"]:
						tactic_option.select(idx)
						break

		# Connect type change to show/hide tactic
		type_option.item_selected.connect(_on_player_type_changed.bind(i))

		player_config_container.add_child(row)


func _on_player_type_changed(_index: int, player_idx: int) -> void:
	var row = player_config_container.get_child(player_idx)
	if not row:
		return
	var type_option = row.get_node("TypeOption_%d" % player_idx) as OptionButton
	var tactic_option = row.get_node("TacticOption_%d" % player_idx) as OptionButton
	if type_option and tactic_option:
		tactic_option.visible = (type_option.get_selected_id() == 1)


func _on_start_game_pressed() -> void:
	player_count = player_count_option.get_selected_id()
	system_count = 15 + (player_count * 5)  # Scale with players

	# Read player configs from UI
	var player_configs = []
	for i in range(player_count):
		var row = player_config_container.get_child(i)
		var type_option = row.get_node("TypeOption_%d" % i) as OptionButton
		var tactic_option = row.get_node("TacticOption_%d" % i) as OptionButton
		var is_ai = type_option.get_selected_id() == 1
		var tactic = tactic_option.get_selected_id() if is_ai else Player.AiTactic.NONE
		player_configs.append({"is_ai": is_ai, "tactic": tactic})

	# Remember setup for restart
	last_setup_player_count = player_count
	last_setup_configs = player_configs.duplicate()

	setup_screen.visible = false
	# Show game UI
	$HUD/TopBar.visible = true
	$HUD/BottomBar.visible = true
	_start_game(player_configs)


func _start_game(player_configs: Array = []) -> void:
	# Clear previous game
	for system in systems:
		system.queue_free()
	systems.clear()
	fleets_in_transit.clear()
	players.clear()
	system_memory.clear()
	pending_combat_reports.clear()
	shield_lines.clear()
	shield_activations.clear()
	shield_select_source = null
	shield_line_memory.clear()

	# Clear stations
	for station in stations:
		if station.has("node") and station["node"]:
			station["node"].queue_free()
	stations.clear()
	station_placement_mode = false
	next_station_id = 0
	selected_station_idx = -1
	send_source_station_idx = -1
	send_target_station_idx = -1

	# Initialize players
	for i in range(player_count):
		if i < player_configs.size():
			var cfg = player_configs[i]
			players.append(Player.new(i, "", cfg["is_ai"], cfg["tactic"]))
		else:
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
	var edge = UniverseGenerator.MAP_EDGE_MARGIN
	var bottom_hud = 100  # Extra margin for bottom HUD bar
	var bounds = Rect2(edge, edge, viewport_size.x - edge * 2, viewport_size.y - edge * 2 - bottom_hud)

	var gen_result = UniverseGenerator.generate_system_positions(
		system_count, bounds, player_count
	)

	var positions: Array = gen_result["positions"]
	var player_starts: Array = gen_result["player_starts"]

	# Pre-generate production rates so fighter distribution can weight by them
	var production_rates: Array[int] = []
	for i in range(positions.size()):
		var player_start_idx = player_starts.find(i)
		if player_start_idx >= 0:
			production_rates.append(3)  # Standard production for home systems
		else:
			production_rates.append(UniverseGenerator.generate_production_rate())

	# Distribute starting fighters based on home world connectivity + neighbor production
	var start_fighters: Array[int] = UniverseGenerator.generate_player_start_fighters(
		positions, player_starts, production_rates)

	# Create systems
	for i in range(positions.size()):
		var system = star_system_scene.instantiate() as StarSystem
		system.system_id = i
		system.system_name = UniverseGenerator.generate_star_name()
		system.position = positions[i]
		system.production_rate = production_rates[i]

		# Check if this is a player start
		var player_start_idx = player_starts.find(i)
		if player_start_idx >= 0:
			system.owner_id = player_start_idx
			players[player_start_idx].home_system_id = system.system_id
			system.fighter_count = start_fighters[player_start_idx]
		else:
			system.owner_id = -1  # Neutral
			system.fighter_count = UniverseGenerator.generate_initial_fighters(system.production_rate)

		# Connect signals
		system.system_clicked.connect(_on_system_clicked)
		system.system_double_clicked.connect(_on_system_double_clicked)
		system.system_hover_started.connect(_on_system_hover_started)
		system.system_hover_ended.connect(_on_system_hover_ended)

		systems_container.add_child(system)
		systems.append(system)

	_update_fog_of_war()


func _update_fog_of_war() -> void:
	# Initialize memory for current player if needed
	if not system_memory.has(current_player):
		system_memory[current_player] = {}

	# First, determine which systems are visible to current player
	var owned_systems: Array[StarSystem] = []
	for system in systems:
		if system.owner_id == current_player:
			owned_systems.append(system)

	# Collect scan positions (owned systems + operative stations)
	var scan_positions: Array[Vector2] = []
	for sys in owned_systems:
		scan_positions.append(sys.global_position)
	for station in stations:
		if station["owner_id"] == current_player and station["operative"]:
			scan_positions.append(station["position"])

	# Update visibility based on current player
	for system in systems:
		var system_visible = false

		# Check if system is owned by current player
		if system.owner_id == current_player:
			system_visible = true
		else:
			# Check if any scan source is within visibility range
			for scan_pos in scan_positions:
				if system.global_position.distance_to(scan_pos) <= UniverseGenerator.MAX_SYSTEM_DISTANCE:
					system_visible = true
					break

		if system_visible:
			system.show_system()
			system.update_visuals()
			if system.owner_id == current_player:
				system.show_fighter_count()
				system_memory[current_player][system.system_id] = {
					"owner_id": system.owner_id,
					"fighter_count": system.fighter_count,
					"bomber_count": system.bomber_count,
					"battery_count": system.battery_count,
					"has_batteries": system.battery_count > 0
				}
			else:
				# Preserve known ship/battery counts from combat intel
				var existing = system_memory[current_player].get(system.system_id, {})
				var owner_changed = existing.get("owner_id", -2) != system.owner_id
				system_memory[current_player][system.system_id] = {
					"owner_id": system.owner_id,
					"fighter_count": "?" if owner_changed else existing.get("fighter_count", "?"),
					"bomber_count": 0 if owner_changed else existing.get("bomber_count", 0),
					"battery_count": -1 if owner_changed else existing.get("battery_count", -1),
					"has_batteries": system.battery_count > 0
				}
				var mem = system_memory[current_player][system.system_id]
				system.show_hidden_info(mem)
		else:
			# Check if we have memory of this system
			var player_memory = system_memory[current_player]
			if player_memory.has(system.system_id):
				system.show_remembered_info(player_memory[system.system_id])
			else:
				system.hide_system()

	# Update shield line memory for fog of war
	_update_shield_line_memory(owned_systems)

	# Update visibility overlay texture
	_update_visibility_texture(owned_systems)


func _update_visibility_texture(owned_systems: Array[StarSystem]) -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	var img = Image.create(int(viewport_size.x), int(viewport_size.y), false, Image.FORMAT_RGBA8)

	var radius = UniverseGenerator.MAX_SYSTEM_DISTANCE
	var radius_sq = radius * radius

	# Collect all scan center positions (systems + operative stations)
	var scan_centers: Array[Vector2] = []
	for sys in owned_systems:
		scan_centers.append(sys.global_position)
	for station in stations:
		if station["owner_id"] == current_player and station["operative"]:
			scan_centers.append(station["position"])

	# For each pixel, check if it's within range of any scan center
	for x in range(img.get_width()):
		for y in range(img.get_height()):
			var pos = Vector2(x, y)
			var in_range = false
			for center in scan_centers:
				if pos.distance_squared_to(center) <= radius_sq:
					in_range = true
					break
			if in_range:
				img.set_pixel(x, y, VISIBILITY_COLOR)

	visibility_texture = ImageTexture.create_from_image(img)

	# Generate enemy scan zone texture (pixels in both FoW AND enemy scan range)
	var scan_img = Image.create(int(viewport_size.x), int(viewport_size.y), false, Image.FORMAT_RGBA8)

	# Collect enemy scan centers with their scan radii
	var enemy_scans: Array = []  # [{pos: Vector2, radius_sq: float}]
	var star_scan_sq = ShipTypes.STATION_PASSIVE_SCAN_RANGE * ShipTypes.STATION_PASSIVE_SCAN_RANGE
	var station_scan_sq = radius_sq  # MAX_SYSTEM_DISTANCE squared
	for sys in systems:
		if sys.owner_id != current_player and sys.owner_id >= 0:
			# Only include visible enemy stars (within own FoW)
			var sys_visible = false
			for center in scan_centers:
				if sys.global_position.distance_squared_to(center) <= radius_sq:
					sys_visible = true
					break
			if sys_visible:
				enemy_scans.append({"pos": sys.global_position, "radius_sq": star_scan_sq})
	for station in stations:
		if station["owner_id"] != current_player and station["owner_id"] >= 0:
			if _is_station_visible_to(station, current_player):
				enemy_scans.append({"pos": station["position"], "radius_sq": station_scan_sq})

	if enemy_scans.size() > 0:
		for x in range(scan_img.get_width()):
			for y in range(scan_img.get_height()):
				var pos = Vector2(x, y)
				# Must be in own FoW visible area
				var in_fow = false
				for center in scan_centers:
					if pos.distance_squared_to(center) <= radius_sq:
						in_fow = true
						break
				if not in_fow:
					continue
				# Check if in any enemy scan range
				for enemy in enemy_scans:
					if pos.distance_squared_to(enemy["pos"]) <= enemy["radius_sq"]:
						scan_img.set_pixel(x, y, ENEMY_SCAN_COLOR)
						break

	enemy_scan_texture = ImageTexture.create_from_image(scan_img)
	queue_redraw()


func _update_shield_line_memory(owned_systems: Array[StarSystem]) -> void:
	if not shield_line_memory.has(current_player):
		shield_line_memory[current_player] = []

	# Build set of currently visible shield lines
	var visible_lines: Array = []
	for line in shield_lines:
		var sys_a = systems[line["system_a"]]
		var sys_b = systems[line["system_b"]]
		# Visible if at least one endpoint is visible to current player
		var a_visible = sys_a.owner_id == current_player
		var b_visible = sys_b.owner_id == current_player
		if not a_visible:
			for owned in owned_systems:
				if sys_a.global_position.distance_to(owned.global_position) <= UniverseGenerator.MAX_SYSTEM_DISTANCE:
					a_visible = true
					break
		if not b_visible:
			for owned in owned_systems:
				if sys_b.global_position.distance_to(owned.global_position) <= UniverseGenerator.MAX_SYSTEM_DISTANCE:
					b_visible = true
					break
		if a_visible or b_visible:
			visible_lines.append(line.duplicate())

	# Merge visible lines into memory (replace if already known, add if new)
	for vline in visible_lines:
		var found = false
		for i in range(shield_line_memory[current_player].size()):
			var mem = shield_line_memory[current_player][i]
			if _line_matches_dict(mem, vline):
				shield_line_memory[current_player][i] = vline.duplicate()
				found = true
				break
		if not found:
			shield_line_memory[current_player].append(vline.duplicate())

	# Remove from memory lines that are currently visible but no longer active
	var to_remove: Array = []
	for i in range(shield_line_memory[current_player].size()):
		var mem = shield_line_memory[current_player][i]
		# Check if both endpoints are visible - if so, we'd know if the line still exists
		var sys_a = systems[mem["system_a"]]
		var sys_b = systems[mem["system_b"]]
		var a_vis = sys_a.visible and not sys_a.is_remembered
		var b_vis = sys_b.visible and not sys_b.is_remembered
		if a_vis and b_vis:
			# Both visible - check if line still active
			var still_active = false
			for line in shield_lines:
				if _line_matches_dict(line, mem):
					still_active = true
					break
			if not still_active:
				to_remove.append(i)
	to_remove.reverse()
	for i in to_remove:
		shield_line_memory[current_player].remove_at(i)


func _show_player_transition() -> void:
	# Skip eliminated players
	if _is_player_eliminated(current_player):
		_advance_to_next_player()
		return

	# Deselect any selected system
	if selected_system:
		selected_system.set_selected(false)
		selected_system = null
	send_panel.visible = false
	action_panel.visible = false
	station_action_panel.visible = false
	shield_select_source = null
	station_placement_mode = false
	selected_station_idx = -1
	_station_shield_source_idx = -1

	# AI players: execute turn automatically (no transition screen)
	if players[current_player].is_ai:
		# Spectator mode: update display and wait before AI acts
		if _is_all_ai():
			_update_fog_of_war()
			transition_screen.visible = false
			_update_ui()
			if ai_paused:
				turn_label.text = "Turn: %d  PAUSED" % current_turn
			queue_redraw()
			await get_tree().create_timer(AI_TURN_DELAY).timeout
			while ai_paused:
				await get_tree().create_timer(0.1).timeout
			if game_ended:
				return
		_execute_ai_turn()
		return

	# Human player: show transition screen
	transition_screen.visible = true
	transition_label.text = "Player %d's Turn\n\n%s\n\nClick Continue when ready" % [
		current_player + 1,
		players[current_player].player_name
	]


func _on_continue_pressed() -> void:
	transition_screen.visible = false
	_update_fog_of_war()
	_update_ui()
	queue_redraw()  # Redraw visibility range circles

	# Show combat reports if this player was involved in battles
	current_report_index = 0
	if pending_combat_reports.has(current_player) and pending_combat_reports[current_player].size() > 0:
		_show_combat_report()
	else:
		# No reports — check victory now
		_check_victory()


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

	# Update build station button
	var station_count = _count_player_stations(current_player)
	build_station_btn.text = "Build Station (%d/%d)" % [station_count, ShipTypes.MAX_STATIONS_PER_PLAYER]
	build_station_btn.disabled = station_count >= ShipTypes.MAX_STATIONS_PER_PLAYER

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
	# Ships in stations
	for station in stations:
		if station["owner_id"] == player_id:
			total += station["fighter_count"] + station["bomber_count"]
	# Ships in transit
	for fleet in fleets_in_transit:
		if fleet.owner_id == player_id:
			total += fleet.fighter_count + fleet.bomber_count
	return total


func _on_system_clicked(system: StarSystem) -> void:
	if game_ended or transition_screen.visible or combat_report_screen.visible:
		return
	if send_panel.visible:
		return

	# Cancel station shield selection if active
	if _station_shield_source_idx >= 0:
		_station_shield_source_idx = -1

	# Shield partner selection mode
	if shield_select_source:
		_try_activate_shield(shield_select_source, system)
		return

	# If a station is selected as source and we click a system, send fleet from station
	if selected_station_idx >= 0:
		var src = stations[selected_station_idx]
		if src["owner_id"] == current_player and (src["fighter_count"] + src["bomber_count"]) > 0:
			_start_send_fleet_from_station(selected_station_idx, system)
			return

	# If we have an owned source selected and click a different system, send fleet
	if selected_system and selected_system != system:
		if selected_system.owner_id == current_player and selected_system.get_total_ships() > 0:
			_start_send_fleet(selected_system, system)
			return
		# Non-owned system selected: fall through to select new system

	# Toggle selection on same system
	if selected_system == system:
		system.set_selected(false)
		selected_system = null
		send_panel.visible = false
		action_panel.visible = false
		show_fleet_arrow = false
		queue_redraw()
		system_info_label.text = ""
		return

	# Select new system (single click: info only, no action panel)
	if selected_system:
		selected_system.set_selected(false)
	selected_system = system
	selected_station_idx = -1
	system.set_selected(true)
	send_panel.visible = false
	action_panel.visible = false
	station_action_panel.visible = false
	show_fleet_arrow = false
	queue_redraw()

	_show_system_info(system)


func _on_system_double_clicked(system: StarSystem) -> void:
	if game_ended or transition_screen.visible or combat_report_screen.visible:
		return
	if send_panel.visible:
		if system == send_target_system:
			_on_send_max_confirmed()
		return

	if system.owner_id != current_player:
		return

	# Ensure system is selected (first click of double-click may have toggled)
	if selected_system and selected_system != system:
		selected_system.set_selected(false)
	selected_system = system
	system.set_selected(true)
	_show_owned_system_info(system)
	_show_action_panel(system)


func _show_system_info(system: StarSystem) -> void:
	if system.owner_id == current_player:
		_show_owned_system_info(system)
	else:
		var select_info: String
		if system.owner_id < 0:
			select_info = "%s - Neutral (+%d/turn)" % [system.system_name, system.production_rate]
		else:
			select_info = "%s - %s (+%d/turn)" % [system.system_name, players[system.owner_id].player_name, system.production_rate]
		var memory = system_memory[current_player].get(system.system_id, {})
		select_info += _format_intel_text(memory, system)
		system_info_label.text = select_info


## Format combat intel for info text (hover and selection)
func _format_intel_text(memory: Dictionary, system: StarSystem) -> String:
	var text = ""
	var known_fighters = memory.get("fighter_count", "?")
	var known_bombers = memory.get("bomber_count", 0)
	var known_batteries = memory.get("battery_count", -1)

	if known_fighters is int:
		if known_bombers > 0:
			text += " (%d F / %d B)" % [known_fighters, known_bombers]
		else:
			text += " (%d F)" % known_fighters

	if known_batteries > 0:
		text += " [(%d) bat.]" % known_batteries
	elif system.battery_count > 0:
		text += " [batteries]"

	return text


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

	# Shield button: requires >= 2 batteries, < 2 active lines, not already activating
	var shield_line_count = _count_shield_lines_for_system(system.system_id)
	var shield_disabled = (system.battery_count < ShipTypes.SHIELD_MIN_BATTERIES or
						   shield_line_count >= ShipTypes.MAX_SHIELD_LINES_PER_SYSTEM or
						   system.production_mode == StarSystem.ProductionMode.SHIELD_ACTIVATE)
	activate_shield_btn.disabled = shield_disabled

	# Update button text to show current state
	produce_fighters_btn.text = "Produce Fighters"
	produce_bombers_btn.text = "Produce Bombers"
	upgrade_btn.text = "Upgrade Production (%d/%d)" % [system.production_rate, ShipTypes.MAX_PRODUCTION_RATE]
	build_battery_btn.text = "Build Battery (%d/%d)" % [system.battery_count, ShipTypes.MAX_BATTERIES]
	activate_shield_btn.text = "Activate Shield (%d/%d)" % [shield_line_count, ShipTypes.MAX_SHIELD_LINES_PER_SYSTEM]

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
		action_panel.visible = false


func _on_produce_bombers_pressed() -> void:
	if selected_system and selected_system.owner_id == current_player:
		selected_system.set_production_mode(StarSystem.ProductionMode.BOMBERS)
		_show_owned_system_info(selected_system)
		action_panel.visible = false


func _on_upgrade_pressed() -> void:
	if selected_system and selected_system.owner_id == current_player:
		selected_system.set_production_mode(StarSystem.ProductionMode.UPGRADE)
		_show_owned_system_info(selected_system)
		action_panel.visible = false


func _on_build_battery_pressed() -> void:
	if selected_system and selected_system.owner_id == current_player:
		selected_system.set_production_mode(StarSystem.ProductionMode.BATTERY_BUILD)
		_show_owned_system_info(selected_system)
		action_panel.visible = false



func _on_activate_shield_pressed() -> void:
	if selected_system and selected_system.owner_id == current_player:
		shield_select_source = selected_system
		action_panel.visible = false
		system_info_label.text = "Select partner system for shield line (ESC to cancel)"


func _try_activate_shield(source: StarSystem, target: StarSystem) -> void:
	# Validation
	if source.system_id == target.system_id:
		system_info_label.text = "Cannot create shield line to same system"
		shield_select_source = null
		return

	if source.owner_id != current_player:
		system_info_label.text = "Source must be owned by you"
		shield_select_source = null
		return

	if target.owner_id != current_player:
		system_info_label.text = "Target must be owned by you"
		shield_select_source = null
		return

	if target.battery_count < ShipTypes.SHIELD_MIN_BATTERIES:
		system_info_label.text = "Target needs at least %d batteries" % ShipTypes.SHIELD_MIN_BATTERIES
		shield_select_source = null
		return

	if source.battery_count < ShipTypes.SHIELD_MIN_BATTERIES:
		system_info_label.text = "Source needs at least %d batteries" % ShipTypes.SHIELD_MIN_BATTERIES
		shield_select_source = null
		return

	var distance = source.get_distance_to(target)
	if distance > UniverseGenerator.MAX_SYSTEM_DISTANCE:
		system_info_label.text = "Systems too far apart"
		shield_select_source = null
		return

	if _count_shield_lines_for_system(source.system_id) >= ShipTypes.MAX_SHIELD_LINES_PER_SYSTEM:
		system_info_label.text = "Source already has max shield lines"
		shield_select_source = null
		return

	if _count_shield_lines_for_system(target.system_id) >= ShipTypes.MAX_SHIELD_LINES_PER_SYSTEM:
		system_info_label.text = "Target already has max shield lines"
		shield_select_source = null
		return

	# Check for duplicate line
	if _shield_line_matches(source.system_id, target.system_id):
		system_info_label.text = "Shield line already exists between these systems"
		shield_select_source = null
		return

	# Check if either system is already activating
	if source.production_mode == StarSystem.ProductionMode.SHIELD_ACTIVATE:
		system_info_label.text = "Source is already activating a shield"
		shield_select_source = null
		return
	if target.production_mode == StarSystem.ProductionMode.SHIELD_ACTIVATE:
		system_info_label.text = "Target is already activating a shield"
		shield_select_source = null
		return

	# Check structure limit
	if not _can_add_shield_structure(source.system_id, target.system_id, current_player):
		system_info_label.text = "Max %d independent shield structures reached" % ShipTypes.MAX_SHIELD_STRUCTURES
		shield_select_source = null
		return

	# All checks passed - activate
	source.set_production_mode(StarSystem.ProductionMode.SHIELD_ACTIVATE)
	source.shield_activate_partner_id = target.system_id
	target.set_production_mode(StarSystem.ProductionMode.SHIELD_ACTIVATE)
	target.shield_activate_partner_id = source.system_id

	shield_activations.append({
		"system_a": source.system_id,
		"system_b": target.system_id,
		"owner_id": current_player,
		"progress": 0
	})

	shield_select_source = null
	system_info_label.text = "Shield activation started between %s and %s" % [source.system_name, target.system_name]
	_show_owned_system_info(source)
	queue_redraw()


func _count_shield_lines_for_system(system_id: int) -> int:
	var count = 0
	for line in shield_lines:
		if line["system_a"] == system_id or line["system_b"] == system_id:
			count += 1
	for act in shield_activations:
		if act["system_a"] == system_id or act["system_b"] == system_id:
			count += 1
	return count


func _shield_line_matches(id_a: int, id_b: int) -> bool:
	for line in shield_lines:
		if (line["system_a"] == id_a and line["system_b"] == id_b) or \
		   (line["system_a"] == id_b and line["system_b"] == id_a):
			return true
	for act in shield_activations:
		if (act["system_a"] == id_a and act["system_b"] == id_b) or \
		   (act["system_a"] == id_b and act["system_b"] == id_a):
			return true
	return false


## Check if adding a shield line between two systems would exceed the MAX_SHIELD_STRUCTURES limit.
## Uses BFS to count connected components in the shield graph.
func _can_add_shield_structure(id_a: int, id_b: int, owner_id: int) -> bool:
	# Build adjacency from existing lines + activations for this owner
	var adj: Dictionary = {}
	for line in shield_lines:
		if line["owner_id"] != owner_id:
			continue
		var a = line["system_a"]
		var b = line["system_b"]
		if not adj.has(a):
			adj[a] = []
		if not adj.has(b):
			adj[b] = []
		adj[a].append(b)
		adj[b].append(a)
	for act in shield_activations:
		if act["owner_id"] != owner_id:
			continue
		var a = act["system_a"]
		var b = act["system_b"]
		if not adj.has(a):
			adj[a] = []
		if not adj.has(b):
			adj[b] = []
		adj[a].append(b)
		adj[b].append(a)

	# If both nodes are already in the same component, adding this edge doesn't create a new structure
	var a_in = adj.has(id_a)
	var b_in = adj.has(id_b)

	if a_in and b_in:
		# BFS from id_a to see if id_b is reachable
		var visited: Dictionary = {}
		var queue: Array = [id_a]
		visited[id_a] = true
		while queue.size() > 0:
			var current = queue.pop_front()
			if current == id_b:
				return true  # Same component, no new structure
			for neighbor in adj.get(current, []):
				if not visited.has(neighbor):
					visited[neighbor] = true
					queue.append(neighbor)
		# Different components - this would merge them, reducing structure count
		return true  # Merging is always fine

	if not a_in and not b_in:
		# Both new - creates a new structure. Count existing structures
		var structure_count = _count_shield_structures(adj)
		return structure_count < ShipTypes.MAX_SHIELD_STRUCTURES

	# One is in an existing structure, the other is new - extends existing structure
	return true


func _count_shield_structures(adj: Dictionary) -> int:
	if adj.is_empty():
		return 0
	var visited: Dictionary = {}
	var count = 0
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
	return count


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		if _is_all_ai() and game_started and not game_ended:
			ai_paused = !ai_paused
			if ai_paused:
				turn_label.text = "Turn: %d  PAUSED" % current_turn
			else:
				turn_label.text = "Turn: %d" % current_turn
			get_viewport().set_input_as_handled()
			return

	# Station placement mode: click to place
	if station_placement_mode and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var mouse_pos = get_global_mouse_position()
			if _is_valid_station_placement(mouse_pos):
				_place_station(mouse_pos)
			else:
				system_info_label.text = "Invalid placement! Must be within range of own system/station, away from others."
			get_viewport().set_input_as_handled()
			return

	if event.is_action_pressed("ui_cancel"):
		if station_placement_mode:
			station_placement_mode = false
			system_info_label.text = ""
			queue_redraw()
		elif combat_report_screen.visible:
			_on_close_report_pressed()
		elif _station_shield_source_idx >= 0:
			_station_shield_source_idx = -1
			system_info_label.text = ""
		elif shield_select_source:
			shield_select_source = null
			system_info_label.text = ""
		elif send_panel.visible:
			_on_send_cancelled()
		elif station_action_panel.visible:
			_on_station_close_pressed()
		elif action_panel.visible:
			_on_action_close_pressed()
		elif selected_system:
			selected_system.set_selected(false)
			selected_system = null
			system_info_label.text = ""
			queue_redraw()
		elif selected_station_idx >= 0:
			selected_station_idx = -1
			station_action_panel.visible = false
			system_info_label.text = ""
			queue_redraw()
		get_viewport().set_input_as_handled()


func _on_action_close_pressed() -> void:
	action_panel.visible = false


func _on_system_hover_started(system: StarSystem) -> void:
	if combat_report_screen.visible:
		return

	# For owned systems, always show detailed info with production mode
	if system.owner_id == current_player:
		_show_owned_system_info(system)
		return

	var info_text: String
	var memory = system_memory[current_player].get(system.system_id, {})

	if system.is_remembered:
		# Show remembered (outdated) info
		var owner_name = "Unknown"
		if memory.has("owner_id"):
			if memory["owner_id"] < 0:
				owner_name = "Neutral"
			else:
				owner_name = players[memory["owner_id"]].player_name
		info_text = "%s - %s (last seen)" % [system.system_name, owner_name]
	elif system.owner_id < 0:
		info_text = "%s - Neutral (+%d/turn)" % [
			system.system_name, system.production_rate
		]
	else:
		info_text = "%s - %s (+%d/turn)" % [
			system.system_name, players[system.owner_id].player_name, system.production_rate
		]

	# Show known combat intel
	info_text += _format_intel_text(memory, system)

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
	# Resize panel to fit content
	var vbox = send_panel.get_node("VBox")
	var padding = Vector2(40, 40)  # 20px on each side
	var needed_size = vbox.get_combined_minimum_size() + padding
	needed_size.x = max(needed_size.x, send_panel.custom_minimum_size.x)
	needed_size.y = max(needed_size.y, send_panel.custom_minimum_size.y)
	send_panel.size = needed_size

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
	var offset_dist = source_radius + star_margin

	# Position candidates: 6 directions around source (perp, behind, diagonals)
	var offsets = [
		perp * (offset_dist + panel_size.x / 2),                             # Left of arrow
		-perp * (offset_dist + panel_size.x / 2),                            # Right of arrow
		-to_target * (offset_dist + panel_size.y / 2),                        # Behind source
		(-to_target + perp).normalized() * (offset_dist + panel_size.x / 2),  # Behind-left
		(-to_target - perp).normalized() * (offset_dist + panel_size.x / 2),  # Behind-right
		to_target * (offset_dist + panel_size.y / 2),                         # Ahead of source (last resort)
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
	var arrow_len = source_pos.distance_to(target_pos)

	for pos in positions:
		var panel_center = pos + panel_size / 2.0

		# Minimum distance from arrow line to panel rectangle (check corners + edge midpoints)
		var check_points = [
			pos,                                             # Top-left
			pos + Vector2(panel_size.x, 0),                  # Top-right
			pos + Vector2(0, panel_size.y),                  # Bottom-left
			pos + panel_size,                                # Bottom-right
			panel_center,                                    # Center
			pos + Vector2(panel_size.x / 2, 0),              # Top-mid
			pos + Vector2(panel_size.x / 2, panel_size.y),   # Bottom-mid
			pos + Vector2(0, panel_size.y / 2),              # Left-mid
			pos + Vector2(panel_size.x, panel_size.y / 2),   # Right-mid
		]

		var min_dist_line = INF
		for pt in check_points:
			var to_pt = pt - source_pos
			var proj = to_pt.dot(to_target)
			var closest = source_pos + to_target * clamp(proj, 0, arrow_len)
			min_dist_line = min(min_dist_line, pt.distance_to(closest))

		# Distance from panel rect to target star (closest corner)
		var min_dist_target = INF
		for pt in check_points:
			min_dist_target = min(min_dist_target, pt.distance_to(target_pos))

		# Distance from panel rect to source star
		var min_dist_source = INF
		for pt in check_points:
			min_dist_source = min(min_dist_source, pt.distance_to(source_pos))

		# Check if panel rect overlaps with target star (using expanded radius)
		var target_radius = send_target_system._get_radius() + 20.0
		var panel_rect = Rect2(pos, panel_size)
		var target_overlap_penalty: float = 0.0
		if panel_rect.has_point(target_pos):
			target_overlap_penalty = 500.0
		elif min_dist_target < target_radius:
			target_overlap_penalty = 300.0

		# Score: prefer far from arrow and both stars, heavily penalize target overlap
		var score = min_dist_line * 2.0 + min_dist_target * 3.0 - min_dist_source * 0.2 - target_overlap_penalty

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
	var source_pos = _get_send_source_pos()
	var target_pos = _get_send_target_pos()
	var distance = source_pos.distance_to(target_pos)
	var travel_time = Fleet.calculate_travel_time(distance, fighters, bombers)
	var morale = Fleet.calculate_fighter_morale(travel_time)

	var text = "Send %d fighters" % fighters
	if morale < 1.0 and fighters > 0:
		text += " (%d%% morale)" % int(morale * 100)
	if bombers > 0:
		text += ", %d bombers" % bombers
	text += " (arrives in %d turns)" % max(1, travel_time)

	# Shield crossing preview
	var crossings = _get_shield_crossings(
		source_pos, target_pos,
		current_player, fighters, bombers
	)
	if crossings.size() > 0:
		var total_f_loss = 0
		var total_b_loss = 0
		var any_f_blocked = false
		var any_b_blocked = false
		for effect in crossings:
			if effect["fighter_blocked"]:
				any_f_blocked = true
			else:
				total_f_loss += effect["fighter_losses"]
			if effect["bomber_blocked"]:
				any_b_blocked = true
			else:
				total_b_loss += effect["bomber_losses"]

		if any_f_blocked and (any_b_blocked or bombers == 0):
			text += "\nSHIELD: BLOCKED"
		elif any_f_blocked:
			text += "\nSHIELD: Fighters BLOCKED"
			if total_b_loss > 0:
				text += ", -%d B" % total_b_loss
		else:
			var loss_parts: Array = []
			if total_f_loss > 0:
				loss_parts.append("-%d F" % total_f_loss)
			if total_b_loss > 0:
				loss_parts.append("-%d B" % total_b_loss)
			if any_b_blocked:
				loss_parts.append("B BLOCKED")
			if loss_parts.size() > 0:
				text += "\nSHIELD: " + ", ".join(loss_parts)

	send_count_label.text = text


## Get all enemy shield line crossings for a fleet path.
## Returns Array of shield effect Dictionaries from calculate_shield_effect.
func _get_shield_crossings(source_pos: Vector2, target_pos: Vector2,
						   fleet_owner: int, fighters: int, bombers: int) -> Array:
	var crossings: Array = []
	for line in shield_lines:
		if line["owner_id"] == fleet_owner:
			continue  # Own shield lines don't affect own fleets
		var sys_a = systems[line["system_a"]]
		var sys_b = systems[line["system_b"]]
		if Combat.segments_intersect(source_pos, target_pos,
									 sys_a.global_position, sys_b.global_position):
			var distance = sys_a.global_position.distance_to(sys_b.global_position)
			var effect = Combat.calculate_shield_effect(
				sys_a.battery_count, sys_b.battery_count,
				distance, fighters, bombers
			)
			crossings.append(effect)
	return crossings


func _on_send_max_confirmed() -> void:
	var max_total: int = ShipTypes.MAX_FLEET_SIZE
	var available_f: int = int(fighter_slider.max_value)
	var available_b: int = int(bomber_slider.max_value) if bomber_slider.visible else 0
	var total: int = available_f + available_b

	# Check shield blockade before committing
	var crossings = _get_shield_crossings(
		_get_send_source_pos(), _get_send_target_pos(),
		current_player, available_f, available_b
	)
	for effect in crossings:
		if effect["fighter_blocked"] and (effect["bomber_blocked"] or available_b == 0):
			system_info_label.text = "Fleet blocked by enemy shield line!"
			return

	if total <= max_total:
		fighter_slider.value = available_f
		bomber_slider.value = available_b
	else:
		# Cap at MAX_FLEET_SIZE, preserving fighter/bomber ratio
		var f_ratio: float = float(available_f) / float(total)
		var send_f: int = int(round(f_ratio * max_total))
		send_f = mini(send_f, available_f)
		var send_b: int = mini(max_total - send_f, available_b)
		# Fill remainder if rounding left a gap
		if send_f + send_b < max_total:
			send_f = mini(send_f + (max_total - send_f - send_b), available_f)
		fighter_slider.value = send_f
		bomber_slider.value = send_b

	_on_send_confirmed()


func _on_send_all_confirmed() -> void:
	var available_f: int = int(fighter_slider.max_value)
	var available_b: int = int(bomber_slider.max_value) if bomber_slider.visible else 0
	var total: int = available_f + available_b

	if total <= 0:
		send_panel.visible = false
		show_fleet_arrow = false
		queue_redraw()
		return

	# Check shield blockade before committing
	var source_pos = _get_send_source_pos()
	var target_pos = _get_send_target_pos()
	var crossings = _get_shield_crossings(source_pos, target_pos, current_player, available_f, available_b)
	for effect in crossings:
		if effect["fighter_blocked"] and (effect["bomber_blocked"] or available_b == 0):
			system_info_label.text = "Fleet blocked by enemy shield line!"
			return

	var distance: float = source_pos.distance_to(target_pos)
	var remaining_f: int = available_f
	var remaining_b: int = available_b

	# Split into MAX_FLEET_SIZE waves, preserving fighter/bomber ratio
	while remaining_f + remaining_b > 0:
		var remaining_total: int = remaining_f + remaining_b
		var wave_size: int = mini(remaining_total, ShipTypes.MAX_FLEET_SIZE)
		var wave_f: int
		var wave_b: int

		if remaining_total <= ShipTypes.MAX_FLEET_SIZE:
			wave_f = remaining_f
			wave_b = remaining_b
		else:
			var f_ratio: float = float(remaining_f) / float(remaining_total)
			wave_f = int(round(f_ratio * wave_size))
			wave_f = mini(wave_f, remaining_f)
			wave_b = mini(wave_size - wave_f, remaining_b)
			if wave_f + wave_b < wave_size:
				wave_f = mini(wave_f + (wave_size - wave_f - wave_b), remaining_f)

		var fleet = Fleet.new(
			current_player, wave_f,
			_get_send_source_id(), _get_send_target_id(),
			current_turn, distance, wave_b
		)
		fleets_in_transit.append(fleet)
		remaining_f -= wave_f
		remaining_b -= wave_b

	# Remove all ships from source
	if send_source_system:
		send_source_system.remove_fighters(available_f)
		send_source_system.remove_bombers(available_b)
	elif send_source_station_idx >= 0:
		var src = stations[send_source_station_idx]
		src["fighter_count"] = max(0, src["fighter_count"] - available_f)
		src["bomber_count"] = max(0, src["bomber_count"] - available_b)

	send_panel.visible = false
	show_fleet_arrow = false
	queue_redraw()
	_update_ui()

	if selected_system and selected_system.get_total_ships() == 0:
		selected_system.set_selected(false)
		selected_system = null
		action_panel.visible = false
		system_info_label.text = ""
	elif selected_system:
		_show_owned_system_info(selected_system)


func _on_send_confirmed() -> void:
	var fighters = int(fighter_slider.value)
	var bombers = int(bomber_slider.value) if bomber_slider.visible else 0

	if fighters <= 0 and bombers <= 0:
		send_panel.visible = false
		show_fleet_arrow = false
		queue_redraw()
		return

	var source_pos = _get_send_source_pos()
	var target_pos = _get_send_target_pos()

	# Check shield blockade before sending
	var crossings = _get_shield_crossings(source_pos, target_pos, current_player, fighters, bombers)
	var fully_blocked = false
	for effect in crossings:
		if effect["fighter_blocked"] and (effect["bomber_blocked"] or bombers == 0):
			fully_blocked = true
			break
	if fully_blocked:
		system_info_label.text = "Fleet blocked by enemy shield line!"
		return

	# Create fleet
	var distance = source_pos.distance_to(target_pos)
	var source_id = _get_send_source_id()
	var target_id = _get_send_target_id()
	var fleet = Fleet.new(
		current_player,
		fighters,
		source_id,
		target_id,
		current_turn,
		distance,
		bombers
	)

	# Remove ships from source
	if send_source_system:
		send_source_system.remove_fighters(fighters)
		send_source_system.remove_bombers(bombers)
	elif send_source_station_idx >= 0:
		var src = stations[send_source_station_idx]
		src["fighter_count"] = max(0, src["fighter_count"] - fighters)
		src["bomber_count"] = max(0, src["bomber_count"] - bombers)
	fleets_in_transit.append(fleet)

	# Update UI
	send_panel.visible = false
	show_fleet_arrow = false
	queue_redraw()
	_update_ui()

	# Deselect system if all ships were sent, otherwise update info
	if selected_system and selected_system.get_total_ships() == 0:
		selected_system.set_selected(false)
		selected_system = null
		action_panel.visible = false
		system_info_label.text = ""
	elif selected_system:
		_show_owned_system_info(selected_system)


func _on_send_cancelled() -> void:
	send_panel.visible = false
	show_fleet_arrow = false
	queue_redraw()
	send_source_system = null
	send_target_system = null
	send_source_station_idx = -1
	send_target_station_idx = -1


func _on_end_turn_pressed() -> void:
	# Deselect
	if selected_system:
		selected_system.set_selected(false)
		selected_system = null
	send_panel.visible = false
	action_panel.visible = false

	_advance_to_next_player()


func _advance_to_next_player() -> void:
	current_player += 1

	if current_player >= player_count:
		# All players have taken their turn, process end of round
		_process_turn_end()
		current_player = 0
		current_turn += 1

	# Check for game over (only early-check for all-AI games; humans see reports first)
	if _is_all_ai():
		if _check_victory():
			return

	# Show transition to next player (combat report shown after transition)
	# Use call_deferred to avoid deep recursion with consecutive AI players
	call_deferred("_show_player_transition")


func _is_player_eliminated(player_id: int) -> bool:
	# Check if a player has no systems, no stations, and no fleets
	for system in systems:
		if system.owner_id == player_id:
			return false
	for station in stations:
		if station["owner_id"] == player_id:
			return false
	for fleet in fleets_in_transit:
		if fleet.owner_id == player_id:
			return false
	return true


func _is_all_ai() -> bool:
	for player in players:
		if not player.is_ai:
			return false
	return true


func _execute_ai_turn() -> void:
	var player = players[current_player]

	# Update fog of war for AI decisions (already done for display in spectator mode)
	if not _is_all_ai():
		_update_fog_of_war()

	# Get AI decisions
	var decisions = AiController.execute_turn(
		current_player,
		player.ai_tactic,
		systems,
		fleets_in_transit,
		system_memory,
		shield_lines,
		shield_activations,
		stations
	)

	# Apply production changes
	for change in decisions["production_changes"]:
		var sys = systems[change["system_id"]]
		if sys.owner_id != current_player:
			continue
		if change.has("shield_partner"):
			# AI wants to activate a shield line
			var partner = systems[change["shield_partner"]]
			_try_activate_shield(sys, partner)
		elif change.has("mode"):
			sys.set_production_mode(change["mode"])

	# Apply station actions
	for action in decisions.get("station_actions", []):
		if action["type"] == "build_station":
			var pos = action["position"]
			if _count_player_stations(current_player) < ShipTypes.MAX_STATIONS_PER_PLAYER:
				if _is_valid_station_placement(pos):
					_place_station_for_player(pos, current_player)
		elif action["type"] == "build_battery":
			var idx = _find_station_by_id(action["station_id"])
			if idx >= 0:
				var station = stations[idx]
				if station["owner_id"] == current_player and station["operative"]:
					if station["battery_count"] < ShipTypes.STATION_MAX_BATTERIES and not station["building_battery"]:
						station["building_battery"] = true
						station["battery_build_progress"] = 0
						station["battery_material"] = 0

	# Apply fleet orders
	for order in decisions["fleet_orders"]:
		var source = systems[order["source_id"]]
		if source.owner_id != current_player:
			continue

		var fighters = min(order["fighters"], source.fighter_count)
		var bombers = min(order["bombers"], source.bomber_count)

		if fighters <= 0 and bombers <= 0:
			continue

		var target_id = order["target_id"]
		var target_pos = _get_entity_position(target_id)
		var distance = source.global_position.distance_to(target_pos)
		var fleet = Fleet.new(
			current_player,
			fighters,
			source.system_id,
			target_id,
			current_turn,
			distance,
			bombers
		)

		source.remove_fighters(fighters)
		source.remove_bombers(bombers)
		fleets_in_transit.append(fleet)

	# Advance to next player
	_advance_to_next_player()


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

	if report_data.get("is_rebellion", false):
		# Rebellion-specific format
		report_text += "REBELLION!\n"
		report_text += "Rebels: %s\n\n" % _format_fb(report_data["attacker_fighters"], 0)

		report_text += "GARRISON\n"
		report_text += "%s  •  %s\n\n" % [
			report_data["defender_name"],
			_format_fb(report_data["defender_fighters"], report_data["defender_bombers"])
		]

		report_text += "LOSSES\n"
		report_text += "Rebels: %s\n" % _format_fb(
			report_data["attacker_fighter_losses"], 0
		)
		report_text += "Garrison: %s\n\n" % _format_fb(
			report_data["defender_fighter_losses"],
			report_data["defender_bomber_losses"]
		)

		report_text += "OUTCOME\n"
		if report_data["winner_name"] == "Rebels":
			report_text += "Rebels seize control with %s" % _format_fb(
				report_data["remaining_fighters"], 0
			)
		else:
			report_text += "%s holds with %s" % [
				report_data["winner_name"],
				_format_fb(report_data["remaining_fighters"], report_data["remaining_bombers"])
			]
	else:
		# Standard combat report format
		report_text += "DEFENDER\n"
		report_text += "%s  •  %s\n\n" % [
			report_data["defender_name"],
			_format_fb(report_data["defender_fighters"], report_data["defender_bombers"])
		]
		report_text += "ATTACKER\n"
		var attacker_morale = report_data.get("attacker_fighter_morale", 1.0)
		var att_f = report_data["attacker_fighters"]
		var att_b = report_data["attacker_bombers"]
		if attacker_morale < 1.0 and att_f > 0:
			var parts: Array[String] = []
			parts.append("%d F (%d%% morale)" % [att_f, int(attacker_morale * 100)])
			if att_b > 0:
				parts.append("%d B" % att_b)
			report_text += "%s  •  %s\n\n" % [report_data["attacker_name"], " / ".join(parts)]
		else:
			report_text += "%s  •  %s\n\n" % [
				report_data["attacker_name"],
				_format_fb(att_f, att_b)
			]

		var bat_f_kills = report_data.get("battery_fighter_kills", 0)
		var bat_b_kills = report_data.get("battery_bomber_kills", 0)
		if bat_f_kills > 0 or bat_b_kills > 0:
			report_text += "BATTERIES\n"
			report_text += "Destroyed %s\n\n" % _format_fb(bat_f_kills, bat_b_kills)

		report_text += "LOSSES\n"
		report_text += "Attacker: %s\n" % _format_fb(
			report_data["attacker_fighter_losses"],
			report_data["attacker_bomber_losses"]
		)
		report_text += "Defender: %s\n\n" % _format_fb(
			report_data["defender_fighter_losses"],
			report_data["defender_bomber_losses"]
		)

		if report_data["production_damage"] > 0:
			report_text += "BOMBER DAMAGE\n"
			report_text += "Production reduced by %d\n\n" % report_data["production_damage"]

		if report_data["conquest_occurred"]:
			report_text += "CONQUEST\n"
			report_text += "Production reduced by %d\n\n" % ShipTypes.CONQUEST_PRODUCTION_LOSS

		report_text += "OUTCOME\n"
		report_text += "%s wins with %s" % [
			report_data["winner_name"],
			_format_fb(report_data["remaining_fighters"], report_data["remaining_bombers"])
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

	# Resize panel to fit content
	var vbox = combat_report_screen.get_node("VBox")
	var padding = Vector2(50, 40)  # 25px left/right, 20px top/bottom
	var needed_size = vbox.get_combined_minimum_size() + padding
	needed_size.x = max(needed_size.x, combat_report_screen.custom_minimum_size.x)
	needed_size.y = max(needed_size.y, combat_report_screen.custom_minimum_size.y)
	combat_report_screen.size = needed_size

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

	# 0. Process shield activations
	_process_shield_activations()

	# 0a. Process station building/battery
	_process_station_building()

	# 0b. Passive scan (discover stations)
	for pid in range(player_count):
		_perform_passive_scan(pid)

	# 1. Calculate ring bonuses and production in owned systems
	var ring_bonuses = _calculate_ring_bonuses()
	for system in systems:
		if system.owner_id >= 0:
			var bonus = ring_bonuses.get(system.system_id, 0.0)
			system.process_production(bonus)

	# 2. Rebellions (after production, before fleet arrival)
	_process_rebellions()

	# 2a. Fleet scan (discover stations while in transit)
	_perform_fleet_scan()

	# 3. Process arriving fleets (renumbered from 2)
	var arriving_fleets: Dictionary = {}  # system_id -> Array[Fleet]
	var arriving_at_stations: Dictionary = {}  # station_idx -> Array[Fleet]
	var remaining_fleets: Array[Fleet] = []

	for fleet in fleets_in_transit:
		if fleet.has_arrived(current_turn + 1):  # +1 because turn increments after this
			# Apply shield attrition before arrival
			_apply_shield_attrition(fleet)
			# Drop fleets reduced to 0 ships by shields
			if fleet.fighter_count <= 0 and fleet.bomber_count <= 0:
				continue
			var target_id = fleet.target_system_id
			if _is_station_id(target_id):
				# Fleet targeting a station
				var station_idx = _find_station_by_id(target_id - STATION_ID_OFFSET)
				if station_idx < 0:
					continue  # Station destroyed — fleet lost
				if not arriving_at_stations.has(station_idx):
					arriving_at_stations[station_idx] = []
				arriving_at_stations[station_idx].append(fleet)
			else:
				if not arriving_fleets.has(target_id):
					arriving_fleets[target_id] = []
				arriving_fleets[target_id].append(fleet)
		else:
			remaining_fleets.append(fleet)

	fleets_in_transit = remaining_fleets

	# 3a. Process fleet arrivals at stations
	_process_station_fleet_arrivals(arriving_at_stations)

	# 4. Resolve combats
	for system_id in arriving_fleets:
		var system = systems[system_id]
		var fleets_here = arriving_fleets[system_id]
		var old_owner = system.owner_id
		var old_fighters = system.fighter_count
		var old_bombers = system.bomber_count
		var old_batteries = system.battery_count

		var merged = Combat.merge_fleets_by_owner(fleets_here)

		# Save original forces before combat modifies the dict
		var reinforcement_fighters = 0
		var reinforcement_bombers = 0
		if merged.has(old_owner):
			reinforcement_fighters = merged[old_owner]["fighters"]
			reinforcement_bombers = merged[old_owner]["bombers"]

		var original_attacker_forces = {}
		for aid in merged.keys():
			if aid != old_owner:
				original_attacker_forces[aid] = {
					"fighters": merged[aid]["fighters"],
					"bombers": merged[aid]["bombers"],
				}

		var eff_batteries = _get_effective_battery_count(system)
		var result = Combat.resolve_system_combat(system, merged, eff_batteries)

		# Apply results to system
		system.owner_id = result["winner"]
		system.fighter_count = result["remaining_fighters"]
		system.bomber_count = result["remaining_bombers"]

		# Apply conquest penalty (FUT-08)
		if result["conquest_occurred"] and result["winner"] >= 0:
			system.apply_conquest_penalty()
			# Batteries take 50% damage on conquest
			if system.battery_count > 0:
				system.battery_count = system.battery_count / 2  # Integer division rounds down
			system.set_production_mode(StarSystem.ProductionMode.FIGHTERS)

		# Apply production damage from bombers (FUT-12)
		if result["production_damage"] > 0:
			system.apply_production_damage(result["production_damage"])

		system.update_visuals()

		# Build per-stage combat reports
		var stages = result["stages"]
		for stage_idx in range(stages.size()):
			var stage = stages[stage_idx]
			var is_last_stage = (stage_idx == stages.size() - 1)

			# Defender for first stage uses original system forces + reinforcements
			var def_fighters = stage["defender_fighters"]
			var def_bombers = stage["defender_bombers"]
			if stage_idx == 0:
				def_fighters = old_fighters + reinforcement_fighters
				def_bombers = old_bombers + reinforcement_bombers

			var report_data = {
				"system_name": system.system_name,
				"system_id": system_id,
				"defender_name": _get_owner_name(stage["defender_id"]),
				"defender_fighters": def_fighters,
				"defender_bombers": def_bombers,
				"defender_fighter_losses": stage["defender_fighter_losses"],
				"defender_bomber_losses": stage["defender_bomber_losses"],
				"attacker_name": _get_owner_name(stage["attacker_id"]),
				"attacker_fighters": stage["attacker_fighters"],
				"attacker_bombers": stage["attacker_bombers"],
				"attacker_fighter_losses": stage["attacker_fighter_losses"],
				"attacker_bomber_losses": stage["attacker_bomber_losses"],
				"attacker_fighter_morale": stage["attacker_fighter_morale"],
				"battery_fighter_kills": stage["battery_fighter_kills"],
				"battery_bomber_kills": stage["battery_bomber_kills"],
				"winner_name": _get_owner_name(stage["stage_winner"]),
				"remaining_fighters": stage["remaining_fighters"],
				"remaining_bombers": stage["remaining_bombers"],
				"batteries_before": stage["batteries_before"],
				"batteries_after": system.battery_count if is_last_stage else stage["batteries_after"],
				"production_damage": result["production_damage"] if is_last_stage else 0,
				"conquest_occurred": result["conquest_occurred"] if is_last_stage else false
			}

			# Add report for attacker and defender of this stage
			var involved_players: Array[int] = []
			if stage["defender_id"] >= 0:
				involved_players.append(stage["defender_id"])
			if stage["attacker_id"] not in involved_players:
				involved_players.append(stage["attacker_id"])

			for player_id in involved_players:
				if not pending_combat_reports.has(player_id):
					pending_combat_reports[player_id] = []
				pending_combat_reports[player_id].append(report_data)

		# Update combat intel in memory for all involved players
		var all_involved: Array[int] = []
		if old_owner >= 0:
			all_involved.append(old_owner)
		for involved_id in original_attacker_forces.keys():
			if involved_id not in all_involved:
				all_involved.append(involved_id)

		for player_id in all_involved:
			if not system_memory.has(player_id):
				system_memory[player_id] = {}
			system_memory[player_id][system_id] = {
				"owner_id": system.owner_id,
				"fighter_count": system.fighter_count,
				"bomber_count": system.bomber_count,
				"battery_count": system.battery_count,
				"has_batteries": system.battery_count > 0
			}

	# 5. Check shield breaks after combat
	_check_shield_breaks()


## Process shield activation progress. Called at start of _process_turn_end.
func _process_shield_activations() -> void:
	var completed: Array = []
	var remaining: Array = []

	for act in shield_activations:
		act["progress"] += 1
		var sys_a = systems[act["system_a"]]
		var sys_b = systems[act["system_b"]]
		sys_a.shield_activate_progress = act["progress"]
		sys_b.shield_activate_progress = act["progress"]

		if act["progress"] >= ShipTypes.SHIELD_ACTIVATE_TIME:
			completed.append(act)
		else:
			remaining.append(act)

	shield_activations = remaining

	for act in completed:
		# Add to active shield lines
		shield_lines.append({
			"system_a": act["system_a"],
			"system_b": act["system_b"],
			"owner_id": act["owner_id"]
		})
		# Reset both systems to FIGHTERS mode
		var sys_a = systems[act["system_a"]]
		var sys_b = systems[act["system_b"]]
		sys_a.set_production_mode(StarSystem.ProductionMode.FIGHTERS)
		sys_b.set_production_mode(StarSystem.ProductionMode.FIGHTERS)


## Apply shield attrition to a fleet that is about to arrive.
## Checks all enemy shield lines the fleet's path crosses.
func _apply_shield_attrition(fleet: Fleet) -> void:
	var source_pos = _get_entity_position(fleet.source_system_id)
	var target_pos = _get_entity_position(fleet.target_system_id)

	for line in shield_lines:
		if line["owner_id"] == fleet.owner_id:
			continue  # Own shields don't affect own fleets

		var sys_a = systems[line["system_a"]]
		var sys_b = systems[line["system_b"]]

		if Combat.segments_intersect(source_pos, target_pos,
									 sys_a.global_position, sys_b.global_position):
			var distance = sys_a.global_position.distance_to(sys_b.global_position)
			var effect = Combat.calculate_shield_effect(
				sys_a.battery_count, sys_b.battery_count,
				distance, fleet.fighter_count, fleet.bomber_count
			)

			# Apply blockade: blocked ships are lost
			if effect["fighter_blocked"]:
				fleet.fighter_count = 0
			else:
				fleet.fighter_count = max(0, fleet.fighter_count - effect["fighter_losses"])

			if effect["bomber_blocked"]:
				fleet.bomber_count = 0
			else:
				fleet.bomber_count = max(0, fleet.bomber_count - effect["bomber_losses"])

			# Fleet destroyed - will be dropped when checking total ships
			if fleet.fighter_count <= 0 and fleet.bomber_count <= 0:
				break


func _process_rebellions() -> void:
	# Compute multi-factor power score per active (non-eliminated) player
	var active_players: int = 0
	var system_counts: Dictionary = {}  # player_id -> count
	var combat_power: Dictionary = {}   # player_id -> fighter equivalents
	var production_total: Dictionary = {}  # player_id -> sum of production_rate
	for i in range(player_count):
		if not _is_player_eliminated(i):
			active_players += 1
			system_counts[i] = 0
			combat_power[i] = 0.0
			production_total[i] = 0.0

	if active_players == 0:
		return

	# Sum systems, garrison combat power, and production per player
	for system in systems:
		if system.owner_id >= 0 and system_counts.has(system.owner_id):
			system_counts[system.owner_id] += 1
			combat_power[system.owner_id] += system.fighter_count + system.bomber_count * (ShipTypes.BOMBER_ATTACK / ShipTypes.FIGHTER_ATTACK)
			production_total[system.owner_id] += system.production_rate

	# Add fleet combat power
	for fleet in fleets_in_transit:
		if combat_power.has(fleet.owner_id):
			combat_power[fleet.owner_id] += fleet.fighter_count + fleet.bomber_count * (ShipTypes.BOMBER_ATTACK / ShipTypes.FIGHTER_ATTACK)

	# Add station garrison combat power
	for station in stations:
		if station["operative"] and combat_power.has(station["owner_id"]):
			combat_power[station["owner_id"]] += station["fighter_count"] + station["bomber_count"] * (ShipTypes.BOMBER_ATTACK / ShipTypes.FIGHTER_ATTACK)

	# Compute weighted power scores
	var power_scores: Dictionary = {}  # player_id -> power
	var total_power: float = 0.0
	for pid in system_counts:
		var power: float = (
			system_counts[pid] * ShipTypes.REBELLION_DOMINANCE_WEIGHT_SYSTEMS
			+ combat_power[pid] * ShipTypes.REBELLION_DOMINANCE_WEIGHT_COMBAT
			+ production_total[pid] * ShipTypes.REBELLION_DOMINANCE_WEIGHT_PRODUCTION
		)
		power_scores[pid] = power
		total_power += power

	var avg_power: float = total_power / float(active_players)

	for player_id in system_counts:
		var power: float = power_scores[player_id]
		if avg_power <= 0.0 or power <= avg_power * ShipTypes.REBELLION_DOMINANCE_FACTOR:
			continue

		var power_ratio: float = power / avg_power
		var rebellion_chance: float = (power_ratio - ShipTypes.REBELLION_DOMINANCE_FACTOR) * ShipTypes.REBELLION_CHANCE_PER_DOMINANCE
		var count: int = system_counts[player_id]

		for system in systems:
			if system.owner_id != player_id:
				continue
			# Home systems are immune
			if system.system_id == players[player_id].home_system_id:
				continue
			# Systems with max batteries are immune, lower levels reduce chance
			if system.battery_count >= ShipTypes.MAX_BATTERIES:
				continue
			# Last system is immune (prevent indirect elimination via rebellion)
			if count <= 1:
				continue

			# Batteries below max reduce rebellion chance proportionally
			var battery_reduction: float = float(system.battery_count) / float(ShipTypes.MAX_BATTERIES)
			var effective_chance: float = rebellion_chance * (1.0 - battery_reduction)
			if randf() < effective_chance:
				var rebel_fighters: int = system.production_rate * ShipTypes.REBELLION_STRENGTH_FACTOR
				var garrison_f: int = system.fighter_count
				var garrison_b: int = system.bomber_count

				var combat_result = Combat.resolve_combat(
					rebel_fighters, 0, -1,
					garrison_f, garrison_b, player_id,
					0, 1.0
				)

				system.fighter_count = combat_result.remaining_fighters
				system.bomber_count = combat_result.remaining_bombers
				system.owner_id = combat_result.winner_id

				if combat_result.winner_id != player_id:
					# Rebels won — system becomes neutral, reset production
					system.set_production_mode(StarSystem.ProductionMode.FIGHTERS)

				system.update_visuals()

				# Update FoW memory so player sees known garrison after rebellion
				if not system_memory.has(player_id):
					system_memory[player_id] = {}
				system_memory[player_id][system.system_id] = {
					"owner_id": system.owner_id,
					"fighter_count": combat_result.remaining_fighters,
					"bomber_count": combat_result.remaining_bombers,
					"battery_count": system.battery_count,
					"has_batteries": system.battery_count > 0
				}

				# Build rebellion report
				var report_data = {
					"system_name": system.system_name,
					"system_id": system.system_id,
					"is_rebellion": true,
					"defender_name": players[player_id].player_name,
					"defender_fighters": garrison_f,
					"defender_bombers": garrison_b,
					"defender_fighter_losses": garrison_f - (combat_result.remaining_fighters if combat_result.winner_id == player_id else 0),
					"defender_bomber_losses": garrison_b - (combat_result.remaining_bombers if combat_result.winner_id == player_id else 0),
					"attacker_name": "Rebels",
					"attacker_fighters": rebel_fighters,
					"attacker_bombers": 0,
					"attacker_fighter_losses": rebel_fighters - (combat_result.remaining_fighters if combat_result.winner_id == -1 else 0),
					"attacker_bomber_losses": 0,
					"attacker_fighter_morale": 1.0,
					"battery_fighter_kills": 0,
					"battery_bomber_kills": 0,
					"winner_name": "Rebels" if combat_result.winner_id != player_id else players[player_id].player_name,
					"remaining_fighters": combat_result.remaining_fighters,
					"remaining_bombers": combat_result.remaining_bombers,
					"batteries_before": 0,
					"batteries_after": 0,
					"production_damage": 0,
					"conquest_occurred": false
				}

				if not pending_combat_reports.has(player_id):
					pending_combat_reports[player_id] = []
				pending_combat_reports[player_id].append(report_data)

	# Check shield breaks after rebellions
	_check_shield_breaks()


func _get_owner_name(owner_id: int) -> String:
	if owner_id < 0:
		return "Neutral"
	return players[owner_id].player_name


func _format_fb(fighters: int, bombers: int) -> String:
	var parts: Array[String] = []
	if fighters > 0:
		parts.append("%d F" % fighters)
	if bombers > 0:
		parts.append("%d B" % bombers)
	if parts.is_empty():
		return "-"
	return " / ".join(parts)


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

	# Also check if players have stations
	for station in stations:
		if station["owner_id"] >= 0 and station["owner_id"] not in players_with_systems:
			players_with_systems.append(station["owner_id"])

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
	# Show map from winner's perspective
	current_player = winner_id
	_update_fog_of_war()
	_update_ui()
	queue_redraw()
	transition_screen.visible = false
	game_over_screen.visible = true
	winner_label.text = "%s Wins!" % players[winner_id].player_name
	winner_label.add_theme_color_override("font_color", players[winner_id].color)


## Draw shield lines on the map
func _draw_shield_lines() -> void:
	# Draw active shield lines
	for line in shield_lines:
		_draw_single_shield_line(line, false)

	# Draw activating shield lines (dimmer)
	for act in shield_activations:
		_draw_single_shield_line(act, true)

	# Draw remembered shield lines (gray)
	if shield_line_memory.has(current_player):
		for mem_line in shield_line_memory[current_player]:
			var already_active = false
			for line in shield_lines:
				if _line_matches_dict(line, mem_line):
					already_active = true
					break
			if not already_active:
				var sys_a = systems[mem_line["system_a"]]
				var sys_b = systems[mem_line["system_b"]]
				if sys_a.visible or sys_b.visible:
					var start_pos = sys_a.global_position
					var end_pos = sys_b.global_position
					var dir = (end_pos - start_pos).normalized()
					start_pos += dir * sys_a._get_radius()
					end_pos -= dir * sys_b._get_radius()
					draw_line(start_pos, end_pos, Color(0.5, 0.5, 0.5, 0.3), 1.5)


func _draw_single_shield_line(line: Dictionary, is_activating: bool) -> void:
	var sys_a = systems[line["system_a"]]
	var sys_b = systems[line["system_b"]]

	var owner_id = line["owner_id"]
	# Enemy shield lines: only visible when BOTH endpoints are visible
	# Own shield lines: visible when at least one endpoint is visible
	if owner_id == current_player:
		if not sys_a.visible and not sys_b.visible:
			return
	else:
		if not sys_a.visible or not sys_b.visible:
			return

	var distance = sys_a.global_position.distance_to(sys_b.global_position)
	var density = Combat.calculate_shield_density(distance)

	var base_color: Color
	if owner_id >= 0 and owner_id < players.size():
		base_color = players[owner_id].color
	else:
		base_color = Color.WHITE

	var alpha = 0.4 + density * 0.5
	var width = 2.0 + density * 2.5

	if is_activating:
		alpha *= 0.6
		width *= 0.7

	base_color.a = alpha

	# Shorten line to star radius
	var start_pos = sys_a.global_position
	var end_pos = sys_b.global_position
	var dir = (end_pos - start_pos).normalized()
	start_pos += dir * sys_a._get_radius()
	end_pos -= dir * sys_b._get_radius()

	draw_line(start_pos, end_pos, base_color, width)


func _line_matches_dict(a: Dictionary, b: Dictionary) -> bool:
	return (a["system_a"] == b["system_a"] and a["system_b"] == b["system_b"]) or \
		   (a["system_a"] == b["system_b"] and a["system_b"] == b["system_a"])


## Find closed rings (cycles) in the shield line graph for a given owner.
## With max degree 2 per node, a connected component is a cycle iff edges == nodes.
func _find_shield_rings(owner_id: int) -> Array:
	# Build adjacency for this owner's shield lines only
	var adj: Dictionary = {}  # node_id -> [neighbor_ids]
	var edge_count: int = 0
	for line in shield_lines:
		if line["owner_id"] != owner_id:
			continue
		var a = line["system_a"]
		var b = line["system_b"]
		if not adj.has(a):
			adj[a] = []
		if not adj.has(b):
			adj[b] = []
		adj[a].append(b)
		adj[b].append(a)
		edge_count += 1

	if adj.is_empty():
		return []

	# Find connected components via BFS
	var visited: Dictionary = {}
	var rings: Array = []

	for start_node in adj:
		if visited.has(start_node):
			continue
		var component_nodes: Array = []
		var component_edges: int = 0
		var queue: Array = [start_node]
		visited[start_node] = true

		while queue.size() > 0:
			var current = queue.pop_front()
			component_nodes.append(current)
			for neighbor in adj[current]:
				component_edges += 1
				if not visited.has(neighbor):
					visited[neighbor] = true
					queue.append(neighbor)

		component_edges /= 2  # Each edge counted twice

		# A cycle: edges == nodes (with max degree 2)
		if component_edges == component_nodes.size() and component_nodes.size() >= 3:
			var ordered = _order_cycle_nodes(component_nodes, adj)
			rings.append(ordered)

	return rings


## Order cycle nodes into a polygon traversal order.
func _order_cycle_nodes(nodes: Array, adj: Dictionary) -> Array:
	if nodes.size() < 3:
		return nodes

	var ordered: Array = [nodes[0]]
	var prev = -1
	var current = nodes[0]

	for i in range(nodes.size() - 1):
		var neighbors = adj[current]
		var next = -1
		for n in neighbors:
			if n != prev:
				next = n
				break
		if next == -1:
			break
		ordered.append(next)
		prev = current
		current = next

	return ordered


## Test if a point is inside a polygon defined by system IDs using ray casting.
func _point_in_polygon(point: Vector2, polygon_ids: Array) -> bool:
	var polygon_size = polygon_ids.size()
	if polygon_size < 3:
		return false

	var inside = false
	var j = polygon_size - 1
	for i in range(polygon_size):
		var pi = systems[polygon_ids[i]].global_position
		var pj = systems[polygon_ids[j]].global_position
		if ((pi.y > point.y) != (pj.y > point.y)) and \
		   (point.x < (pj.x - pi.x) * (point.y - pi.y) / (pj.y - pi.y) + pi.x):
			inside = not inside
		j = i

	return inside


## Calculate ring bonuses for all systems. Returns Dictionary[system_id -> float bonus].
func _calculate_ring_bonuses() -> Dictionary:
	var bonuses: Dictionary = {}  # system_id -> float

	for pid in range(player_count):
		var rings = _find_shield_rings(pid)
		for ring in rings:
			# Ring systems get SHIELD_RING_BONUS_RING
			for node_id in ring:
				var current = bonuses.get(node_id, 0.0)
				bonuses[node_id] = max(current, ShipTypes.SHIELD_RING_BONUS_RING)

			# Check all systems for being inside this ring
			for system in systems:
				if system.system_id in ring:
					continue  # Already handled as ring node
				if system.owner_id != pid:
					continue  # Only bonus for own systems
				if _point_in_polygon(system.global_position, ring):
					var current = bonuses.get(system.system_id, 0.0)
					bonuses[system.system_id] = max(current, ShipTypes.SHIELD_RING_BONUS_INNER)

	return bonuses


## Calculate effective battery count including shield line neighbor support.
## Neighbors contribute their batteries × shield_density × 0.5.
func _get_effective_battery_count(system: StarSystem) -> int:
	var base = system.battery_count
	var support = 0.0
	for line in shield_lines:
		var neighbor: StarSystem = null
		if line["system_a"] == system.system_id and line["owner_id"] == system.owner_id:
			neighbor = systems[line["system_b"]]
		elif line["system_b"] == system.system_id and line["owner_id"] == system.owner_id:
			neighbor = systems[line["system_a"]]
		if neighbor and neighbor.owner_id == system.owner_id:
			var dist = system.global_position.distance_to(neighbor.global_position)
			var density = Combat.calculate_shield_density(dist)
			support += neighbor.battery_count * density * ShipTypes.SHIELD_BATTERY_SUPPORT_FACTOR
	return base + int(support)


## Check and remove broken shield lines (ownership changed, batteries < 2).
## Also cancel activations for broken conditions.
func _check_shield_breaks() -> void:
	# Check active shield lines
	var remaining_lines: Array = []
	for line in shield_lines:
		var sys_a = systems[line["system_a"]]
		var sys_b = systems[line["system_b"]]
		if sys_a.owner_id == line["owner_id"] and sys_b.owner_id == line["owner_id"] and \
		   sys_a.battery_count >= ShipTypes.SHIELD_MIN_BATTERIES and \
		   sys_b.battery_count >= ShipTypes.SHIELD_MIN_BATTERIES:
			remaining_lines.append(line)
	shield_lines = remaining_lines

	# Check activations
	var remaining_acts: Array = []
	for act in shield_activations:
		var sys_a = systems[act["system_a"]]
		var sys_b = systems[act["system_b"]]
		if sys_a.owner_id == act["owner_id"] and sys_b.owner_id == act["owner_id"] and \
		   sys_a.battery_count >= ShipTypes.SHIELD_MIN_BATTERIES and \
		   sys_b.battery_count >= ShipTypes.SHIELD_MIN_BATTERIES:
			remaining_acts.append(act)
		else:
			# Reset both systems to FIGHTERS mode
			if sys_a.production_mode == StarSystem.ProductionMode.SHIELD_ACTIVATE:
				sys_a.set_production_mode(StarSystem.ProductionMode.FIGHTERS)
			if sys_b.production_mode == StarSystem.ProductionMode.SHIELD_ACTIVATE:
				sys_b.set_production_mode(StarSystem.ProductionMode.FIGHTERS)
	shield_activations = remaining_acts


# ── Space Stations (FUT-20) ──────────────────────────────────────

## Get position for any entity (system or station) by ID
func _get_entity_position(entity_id: int) -> Vector2:
	if entity_id >= STATION_ID_OFFSET:
		var idx = entity_id - STATION_ID_OFFSET
		if idx >= 0 and idx < stations.size():
			return stations[idx]["position"]
		return Vector2.ZERO
	if entity_id >= 0 and entity_id < systems.size():
		return systems[entity_id].global_position
	return Vector2.ZERO


## Get owner for any entity by ID
func _get_entity_owner(entity_id: int) -> int:
	if entity_id >= STATION_ID_OFFSET:
		var idx = entity_id - STATION_ID_OFFSET
		if idx >= 0 and idx < stations.size():
			return stations[idx]["owner_id"]
		return -1
	if entity_id >= 0 and entity_id < systems.size():
		return systems[entity_id].owner_id
	return -1


## Check if an entity ID refers to a station
func _is_station_id(entity_id: int) -> bool:
	return entity_id >= STATION_ID_OFFSET


## Convert ships to fighter-equivalents (FÄ): 1 bomber = 2 FÄ
func _ships_to_fae(fighters: int, bombers: int) -> int:
	return fighters + bombers * 2


## Count stations owned by a player (including under construction)
func _count_player_stations(player_id: int) -> int:
	var count = 0
	for station in stations:
		if station["owner_id"] == player_id:
			count += 1
	return count


## Find station at a position (for click detection)
func _find_station_at(pos: Vector2) -> int:
	for i in range(stations.size()):
		if pos.distance_to(stations[i]["position"]) <= STATION_CLICK_RADIUS:
			return i
	return -1


## Check if a station is visible to a player
func _is_station_visible_to(station: Dictionary, player_id: int) -> bool:
	# Own stations always visible
	if station["owner_id"] == player_id:
		return true
	# Discovered stations are permanently visible
	if player_id in station["discovered_by"]:
		return true
	# Stations with garrison are visible to all
	if station["operative"] and (station["fighter_count"] > 0 or station["bomber_count"] > 0):
		return true
	return false


## Check if a station is in scan range of a player (passive scan)
func _is_station_in_scan_range(station: Dictionary, player_id: int) -> bool:
	var station_pos = station["position"]
	# Check distance to any owned system (reduced scan range)
	for system in systems:
		if system.owner_id == player_id:
			if station_pos.distance_to(system.global_position) <= ShipTypes.STATION_PASSIVE_SCAN_RANGE:
				return true
	# Check distance to any owned operative station (full visibility range)
	for other in stations:
		if other["owner_id"] == player_id and other["operative"] and other["id"] != station["id"]:
			if station_pos.distance_to(other["position"]) <= UniverseGenerator.MAX_SYSTEM_DISTANCE:
				return true
	return false


## Validate station placement position
func _is_valid_station_placement(pos: Vector2) -> bool:
	# Check minimum distance to all systems
	for system in systems:
		if pos.distance_to(system.global_position) < UniverseGenerator.MIN_SYSTEM_DISTANCE:
			return false
	# Check minimum distance to all stations
	for station in stations:
		if pos.distance_to(station["position"]) < UniverseGenerator.MIN_SYSTEM_DISTANCE:
			return false
	# Must be within FoW visible area (own star or operative station within MAX_SYSTEM_DISTANCE)
	var in_visible = false
	for system in systems:
		if system.owner_id == current_player:
			if pos.distance_to(system.global_position) <= UniverseGenerator.MAX_SYSTEM_DISTANCE:
				in_visible = true
				break
	if not in_visible:
		for station in stations:
			if station["owner_id"] == current_player and station["operative"]:
				if pos.distance_to(station["position"]) <= UniverseGenerator.MAX_SYSTEM_DISTANCE:
					in_visible = true
					break
	if not in_visible:
		return false
	# Check within map bounds (half the star edge margin)
	var viewport_size = get_viewport().get_visible_rect().size
	var edge = UniverseGenerator.MIN_SYSTEM_DISTANCE / 2.0
	if pos.x < edge or pos.x > viewport_size.x - edge:
		return false
	if pos.y < edge or pos.y > viewport_size.y - edge:
		return false
	return true


## Create a new station (build marker)
func _place_station(pos: Vector2) -> void:
	var station = {
		"id": next_station_id,
		"position": pos,
		"owner_id": current_player,
		"operative": false,
		"build_progress": 0,
		"material": 0,
		"fighter_count": 0,
		"bomber_count": 0,
		"battery_count": 0,
		"building_battery": false,
		"battery_build_progress": 0,
		"battery_material": 0,
		"discovered_by": [current_player],
		"node": null,
	}
	next_station_id += 1
	stations.append(station)

	# Create Area2D for click detection
	_create_station_area(stations.size() - 1)

	station_placement_mode = false
	system_info_label.text = "Station build site placed! Send fleets to deliver material."
	queue_redraw()


## Place a station for a specific player (used by AI)
func _place_station_for_player(pos: Vector2, player_id: int) -> void:
	var station = {
		"id": next_station_id,
		"position": pos,
		"owner_id": player_id,
		"operative": false,
		"build_progress": 0,
		"material": 0,
		"fighter_count": 0,
		"bomber_count": 0,
		"battery_count": 0,
		"building_battery": false,
		"battery_build_progress": 0,
		"battery_material": 0,
		"discovered_by": [player_id],
		"node": null,
	}
	next_station_id += 1
	stations.append(station)
	_create_station_area(stations.size() - 1)
	queue_redraw()


## Create an Area2D node for station click detection
func _create_station_area(station_idx: int) -> void:
	var station = stations[station_idx]
	var area = Area2D.new()
	area.position = station["position"]
	area.name = "Station_%d" % station["id"]

	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = STATION_CLICK_RADIUS
	shape.shape = circle
	area.add_child(shape)

	area.input_event.connect(_on_station_input_event.bind(station["id"]))
	area.mouse_entered.connect(_on_station_hover_started.bind(station["id"]))
	area.mouse_exited.connect(_on_station_hover_ended.bind(station["id"]))
	area.input_pickable = true

	systems_container.add_child(area)
	station["node"] = area


## Handle station input events (bound to station ID, not array index)
func _on_station_input_event(_viewport: Node, event: InputEvent, _shape_idx: int, station_id: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var station_idx = _find_station_by_id(station_id)
			if station_idx < 0:
				return
			if not _is_station_visible_to(stations[station_idx], current_player):
				return
			if event.double_click:
				_on_station_double_clicked(station_idx)
			else:
				_on_station_clicked(station_idx)


func _on_station_hover_started(station_id: int) -> void:
	var station_idx = _find_station_by_id(station_id)
	if station_idx < 0:
		return
	if combat_report_screen.visible:
		return
	if not _is_station_visible_to(stations[station_idx], current_player):
		return
	var station = stations[station_idx]
	var info = _get_station_info_text(station)

	# Show travel time if a source is selected
	if selected_system or selected_station_idx >= 0:
		var source_pos: Vector2
		if selected_system:
			source_pos = selected_system.global_position
		else:
			source_pos = stations[selected_station_idx]["position"]
		var distance = source_pos.distance_to(station["position"])
		var fighter_time = Fleet.calculate_travel_time(distance, 1, 0)
		var bomber_time = Fleet.calculate_travel_time(distance, 1, 1)
		if fighter_time != bomber_time:
			info += " [F:%d B:%d turns]" % [fighter_time, bomber_time]
		else:
			info += " [%d turns]" % fighter_time

	system_info_label.text = info


func _on_station_hover_ended(_station_id: int) -> void:
	if combat_report_screen.visible:
		return
	if selected_system and selected_system.owner_id == current_player:
		_show_owned_system_info(selected_system)
	elif selected_station_idx >= 0 and stations[selected_station_idx]["owner_id"] == current_player:
		system_info_label.text = _get_station_info_text(stations[selected_station_idx])
	else:
		system_info_label.text = ""


## Get info text for a station
func _get_station_info_text(station: Dictionary) -> String:
	var text = ""
	if station["owner_id"] == current_player:
		if not station["operative"]:
			text = "Station (Building %d/%d)" % [station["build_progress"], ShipTypes.STATION_BUILD_ROUNDS]
			text += " Material: %d/%d FÄ" % [station["material"], ShipTypes.STATION_BUILD_PER_ROUND]
		else:
			text = "Station"
			if station["fighter_count"] > 0 or station["bomber_count"] > 0:
				text += " F:%d B:%d" % [station["fighter_count"], station["bomber_count"]]
			if station["battery_count"] > 0:
				text += " [%d batteries]" % station["battery_count"]
			if station["building_battery"]:
				var target_rounds = station["battery_count"] + 1
				text += "\nBuilding Battery (%d/%d) Material: %d/%d FÄ" % [
					station["battery_build_progress"], target_rounds,
					station["battery_material"], ShipTypes.STATION_BATTERY_PER_ROUND
				]
	else:
		var owner_name = "Unknown"
		if station["owner_id"] >= 0:
			owner_name = players[station["owner_id"]].player_name
		text = "Station - %s" % owner_name
	return text


## Handle station click
func _on_station_clicked(station_idx: int) -> void:
	if game_ended or transition_screen.visible or combat_report_screen.visible:
		return
	if send_panel.visible:
		return

	var station = stations[station_idx]

	# Shield partner selection mode — stations can be shield endpoints
	if shield_select_source:
		# Stations can't be shield activation targets (only systems have production modes)
		# But operative stations with batteries can be shield line endpoints
		system_info_label.text = "Shield activation requires two star systems"
		shield_select_source = null
		return

	# If we have a selected source (system or station) with ships, start send fleet
	if selected_system and selected_system != null:
		if selected_system.owner_id == current_player and selected_system.get_total_ships() > 0:
			_start_send_fleet_to_station(selected_system, station_idx)
			return
	if selected_station_idx >= 0 and selected_station_idx != station_idx:
		var src = stations[selected_station_idx]
		if src["owner_id"] == current_player and (src["fighter_count"] + src["bomber_count"]) > 0:
			_start_send_fleet_station_to_station(selected_station_idx, station_idx)
			return

	# Toggle selection on same station
	if selected_station_idx == station_idx:
		selected_station_idx = -1
		send_panel.visible = false
		station_action_panel.visible = false
		show_fleet_arrow = false
		queue_redraw()
		system_info_label.text = ""
		return

	# Select station (deselect system if any)
	if selected_system:
		selected_system.set_selected(false)
		selected_system = null
	selected_station_idx = station_idx
	send_panel.visible = false
	action_panel.visible = false
	station_action_panel.visible = false
	show_fleet_arrow = false
	queue_redraw()
	system_info_label.text = _get_station_info_text(station)


## Handle station double-click
func _on_station_double_clicked(station_idx: int) -> void:
	if game_ended or transition_screen.visible or combat_report_screen.visible:
		return
	if send_panel.visible:
		if send_target_station_idx == station_idx:
			_on_send_max_confirmed()
		return

	var station = stations[station_idx]
	if station["owner_id"] != current_player:
		return
	if not station["operative"]:
		return

	# Select station
	if selected_system:
		selected_system.set_selected(false)
		selected_system = null
	selected_station_idx = station_idx
	action_panel.visible = false
	system_info_label.text = _get_station_info_text(station)
	_show_station_action_panel(station_idx)


## Show action panel for a station
func _show_station_action_panel(station_idx: int) -> void:
	var station = stations[station_idx]

	station_title_label.text = "Station"

	# Battery button
	var can_build_battery = station["battery_count"] < ShipTypes.STATION_MAX_BATTERIES and not station["building_battery"]
	station_battery_btn.disabled = not can_build_battery
	station_battery_btn.text = "Build Battery (%d/%d)" % [station["battery_count"], ShipTypes.STATION_MAX_BATTERIES]

	# Shield button (station shield lines not yet supported)
	station_shield_btn.disabled = true
	station_shield_btn.text = "Activate Shield (N/A)"

	# Position panel
	var viewport_size = get_viewport().get_visible_rect().size
	var panel_size = station_action_panel.size
	var margin = 20.0
	var panel_pos = Vector2(
		station["position"].x + 60,
		station["position"].y - panel_size.y / 2.0
	)
	panel_pos.x = clamp(panel_pos.x, margin, viewport_size.x - panel_size.x - margin)
	panel_pos.y = clamp(panel_pos.y, margin + 50, viewport_size.y - panel_size.y - margin)
	station_action_panel.position = panel_pos
	station_action_panel.visible = true


func _on_station_battery_pressed() -> void:
	if selected_station_idx < 0:
		return
	var station = stations[selected_station_idx]
	if station["owner_id"] != current_player or not station["operative"]:
		return
	station["building_battery"] = true
	station["battery_build_progress"] = 0
	station["battery_material"] = 0
	system_info_label.text = _get_station_info_text(station)
	_show_station_action_panel(selected_station_idx)


func _on_station_shield_pressed() -> void:
	pass  # Station shield lines not yet supported


var _station_shield_source_idx: int = -1


func _on_station_close_pressed() -> void:
	station_action_panel.visible = false


## Build Station button handler
func _on_build_station_pressed() -> void:
	if game_ended or transition_screen.visible:
		return
	# Toggle off if already in placement mode
	if station_placement_mode:
		station_placement_mode = false
		system_info_label.text = ""
		queue_redraw()
		return
	if _count_player_stations(current_player) >= ShipTypes.MAX_STATIONS_PER_PLAYER:
		system_info_label.text = "Maximum stations reached (%d/%d)" % [
			_count_player_stations(current_player), ShipTypes.MAX_STATIONS_PER_PLAYER]
		return
	station_placement_mode = true
	# Deselect current
	if selected_system:
		selected_system.set_selected(false)
		selected_system = null
	selected_station_idx = -1
	send_panel.visible = false
	action_panel.visible = false
	station_action_panel.visible = false
	system_info_label.text = "Click to place station (ESC to cancel)"
	queue_redraw()


## Count shield lines connected to a station
func _count_shield_lines_for_station(station_idx: int) -> int:
	var station_id = stations[station_idx]["id"] + STATION_ID_OFFSET
	var count = 0
	for line in shield_lines:
		if line["system_a"] == station_id or line["system_b"] == station_id:
			count += 1
	for act in shield_activations:
		if act["system_a"] == station_id or act["system_b"] == station_id:
			count += 1
	return count


## Start send fleet from system to station
func _start_send_fleet_to_station(source: StarSystem, target_station_idx: int) -> void:
	var station = stations[target_station_idx]
	send_source_system = source
	send_target_system = null
	send_source_station_idx = -1
	send_target_station_idx = target_station_idx

	# Setup sliders
	fighter_slider.max_value = source.fighter_count
	fighter_slider.value = ceili(source.fighter_count / 2.0)
	bomber_slider.max_value = source.bomber_count
	bomber_slider.value = ceili(source.bomber_count / 2.0) if source.bomber_count > 0 else 0
	bomber_slider.visible = source.bomber_count > 0

	var bomber_label = $HUD/SendPanel/VBox/BomberLabel
	if bomber_label:
		bomber_label.visible = source.bomber_count > 0

	send_panel.visible = true
	action_panel.visible = false
	station_action_panel.visible = false
	show_fleet_arrow = true
	queue_redraw()
	_position_send_panel_generic()
	_update_send_count_label()


## Start send fleet from station to station
func _start_send_fleet_station_to_station(src_idx: int, tgt_idx: int) -> void:
	var src = stations[src_idx]
	send_source_system = null
	send_target_system = null
	send_source_station_idx = src_idx
	send_target_station_idx = tgt_idx

	fighter_slider.max_value = src["fighter_count"]
	fighter_slider.value = ceili(src["fighter_count"] / 2.0)
	bomber_slider.max_value = src["bomber_count"]
	bomber_slider.value = ceili(src["bomber_count"] / 2.0) if src["bomber_count"] > 0 else 0
	bomber_slider.visible = src["bomber_count"] > 0

	var bomber_label = $HUD/SendPanel/VBox/BomberLabel
	if bomber_label:
		bomber_label.visible = src["bomber_count"] > 0

	send_panel.visible = true
	action_panel.visible = false
	station_action_panel.visible = false
	show_fleet_arrow = true
	queue_redraw()
	_position_send_panel_generic()
	_update_send_count_label()


## Start send fleet from station to system
func _start_send_fleet_from_station(src_idx: int, target: StarSystem) -> void:
	var src = stations[src_idx]
	send_source_system = null
	send_target_system = target
	send_source_station_idx = src_idx
	send_target_station_idx = -1

	fighter_slider.max_value = src["fighter_count"]
	fighter_slider.value = ceili(src["fighter_count"] / 2.0)
	bomber_slider.max_value = src["bomber_count"]
	bomber_slider.value = ceili(src["bomber_count"] / 2.0) if src["bomber_count"] > 0 else 0
	bomber_slider.visible = src["bomber_count"] > 0

	var bomber_label = $HUD/SendPanel/VBox/BomberLabel
	if bomber_label:
		bomber_label.visible = src["bomber_count"] > 0

	send_panel.visible = true
	action_panel.visible = false
	station_action_panel.visible = false
	show_fleet_arrow = true
	queue_redraw()
	_position_send_panel_generic()
	_update_send_count_label()


## Get the current send source position (system or station)
func _get_send_source_pos() -> Vector2:
	if send_source_system:
		return send_source_system.global_position
	if send_source_station_idx >= 0:
		return stations[send_source_station_idx]["position"]
	return Vector2.ZERO


## Get the current send target position (system or station)
func _get_send_target_pos() -> Vector2:
	if send_target_system:
		return send_target_system.global_position
	if send_target_station_idx >= 0:
		return stations[send_target_station_idx]["position"]
	return Vector2.ZERO


## Get the current send source entity ID (for Fleet)
func _get_send_source_id() -> int:
	if send_source_system:
		return send_source_system.system_id
	if send_source_station_idx >= 0:
		return stations[send_source_station_idx]["id"] + STATION_ID_OFFSET
	return -1


## Get the current send target entity ID (for Fleet)
func _get_send_target_id() -> int:
	if send_target_system:
		return send_target_system.system_id
	if send_target_station_idx >= 0:
		return stations[send_target_station_idx]["id"] + STATION_ID_OFFSET
	return -1


## Position send panel generically (for both system and station sources/targets)
func _position_send_panel_generic() -> void:
	var vbox = send_panel.get_node("VBox")
	var padding = Vector2(40, 40)
	var needed_size = vbox.get_combined_minimum_size() + padding
	needed_size.x = max(needed_size.x, send_panel.custom_minimum_size.x)
	needed_size.y = max(needed_size.y, send_panel.custom_minimum_size.y)
	send_panel.size = needed_size

	var viewport_size = get_viewport().get_visible_rect().size
	var panel_size = send_panel.size
	var margin = 20.0

	var source_pos = _get_send_source_pos()
	var target_pos = _get_send_target_pos()

	# Simple positioning: to the right and center of source
	var panel_pos = Vector2(source_pos.x + 60, source_pos.y - panel_size.y / 2.0)
	panel_pos.x = clamp(panel_pos.x, margin, viewport_size.x - panel_size.x - margin)
	panel_pos.y = clamp(panel_pos.y, margin + 50, viewport_size.y - panel_size.y - margin)
	send_panel.position = panel_pos


## Process station building each turn
func _process_station_building() -> void:
	for station in stations:
		if station["owner_id"] < 0:
			continue
		# Station construction
		if not station["operative"]:
			if station["material"] >= ShipTypes.STATION_BUILD_PER_ROUND:
				station["material"] -= ShipTypes.STATION_BUILD_PER_ROUND
				station["build_progress"] += 1
				if station["build_progress"] >= ShipTypes.STATION_BUILD_ROUNDS:
					station["operative"] = true
					station["material"] = 0  # Leftover material is lost
		# Battery construction
		elif station["building_battery"]:
			if station["battery_material"] >= ShipTypes.STATION_BATTERY_PER_ROUND:
				station["battery_material"] -= ShipTypes.STATION_BATTERY_PER_ROUND
				station["battery_build_progress"] += 1
				var target_rounds = station["battery_count"] + 1  # Scales with level
				if station["battery_build_progress"] >= target_rounds:
					station["battery_count"] += 1
					station["building_battery"] = false
					station["battery_build_progress"] = 0
					station["battery_material"] = 0


## Process fleet arrival at a station
func _process_fleet_arrival_at_station(fleet: Fleet, station: Dictionary) -> void:
	# Under construction: ships become material
	if not station["operative"]:
		var fae = _ships_to_fae(fleet.fighter_count, fleet.bomber_count)
		station["material"] += fae
		return
	# Operative, building battery: ships become battery material
	if station["building_battery"]:
		var fae = _ships_to_fae(fleet.fighter_count, fleet.bomber_count)
		station["battery_material"] += fae
		return
	# Operative, idle: ships join garrison
	station["fighter_count"] += fleet.fighter_count
	station["bomber_count"] += fleet.bomber_count


## Resolve combat at a station (enemy fleet arrival)
func _resolve_station_combat(station: Dictionary, arriving_fleets: Dictionary) -> Dictionary:
	var station_owner = station["owner_id"]
	var station_fighters = station["fighter_count"]
	var station_bombers = station["bomber_count"]

	var result = {
		"winner": station_owner,
		"remaining_fighters": station_fighters,
		"remaining_bombers": station_bombers,
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

	# Add friendly reinforcements
	if arriving_fleets.has(station_owner):
		result["remaining_fighters"] += arriving_fleets[station_owner]["fighters"]
		result["remaining_bombers"] += arriving_fleets[station_owner]["bombers"]
		arriving_fleets.erase(station_owner)

	# Split waves
	var waves: Array = []
	for attacker_id in arriving_fleets:
		var force = arriving_fleets[attacker_id]
		var owner_waves = Combat.split_into_waves(attacker_id, force["fighters"], force["bombers"], force["fighter_morale"])
		waves.append_array(owner_waves)

	for wave in waves:
		wave["pre_fighters"] = wave["fighters"]
		wave["pre_bombers"] = wave["bombers"]
		wave["bat_fighter_kills"] = 0
		wave["bat_bomber_kills"] = 0

	# Battery pre-combat
	if station["battery_count"] > 0 and waves.size() > 0:
		waves.sort_custom(func(a, b):
			return Combat.calculate_attack_power(a["fighters"], a["bombers"], a["fighter_morale"]) > Combat.calculate_attack_power(b["fighters"], b["bombers"], b["fighter_morale"])
		)
		for wave in waves:
			var battery_result = Combat.resolve_battery_combat(station["battery_count"], wave["fighters"], wave["bombers"])
			wave["fighters"] = max(0, wave["fighters"] - battery_result["fighter_kills"])
			wave["bombers"] = max(0, wave["bombers"] - battery_result["bomber_kills"])
			wave["bat_fighter_kills"] = battery_result["fighter_kills"]
			wave["bat_bomber_kills"] = battery_result["bomber_kills"]
			result["battery_kills"] += battery_result["fighter_kills"] + battery_result["bomber_kills"]

		var surviving_waves: Array = []
		for wave in waves:
			if wave["fighters"] + wave["bombers"] > 0:
				surviving_waves.append(wave)
		waves = surviving_waves

	waves.sort_custom(func(a, b):
		return Combat.calculate_attack_power(a["fighters"], a["bombers"], a["fighter_morale"]) > Combat.calculate_attack_power(b["fighters"], b["bombers"], b["fighter_morale"])
	)

	# Process each wave
	for wave in waves:
		var attacker_id = wave["id"]

		if attacker_id == result["winner"]:
			result["remaining_fighters"] += wave["fighters"]
			result["remaining_bombers"] += wave["bombers"]
			continue

		if result["remaining_fighters"] == 0 and result["remaining_bombers"] == 0 and result["winner"] == -1:
			result["winner"] = attacker_id
			result["remaining_fighters"] = wave["fighters"]
			result["remaining_bombers"] = wave["bombers"]
			result["conquest_occurred"] = true
		else:
			var combat_result = Combat.resolve_combat(
				wave["fighters"], wave["bombers"], attacker_id,
				result["remaining_fighters"], result["remaining_bombers"], result["winner"],
				0, wave["fighter_morale"]
			)
			result["attacker_fighter_losses"] += combat_result.attacker_fighter_losses
			result["attacker_bomber_losses"] += combat_result.attacker_bomber_losses
			result["defender_fighter_losses"] += combat_result.defender_fighter_losses
			result["defender_bomber_losses"] += combat_result.defender_bomber_losses

			if combat_result.winner_id != result["winner"] and combat_result.winner_id != -1:
				if result["winner"] != -1:
					result["conquest_occurred"] = true

			result["winner"] = combat_result.winner_id
			result["remaining_fighters"] = combat_result.remaining_fighters
			result["remaining_bombers"] = combat_result.remaining_bombers

	return result


## Destroy a station (removes from array, frees node)
func _destroy_station(station_idx: int) -> void:
	var station = stations[station_idx]
	if station.has("node") and station["node"]:
		station["node"].queue_free()
	# Remove shield lines connected to this station
	var station_id = station["id"] + STATION_ID_OFFSET
	shield_lines = shield_lines.filter(func(l): return l["system_a"] != station_id and l["system_b"] != station_id)
	shield_activations = shield_activations.filter(func(a): return a["system_a"] != station_id and a["system_b"] != station_id)
	stations.remove_at(station_idx)
	# Update all station index references after removal
	if selected_station_idx == station_idx:
		selected_station_idx = -1
	elif selected_station_idx > station_idx:
		selected_station_idx -= 1
	if send_source_station_idx == station_idx:
		send_source_station_idx = -1
	elif send_source_station_idx > station_idx:
		send_source_station_idx -= 1
	if send_target_station_idx == station_idx:
		send_target_station_idx = -1
	elif send_target_station_idx > station_idx:
		send_target_station_idx -= 1


## Destroy all stations belonging to a player (on elimination)
func _destroy_player_stations(player_id: int) -> void:
	var i = stations.size() - 1
	while i >= 0:
		if stations[i]["owner_id"] == player_id:
			_destroy_station(i)
		i -= 1


## Perform fleet scan for station discovery
func _perform_fleet_scan() -> void:
	for fleet in fleets_in_transit:
		var fleet_size = fleet.fighter_count + fleet.bomber_count
		if fleet_size <= ShipTypes.STATION_FLEET_SCAN_THRESHOLD:
			continue
		var scan_range = min(ShipTypes.STATION_FLEET_SCAN_MAX,
							max(0, (fleet_size - ShipTypes.STATION_FLEET_SCAN_THRESHOLD) * ShipTypes.STATION_FLEET_SCAN_PER_SHIP))
		if scan_range <= 0:
			continue

		var source_pos = _get_entity_position(fleet.source_system_id)
		var target_pos = _get_entity_position(fleet.target_system_id)

		for station in stations:
			if station["owner_id"] == fleet.owner_id:
				continue
			if fleet.owner_id in station["discovered_by"]:
				continue
			# Check minimum distance from fleet path to station
			var dist = _point_to_segment_distance(station["position"], source_pos, target_pos)
			if dist <= scan_range:
				station["discovered_by"].append(fleet.owner_id)


## Calculate minimum distance from point to line segment
func _point_to_segment_distance(point: Vector2, seg_start: Vector2, seg_end: Vector2) -> float:
	var seg = seg_end - seg_start
	var seg_len_sq = seg.length_squared()
	if seg_len_sq < 0.001:
		return point.distance_to(seg_start)
	var t = clampf((point - seg_start).dot(seg) / seg_len_sq, 0.0, 1.0)
	var closest = seg_start + seg * t
	return point.distance_to(closest)


## Draw all stations on the map
func _draw_stations() -> void:
	for station in stations:
		_draw_single_station(station)


## Draw a single station (diamond shape)
func _draw_single_station(station: Dictionary) -> void:
	var visible_to_player = _is_station_visible_to(station, current_player)
	if not visible_to_player:
		return

	var pos = station["position"]
	var size = STATION_DIAMOND_SIZE
	var color: Color

	if station["owner_id"] >= 0 and station["owner_id"] < players.size():
		color = players[station["owner_id"]].color
	else:
		color = Player.get_neutral_color()

	# Under construction: transparent
	if not station["operative"]:
		color.a = 0.5

	# Remembered (not in current visibility): gray
	var in_scan = _is_station_in_scan_range(station, current_player)
	if not in_scan and station["owner_id"] != current_player:
		color = Color(0.5, 0.5, 0.5, 0.5)

	# Draw diamond shape
	var diamond = PackedVector2Array([
		pos + Vector2(0, -size),   # Top
		pos + Vector2(size, 0),    # Right
		pos + Vector2(0, size),    # Bottom
		pos + Vector2(-size, 0),   # Left
	])
	draw_colored_polygon(diamond, color)

	# Outline
	var outline_color = color.lightened(0.3)
	outline_color.a = color.a
	for i in range(4):
		draw_line(diamond[i], diamond[(i + 1) % 4], outline_color, 1.5)

	# Build progress indicator (ring around diamond)
	if not station["operative"] and station["owner_id"] == current_player:
		var progress = float(station["build_progress"]) / float(ShipTypes.STATION_BUILD_ROUNDS)
		if progress > 0:
			var arc_radius = size + 4
			var arc_points = PackedVector2Array()
			var arc_steps = int(progress * 32)
			for i_step in range(arc_steps + 1):
				var angle = -PI / 2.0 + (float(i_step) / 32.0) * TAU
				arc_points.append(pos + Vector2(cos(angle), sin(angle)) * arc_radius)
			if arc_points.size() > 1:
				draw_polyline(arc_points, Color(0, 1, 1, 0.7), 2.0)

	# Battery indicator
	if station["battery_count"] > 0 and (station["owner_id"] == current_player or in_scan):
		var bat_text = "[%d]" % station["battery_count"]
		draw_string(ThemeDB.fallback_font, pos + Vector2(-10, size + 18), bat_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)

	# Ship count (only for own stations or visible garrison)
	if station["owner_id"] == current_player:
		if station["operative"]:
			var count_text = ""
			if station["fighter_count"] > 0 or station["bomber_count"] > 0:
				if station["bomber_count"] > 0:
					count_text = "%d/%d" % [station["fighter_count"], station["bomber_count"]]
				else:
					count_text = str(station["fighter_count"])
			if count_text != "":
				draw_string(ThemeDB.fallback_font, pos + Vector2(-20, -size - 6), count_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
	elif station["fighter_count"] > 0 or station["bomber_count"] > 0:
		# Enemy station with visible garrison
		var count_text = "?"
		draw_string(ThemeDB.fallback_font, pos + Vector2(-6, -size - 6), count_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)


## Perform passive scan from own systems and stations to discover enemy stations
func _perform_passive_scan(player_id: int) -> void:
	for station in stations:
		if station["owner_id"] == player_id:
			continue
		if player_id in station["discovered_by"]:
			continue
		if _is_station_in_scan_range(station, player_id):
			station["discovered_by"].append(player_id)


## Check if player has any stations (for elimination check)
func _player_has_stations(player_id: int) -> bool:
	for station in stations:
		if station["owner_id"] == player_id:
			return true
	return false


## Find station index by station ID (not array index)
func _find_station_by_id(station_id: int) -> int:
	for i in range(stations.size()):
		if stations[i]["id"] == station_id:
			return i
	return -1


## Process fleet arrivals at stations
func _process_station_fleet_arrivals(arriving_at_stations: Dictionary) -> void:
	# Sort station indices in descending order for safe removal during destruction
	var station_indices = arriving_at_stations.keys()
	station_indices.sort()
	station_indices.reverse()

	for station_idx in station_indices:
		var station = stations[station_idx]
		var fleets_here: Array = arriving_at_stations[station_idx]
		var old_owner = station["owner_id"]

		var merged = Combat.merge_fleets_by_owner(fleets_here)

		# Friendly fleets: deliver material or reinforce garrison
		if merged.has(old_owner):
			var friendly = merged[old_owner]
			for fleet in fleets_here:
				if fleet.owner_id == old_owner:
					_process_fleet_arrival_at_station(fleet, station)
			merged.erase(old_owner)

		# Enemy fleets: combat
		if merged.size() > 0:
			var result = _resolve_station_combat(station, merged)

			# Apply results
			if result["conquest_occurred"] or (result["winner"] != old_owner and result["winner"] >= 0):
				# Station conquered = destroyed
				# Create combat report
				var attacker_id = result["winner"]
				var report_data = {
					"system_name": "Station",
					"system_id": -1,
					"defender_name": _get_owner_name(old_owner),
					"defender_fighters": station["fighter_count"],
					"defender_bombers": station["bomber_count"],
					"defender_fighter_losses": result["defender_fighter_losses"],
					"defender_bomber_losses": result["defender_bomber_losses"],
					"attacker_name": _get_owner_name(attacker_id),
					"attacker_fighters": result["attacker_fighter_losses"] + result["remaining_fighters"],
					"attacker_bombers": result["attacker_bomber_losses"] + result["remaining_bombers"],
					"attacker_fighter_losses": result["attacker_fighter_losses"],
					"attacker_bomber_losses": result["attacker_bomber_losses"],
					"attacker_fighter_morale": result["attacker_fighter_morale"],
					"battery_fighter_kills": result["battery_kills"],
					"battery_bomber_kills": 0,
					"winner_name": _get_owner_name(attacker_id) + " (Station destroyed)",
					"remaining_fighters": result["remaining_fighters"],
					"remaining_bombers": result["remaining_bombers"],
					"batteries_before": station["battery_count"],
					"batteries_after": 0,
					"production_damage": 0,
					"conquest_occurred": true
				}

				# Report for involved players
				if old_owner >= 0:
					if not pending_combat_reports.has(old_owner):
						pending_combat_reports[old_owner] = []
					pending_combat_reports[old_owner].append(report_data)
				if attacker_id >= 0 and attacker_id != old_owner:
					if not pending_combat_reports.has(attacker_id):
						pending_combat_reports[attacker_id] = []
					pending_combat_reports[attacker_id].append(report_data)

				_destroy_station(station_idx)
			else:
				# Defender held
				station["fighter_count"] = result["remaining_fighters"]
				station["bomber_count"] = result["remaining_bombers"]




func _on_restart_pressed() -> void:
	game_over_screen.visible = false
	_show_setup_screen()
