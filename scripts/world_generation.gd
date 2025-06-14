extends Node2D

const GalaxyGenerator = preload("res://scripts/generators/galaxy_generator.gd")

## Scene instantiated for each generated star.
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

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var generator: GalaxyGenerator = GalaxyGenerator.new()

func _ready() -> void:
rng.seed = seed
_generate_galaxy()
_highlight_last_visited()
	if Globals.first_load:
		Globals.first_load = false
		_open_random_star_system()

## Generates a simple spiral galaxy. Adjust exported variables to tweak the
## resulting shape.
func _generate_galaxy() -> void:
	if scene_to_instance == null:
		push_warning("scene_to_instance is not set")
		return
	var star_data := generator.generate_star_data(
		star_count,
		radius,
		arm_count,
		twist,
		arm_spread,
		random_offset,
		rng
	)
	for data in star_data:
		var instance: Node2D = scene_to_instance.instantiate()
		instance.position = data.position
		if "seed" in instance:
			instance.seed = data.seed
		add_child(instance)

func _highlight_last_visited() -> void:
	for star in get_children():
		if "seed" in star and star.seed == Globals.star_seed:
			if star.has_method("mark_as_last_visited"):
				star.mark_as_last_visited()
				break

func _open_random_star_system() -> void:
	var stars := get_children()
	if stars.size() == 0:
		return
	var star_index := rng.randi_range(0, stars.size() - 1)
	var star := stars[star_index]
	Globals.star_seed = star.seed
	get_tree().change_scene_to_file("res://scenes/star_system.tscn")
