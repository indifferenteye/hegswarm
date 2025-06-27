extends Node2D

@export var move_speed: float = 50.0
@export var detection_range: float = 4000.0
@export var mining_range: float = 20.0
@export var mining_rate: float = 1.0
## Minimum distance this drone tries to keep from other drones.
@export var separation_distance: float = 30.0
@export var cluster_scene: PackedScene
## Maximum number of other drones this drone can store.
@export var storeable_amount: int = 0
## Total storage capacity of this drone. Defaults to storeable_amount for
## backwards compatibility.
@export var storage_capacity: float = 0.0
## Amount of storage space this drone occupies when carried by a carrier.
@export var cargo_space: float = 1.0

## Amount of storage space currently used by stored drones.
var current_storage: float = 0.0

## Paths of drones currently stored inside this drone.
## Information about drones stored inside this drone. Each entry is a Dictionary
## with keys `path` and `space`.
var stored_drones: Array = []

var asteroid_target: Node2D = null
var manual_destination: Vector2
var manual_destination_active: bool = false
var carried_material = null
var blueprint_target: Node2D = null
var cluster_target: Node2D = null
var deliver_to_cluster: bool = false
var path_line: Node2D

func _ready() -> void:
    path_line = preload("res://scripts/utils/path_line.gd").new()
    path_line.set_as_top_level(true)
    path_line.visible = false
    if get_parent():
        get_parent().add_child(path_line)
    if storage_capacity <= 0.0 and storeable_amount > 0:
        storage_capacity = float(storeable_amount)

func _show_path_line_to(pos: Vector2) -> void:
    if path_line:
        path_line.start_pos = global_position
        path_line.end_pos = pos
        path_line.visible = true

func _hide_path_line() -> void:
    if path_line:
        path_line.visible = false

## Push away from nearby drones to avoid clumping.
func _apply_separation_force(delta: float) -> void:
    var push := Vector2.ZERO
    for d in get_tree().get_nodes_in_group("drone"):
        if d == self:
            continue
        var dist := position.distance_to(d.position)
        if dist < separation_distance and dist > 0.0:
            push += (position - d.position).normalized() * (separation_distance - dist)
    if push.length() > 0.0:
        position += push.normalized() * move_speed * delta

var manual_target: Node2D = null

func move_to(pos) -> void:
    manual_destination_active = true
    manual_target = null
    if pos is Node2D:
        manual_target = pos
        manual_destination = pos.global_position
    else:
        manual_destination = pos
    if path_line:
        path_line.start_pos = global_position
        path_line.end_pos = manual_destination
        path_line.visible = true

func _process(delta: float) -> void:
    _apply_separation_force(delta)
    if path_line and path_line.visible:
        path_line.start_pos = global_position
    if _handle_manual_move(delta):
        return
    if carried_material != null:
        if deliver_to_cluster:
            if _deliver_to_cluster(delta):
                return
        else:
            if _deliver_material(delta):
                return
    if _take_from_cluster(delta):
        return
    if _collect_material(delta):
        return
    _mine_or_move_asteroid(delta)

func _handle_manual_move(delta: float) -> bool:
    if not manual_destination_active:
        return false
    if manual_target and is_instance_valid(manual_target):
        manual_destination = manual_target.global_position
    var dist := position.distance_to(manual_destination)
    if dist > separation_distance * 1.5:
        var dir := (manual_destination - position).normalized()
        position += dir * move_speed * delta
        if path_line:
            path_line.start_pos = global_position
    else:
        manual_destination_active = false
        if manual_target and is_instance_valid(manual_target) and manual_target != self:
            if manual_target.has_method("store_drone"):
                if manual_target.store_drone(self):
                    _hide_path_line()
                    return true
        if path_line:
            path_line.visible = false
    return true

func _deliver_material(delta: float) -> bool:
    if carried_material == null:
        return false
    if blueprint_target == null or not is_instance_valid(blueprint_target):
        blueprint_target = _get_nearest_blueprint()
    if blueprint_target == null:
        _hide_path_line()
        return true
    var dist := position.distance_to(blueprint_target.global_position)
    if dist > mining_range:
        var dir := (blueprint_target.global_position - position).normalized()
        position += dir * move_speed * delta
        _show_path_line_to(blueprint_target.global_position)
    else:
        if blueprint_target.has_method("add_material"):
            blueprint_target.add_material(carried_material["material_type"])
        carried_material = null
        blueprint_target = null
        _hide_path_line()
    return true

func _deliver_to_cluster(delta: float) -> bool:
    if carried_material == null:
        return false
    if cluster_target == null or not is_instance_valid(cluster_target):
        cluster_target = _get_cluster_with_room()
        if cluster_target == null:
            cluster_target = _create_cluster()
    else:
        if "stored_amount" in cluster_target and "capacity" in cluster_target:
            if cluster_target.stored_amount >= cluster_target.capacity:
                cluster_target = _get_cluster_with_room()
                if cluster_target == null:
                    cluster_target = _create_cluster()
    if cluster_target == null:
        _hide_path_line()
        return true
    var dist := position.distance_to(cluster_target.global_position)
    if dist > mining_range:
        var dir := (cluster_target.global_position - position).normalized()
        position += dir * move_speed * delta
        _show_path_line_to(cluster_target.global_position)
    else:
        if cluster_target.has_method("add_material"):
            if cluster_target.add_material(carried_material["material_type"]):
                carried_material = null
                deliver_to_cluster = false
                cluster_target = null
        _hide_path_line()
    return true

