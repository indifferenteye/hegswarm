extends Object

class_name DroneCargo

var drone: Node2D
var move_speed: float
var detection_range: float
var mining_range: float
var path_line: Node2D

var carried_material = null
var blueprint_target: Node2D = null
var cluster_target: Node2D = null
var deliver_to_cluster: bool = false

func _init(d: Node2D, path: Node2D, speed: float, detect: float, range: float) -> void:
    drone = d
    path_line = path
    move_speed = speed
    detection_range = detect
    mining_range = range

func show_path_line_to(pos: Vector2) -> void:
    if path_line:
        path_line.start_pos = drone.global_position
        path_line.end_pos = pos
        path_line.visible = true

func hide_path_line() -> void:
    if path_line:
        path_line.visible = false

func deliver_material(delta: float) -> bool:
    if carried_material == null:
        return false
    if blueprint_target == null or not is_instance_valid(blueprint_target):
        blueprint_target = get_nearest_blueprint()
    if blueprint_target == null:
        hide_path_line()
        return true
    var dist := drone.position.distance_to(blueprint_target.global_position)
    if dist > mining_range:
        var dir := (blueprint_target.global_position - drone.position).normalized()
        drone.position += dir * move_speed * delta
        show_path_line_to(blueprint_target.global_position)
    else:
        if blueprint_target.has_method("add_material"):
            blueprint_target.add_material(carried_material["material_type"])
        carried_material = null
        blueprint_target = null
        hide_path_line()
    return true

func deliver_to_cluster_action(delta: float) -> bool:
    if carried_material == null:
        return false
    if cluster_target == null or not is_instance_valid(cluster_target):
        cluster_target = get_cluster_with_room()
        if cluster_target == null:
            cluster_target = create_cluster()
    else:
        if "stored_amount" in cluster_target and "capacity" in cluster_target:
            if cluster_target.stored_amount >= cluster_target.capacity:
                cluster_target = get_cluster_with_room()
                if cluster_target == null:
                    cluster_target = create_cluster()
    if cluster_target == null:
        hide_path_line()
        return true
    var dist := drone.position.distance_to(cluster_target.global_position)
    if dist > mining_range:
        var dir := (cluster_target.global_position - drone.position).normalized()
        drone.position += dir * move_speed * delta
        show_path_line_to(cluster_target.global_position)
    else:
        if cluster_target.has_method("add_material"):
            if cluster_target.add_material(carried_material["material_type"]):
                carried_material = null
                deliver_to_cluster = false
                cluster_target = null
        hide_path_line()
    return true

func take_from_cluster(delta: float) -> bool:
    var cluster := get_nearest_cluster()
    var blueprint := get_nearest_blueprint()
    if cluster == null or blueprint == null:
        hide_path_line()
        return false
    if not blueprint.has_method("needs_material") or not blueprint.needs_material(cluster.material_type):
        hide_path_line()
        return false
    var dist := drone.position.distance_to(cluster.global_position)
    if dist > mining_range:
        var dir := (cluster.global_position - drone.position).normalized()
        drone.position += dir * move_speed * delta
        show_path_line_to(cluster.global_position)
    else:
        if cluster.has_method("take_material") and cluster.take_material():
            carried_material = {"material_type": cluster.material_type}
            blueprint_target = blueprint
            deliver_to_cluster = false
        hide_path_line()
    return true

func collect_material(delta: float) -> bool:
    var iron := get_nearest_material()
    if iron == null:
        hide_path_line()
        return false
    var cluster := get_cluster_with_room()
    if cluster == null:
        cluster = create_cluster()
        if cluster == null:
            hide_path_line()
            return false
    var dist := drone.position.distance_to(iron.global_position)
    if dist > mining_range:
        var dir := (iron.global_position - drone.position).normalized()
        drone.position += dir * move_speed * delta
        show_path_line_to(iron.global_position)
    else:
        carried_material = {"material_type": iron.material_type}
        deliver_to_cluster = true
        cluster_target = cluster
        iron.queue_free()
        hide_path_line()
    return true

func get_nearest_material() -> Node2D:
    var closest
    var closest_distance := detection_range
    for iron in drone.get_tree().get_nodes_in_group("processed_material"):
        var distance := drone.position.distance_to(iron.global_position)
        if distance < closest_distance:
            closest_distance = distance
            closest = iron
    return closest

func get_nearest_blueprint() -> Node2D:
    var closest
    var closest_distance := 9999999
    for bp in drone.get_tree().get_nodes_in_group("drone_blueprint"):
        var distance := drone.position.distance_to(bp.global_position)
        if distance < closest_distance:
            closest_distance = distance
            closest = bp
    return closest

func get_nearest_cluster() -> Node2D:
    var closest
    var closest_distance := detection_range
    for c in drone.get_tree().get_nodes_in_group("material_cluster"):
        var distance := drone.position.distance_to(c.global_position)
        if distance < closest_distance:
            closest_distance = distance
            closest = c
    return closest

func get_cluster_with_room() -> Node2D:
    for c in drone.get_tree().get_nodes_in_group("material_cluster"):
        if "stored_amount" in c and "capacity" in c:
            if c.stored_amount < c.capacity:
                return c
    return null

func create_cluster() -> Node2D:
    var scene: PackedScene = drone.cluster_scene
    if scene == null:
        return null
    var cluster := scene.instantiate()
    drone.get_parent().add_child(cluster)
    cluster.position = drone.position
    cluster.scale *= 10
    return cluster
