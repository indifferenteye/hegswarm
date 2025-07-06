extends Node

##
## Maintains drone counts and positions between scenes.
## Scenes should call the record_* functions when exiting and the
## spawn_* counterparts when entering so drones persist across
## galaxy, star system and space scenes.
##

var system_drone_data: Array = []
var star_drone_counts: Dictionary = {}
var space_drone_positions: Array = []

const PathLine = preload("res://scripts/utils/path_line.gd")

func record_space_drones(space_node: Node2D) -> void:
    var BeltManager = preload("res://scripts/utils/belt_manager.gd")
    BeltManager.record_belt_state(space_node, space_node.drone_scene)
    var data: Array = []
    for d in space_node.get_tree().get_nodes_in_group("drone"):
        if "storage_capacity" in d and d.storage_capacity > 0.0:
            var entry := {
                "pos": Globals.space_origin + d.position / 10,
                "path": d.get_meta("scene_path", space_node.drone_scene.resource_path)
            }
            data.append(entry)
    system_drone_data = data

func spawn_space_drones(space_node: Node2D) -> void:
    if space_node.drone_scene == null:
        return
    var belt_seed := Globals.space_belt_seed
    var key := str(Globals.star_seed) + "_" + str(belt_seed)
    var drone_positions := space_drone_positions.duplicate()
    var counts: Dictionary = Globals.belt_drones.get(key, {})
    for scene_path in counts.keys():
        var scene := load(scene_path)
        if scene == null:
            continue
        for i in range(int(counts[scene_path])):
            var d: Node2D = scene.instantiate()
            space_node.add_child(d)
            var pos := Vector2.ZERO
            if drone_positions.size() > 0:
                pos = drone_positions.pop_front() * 10
            d.position = pos
            d.scale *= 10
            d.add_to_group("drone")
            d.set_meta("scene_path", scene_path)
            if "cluster_scene" in d and "material_cluster_scene" in space_node:
                d.cluster_scene = space_node.material_cluster_scene
    for pos in drone_positions:
        var d: Node2D = space_node.drone_scene.instantiate()
        space_node.add_child(d)
        d.position = pos * 10
        d.scale *= 10
        d.add_to_group("drone")
        d.set_meta("scene_path", space_node.drone_scene.resource_path)
        if "cluster_scene" in d and "material_cluster_scene" in space_node:
            d.cluster_scene = space_node.material_cluster_scene
    space_drone_positions = []

func record_star_drones(source: Node) -> void:
    if source.has_method("get_drones"):
        var count := 0
        for d in source.get_drones():
            if "storage_capacity" in d and d.storage_capacity > 0.0:
                count += 1
        var star_counts: Dictionary = star_drone_counts.get(Globals.star_seed, {})
        star_counts[Globals.GALAXY_DRONE_SCENE_PATH] = count
        star_drone_counts[Globals.star_seed] = star_counts
        return
    var counts: Dictionary = {}
    for d in source.get_tree().get_nodes_in_group("galaxy_drone"):
        if not ("belongs_to_star_seed" in d):
            continue
        var seed = d.belongs_to_star_seed
        if not counts.has(seed):
            counts[seed] = {}
        var type_counts: Dictionary = counts[seed]
        var t := Globals.GALAXY_DRONE_SCENE_PATH
        type_counts[t] = type_counts.get(t, 0) + 1
        counts[seed] = type_counts
    star_drone_counts = counts

func spawn_star_drones(manager: Node) -> void:
    var drone_scene = manager.drone_scene
    var planets = manager.planets
    if drone_scene == null or planets.is_empty():
        return
    manager.path_lines.clear()
    if system_drone_data.size() > 0:
        for info in system_drone_data:
            var path := info.get("path", drone_scene.resource_path)
            var scene := load(path)
            if scene == null:
                continue
            var d: Node2D = scene.instantiate()
            manager.add_child(d)
            d.add_to_group("drone")
            d.set_meta("scene_path", path)
            d.position = info.get("pos", Vector2.ZERO)
            manager.drones.append(d)
            manager.drone_targets.append(d.position)
            var line: Node2D = PathLine.new()
            line.set_as_top_level(true)
            line.visible = false
            manager.add_child(line)
            manager.path_lines.append(line)
        system_drone_data = []
        Globals.entering_drone_count = 0
        return
    var count := Globals.entering_drone_count
    if count <= 0:
        return
    for i in range(count):
        var d: Node2D = drone_scene.instantiate()
        manager.add_child(d)
        d.add_to_group("drone")
        d.set_meta("scene_path", drone_scene.resource_path)
        var planet: Node2D = planets[manager.rng.randi_range(0, planets.size() - 1)]
        d.position = planet.position + Vector2(20, 0).rotated(manager.rng.randf() * TAU)
        manager.drones.append(d)
        manager.drone_targets.append(d.position)
        var line: Node2D = PathLine.new()
        line.set_as_top_level(true)
        line.visible = false
        manager.add_child(line)
        manager.path_lines.append(line)
    Globals.entering_drone_count = 0

