extends Object

class_name DroneStorage

var drone: Node2D
var storage_capacity: float = 0.0
var cargo_space: float = 1.0
var stored_drones: Array = []
var current_storage: float = 0.0
var cluster_scene: PackedScene

func _init(d: Node2D, capacity: float, space: float, scene: PackedScene) -> void:
    drone = d
    storage_capacity = capacity
    cargo_space = space
    cluster_scene = scene

func store_drone(other: Node2D) -> bool:
    if storage_capacity <= 0.0:
        return false
    if not other:
        return false
    var space: float = 1.0
    if "cargo_space" in other:
        space = float(other.cargo_space)
    if current_storage + space > storage_capacity:
        return false
    var path := ""
    if other.has_meta("scene_path"):
        path = str(other.get_meta("scene_path"))
    elif other.scene_file_path != "":
        path = other.scene_file_path
    stored_drones.append({"path": path, "space": space})
    current_storage += space
    other.queue_free()
    return true

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
        if drone.get_parent():
            drone.get_parent().add_child(d)
        d.global_position = drone.global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
        d.scale *= 10
        d.add_to_group("drone")
        d.set_meta("scene_path", path)
        if "cluster_scene" in d:
            d.cluster_scene = cluster_scene
    stored_drones.clear()
    current_storage = 0.0
