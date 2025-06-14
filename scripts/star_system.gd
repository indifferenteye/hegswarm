extends Node2D

## Scene used for the system's star.
@export var sun_scene: PackedScene = preload("res://assets/sun.tscn")
## Scene used for planets orbiting the star.
@export var planet_scene: PackedScene = preload("res://assets/planet.tscn")
## Minimum number of planets to generate.
@export var min_planets: int = 1
## Maximum number of planets to generate.
@export var max_planets: int = 5
## Spacing between each planet's orbit.
@export var orbit_step: float = 40.0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	rng.seed = Globals.star_seed
	var sun: Node2D = sun_scene.instantiate()
	add_child(sun)
	sun.position = Vector2.ZERO
	_generate_planets(sun)

func _generate_planets(sun: Node2D) -> void:
	var count := rng.randi_range(min_planets, max_planets)
	for i in range(count):
		var planet: Node2D = planet_scene.instantiate()
		add_child(planet)
		var radius := orbit_step * (i + 1) + rng.randf_range(-orbit_step * 0.25, orbit_step * 0.25)
		var angle := rng.randf_range(0.0, TAU)
		planet.position = sun.position + Vector2(cos(angle), sin(angle)) * radius
