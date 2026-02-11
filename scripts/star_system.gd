extends Node2D
class_name StarSystem

## Represents a star system that can be owned by players

signal system_clicked(system: StarSystem)
signal system_double_clicked(system: StarSystem)
signal system_hover_started(system: StarSystem)
signal system_hover_ended(system: StarSystem)

enum ProductionMode {
	FIGHTERS,
	BOMBERS,
	UPGRADE,
	BATTERY_BUILD
}

@export var system_id: int = 0
@export var system_name: String = "System"
@export var owner_id: int = -1  # -1 = neutral
@export var fighter_count: int = 10
@export var bomber_count: int = 0
@export var production_rate: int = 2  # Fighters produced per turn
@export var battery_count: int = 0  # Defense batteries (max 3)

var production_mode: ProductionMode = ProductionMode.FIGHTERS
var bomber_production_progress: float = 0.0  # Batch delivery every 2 turns
var upgrade_progress: float = 0.0  # Progress towards next production rate
var battery_build_progress: float = 0.0  # Progress towards next battery (2 turns per battery)

var is_selected: bool = false
var is_hovered: bool = false
var is_remembered: bool = false  # Fog of war: seen before but not currently visible

# Selection animation
var selection_pulse_time: float = 0.0
const PULSE_SPEED: float = 2.0  # Cycles per second
const HALO_SIZE: float = 12.0  # Extra pixels for halo effect
const SELECTION_OUTLINE_WIDTH: float = 4.0

@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var label: Label = $Label
@onready var name_label: Label = $NameLabel


func _get_radius() -> float:
	# Radius based on production rate (1-8) -> (12.5-30 px)
	return 10.0 + (production_rate * 2.5)

var sprite: Sprite2D = null


func _ready() -> void:
	# Create circle using Sprite2D with generated texture
	_create_sprite_visual()

	update_visuals()

	# Setup collision shape based on production rate
	var shape = CircleShape2D.new()
	shape.radius = _get_radius() + 10
	collision_shape.shape = shape


func _process(delta: float) -> void:
	if is_selected:
		selection_pulse_time += delta * PULSE_SPEED
		_update_circle_visuals()
	elif selection_pulse_time != 0.0:
		selection_pulse_time = 0.0


func _create_sprite_visual() -> void:
	# Create a circle texture programmatically (with extra space for halo)
	var radius = _get_radius()
	var total_size = int((radius + HALO_SIZE + SELECTION_OUTLINE_WIDTH) * 2 + 4)
	var img = Image.create(total_size, total_size, false, Image.FORMAT_RGBA8)
	var center = Vector2(total_size / 2.0, total_size / 2.0)
	var color = _get_owner_color()

	# Fill with circle (no selection initially)
	for x in range(img.get_width()):
		for y in range(img.get_height()):
			var dist = Vector2(x, y).distance_to(center)
			if dist <= radius:
				img.set_pixel(x, y, color)
			elif dist <= radius + 2:
				img.set_pixel(x, y, color.lightened(0.3))
			else:
				img.set_pixel(x, y, Color(0, 0, 0, 0))

	var texture = ImageTexture.create_from_image(img)
	sprite = Sprite2D.new()
	sprite.texture = texture
	add_child(sprite)


func _get_owner_color() -> Color:
	var color: Color
	if owner_id < 0:
		color = Player.get_neutral_color()
	else:
		color = Player.get_player_color(owner_id)
	# Desaturate and darken for remembered (fog of war) systems
	if is_remembered:
		color = color.darkened(0.5)
		color.s *= 0.3  # Reduce saturation
	return color


func update_visuals() -> void:
	_update_circle_visuals()
	_update_labels()


