extends Node2D

@export var move_speed: float = 50.0
@export var detection_range: float = 300.0
@export var mining_range: float = 20.0
@export var mining_rate: float = 1.0

var target: Node2D = null

func _process(delta: float) -> void:
    if target == null or not is_instance_valid(target):
        target = _find_nearest_asteroid()
    if target == null:
        return
    var dist := position.distance_to(target.global_position)
    if dist > mining_range:
        var dir := (target.global_position - position).normalized()
        position += dir * move_speed * delta
    else:
        if target.has_method("mine"):
            target.mine(mining_rate * delta)
            if not is_instance_valid(target):
                target = null

func _find_nearest_asteroid() -> Node2D:
    var nearest := null
    var nearest_dist := detection_range
    for asteroid in get_tree().get_nodes_in_group("asteroid"):
        var d := position.distance_to(asteroid.global_position)
        if d < nearest_dist:
            nearest_dist = d
            nearest = asteroid
    return nearest
