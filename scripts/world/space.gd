extends Node2D

const BeltManager = preload("res://scripts/utils/belt_manager.gd")
const SelectionUtils = preload("res://scripts/utils/selection_utils.gd")

@export var asteroid_scene: PackedScene = preload("res://assets/celestials/space_asteroid.tscn")
@export var drone_scene: PackedScene = preload("res://assets/drones/space_drone.tscn")
@export var processed_material_scene: PackedScene = preload("res://assets/materials/processed_iron.tscn")
@export var blueprint_scene: PackedScene = preload("res://assets/drones/drone_blueprint.tscn")
@export var material_cluster_scene: PackedScene = preload("res://assets/materials/material_cluster.tscn")

var build_mode: String = ""
var blueprint_drone_scene: PackedScene
var selected_drones: Array = []
var selecting: bool = false
var select_start: Vector2
var select_rect: Rect2 = Rect2()

func _ready() -> void:
    blueprint_drone_scene = drone_scene
    var positions := Globals.space_asteroid_positions
    var seeds := Globals.space_asteroid_seeds
    var belt_seed := Globals.space_belt_seed
    var key := str(Globals.star_seed) + "_" + str(belt_seed)



    BeltManager.apply_offline_progress(self, material_cluster_scene, key)
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
    BeltManager.apply_mining_to_asteroids(self, key)
    Globals.space_asteroid_positions = []
    Globals.space_asteroid_seeds = []

    var drone_positions := Globals.space_drone_positions
    var counts: Dictionary = Globals.belt_drones.get(key, {})
    for scene_path in counts.keys():
        var scene := load(scene_path)
        if scene == null:
            continue
        for i in range(int(counts[scene_path])):
            var d: Node2D = scene.instantiate()
            add_child(d)
            var pos := Vector2.ZERO
            if drone_positions.size() > 0:
                pos = drone_positions.pop_front() * 10
            d.position = pos
            d.scale *= 10
            d.add_to_group("drone")
            d.set_meta("scene_path", scene_path)
            if "cluster_scene" in d:
                d.cluster_scene = material_cluster_scene
    for pos in drone_positions:
        var d: Node2D = drone_scene.instantiate()
        add_child(d)
        d.position = pos * 10
        d.scale *= 10
        d.add_to_group("drone")
        d.set_meta("scene_path", drone_scene.resource_path)
        if "cluster_scene" in d:
            d.cluster_scene = material_cluster_scene
    Globals.space_drone_positions = []


func _draw() -> void:
    if selecting:
        var rect := Rect2(to_local(select_start), select_rect.size)
        draw_rect(rect, Color(0.4, 0.6, 1.0, 0.15), true)
        draw_rect(rect, Color(0.4, 0.6, 1.0, 0.8), false, 1.0)

func _process(_delta: float) -> void:
    if selecting:
        var current := get_global_mouse_position()
        select_rect = Rect2(select_start, current - select_start)
        queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if build_mode != "":
        if event is InputEventMouseButton:
            if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
                if build_mode == "drone" and blueprint_scene:
                    var bp: Node2D = blueprint_scene.instantiate()
                    add_child(bp)
                    bp.global_position = get_global_mouse_position()
                    bp.scale *= 10
                    if "cluster_scene" in bp:
                        bp.cluster_scene = material_cluster_scene
                    if "drone_scene" in bp and blueprint_drone_scene:
                        bp.drone_scene = blueprint_drone_scene
                return
            elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
                build_mode = ""
                return

    if event.is_action_pressed('toggle_star_system'):
        _save_system_drone_positions()
        get_tree().change_scene_to_file(Globals.STAR_SYSTEM_SCENE_PATH)
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
            for d in selected_drones:
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
    blueprint_drone_scene = drone_scene

func _on_carrier_button_pressed() -> void:
    build_mode = "drone"
    blueprint_drone_scene = preload("res://assets/drones/carrier_drone.tscn")


func _on_asteroid_mined(global_pos: Vector2, asteroid: Node) -> void:
    if processed_material_scene == null:
        return
    var iron: Node2D = processed_material_scene.instantiate()
    add_child(iron)
    iron.global_position = global_pos
    iron.scale *= 10
    iron.add_to_group("processed_material")
    var belt_seed := 0
    if "belt_seed" in asteroid:
        belt_seed = asteroid.belt_seed
    var key := str(Globals.star_seed) + "_" + str(belt_seed)
    var count = Globals.belt_asteroid_count.get(key, 1)
    var mined = Globals.belt_mining_percent.get(key, 0.0)
    mined += 1.0 / float(count)
    Globals.belt_mining_percent[key] = clamp(mined, 0.0, 1.0)

func _save_system_drone_positions() -> void:
    BeltManager.record_belt_state(self, drone_scene)
    var positions: Array = []
    for d in get_tree().get_nodes_in_group("drone"):
        positions.append(Globals.space_origin + d.position / 10)
    Globals.system_drone_positions = positions
