extends Node2D

## Unique seed for this star, useful for deterministic system generation.
@export var seed: int = 0

## Called when the node is ready. Sets up input handling so the star can be
## clicked by the player.
func _on_ready() -> void:
    input_pickable = true

## Handles mouse input on the star. When the player left-clicks the star, the
## scene changes to the star system view.
func _input_event(viewport, event: InputEvent, _shape_idx: int) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        get_tree().change_scene_to_file("res://scenes/starSystem.tscn")
