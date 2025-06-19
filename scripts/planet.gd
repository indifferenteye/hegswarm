extends Node2D

@export var click_radius: float = 16.0
@export var seed: int = 0
@export_range(0.0, 1.0) var water: float = 0.5
@export_range(0.0, 1.0) var plants: float = 0.5

func _ready() -> void:
    var mat := $Sprite2D.material
    if mat != null:
        mat.set_shader_parameter("seed", float(seed))
        mat.set_shader_parameter("water", water)
        mat.set_shader_parameter("plants", plants)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        if global_position.distance_to(get_global_mouse_position()) <= click_radius:
            print("planet clicked")
