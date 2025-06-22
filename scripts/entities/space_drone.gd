extends Node2D

@export var move_speed: float = 50.0
@export var detection_range: float = 4000.0
@export var mining_range: float = 20.0
@export var mining_rate: float = 1.0
## Minimum distance this drone tries to keep from other drones.
@export var separation_distance: float = 30.0

var asteroid_target: Node2D = null
var manual_destination: Vector2
var manual_destination_active: bool = false
var carried_material = null
var blueprint_target: Node2D = null
var cluster_target: Node2D = null
var deliver_to_cluster: bool = false

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

func move_to(pos: Vector2) -> void:
    manual_destination = pos
    manual_destination_active = true

func _process(delta: float) -> void:
    _apply_separation_force(delta)
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
    var dist := position.distance_to(manual_destination)
    if dist > 5.0:
        var dir := (manual_destination - position).normalized()
        position += dir * move_speed * delta
    else:
        manual_destination_active = false
    return true

func _deliver_material(delta: float) -> bool:
    if carried_material == null:
        return false
    if blueprint_target == null or not is_instance_valid(blueprint_target):
        blueprint_target = _get_nearest_blueprint()
    if blueprint_target == null:
        return true
    var dist := position.distance_to(blueprint_target.global_position)
    if dist > mining_range:
        var dir := (blueprint_target.global_position - position).normalized()
        position += dir * move_speed * delta
    else:
        if blueprint_target.has_method("add_material"):
            blueprint_target.add_material(carried_material["material_type"])
        carried_material = null
        blueprint_target = null
    return true

func _deliver_to_cluster(delta: float) -> bool:
    if carried_material == null:
        return false
    if cluster_target == null or not is_instance_valid(cluster_target):
        cluster_target = _get_nearest_cluster()
    if cluster_target == null:
        return true
    var dist := position.distance_to(cluster_target.global_position)
    if dist > mining_range:
        var dir := (cluster_target.global_position - position).normalized()
        position += dir * move_speed * delta
    else:
        if cluster_target.has_method("add_material"):
            if cluster_target.add_material(carried_material["material_type"]):
                carried_material = null
                deliver_to_cluster = false
                cluster_target = null
    return true

func _take_from_cluster(delta: float) -> bool:
    var cluster := _get_nearest_cluster()
    var blueprint := _get_nearest_blueprint()
    if cluster == null or blueprint == null:
        return false
    if not blueprint.has_method("needs_material") or not blueprint.needs_material(cluster.material_type):
        return false
    var dist := position.distance_to(cluster.global_position)
    if dist > mining_range:
        var dir := (cluster.global_position - position).normalized()
        position += dir * move_speed * delta
    else:
        if cluster.has_method("take_material") and cluster.take_material():
            carried_material = {"material_type": cluster.material_type}
            blueprint_target = blueprint
            deliver_to_cluster = false
    return true

func _collect_material(delta: float) -> bool:
    var iron := _get_nearest_material()
    var cluster := _get_nearest_cluster()
    if iron == null or cluster == null:
        return false
    var dist := position.distance_to(iron.global_position)
    if dist > mining_range:
        var dir := (iron.global_position - position).normalized()
        position += dir * move_speed * delta
    else:
        carried_material = {"material_type": iron.material_type}
        deliver_to_cluster = true
        cluster_target = cluster
        iron.queue_free()
    return true

func _mine_or_move_asteroid(delta: float) -> void:
    if asteroid_target == null or not is_instance_valid(asteroid_target):
        asteroid_target = _get_nearest_asteroid()
    if asteroid_target == null:
        return
    var dist := position.distance_to(asteroid_target.global_position)
    if dist > mining_range:
        var dir := (asteroid_target.global_position - position).normalized()
        position += dir * move_speed * delta
    elif asteroid_target.has_method("mine"):
        asteroid_target.mine(mining_rate * delta)
        if not is_instance_valid(asteroid_target):
            asteroid_target = null

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
