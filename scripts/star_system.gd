extends Node2D

const StarSystemGenerator = preload('res://scripts/generators/star_system_generator.gd')

## Scene used for the system's star.
@export var sun_scene: PackedScene = preload('res://assets/sun.tscn')
## Scene used for planets orbiting the star.
@export var planet_scene: PackedScene = preload('res://assets/planet.tscn')
## Scene used for the player's drone.
@export var drone_scene: PackedScene = preload('res://assets/drone.tscn')
## Minimum number of planets to generate.
@export var min_planets: int = 1
## Maximum number of planets to generate.
@export var max_planets: int = 5
## Spacing between each planet's orbit.
@export var orbit_step: float = 40.0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var generator: StarSystemGenerator = StarSystemGenerator.new()
var planets: Array = []
var drone: Node2D
var drone_target: Vector2
## Speed at which the drone moves toward the target position.
@export var drone_speed: float = 80.0

func _ready() -> void:
	rng.seed = Globals.star_seed
	var sun: Node2D = sun_scene.instantiate()
	add_child(sun)
	sun.position = Vector2.ZERO
	_spawn_planets(sun)
	_spawn_drone()

func _spawn_planets(sun: Node2D) -> void:
	if planet_scene == null:
		push_warning('planet_scene is not set')
		return
	var offsets := generator.generate_planet_offsets(min_planets, max_planets, orbit_step, rng)
	for offset in offsets:
		var planet: Node2D = planet_scene.instantiate()
		add_child(planet)
		planet.position = sun.position + offset
		planets.append(planet)

func _spawn_drone() -> void:
	if drone_scene == null or planets.is_empty():
		return
	drone = drone_scene.instantiate()
	add_child(drone)
	var planet: Node2D = planets[rng.randi_range(0, planets.size() - 1)]
	drone.position = planet.position + Vector2(20, 0)
	drone_target = drone.position

func _process(delta: float) -> void:
	if drone:
		var delta_pos := drone_target - drone.position
		if delta_pos.length() > 1.0:
			drone.position += delta_pos.normalized() * drone_speed * delta
		else:
			drone.position = drone_target

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('return_to_galaxy'):
		get_tree().change_scene_to_file('res://scenes/galaxy.tscn')
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		drone_target = get_global_mouse_position()

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file('res://scenes/galaxy.tscn')
