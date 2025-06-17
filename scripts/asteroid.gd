extends Node2D

@export var radius: float = 2.0
@export var click_radius: float = 4.0
@export var color: Color = Color.WHITE

func _ready() -> void:
    pass

func _draw() -> void:
    draw_circle(Vector2.ZERO, radius, color)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        if global_position.distance_to(get_global_mouse_position()) <= click_radius:
            print("asteroid clicked")
