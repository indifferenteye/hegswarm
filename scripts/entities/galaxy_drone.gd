extends Node2D

@export var move_speed: float = 80.0
@export var enter_distance: float = 40.0

## Seed of the star this drone currently belongs to.
@export var belongs_to_star_seed: int = 0

var target_position: Vector2
var path_line: Node2D

func _ready() -> void:
    add_to_group("galaxy_drone")
    target_position = position
    path_line = preload("res://scripts/utils/path_line.gd").new()
    path_line.set_as_top_level(true)
    path_line.visible = false
    if get_parent():
        get_parent().add_child(path_line)

func move_to(pos: Vector2) -> void:
    target_position = pos
    if path_line:
        path_line.start_pos = global_position
        path_line.end_pos = pos
        path_line.visible = true

func is_near(pos: Vector2) -> bool:
    return position.distance_to(pos) <= enter_distance

func _process(delta: float) -> void:
    var delta_pos := target_position - position
    if delta_pos.length() > 1.0:
        position += delta_pos.normalized() * move_speed * delta
        if path_line:
            path_line.start_pos = global_position
    else:
        if path_line:
            path_line.visible = false
