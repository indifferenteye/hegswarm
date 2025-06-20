extends Node2D

const StarSystemGenerator = preload('res://scripts/generators/star_system_generator.gd')
const StarSystemDroneManager = preload('res://scripts/star_system_drone_manager.gd')
const BeltManager = preload("res://scripts/utils/belt_manager.gd")
const SelectionUtils = preload("res://scripts/utils/selection_utils.gd")

## Scene used for the system's star.
@export var sun_scene: PackedScene = preload('res://assets/sun.tscn')
## Scene used for planets orbiting the star.
@export var planet_scene: PackedScene = preload('res://assets/planet.tscn')
## Scene used for asteroid belts that may appear instead of planets.
@export var asteroid_belt_scene: PackedScene = preload('res://assets/asteroid_belt.tscn')
## Chance that an orbit will contain an asteroid belt instead of a planet.
@export var asteroid_belt_chance: float = 0.2
## Scene used for the player's drone.
@export var drone_scene: PackedScene = preload('res://assets/drone.tscn')
## Minimum number of planets to generate.
@export var min_planets: int = 1
## Maximum number of planets to generate.
@export var max_planets: int = 5
## Spacing between each planet's orbit.
@export var orbit_step: float = 80.0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var generator: StarSystemGenerator = StarSystemGenerator.new()
var planets: Array = []
var orbit_radii: Array = []
var sun: Node2D
var drone_manager: StarSystemDroneManager

@export var orbit_color: Color = Color.GRAY
@export var orbit_width: float = 1
## Speed at which the drone moves toward the target position.
@export var drone_speed: float = 80.0
var asteroid_load_radius: float = 500.0

var selected_drones: Array = []
var selecting: bool = false
var select_start: Vector2
var select_rect: Rect2 = Rect2()

func _ready() -> void:
    rng.seed = Globals.star_seed
    sun = sun_scene.instantiate()
    add_child(sun)
    if "seed" in sun:
        sun.seed = rng.seed
    sun.position = Vector2.ZERO
    _spawn_planets(sun)
    _apply_belt_mining()
    _connect_asteroids()
    drone_manager = StarSystemDroneManager.new()
    add_child(drone_manager)
    drone_manager.drone_scene = drone_scene
    drone_manager.drone_speed = drone_speed
    drone_manager.setup(rng.seed, planets)

func _process(_delta: float) -> void:
    if selecting:
        var current := get_global_mouse_position()
        select_rect = Rect2(select_start, current - select_start)
        queue_redraw()


func _spawn_planets(sun: Node2D) -> void:
    if planet_scene == null:
        push_warning('planet_scene is not set')
        return
    orbit_radii.clear()
    var offsets := generator.generate_planet_offsets(min_planets, max_planets, orbit_step, rng, 1.5)
    for offset in offsets:
        var is_belt := asteroid_belt_scene != null and rng.randf() < asteroid_belt_chance
        if not is_belt:
            orbit_radii.append(offset.length())
        var body: Node2D = (asteroid_belt_scene if is_belt else planet_scene).instantiate()
        body.position = sun.position + (Vector2.ZERO if is_belt else offset)
        if "seed" in body:
            body.seed = rng.randi()
        if is_belt and "star_seed" in body:
            body.star_seed = Globals.star_seed
        if "water" in body:
            body.water = rng.randf()
        if "plants" in body:
            body.plants = rng.randf()
        if is_belt:
            if "radius" in body:
                body.radius = offset.length()
            var key := str(Globals.star_seed) + "_" + str(body.seed)
            if not Globals.belt_asteroid_count.has(key):
                Globals.belt_asteroid_count[key] = body.asteroid_count
        add_child(body)
        planets.append(body)
    queue_redraw()


func _draw() -> void:
    if sun == null:
        return
    for radius in orbit_radii:
        draw_arc(sun.position, radius, 0.0, TAU, 64, orbit_color, orbit_width)
    if selecting:
        var rect := Rect2(to_local(select_start), select_rect.size)
        draw_rect(rect, Color(0.4, 0.6, 1.0, 0.15), true)
        draw_rect(rect, Color(0.4, 0.6, 1.0, 0.8), false, 1.0)

func _apply_belt_mining() -> void:
    for belt in get_tree().get_nodes_in_group("asteroid_belt"):
        var key := str(Globals.star_seed) + "_" + str(belt.seed)
        var percent :float = Globals.belt_mining_percent.get(key, 0.0)
        if belt.has_method("apply_mining"):
            belt.apply_mining(percent, Globals.star_seed)

func _connect_asteroids() -> void:
    for asteroid in get_tree().get_nodes_in_group("asteroid"):
        if asteroid.has_signal("clicked"):
            asteroid.connect("clicked", Callable(self, "_on_asteroid_clicked").bind(asteroid))


func _on_asteroid_clicked(click_pos: Vector2, src: Node) -> void:
    Globals.space_origin = click_pos
    var belt_seed := 0
    if "belt_seed" in src:
        belt_seed = src.belt_seed
    Globals.space_belt_seed = belt_seed
    var positions: Array = []
    var seeds: Array = []
    for asteroid in get_tree().get_nodes_in_group("asteroid"):
        if belt_seed != 0 and ("belt_seed" in asteroid and asteroid.belt_seed != belt_seed):
            continue
        if asteroid.global_position.distance_to(click_pos) <= asteroid_load_radius:
            positions.append(asteroid.global_position - click_pos)
            if "seed" in asteroid:
                seeds.append(asteroid.seed)
    Globals.space_asteroid_positions = positions
    Globals.space_asteroid_seeds = seeds

    var drone_positions: Array = []
    for d in drone_manager.get_drones():
        if d.global_position.distance_to(click_pos) <= asteroid_load_radius:
            drone_positions.append(d.global_position - click_pos)
    Globals.space_drone_positions = drone_positions

    get_tree().change_scene_to_file(Globals.SPACE_SCENE_PATH)


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed('return_to_galaxy') or event.is_action_pressed('toggle_star_system'):
        var count := 0
        if drone_manager:
            count = drone_manager.get_drones().size()
        Globals.returning_drone_count = count
        var star_counts: Dictionary = Globals.star_drone_counts.get(Globals.star_seed, {})
        star_counts[Globals.GALAXY_DRONE_SCENE_PATH] = count
        Globals.star_drone_counts[Globals.star_seed] = star_counts
        get_tree().change_scene_to_file(Globals.GALAXY_SCENE_PATH)
    elif event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if event.pressed:
                select_start = get_global_mouse_position()
                selecting = true
                select_rect = Rect2(select_start, Vector2.ZERO)
                queue_redraw()
            else:
                selecting = false
                var rect := Rect2(select_start, get_global_mouse_position() - select_start)
                rect = rect.abs()
                SelectionUtils.apply_selection(self, rect, selected_drones)
                select_rect = Rect2()
                queue_redraw()
        elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
            var target := get_global_mouse_position()
            if selected_drones.is_empty():
                return
            if drone_manager:
                drone_manager.set_targets_for(selected_drones, target)
            else:
                for d in selected_drones:
                    if d.has_method("move_to"):
                        d.move_to(target)

func _on_back_button_pressed() -> void:
    var count := 0
    if drone_manager:
        count = drone_manager.get_drones().size()
    Globals.returning_drone_count = count
    var star_counts: Dictionary = Globals.star_drone_counts.get(Globals.star_seed, {})
    star_counts[Globals.GALAXY_DRONE_SCENE_PATH] = count
    Globals.star_drone_counts[Globals.star_seed] = star_counts
    get_tree().change_scene_to_file(Globals.GALAXY_SCENE_PATH)