func _update_circle_visuals() -> void:
	if sprite:
		# Regenerate texture with new color
		var radius = _get_radius()
		var total_size = int((radius + HALO_SIZE + SELECTION_OUTLINE_WIDTH) * 2 + 4)
		var img = Image.create(total_size, total_size, false, Image.FORMAT_RGBA8)
		var center = Vector2(total_size / 2.0, total_size / 2.0)
		var color = _get_owner_color()

		# Calculate pulse value (0.0 to 1.0)
		var pulse = (sin(selection_pulse_time * TAU) + 1.0) / 2.0 if is_selected else 0.0

		# Selection colors - cyan with pulse
		var selection_color = Color(0.0, 0.9, 1.0, 0.8 + pulse * 0.2)  # Cyan, pulsing alpha
		var halo_base_alpha = 0.3 + pulse * 0.2

		for x in range(img.get_width()):
			for y in range(img.get_height()):
				var dist = Vector2(x, y).distance_to(center)

				if dist <= radius:
					# Star core
					img.set_pixel(x, y, color)
				elif dist <= radius + 2:
					# Normal outline
					var outline_color = color.lightened(0.3)
					img.set_pixel(x, y, outline_color)
				elif is_selected:
					# Selection effects
					if dist <= radius + 2 + SELECTION_OUTLINE_WIDTH:
						# Solid selection outline (4px)
						img.set_pixel(x, y, selection_color)
					elif dist <= radius + 2 + SELECTION_OUTLINE_WIDTH + HALO_SIZE:
						# Soft halo glow
						var halo_dist = dist - (radius + 2 + SELECTION_OUTLINE_WIDTH)
						var halo_alpha = (1.0 - halo_dist / HALO_SIZE) * halo_base_alpha
						var halo_color = Color(0.0, 0.9, 1.0, halo_alpha)
						img.set_pixel(x, y, halo_color)
					else:
						img.set_pixel(x, y, Color(0, 0, 0, 0))
				else:
					img.set_pixel(x, y, Color(0, 0, 0, 0))

		sprite.texture = ImageTexture.create_from_image(img)


func _update_labels() -> void:
	var radius = _get_radius()
	if label:
		# Show fighters/bombers count
		if bomber_count > 0:
			label.text = "%d/%d" % [fighter_count, bomber_count]
		else:
			label.text = str(fighter_count)

		# Add battery indicator if batteries exist
		if battery_count > 0:
			label.text += " [%d]" % battery_count

		label.add_theme_color_override("font_color", Color.WHITE)
		# Position label above the star based on radius
		label.position = Vector2(-40, -radius - 30)
	if name_label:
		name_label.text = system_name
		name_label.add_theme_color_override("font_color", Color.WHITE)
		# Position name label below the star based on radius
		name_label.position = Vector2(-60, radius + 5)


## Hide the entire star system (fog of war - not in visibility range)
func hide_system() -> void:
	visible = false
	is_remembered = false


## Show the star system
func show_system() -> void:
	visible = true
	is_remembered = false


## Show hidden info for fog of war (visible but not owned)
func show_hidden_info(memory: Dictionary = {}) -> void:
	is_remembered = false
	if label:
		var text = _format_intel(memory, false)
		label.text = text


## Show remembered info (fog of war - previously seen but not currently visible)
func show_remembered_info(memory: Dictionary) -> void:
	visible = true
	is_remembered = true
	if label:
		label.text = _format_intel(memory, true)
		label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	if name_label:
		name_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	_update_circle_visuals()


## Format ship/battery intel from memory for display
func _format_intel(memory: Dictionary, is_memory: bool) -> String:
	var known_fighters = memory.get("fighter_count", "?")
	var known_bombers = memory.get("bomber_count", 0)
	var known_batteries = memory.get("battery_count", -1)
	var has_batteries_flag = memory.get("has_batteries", battery_count > 0)

	var text = ""
	if known_fighters is int:
		# Known counts from combat intel — show in parentheses
		if known_bombers > 0:
			text = "(%d/%d)" % [known_fighters, known_bombers]
		else:
			text = "(%d)" % known_fighters
	else:
		text = "?"

	# Battery display
	if known_batteries > 0:
		text += " [(%d)]" % known_batteries
	elif has_batteries_flag:
		text += " [?]"

	return text


## Show actual fighter/bomber count
func show_fighter_count() -> void:
	_update_labels()


func set_selected(selected: bool) -> void:
	is_selected = selected
	if not selected:
		selection_pulse_time = 0.0
	_update_circle_visuals()


func set_system_owner(new_owner: int) -> void:
	owner_id = new_owner
	update_visuals()


func add_fighters(count: int) -> void:
	fighter_count = max(0, fighter_count + count)
	update_visuals()


