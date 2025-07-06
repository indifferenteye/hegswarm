extends Object

class_name DroneMovement

var drone: Node2D
var move_speed: float
var separation_distance: float
var path_line: Node2D
var manual_destination: Vector2
var manual_destination_active: bool = false
var manual_target: Node2D = null

func _init(d: Node2D, path: Node2D, speed: float, separation: float) -> void:
    drone = d
    path_line = path
    move_speed = speed
    separation_distance = separation

func show_path_line_to(pos: Vector2) -> void:
    if path_line:
        path_line.start_pos = drone.global_position
        path_line.end_pos = pos
        path_line.visible = true

func hide_path_line() -> void:
    if path_line:
        path_line.visible = false

func apply_separation_force(delta: float) -> void:
    var push := Vector2.ZERO
    for d in drone.get_tree().get_nodes_in_group("drone"):
        if d == drone:
            continue
        var dist := drone.position.distance_to(d.position)
        if dist < separation_distance and dist > 0.0:
            push += (drone.position - d.position).normalized() * (separation_distance - dist)
    if push.length() > 0.0:
        drone.position += push.normalized() * move_speed * delta

func move_to(pos) -> void:
    manual_destination_active = true
    manual_target = null
    if pos is Node2D:
        manual_target = pos
        manual_destination = pos.global_position
    else:
        manual_destination = pos
    if path_line:
        path_line.start_pos = drone.global_position
        path_line.end_pos = manual_destination
        path_line.visible = true

func handle_manual_move(delta: float) -> bool:
    if not manual_destination_active:
        return false
    if manual_target and is_instance_valid(manual_target):
        manual_destination = manual_target.global_position
    var dist := drone.position.distance_to(manual_destination)
    if dist > separation_distance * 1.5:
        var dir := (manual_destination - drone.position).normalized()
        drone.position += dir * move_speed * delta
        if path_line:
            path_line.start_pos = drone.global_position
    else:
        manual_destination_active = false
        if manual_target and is_instance_valid(manual_target) and manual_target != drone:
            if manual_target.has_method("store_drone"):
                if manual_target.store_drone(drone):
                    hide_path_line()
                    return true
        if path_line:
            path_line.visible = false
    return true