func _take_from_cluster(delta: float) -> bool:
    var cluster := _get_nearest_cluster()
    var blueprint := _get_nearest_blueprint()
    if cluster == null or blueprint == null:
        _hide_path_line()
        return false
    if not blueprint.has_method("needs_material") or not blueprint.needs_material(cluster.material_type):
        _hide_path_line()
        return false
    var dist := position.distance_to(cluster.global_position)
    if dist > mining_range:
        var dir := (cluster.global_position - position).normalized()
        position += dir * move_speed * delta
        _show_path_line_to(cluster.global_position)
    else:
        if cluster.has_method("take_material") and cluster.take_material():
            carried_material = {"material_type": cluster.material_type}
            blueprint_target = blueprint
            deliver_to_cluster = false
        _hide_path_line()
    return true

func _collect_material(delta: float) -> bool:
    var iron := _get_nearest_material()
    if iron == null:
        _hide_path_line()
        return false
    var cluster := _get_cluster_with_room()
    if cluster == null:
        cluster = _create_cluster()
        if cluster == null:
            _hide_path_line()
            return false
    var dist := position.distance_to(iron.global_position)
    if dist > mining_range:
        var dir := (iron.global_position - position).normalized()
        position += dir * move_speed * delta
        _show_path_line_to(iron.global_position)
    else:
        carried_material = {"material_type": iron.material_type}
        deliver_to_cluster = true
        cluster_target = cluster
        iron.queue_free()
        _hide_path_line()
    return true

func _mine_or_move_asteroid(delta: float) -> void:
    if asteroid_target == null or not is_instance_valid(asteroid_target):
        asteroid_target = _get_nearest_asteroid()
    if asteroid_target == null:
        _hide_path_line()
        return
    var dist := position.distance_to(asteroid_target.global_position)
    if dist > mining_range:
        var dir := (asteroid_target.global_position - position).normalized()
        position += dir * move_speed * delta
        _show_path_line_to(asteroid_target.global_position)
    elif asteroid_target.has_method("mine"):
        asteroid_target.mine(mining_rate * delta)
        if not is_instance_valid(asteroid_target):
            asteroid_target = null
        _hide_path_line()
func _get_nearest_asteroid() -> Node2D:
    var closest
    var closest_distance := detection_range
    for asteroid in get_tree().get_nodes_in_group("asteroid"):
        var distance := position.distance_to(asteroid.global_position)
        if distance < closest_distance:
            closest_distance = distance
            closest = asteroid
    return closest

func _get_nearest_material() -> Node2D:
    var closest
    var closest_distance := detection_range
    for iron in get_tree().get_nodes_in_group("processed_material"):
        var distance := position.distance_to(iron.global_position)
        if distance < closest_distance:
            closest_distance = distance
            closest = iron
    return closest

func _get_nearest_blueprint() -> Node2D:
    var closest
    var closest_distance := 9999999
    for bp in get_tree().get_nodes_in_group("drone_blueprint"):
        var distance := position.distance_to(bp.global_position)
        if distance < closest_distance:
            closest_distance = distance
            closest = bp
    return closest

func _get_nearest_cluster() -> Node2D:
    var closest
    var closest_distance := detection_range
    for c in get_tree().get_nodes_in_group("material_cluster"):
        var distance := position.distance_to(c.global_position)
        if distance < closest_distance:
            closest_distance = distance
            closest = c
    return closest

func _get_cluster_with_room() -> Node2D:
    for c in get_tree().get_nodes_in_group("material_cluster"):
        if "stored_amount" in c and "capacity" in c:
            if c.stored_amount < c.capacity:
                return c
    return null

func _create_cluster() -> Node2D:
    if cluster_scene == null:
        return null
    var cluster := cluster_scene.instantiate()
    get_parent().add_child(cluster)
    cluster.position = position
    cluster.scale *= 10
    return cluster

## Store another drone inside this drone if there is capacity.
func store_drone(drone: Node2D) -> bool:
    if storage_capacity <= 0.0:
        return false
    if not drone:
        return false
    var space: float = 1.0
    if "cargo_space" in drone:
        space = float(drone.cargo_space)
    if current_storage + space > storage_capacity:
        return false
    var path := ""
    if drone.has_meta("scene_path"):
        path = str(drone.get_meta("scene_path"))
    elif drone.scene_file_path != "":
        path = drone.scene_file_path
    stored_drones.append({"path": path, "space": space})
    current_storage += space
    drone.queue_free()
    return true

## Unload all stored drones at this drone's position.
func unload_drones() -> void:
    if storage_capacity <= 0.0:
        return
    if stored_drones.is_empty():
        return
    for info in stored_drones:
        var path = info.get("path", "")
        var scene := load(path)
        if scene == null:
            continue
        var d: Node2D = scene.instantiate()
        if get_parent():
            get_parent().add_child(d)
        d.global_position = global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
        d.scale *= 10
        d.add_to_group("drone")
        d.set_meta("scene_path", path)
        if "cluster_scene" in d:
            d.cluster_scene = cluster_scene
    stored_drones.clear()
    current_storage = 0.0
