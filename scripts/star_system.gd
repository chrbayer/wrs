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
var base_radius: float = 30.0

@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var label: Label = $Label
@onready var production_label: Label = $ProductionLabel

var sprite: Sprite2D = null


func _ready() -> void:
	# Create circle using Sprite2D with generated texture
	_create_sprite_visual()

	update_visuals()

	# Setup collision shape
	var shape = CircleShape2D.new()
	shape.radius = base_radius + 10
	collision_shape.shape = shape


func _create_sprite_visual() -> void:
	# Create a circle texture programmatically
	var img = Image.create(int(base_radius * 2 + 4), int(base_radius * 2 + 4), false, Image.FORMAT_RGBA8)
	var center = Vector2(base_radius + 2, base_radius + 2)
	var color = _get_owner_color()

	# Fill with circle
	for x in range(img.get_width()):
		for y in range(img.get_height()):
			var dist = Vector2(x, y).distance_to(center)
			if dist <= base_radius:
				img.set_pixel(x, y, color)
			elif dist <= base_radius + 2:
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
		var img = Image.create(int(base_radius * 2 + 4), int(base_radius * 2 + 4), false, Image.FORMAT_RGBA8)
		var center = Vector2(base_radius + 2, base_radius + 2)
		var color = _get_owner_color()
		var outline_color = Color.WHITE if is_selected else color.lightened(0.3)

		for x in range(img.get_width()):
			for y in range(img.get_height()):
				var dist = Vector2(x, y).distance_to(center)
				if dist <= base_radius:
					img.set_pixel(x, y, color)
				elif dist <= base_radius + 2:
					img.set_pixel(x, y, outline_color)
				else:
					img.set_pixel(x, y, Color(0, 0, 0, 0))

		sprite.texture = ImageTexture.create_from_image(img)


func _update_labels() -> void:
	if label:
		label.text = str(fighter_count)
		label.add_theme_color_override("font_color", Color.WHITE)

	if production_label:
		production_label.text = "+%d" % production_rate
		production_label.add_theme_color_override("font_color", Color(0.56, 0.93, 0.56))


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
