extends Node

class_name StarSystemDroneManager

@export var drone_scene: PackedScene
@export var drone_speed: float = 80.0

const PathLine = preload("res://scripts/utils/path_line.gd")

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var drones: Array = []
var drone_targets: Array = []
var planets: Array = []
var path_lines: Array = []

func setup(seed: int, planets_array: Array) -> void:
    rng.seed = seed
    planets = planets_array.duplicate()
    _spawn_drones()

func get_drones() -> Array:
    return drones

func set_all_targets(target: Vector2) -> void:
    for i in range(drone_targets.size()):
        drone_targets[i] = target
        if i < path_lines.size():
            var line: Node2D = path_lines[i]
            line.start_pos = drones[i].global_position
            line.end_pos = target
            line.visible = true

func set_targets_for(drones_to_set: Array, target: Vector2) -> void:
    for d in drones_to_set:
        var idx := drones.find(d)
        if idx != -1:
            drone_targets[idx] = target
            if idx < path_lines.size():
                var line: Node2D = path_lines[idx]
                line.start_pos = d.global_position
                line.end_pos = target
                line.visible = true

func _process(delta: float) -> void:
    for i in range(drones.size()):
        var d: Node2D = drones[i]
        var target: Vector2 = drone_targets[i]
        var line: Node2D = path_lines[i]
        var delta_pos := target - d.position
        if delta_pos.length() > 1.0:
            d.position += delta_pos.normalized() * drone_speed * delta
            if line:
                line.start_pos = d.global_position
        else:
            d.position = target
            if line:
                line.visible = false

func _spawn_drones() -> void:
    if drone_scene == null or planets.is_empty():
        return

    path_lines.clear()

    var details: Array = Globals.star_carrier_info.get(Globals.star_seed, [])

    if Globals.system_drone_positions.size() > 0:
        for i in range(Globals.system_drone_positions.size()):
            var pos = Globals.system_drone_positions[i]
            var d: Node2D = drone_scene.instantiate()
            add_child(d)
            d.add_to_group("drone")
            d.set_meta("scene_path", drone_scene.resource_path)
            d.position = pos
            if i < details.size():
                var info = details[i]
                if "storeable_amount" in d:
                    d.storeable_amount = info.get("storeable_amount", 0)
                if "stored_drones" in d:
                    d.stored_drones = info.get("stored_drones", []).duplicate()
            drones.append(d)
            drone_targets.append(d.position)
            var line: Node2D = PathLine.new()
            line.set_as_top_level(true)
            line.visible = false
            add_child(line)
            path_lines.append(line)
        Globals.system_drone_positions = []
        Globals.entering_drone_count = 0
        return

    var count := Globals.entering_drone_count
    if count <= 0 and details.size() == 0:
        return

    if details.size() > 0:
        count = details.size()

    for i in range(count):
        var d: Node2D = drone_scene.instantiate()
        add_child(d)
        d.add_to_group("drone")
        d.set_meta("scene_path", drone_scene.resource_path)
        var planet: Node2D = planets[rng.randi_range(0, planets.size() - 1)]
        d.position = planet.position + Vector2(20, 0).rotated(rng.randf() * TAU)
        if i < details.size():
            var info2 = details[i]
            if "storeable_amount" in d:
                d.storeable_amount = info2.get("storeable_amount", 0)
            if "stored_drones" in d:
                d.stored_drones = info2.get("stored_drones", []).duplicate()
        drones.append(d)
        drone_targets.append(d.position)
        var line: Node2D = PathLine.new()
        line.set_as_top_level(true)
        line.visible = false
        add_child(line)
        path_lines.append(line)
    Globals.entering_drone_count = 0
