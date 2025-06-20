extends Node2D

@export var asteroid_scene: PackedScene = preload("res://assets/space_asteroid.tscn")
@export var drone_scene: PackedScene = preload("res://assets/space_drone.tscn")
@export var processed_material_scene: PackedScene = preload("res://assets/processed_iron.tscn")
@export var blueprint_scene: PackedScene = preload("res://assets/drone_blueprint.tscn")

var build_mode: String = ""
var selected_drones: Array = []
var selecting: bool = false
var select_start: Vector2
var select_rect: Rect2 = Rect2()

func _ready() -> void:
    var positions := Globals.space_asteroid_positions
    var seeds := Globals.space_asteroid_seeds
    var belt_seed := Globals.space_belt_seed
    var key := str(Globals.star_seed) + "_" + str(belt_seed)
    _apply_offline_progress(key)
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
    if drone_positions.size() > 0:
        for pos in drone_positions:
            var d: Node2D = drone_scene.instantiate()
            add_child(d)
            d.position = pos * 10
            d.scale *= 10
            d.add_to_group("drone")
            d.set_meta("scene_path", drone_scene.resource_path)
        Globals.space_drone_positions = []
    else:
        var counts: Dictionary = Globals.belt_drones.get(key, {})
        for scene_path in counts.keys():
            var scene := load(scene_path)
            if scene == null:
                continue
            for i in range(int(counts[scene_path])):
                var d: Node2D = scene.instantiate()
                add_child(d)
                d.position = Vector2.ZERO
                d.scale *= 10
                d.add_to_group("drone")
                d.set_meta("scene_path", scene_path)

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
                _apply_selection(rect)
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

func _set_drone_selected(d: Node2D, selected: bool) -> void:
    var sprite: Sprite2D = d.get_node_or_null("Sprite2D")
    if sprite:
        sprite.modulate = (Color.YELLOW if selected else Color.WHITE)

func _clear_selection() -> void:
    for d in selected_drones:
        _set_drone_selected(d, false)
    selected_drones.clear()

func _apply_selection(rect: Rect2) -> void:
    _clear_selection()
    rect = rect.abs()
    for d in get_tree().get_nodes_in_group("drone"):
        if rect.has_point(d.global_position):
            selected_drones.append(d)
            _set_drone_selected(d, true)

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
    _record_belt_state()
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

## Estimate asteroid mining progress that occurred while this belt was unloaded.
func _apply_offline_progress(key: String) -> void:
    var offline_progress_factor = 0.05
    var last_time = Globals.belt_last_loaded.get(key, 0)
    var now := Time.get_unix_time_from_system()
    if last_time == 0:
        Globals.belt_last_loaded[key] = now
        return
    var counts: Dictionary = Globals.belt_drones.get(key, {})
    if counts.is_empty():
        Globals.belt_last_loaded[key] = now
        return
    var mined_total := 0.0
    var total_asteroids = Globals.belt_asteroid_count.get(key, 1)
    var total_integrity = Globals.belt_total_integrity.get(key, float(total_asteroids))
    for scene_path in counts.keys():
        var scene := load(scene_path)
        if scene == null:
            continue
        var inst = scene.instantiate()
        var rate := 0.0
        if "mining_rate" in inst:
            rate = inst.mining_rate
        var speed := 0.0
        if "move_speed" in inst:
            speed = inst.move_speed
        inst.free()
        mined_total += float(counts[scene_path]) * rate * float(now - last_time) * offline_progress_factor / (total_integrity / speed)
    var percent = Globals.belt_mining_percent.get(key, 0.0)
    percent += mined_total / float(total_integrity)
    print(percent)
    Globals.belt_mining_percent[key] = clamp(percent, 0.0, 1.0)
    Globals.belt_last_loaded[key] = now

## Save how many drones of each type are currently in this belt and when it was left.
func _record_belt_state() -> void:
    var belt_seed := Globals.space_belt_seed
    if belt_seed == 0:
        return
    var key := str(Globals.star_seed) + "_" + str(belt_seed)
    var counts: Dictionary = {}
    for d in get_tree().get_nodes_in_group("drone"):
        var path := ""
        if d.has_meta("scene_path"):
            path = str(d.get_meta("scene_path"))
        else:
            path = drone_scene.resource_path
        counts[path] = counts.get(path, 0) + 1
    Globals.belt_drones[key] = counts
    Globals.belt_last_loaded[key] = Time.get_unix_time_from_system()
