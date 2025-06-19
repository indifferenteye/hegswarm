extends Node

class_name StarSystemDroneManager

@export var drone_scene: PackedScene
@export var drone_speed: float = 80.0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var drones: Array = []
var drone_targets: Array = []
var planets: Array = []

func setup(seed: int, planets_array: Array) -> void:
    rng.seed = seed
    planets = planets_array.duplicate()
    _spawn_drones()

func get_drones() -> Array:
    return drones

func set_all_targets(target: Vector2) -> void:
    for i in range(drone_targets.size()):
        drone_targets[i] = target

func _process(delta: float) -> void:
    for i in range(drones.size()):
        var d: Node2D = drones[i]
        var target: Vector2 = drone_targets[i]
        var delta_pos := target - d.position
        if delta_pos.length() > 1.0:
            d.position += delta_pos.normalized() * drone_speed * delta
        else:
            d.position = target

func _spawn_drones() -> void:
    if drone_scene == null or planets.is_empty():
        return

    if Globals.system_drone_positions.size() > 0:
        for pos in Globals.system_drone_positions:
            var d: Node2D = drone_scene.instantiate()
            add_child(d)
            d.position = pos
            drones.append(d)
            drone_targets.append(d.position)
        Globals.system_drone_positions = []
        Globals.entering_drone_count = 0
        return

    var count := Globals.entering_drone_count
    if count <= 0:
        return

    for i in range(count):
        var d: Node2D = drone_scene.instantiate()
        add_child(d)
        var planet: Node2D = planets[rng.randi_range(0, planets.size() - 1)]
        d.position = planet.position + Vector2(20, 0).rotated(rng.randf() * TAU)
        drones.append(d)
        drone_targets.append(d.position)
    Globals.entering_drone_count = 0

