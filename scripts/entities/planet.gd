extends Node2D

@export var click_radius: float = 16.0
@export var seed: int = 0
@export_range(0.0, 1.0) var water: float = 0.5
@export_range(0.0, 1.0) var plants: float = 0.5
@export_range(5.0, 40.0) var grid_size: float = 20.0

func _ready() -> void:
    if $Sprite2D.material:
        $Sprite2D.material = $Sprite2D.material.duplicate()
        var mat = $Sprite2D.material
        mat.set_shader_parameter("seed", float(seed))
        mat.set_shader_parameter("water", water)
        mat.set_shader_parameter("plants", plants)
        mat.set_shader_parameter("grid_size", grid_size)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        if global_position.distance_to(get_global_mouse_position()) <= click_radius:
            print("planet clicked")
