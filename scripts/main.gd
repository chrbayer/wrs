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
@onready var send_all_button: Button = $HUD/SendPanel/VBox/SendButtonContainer/SendAllButton
@onready var cancel_button: Button = $HUD/SendPanel/VBox/CancelButton

# Production action panel
@onready var action_panel: Panel = $HUD/ActionPanel
@onready var produce_fighters_btn: Button = $HUD/ActionPanel/VBox/ProduceFightersBtn
@onready var produce_bombers_btn: Button = $HUD/ActionPanel/VBox/ProduceBombersBtn
@onready var upgrade_btn: Button = $HUD/ActionPanel/VBox/UpgradeBtn
@onready var build_battery_btn: Button = $HUD/ActionPanel/VBox/BuildBatteryBtn
@onready var action_close_btn: Button = $HUD/ActionPanel/VBox/CloseBtn

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
	player_count_option.item_selected.connect(_on_player_count_changed)
	start_game_button.pressed.connect(_on_start_game_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	close_report_button.pressed.connect(_on_close_report_pressed)

	# Action panel connections
	produce_fighters_btn.pressed.connect(_on_produce_fighters_pressed)
	produce_bombers_btn.pressed.connect(_on_produce_bombers_pressed)
	upgrade_btn.pressed.connect(_on_upgrade_pressed)
	build_battery_btn.pressed.connect(_on_build_battery_pressed)
	action_close_btn.pressed.connect(_on_action_close_pressed)

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

	# Distribute starting fighters based on home world connectivity
	var start_fighters: Array[int] = UniverseGenerator.generate_player_start_fighters(positions, player_starts)

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
			players[player_start_idx].home_system_id = system.system_id
			system.fighter_count = start_fighters[player_start_idx]
			system.production_rate = 3  # Standard production for home systems
		else:
			system.owner_id = -1  # Neutral
			system.production_rate = UniverseGenerator.generate_production_rate()
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

	# Update visibility overlay texture
	_update_visibility_texture(owned_systems)


func _update_visibility_texture(owned_systems: Array[StarSystem]) -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	var img = Image.create(int(viewport_size.x), int(viewport_size.y), false, Image.FORMAT_RGBA8)

	var radius = UniverseGenerator.MAX_SYSTEM_DISTANCE
	var radius_sq = radius * radius

	# For each pixel, check if it's within range of any owned system
	for x in range(img.get_width()):
		for y in range(img.get_height()):
			var pos = Vector2(x, y)
			var in_range = false
			for system in owned_systems:
				if pos.distance_squared_to(system.global_position) <= radius_sq:
					in_range = true
					break
			if in_range:
				img.set_pixel(x, y, VISIBILITY_COLOR)

	visibility_texture = ImageTexture.create_from_image(img)
	queue_redraw()


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
	if send_panel.visible:
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
	system.set_selected(true)
	send_panel.visible = false
	action_panel.visible = false
	show_fleet_arrow = false
	queue_redraw()

	_show_system_info(system)


func _on_system_double_clicked(system: StarSystem) -> void:
	if game_ended or transition_screen.visible or combat_report_screen.visible:
		return
	if send_panel.visible:
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

	# Update button text to show current state
	produce_fighters_btn.text = "Produce Fighters"
	produce_bombers_btn.text = "Produce Bombers"
	upgrade_btn.text = "Upgrade Production (%d/%d)" % [system.production_rate, ShipTypes.MAX_PRODUCTION_RATE]
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

	if event.is_action_pressed("ui_cancel"):
		if combat_report_screen.visible:
			_on_close_report_pressed()
		elif send_panel.visible:
			_on_send_cancelled()
		elif action_panel.visible:
			_on_action_close_pressed()
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

		# Score: prefer far from arrow and both stars
		var score = min_dist_line * 2.0 + min(min_dist_target, 150.0) - min_dist_source * 0.2

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
	var morale = Fleet.calculate_fighter_morale(travel_time)

	var text = "Send %d fighters" % fighters
	if morale < 1.0 and fighters > 0:
		text += " (%d%% morale)" % int(morale * 100)
	if bombers > 0:
		text += ", %d bombers" % bombers
	text += " (arrives in %d turns)" % max(1, travel_time)
	send_count_label.text = text


func _on_send_all_confirmed() -> void:
	var max_total: int = ShipTypes.MAX_FLEET_SIZE
	var available_f: int = int(fighter_slider.max_value)
	var available_b: int = int(bomber_slider.max_value) if bomber_slider.visible else 0
	var total: int = available_f + available_b

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
	# Check if a player has no systems and no fleets
	for system in systems:
		if system.owner_id == player_id:
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
		system_memory
	)

	# Apply production changes
	for change in decisions["production_changes"]:
		var sys = systems[change["system_id"]]
		if sys.owner_id != current_player:
			continue
		if change.has("mode"):
			sys.set_production_mode(change["mode"])

	# Apply fleet orders
	for order in decisions["fleet_orders"]:
		var source = systems[order["source_id"]]
		var target = systems[order["target_id"]]
		if source.owner_id != current_player:
			continue

		var fighters = min(order["fighters"], source.fighter_count)
		var bombers = min(order["bombers"], source.bomber_count)

		if fighters <= 0 and bombers <= 0:
			continue

		var distance = source.global_position.distance_to(target.global_position)
		var fleet = Fleet.new(
			current_player,
			fighters,
			source.system_id,
			target.system_id,
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

	# 1. Production in owned systems
	for system in systems:
		if system.owner_id >= 0:
			system.process_production()

	# 2. Rebellions (after production, before fleet arrival)
	_process_rebellions()

	# 3. Process arriving fleets (renumbered from 2)
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

		var result = Combat.resolve_system_combat(system, merged)

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


func _process_rebellions() -> void:
	# Count systems per active (non-eliminated) player
	var system_counts: Dictionary = {}  # player_id -> count
	var active_players: int = 0
	for i in range(player_count):
		if not _is_player_eliminated(i):
			active_players += 1
			system_counts[i] = 0

	if active_players == 0:
		return

	for system in systems:
		if system.owner_id >= 0 and system_counts.has(system.owner_id):
			system_counts[system.owner_id] += 1

	var total_owned: int = 0
	for pid in system_counts:
		total_owned += system_counts[pid]

	var average: float = float(total_owned) / float(active_players)

	for player_id in system_counts:
		var count: int = system_counts[player_id]
		if count <= average * ShipTypes.REBELLION_DOMINANCE_FACTOR:
			continue

		var rebellion_chance: float = (count - average) * ShipTypes.REBELLION_CHANCE_PER_EXCESS

		for system in systems:
			if system.owner_id != player_id:
				continue
			# Home systems are immune
			if system.system_id == players[player_id].home_system_id:
				continue
			# Systems with batteries are immune
			if system.battery_count > 0:
				continue
			# Last system is immune (prevent indirect elimination via rebellion)
			if count <= 1:
				continue

			if randf() < rebellion_chance:
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


func _on_restart_pressed() -> void:
	game_over_screen.visible = false
	_show_setup_screen()
