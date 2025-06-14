extends Node2D

## Scene that will be instanced for each generated star.
@export var scene_to_instance: PackedScene
## Total number of stars to create.
@export var star_count: int = 100
## Maximum radius of the galaxy.
@export var radius: float = 200.0
## How many arms the spiral galaxy has.
@export var arm_count: int = 2
## Total twist of the spiral from the center to the outer edge.
@export var twist: float = TAU * 2
## Random angle deviation for each star.
@export var arm_spread: float = 0.3
## Random radial offset for each star.
@export var random_offset: float = 10.0
## Seed used to deterministically generate the galaxy.
@export var seed: int = 0

var rng := RandomNumberGenerator.new()

func _ready():
				rng.seed = seed
				generate_spiral_galaxy()

## Generates a simple spiral galaxy. Adjust exported variables to
## tweak the resulting shape.
func generate_spiral_galaxy() -> void:
				for i in range(star_count):
								var instance = scene_to_instance.instantiate()
								var t := float(i) / star_count
								var arm := rng.randi() % arm_count
								var r := t * radius + rng.randf_range(-random_offset, random_offset)
								var angle := t * twist + TAU * arm / arm_count
								angle += rng.randf_range(-arm_spread, arm_spread)
								instance.position = Vector2(cos(angle), sin(angle)) * r
								instance.seed = rng.randi()
								add_child(instance)
