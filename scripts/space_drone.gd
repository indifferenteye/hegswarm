extends Node2D

@export var move_speed: float = 50.0
@export var detection_range: float = 800.0
@export var mining_range: float = 20.0
@export var mining_rate: float = 1.0
## Minimum distance this drone tries to keep from other drones.
@export var separation_distance: float = 30.0

var target: Node2D = null
var manual_target: Vector2
var has_manual_target: bool = false
var carrying: Node2D = null
var deliver_target: Node2D = null

## Push away from nearby drones to avoid clumping.
func _apply_separation(delta: float) -> void:
    var push := Vector2.ZERO
    for d in get_tree().get_nodes_in_group("drone"):
        if d == self:
            continue
        var dist := position.distance_to(d.position)
        if dist < separation_distance and dist > 0.0:
            push += (position - d.position).normalized() * (separation_distance - dist)
    if push.length() > 0.0:
        position += push.normalized() * move_speed * delta

func move_to(pos: Vector2) -> void:
    manual_target = pos
    has_manual_target = true

func _process(delta: float) -> void:
    _apply_separation(delta)
    if has_manual_target:
        var dist := position.distance_to(manual_target)
        if dist > 5.0:
            var dir := (manual_target - position).normalized()
            position += dir * move_speed * delta
            return
        else:
            has_manual_target = false
    if carrying != null:
        if deliver_target == null or not is_instance_valid(deliver_target):
            deliver_target = _find_nearest_blueprint()
        if deliver_target == null:
            carrying.queue_free()
            carrying = null
            return
        var dist := position.distance_to(deliver_target.global_position)
        if dist > mining_range:
            var dir := (deliver_target.global_position - position).normalized()
            position += dir * move_speed * delta
        else:
            if deliver_target.has_method("add_iron"):
                deliver_target.add_iron()
            carrying.queue_free()
            carrying = null
            deliver_target = null
        return

    var iron := _find_nearest_processed_iron()
    var blueprint := _find_nearest_blueprint()
    if iron != null and blueprint != null:
        var dist := position.distance_to(iron.global_position)
        if dist > mining_range:
            var dir := (iron.global_position - position).normalized()
            position += dir * move_speed * delta
        else:
            carrying = iron
        return

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
    var nearest
    var nearest_dist := detection_range
    for asteroid in get_tree().get_nodes_in_group("asteroid"):
        var d := position.distance_to(asteroid.global_position)
        if d < nearest_dist:
            nearest_dist = d
            nearest = asteroid
    return nearest

func _find_nearest_processed_iron() -> Node2D:
    var nearest
    var nearest_dist := detection_range
    for iron in get_tree().get_nodes_in_group("processed_iron"):
        var d := position.distance_to(iron.global_position)
        if d < nearest_dist:
            nearest_dist = d
            nearest = iron
    return nearest

func _find_nearest_blueprint() -> Node2D:
    var nearest
    var nearest_dist := detection_range
    for bp in get_tree().get_nodes_in_group("drone_blueprint"):
        var d := position.distance_to(bp.global_position)
        if d < nearest_dist:
            nearest_dist = d
            nearest = bp
    return nearest