func add_bombers(count: int) -> void:
	bomber_count = max(0, bomber_count + count)
	update_visuals()


func remove_fighters(count: int) -> int:
	var removed = min(fighter_count, count)
	fighter_count -= removed
	update_visuals()
	return removed


func remove_bombers(count: int) -> int:
	var removed = min(bomber_count, count)
	bomber_count -= removed
	update_visuals()
	return removed


func get_total_ships() -> int:
	return fighter_count + bomber_count


## Process production for this turn based on production mode
func process_production() -> void:
	if owner_id < 0:  # Only owned systems produce
		return

	match production_mode:
		ProductionMode.FIGHTERS:
			fighter_count += production_rate
		ProductionMode.BOMBERS:
			# Half production rate (FUT-07): full batch every 2 turns
			bomber_production_progress += ShipTypes.BOMBER_PRODUCTION_MULTIPLIER
			if bomber_production_progress >= 1.0:
				bomber_count += production_rate
				bomber_production_progress = 0.0
		ProductionMode.UPGRADE:
			if production_rate < ShipTypes.MAX_PRODUCTION_RATE:
				upgrade_progress += 1.0 / production_rate
				if upgrade_progress >= 1.0:
					production_rate += 1
					upgrade_progress = 0.0
					production_mode = ProductionMode.FIGHTERS
		ProductionMode.BATTERY_BUILD:
			if battery_count < ShipTypes.MAX_BATTERIES:
				# Build time scales with target level (like production upgrade)
				battery_build_progress += 1.0 / (battery_count + 1)
				if battery_build_progress >= 1.0:
					battery_count += 1
					battery_build_progress = 0.0
					# Switch back to fighters production
					production_mode = ProductionMode.FIGHTERS

	update_visuals()


## Apply production damage from bomber attack
## damage_ratio is the ratio of attackers to defenders (capped at reasonable values)
func apply_production_damage(damage_ratio: float) -> int:
	var damage = int(ceil(damage_ratio))
	var old_rate = production_rate
	production_rate = max(ShipTypes.MIN_PRODUCTION_RATE, production_rate - damage)
	update_visuals()
	return old_rate - production_rate


## Apply conquest penalty (FUT-08)
func apply_conquest_penalty() -> void:
	production_rate = max(ShipTypes.MIN_PRODUCTION_RATE, production_rate - ShipTypes.CONQUEST_PRODUCTION_LOSS)
	update_visuals()


## Set production mode
func set_production_mode(mode: ProductionMode) -> void:
	production_mode = mode
	# Reset progress when switching modes
	if mode != ProductionMode.BOMBERS:
		bomber_production_progress = 0.0
	if mode != ProductionMode.UPGRADE:
		upgrade_progress = 0.0
	if mode != ProductionMode.BATTERY_BUILD:
		battery_build_progress = 0.0


## Get current production mode as string
func get_production_mode_string() -> String:
	match production_mode:
		ProductionMode.FIGHTERS:
			return "Producing Fighters (+%d/turn)" % production_rate
		ProductionMode.BOMBERS:
			var total_turns = int(1.0 / ShipTypes.BOMBER_PRODUCTION_MULTIPLIER)
			var done_turns = int(bomber_production_progress * total_turns)
			return "Producing Bombers (%d/%d)" % [done_turns, total_turns]
		ProductionMode.UPGRADE:
			var total_turns = production_rate
			var done_turns = int(upgrade_progress * total_turns)
			return "Upgrading (%d/%d)" % [done_turns, total_turns]
		ProductionMode.BATTERY_BUILD:
			var total_turns = battery_count + 1
			var done_turns = int(battery_build_progress * total_turns)
			return "Building Battery (%d/%d)" % [done_turns, total_turns]
	return "Unknown"



func get_distance_to(other_system: StarSystem) -> float:
	return global_position.distance_to(other_system.global_position)


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if event.double_click:
				system_double_clicked.emit(self)
			else:
				system_clicked.emit(self)


func _on_area_2d_mouse_entered() -> void:
	is_hovered = true
	queue_redraw()
	system_hover_started.emit(self)


func _on_area_2d_mouse_exited() -> void:
	is_hovered = false
	queue_redraw()
	system_hover_ended.emit(self)
