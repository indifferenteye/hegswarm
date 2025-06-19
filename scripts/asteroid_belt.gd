extends Node2D

var _radius: float = 300.0
@export var radius: float = 100.0:
    set = set_radius,
    get = get_radius
@export var asteroid_count: int = 100
@export var asteroid_scene: PackedScene = preload("res://assets/asteroid.tscn")
@export var thickness: float = 100.0
@export var seed: int = 0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
    rng.seed = seed
    _generate_asteroids()

func set_radius(value: float) -> void:
    _radius = value
    _generate_asteroids()

func get_radius() -> float:
    return _radius

func _generate_asteroids() -> void:
    rng.seed = seed
    for child in get_children():
        child.queue_free()
    for i in range(asteroid_count):
        var asteroid: Node2D = asteroid_scene.instantiate()
        if "seed" in asteroid:
            asteroid.seed = rng.randi()
        add_child(asteroid)
        asteroid.add_to_group("asteroid")
        var angle := rng.randf() * TAU
        var r := radius + rng.randf_range(-thickness / 2.0, thickness / 2.0)
        asteroid.position = Vector2(cos(angle), sin(angle)) * r
