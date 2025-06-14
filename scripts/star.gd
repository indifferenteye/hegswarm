extends Node2D

## Unique seed for this star, useful for deterministic system generation.
@export var seed: int = 0

## Called when the node is ready. Sets up input handling so the star can be
## clicked by the player. In Godot 4 the ``input_pickable`` property must be
## enabled on the ``Sprite2D`` child so that its ``input_event`` signal emits
## when clicked.
func _on_ready() -> void:
    var sprite: Sprite2D = $Sprite2D
    sprite.input_pickable = true
    sprite.connect("input_event", _on_sprite_input_event)

## Handles mouse input on the star. When the player left-clicks the star, the
## scene changes to the star system view.
func _on_sprite_input_event(viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        get_tree().change_scene_to_file("res://scenes/starSystem.tscn")
