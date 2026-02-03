extends Node2D
class_name StarSystem

## Represents a star system that can be owned by players

signal system_clicked(system: StarSystem)
signal system_hover_started(system: StarSystem)
signal system_hover_ended(system: StarSystem)

@export var system_id: int = 0
@export var system_name: String = "System"
@export var owner_id: int = -1  # -1 = neutral
@export var fighter_count: int = 10
@export var production_rate: int = 2  # Fighters produced per turn

var is_selected: bool = false
var is_hovered: bool = false

@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var label: Label = $Label
@onready var name_label: Label = $NameLabel


func _get_radius() -> float:
	# Radius based on production rate (1-5) -> (20-40 px)
	return 15.0 + (production_rate * 5.0)

var sprite: Sprite2D = null


func _ready() -> void:
	# Create circle using Sprite2D with generated texture
	_create_sprite_visual()

	update_visuals()

	# Setup collision shape based on production rate
	var shape = CircleShape2D.new()
	shape.radius = _get_radius() + 10
	collision_shape.shape = shape


func _create_sprite_visual() -> void:
	# Create a circle texture programmatically
	var radius = _get_radius()
	var img = Image.create(int(radius * 2 + 4), int(radius * 2 + 4), false, Image.FORMAT_RGBA8)
	var center = Vector2(radius + 2, radius + 2)
	var color = _get_owner_color()

	# Fill with circle
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
	if owner_id < 0:
		return Player.get_neutral_color()
	return Player.get_player_color(owner_id)


func update_visuals() -> void:
	_update_circle_visuals()
	_update_labels()


func _update_circle_visuals() -> void:
	if sprite:
		# Regenerate texture with new color
		var radius = _get_radius()
		var img = Image.create(int(radius * 2 + 4), int(radius * 2 + 4), false, Image.FORMAT_RGBA8)
		var center = Vector2(radius + 2, radius + 2)
		var color = _get_owner_color()
		var outline_color = Color.WHITE if is_selected else color.lightened(0.3)

		for x in range(img.get_width()):
			for y in range(img.get_height()):
				var dist = Vector2(x, y).distance_to(center)
				if dist <= radius:
					img.set_pixel(x, y, color)
				elif dist <= radius + 2:
					img.set_pixel(x, y, outline_color)
				else:
					img.set_pixel(x, y, Color(0, 0, 0, 0))

		sprite.texture = ImageTexture.create_from_image(img)


func _update_labels() -> void:
	var radius = _get_radius()
	if label:
		label.text = str(fighter_count)
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


## Show the star system
func show_system() -> void:
	visible = true


## Show hidden info for fog of war (visible but not owned)
func show_hidden_info() -> void:
	if label:
		label.text = "?"


## Show actual fighter count
func show_fighter_count() -> void:
	if label:
		label.text = str(fighter_count)


func set_selected(selected: bool) -> void:
	is_selected = selected
	_update_circle_visuals()


func set_system_owner(new_owner: int) -> void:
	owner_id = new_owner
	update_visuals()


func add_fighters(count: int) -> void:
	fighter_count = max(0, fighter_count + count)
	update_visuals()


func remove_fighters(count: int) -> int:
	var removed = min(fighter_count, count)
	fighter_count -= removed
	update_visuals()
	return removed


func produce_fighters() -> void:
	if owner_id >= 0:  # Only owned systems produce
		fighter_count += production_rate


func get_distance_to(other_system: StarSystem) -> float:
	return global_position.distance_to(other_system.global_position)


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			system_clicked.emit(self)


func _on_area_2d_mouse_entered() -> void:
	is_hovered = true
	queue_redraw()
	system_hover_started.emit(self)


func _on_area_2d_mouse_exited() -> void:
	is_hovered = false
	queue_redraw()
	system_hover_ended.emit(self)
