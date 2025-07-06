extends Object

class_name DroneMining

var drone: Node2D
var move_speed: float
var mining_range: float
var mining_rate: float
var detection_range: float
var path_line: Node2D
var asteroid_target: Node2D = null

func _init(d: Node2D, path: Node2D, speed: float, range: float, rate: float, detect: float) -> void:
    drone = d
    path_line = path
    move_speed = speed
    mining_range = range
    mining_rate = rate
    detection_range = detect

func show_path_line_to(pos: Vector2) -> void:
    if path_line:
        path_line.start_pos = drone.global_position
        path_line.end_pos = pos
        path_line.visible = true

func hide_path_line() -> void:
    if path_line:
        path_line.visible = false

func mine_or_move_asteroid(delta: float) -> void:
    if asteroid_target == null or not is_instance_valid(asteroid_target):
        asteroid_target = get_nearest_asteroid()
    if asteroid_target == null:
        hide_path_line()
        return
    var dist := drone.position.distance_to(asteroid_target.global_position)
    if dist > mining_range:
        var dir := (asteroid_target.global_position - drone.position).normalized()
        drone.position += dir * move_speed * delta
        show_path_line_to(asteroid_target.global_position)
    elif asteroid_target.has_method("mine"):
        asteroid_target.mine(mining_rate * delta)
        if not is_instance_valid(asteroid_target):
            asteroid_target = null
        hide_path_line()

func get_nearest_asteroid() -> Node2D:
    var closest
    var closest_distance := detection_range
    for asteroid in drone.get_tree().get_nodes_in_group("asteroid"):
        var distance := drone.position.distance_to(asteroid.global_position)
        if distance < closest_distance:
            closest_distance = distance
            closest = asteroid
    return closest
