extends Node2D

@export var click_radius: float = 16.0

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        if global_position.distance_to(event.position) <= click_radius:
            print("planet clicked")
