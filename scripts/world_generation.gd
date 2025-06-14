extends Node2D

@export var scene_to_instance: PackedScene
@export var count: int = 8
@export var radius: float = 200.0
@export var seed: int = 0

var rng := RandomNumberGenerator.new()

func _ready():
        rng.seed = seed
        for i in range(count):
                var instance = scene_to_instance.instantiate()
                var angle = rng.randf_range(0, TAU)
                var distance = rng.randf_range(0, radius)
                instance.position = Vector2(cos(angle), sin(angle)) * distance
                if instance.has_variable("seed"):
                        instance.seed = rng.randi()
                add_child(instance)
