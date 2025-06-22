extends Node

class_name BeltManager

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
    var offline_progress_factor = 0.05
    var last_time = Globals.belt_last_loaded.get(key, 0)
    var now := Time.get_unix_time_from_system()
    if last_time == 0:
        Globals.belt_last_loaded[key] = now
        return
    var counts: Dictionary = Globals.belt_drones.get(key, {})
    if counts.is_empty():
        Globals.belt_last_loaded[key] = now
        return
    var mined_total := 0.0
    var total_asteroids = Globals.belt_asteroid_count.get(key, 1)
    var total_integrity = Globals.belt_total_integrity.get(key, float(total_asteroids))
    for scene_path in counts.keys():
        var scene := load(scene_path)
        if scene == null:
            continue
        var inst = scene.instantiate()
        var rate := 0.0
        if "mining_rate" in inst:
            rate = inst.mining_rate
        var speed := 0.0
        if "move_speed" in inst:
            speed = inst.move_speed
        inst.free()
        mined_total += float(counts[scene_path]) * rate * float(now - last_time) * offline_progress_factor / (total_integrity / speed)
    var percent = Globals.belt_mining_percent.get(key, 0.0)
    percent += mined_total / float(total_integrity)
    Globals.belt_mining_percent[key] = clamp(percent, 0.0, 1.0)
    Globals.belt_last_loaded[key] = now

    var material_count := int(mined_total)
    if material_count > 0:
        add_material_to_clusters(owner, cluster_scene, "iron", material_count)

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
    Globals.belt_last_loaded[key] = Time.get_unix_time_from_system()
