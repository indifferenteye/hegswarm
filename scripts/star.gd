extends Node2D

## Unique seed for this star, useful for deterministic system generation.
@export var seed: int = 0

## Handles mouse input on the star. When the player left-clicks the star, the
## scene changes to the star system view.
func _on_sprite_input_event(viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_tree().change_scene_to_file("res://scenes/star_system.tscn")


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		_on_sprite_input_event(viewport, event, shape_idx)
