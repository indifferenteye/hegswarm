extends Node

class_name BeltManager

const BeltOfflineProgress = preload("res://scripts/utils/belt_offline_progress.gd")

static func _cluster_with_room(owner: Node) -> Node:
    for c in owner.get_tree().get_nodes_in_group("material_cluster"):
        if "stored_amount" in c and "capacity" in c:
            if c.stored_amount < c.capacity:
                return c
    return null

static func add_material_to_clusters(owner: Node, cluster_scene: PackedScene, material_type: String, amount: int) -> void:
    for i in range(amount):
        var cluster := _cluster_with_room(owner)
        if cluster == null:
            if cluster_scene == null:
                return
            cluster = cluster_scene.instantiate()
            owner.add_child(cluster)
            cluster.position = Vector2.ZERO
            cluster.scale *= 10
        if cluster.has_method("add_material"):
            cluster.add_material(material_type)

static func apply_mining_to_asteroids(owner: Node, key: String) -> void:
    var percent = Globals.belt_mining_percent.get(key, 0.0)
    if percent <= 0.0:
        return
    for asteroid in owner.get_tree().get_nodes_in_group("asteroid"):
        if not ("seed" in asteroid):
            continue
        var r := RandomNumberGenerator.new()
        r.seed = int(asteroid.seed) + Globals.space_belt_seed + Globals.star_seed
        if r.randf() < percent:
            asteroid.queue_free()

static func apply_offline_progress(owner: Node, cluster_scene: PackedScene, key: String) -> void:
    var calc := BeltOfflineProgress.new()
    var available := calc.apply(key)
    if cluster_scene != null:
        if available > 0:
            add_material_to_clusters(owner, cluster_scene, "iron", available)
        Globals.belt_cluster_iron[key] = 0
    else:
        Globals.belt_cluster_iron[key] = available

static func record_belt_state(owner: Node, drone_scene: PackedScene) -> void:
    var belt_seed := Globals.space_belt_seed
    if belt_seed == 0:
        return
    var key := str(Globals.star_seed) + "_" + str(belt_seed)
    var counts: Dictionary = {}
    for d in owner.get_tree().get_nodes_in_group("drone"):
        var path := ""
        if d.has_meta("scene_path"):
            path = str(d.get_meta("scene_path"))
        else:
            path = drone_scene.resource_path
        counts[path] = counts.get(path, 0) + 1
    Globals.belt_drones[key] = counts

    var cluster_total := 0
    for c in owner.get_tree().get_nodes_in_group("material_cluster"):
        if "stored_amount" in c:
            cluster_total += int(c.stored_amount)
    Globals.belt_cluster_iron[key] = cluster_total

    var bp_count := 0
    var bp_needed := 0
    for bp in owner.get_tree().get_nodes_in_group("drone_blueprint"):
        bp_count += 1
        var req := int(bp.required_materials.get("iron", 0))
        var cur := int(bp.current_materials.get("iron", 0))
        bp_needed += max(0, req - cur)
    Globals.belt_blueprint_counts[key] = bp_count
    Globals.belt_blueprint_iron_needed[key] = bp_needed

    Globals.belt_last_loaded[key] = Time.get_unix_time_from_system()
