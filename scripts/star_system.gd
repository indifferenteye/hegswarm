extends Node2D

const StarSystemGenerator = preload('res://scripts/generators/star_system_generator.gd')

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
var drones: Array = []
var drone_targets: Array = []
var orbit_radii: Array = []
var sun: Node2D

@export var orbit_color: Color = Color.GRAY
@export var orbit_width: float = 1
## Speed at which the drone moves toward the target position.
@export var drone_speed: float = 80.0
var asteroid_click_radius: float = 200.0

func _ready() -> void:
    rng.seed = Globals.star_seed
    sun = sun_scene.instantiate()
    add_child(sun)
    sun.position = Vector2.ZERO
    _spawn_planets(sun)
    _connect_asteroids()
    _spawn_drones()

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
        add_child(body)
        body.position = sun.position + (Vector2.ZERO if is_belt else offset)
        if is_belt and "radius" in body:
            body.radius = offset.length()
        planets.append(body)
    queue_redraw()

func _spawn_drones() -> void:
    if drone_scene == null or planets.is_empty():
        return
    var count := Globals.entering_drone_count
    if count <= 0:
        return
    for i in range(count):
        var d: Node2D = drone_scene.instantiate()
        add_child(d)
        var planet: Node2D = planets[rng.randi_range(0, planets.size() - 1)]
        d.position = planet.position + Vector2(20, 0).rotated(rng.randf() * TAU)
        drones.append(d)
        drone_targets.append(d.position)
    Globals.entering_drone_count = 0

func _draw() -> void:
    if sun == null:
        return
    for radius in orbit_radii:
        draw_arc(sun.position, radius, 0.0, TAU, 64, orbit_color, orbit_width)

func _connect_asteroids() -> void:
    for asteroid in get_tree().get_nodes_in_group("asteroid"):
        if asteroid.has_signal("clicked"):
            asteroid.connect("clicked", Callable(self, "_on_asteroid_clicked"))

func _on_asteroid_clicked(click_pos: Vector2) -> void:
    var positions: Array = []
    for asteroid in get_tree().get_nodes_in_group("asteroid"):
        if asteroid.global_position.distance_to(click_pos) <= asteroid_click_radius:
            positions.append(asteroid.global_position - click_pos)
    Globals.space_asteroid_positions = positions

    var drone_positions: Array = []
    for d in drones:
        if d.global_position.distance_to(click_pos) <= asteroid_click_radius:
            drone_positions.append(d.global_position - click_pos)
    Globals.space_drone_positions = drone_positions

    get_tree().change_scene_to_file(Globals.SPACE_SCENE_PATH)

func _process(delta: float) -> void:
    for i in range(drones.size()):
        var d: Node2D = drones[i]
        var target: Vector2 = drone_targets[i]
        var delta_pos := target - d.position
        if delta_pos.length() > 1.0:
            d.position += delta_pos.normalized() * drone_speed * delta
        else:
            d.position = target

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed('return_to_galaxy') or event.is_action_pressed('toggle_star_system'):
        get_tree().change_scene_to_file('res://scenes/galaxy.tscn')
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        var target := get_global_mouse_position()
        for i in range(drone_targets.size()):
            drone_targets[i] = target

func _on_back_button_pressed() -> void:
    get_tree().change_scene_to_file('res://scenes/galaxy.tscn')
