extends Node2D

const GalaxyGenerator = preload("res://scripts/generators/galaxy_generator.gd")

## Scene instantiated for each generated star.
@export var scene_to_instance: PackedScene
## Scene used for the drone in the galaxy view.
@export var drone_scene: PackedScene
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
@export var seed: int = 1

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var generator: GalaxyGenerator = GalaxyGenerator.new()
var drone: Node2D

func _get_star_by_seed(seed_to_find: int) -> Node2D:
    for star in get_children():
        if "seed" in star and star.seed == seed_to_find:
            return star
    return null

func _ready() -> void:
    rng.seed = seed
    _generate_galaxy()
    _highlight_last_visited()
    _spawn_drone()
    _center_camera_on_last_visited()
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
    var star := _get_star_by_seed(Globals.star_seed)
    if star and star.has_method("mark_as_last_visited"):
        star.mark_as_last_visited()

func _spawn_drone() -> void:
    if drone_scene == null:
        return
    drone = drone_scene.instantiate()
    add_child(drone)
    var spawn_pos := Globals.galaxy_drone_position
    if spawn_pos == Vector2.ZERO:
        var star := _get_star_by_seed(Globals.start_star_seed)
        if star != null:
            spawn_pos = star.position + Vector2(20, 0)
    drone.position = spawn_pos
    drone.set("target_position", drone.position)
    if "belongs_to_star_seed" in drone:
        drone.belongs_to_star_seed = Globals.start_star_seed

func _center_camera_on_last_visited() -> void:
    var current_scene := get_tree().get_current_scene()
    if current_scene == null:
        return
    var camera := current_scene.get_node_or_null("MainCamera")
    if camera == null:
        return
    var star := _get_star_by_seed(Globals.star_seed)
    if star:
        camera.position = star.global_position
        camera.zoom = Vector2(1, 1)

func _open_random_star_system() -> void:
    var stars := get_children()
    if stars.size() == 0:
        return
    var star_index := rng.randi_range(0, stars.size() - 1)
    var star := stars[star_index]
    _open_star_system(star.seed)

func _open_last_star_system() -> void:
    _open_star_system(Globals.star_seed)

func _open_star_system(seed_to_open: int) -> void:
    var star := _get_star_by_seed(seed_to_open)
    if star:
        Globals.entering_drone_count = Globals.count_drones_near_star(star.global_position, seed_to_open)
    else:
        Globals.entering_drone_count = 0
    Globals.star_seed = seed_to_open
    Globals.start_star_seed = seed_to_open
    if drone != null:
        Globals.galaxy_drone_position = drone.global_position
    get_tree().change_scene_to_file(Globals.STAR_SYSTEM_SCENE_PATH)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed('toggle_star_system'):
        _open_last_star_system()
