extends Node2D

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

func _ready() -> void:
	rng.seed = seed
	generate_spiral_galaxy()
	_highlight_last_visited()
	if Globals.first_load:
		Globals.first_load = false
		_open_random_star_system()

## Generates a simple spiral galaxy. Adjust exported variables to tweak the
## resulting shape.
func generate_spiral_galaxy() -> void:
	for i in range(star_count):
		var instance: Node2D = scene_to_instance.instantiate()
		var t: float = float(i) / star_count
		var arm := rng.randi() % arm_count
		var r := t * radius + rng.randf_range(-random_offset, random_offset)
		var angle := t * twist + TAU * arm / arm_count
		angle += rng.randf_range(-arm_spread, arm_spread)
		instance.position = Vector2(cos(angle), sin(angle)) * r
		instance.seed = rng.randi()
		add_child(instance)

func _highlight_last_visited() -> void:
	for star in get_children():
		if star.has_variable("seed") and star.seed == Globals.star_seed:
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
