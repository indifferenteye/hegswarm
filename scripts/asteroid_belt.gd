extends Node2D

var _radius: float = 300.0
@export var radius: float = 100.0:
    set = set_radius,
    get = get_radius
@export var asteroid_count: int = 150
@export var asteroid_scene: PackedScene = preload("res://assets/asteroid.tscn")
@export var thickness: float = 100.0
@export var seed: int = 0
@export var star_seed: int = 0

var _total_integrity: float = 0.0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
    rng.seed = seed
    add_to_group("asteroid_belt")
    _generate_asteroids()

func set_radius(value: float) -> void:
    _radius = value
    _generate_asteroids()

func get_radius() -> float:
    return _radius

func _generate_asteroids() -> void:
    rng.seed = seed
    _total_integrity = 0.0
    for child in get_children():
        child.queue_free()
    for i in range(asteroid_count):
        var asteroid: Node2D = asteroid_scene.instantiate()
        var a_seed := rng.randi()
        if "seed" in asteroid:
            asteroid.seed = a_seed
        if "belt_seed" in asteroid:
            asteroid.belt_seed = seed
        add_child(asteroid)
        asteroid.add_to_group("asteroid")
        var angle := rng.randf() * TAU
        var r := radius + rng.randf_range(-thickness / 2.0, thickness / 2.0)
        asteroid.position = Vector2(cos(angle), sin(angle)) * r
        if asteroid.has_method("calculate_integrity"):
            _total_integrity += asteroid.calculate_integrity(asteroid.radius, asteroid.voxel_size, a_seed)
        else:
            _total_integrity += 1.0

    if star_seed != 0:
        var key := str(star_seed) + "_" + str(seed)
        if not Globals.belt_total_integrity.has(key):
            Globals.belt_total_integrity[key] = _total_integrity

## Removes asteroids based on the given mined percentage using the provided
## system seed for deterministic results.
func apply_mining(mined_percent: float, system_seed: int) -> void:
    if mined_percent <= 0.0:
        return
    for asteroid in get_children():
        if not ("seed" in asteroid):
            continue
        var r := RandomNumberGenerator.new()
        r.seed = int(asteroid.seed) + seed + system_seed
        if r.randf() < mined_percent:
            asteroid.queue_free()
