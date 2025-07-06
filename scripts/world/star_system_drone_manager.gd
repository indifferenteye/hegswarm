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
    DroneManager.spawn_star_drones(self)
