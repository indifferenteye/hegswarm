extends Node2D

@export var asteroid_scene: PackedScene = preload("res://assets/space_asteroid.tscn")
@export var drone_scene: PackedScene = preload("res://assets/space_drone.tscn")
@export var processed_iron_scene: PackedScene = preload("res://assets/processed_iron.tscn")
@export var blueprint_scene: PackedScene = preload("res://assets/drone_blueprint.tscn")

var build_mode: String = ""

func _ready() -> void:
    var positions := Globals.space_asteroid_positions
    var seeds := Globals.space_asteroid_seeds
    var belt_seed := Globals.space_belt_seed
    var key := str(Globals.star_seed) + "_" + str(belt_seed)
    for i in range(positions.size()):
        var pos = positions[i]
        var asteroid: Node2D = asteroid_scene.instantiate()
        asteroid.position = pos * 10
        asteroid.add_to_group("asteroid")
        if i < seeds.size() and "seed" in asteroid:
            asteroid.seed = seeds[i]
        if "belt_seed" in asteroid:
            asteroid.belt_seed = belt_seed
        if asteroid.has_signal("mined"):
            asteroid.connect("mined", Callable(self, "_on_asteroid_mined").bind(asteroid))
        add_child(asteroid)
    _apply_mining_to_asteroids(key)
    Globals.space_asteroid_positions = []
    Globals.space_asteroid_seeds = []

    var drone_positions := Globals.space_drone_positions
    for pos in drone_positions:
        var d: Node2D = drone_scene.instantiate()
        add_child(d)
        d.position = pos * 10
        d.scale *= 10
        d.add_to_group("drone")
    Globals.space_drone_positions = []

func _unhandled_input(event: InputEvent) -> void:
    if build_mode != "":
        if event is InputEventMouseButton:
            if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
                if build_mode == "drone" and blueprint_scene:
                    var bp: Node2D = blueprint_scene.instantiate()
                    add_child(bp)
                    bp.global_position = get_global_mouse_position()
                    bp.scale *= 10
                return
            elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
                build_mode = ""
                return

    if event.is_action_pressed('toggle_star_system'):
        _save_system_drone_positions()
        get_tree().change_scene_to_file(Globals.STAR_SYSTEM_SCENE_PATH)
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
        var target := get_global_mouse_position()
        for d in get_tree().get_nodes_in_group("drone"):
            if d.has_method("move_to"):
                d.move_to(target)

func _on_back_button_pressed() -> void:
    _save_system_drone_positions()
    get_tree().change_scene_to_file(Globals.STAR_SYSTEM_SCENE_PATH)

func _on_build_toggle_pressed() -> void:
    if has_node("UI/BuildPanel"):
        var panel = get_node("UI/BuildPanel")
        panel.visible = !panel.visible

func _on_drone_button_pressed() -> void:
    build_mode = "drone"

func _on_asteroid_mined(global_pos: Vector2, asteroid: Node) -> void:
    if processed_iron_scene == null:
        return
    var iron: Node2D = processed_iron_scene.instantiate()
    add_child(iron)
    iron.global_position = global_pos
    iron.scale *= 10
    iron.add_to_group("processed_iron")
    var belt_seed := 0
    if "belt_seed" in asteroid:
        belt_seed = asteroid.belt_seed
    var key := str(Globals.star_seed) + "_" + str(belt_seed)
    var count = Globals.belt_asteroid_count.get(key, 1)
    var mined = Globals.belt_mining_percent.get(key, 0.0)
    mined += 1.0 / float(count)
    Globals.belt_mining_percent[key] = clamp(mined, 0.0, 1.0)

func _save_system_drone_positions() -> void:
    var positions: Array = []
    for d in get_tree().get_nodes_in_group("drone"):
        positions.append(Globals.space_origin + d.position / 10)
    Globals.system_drone_positions = positions

func _apply_mining_to_asteroids(key: String) -> void:
    var percent = Globals.belt_mining_percent.get(key, 0.0)
    if percent <= 0.0:
        return
    for asteroid in get_tree().get_nodes_in_group("asteroid"):
        if not ("seed" in asteroid):
            continue
        var r := RandomNumberGenerator.new()
        r.seed = int(asteroid.seed) + Globals.space_belt_seed + Globals.star_seed
        if r.randf() < percent:
            asteroid.queue_free()
