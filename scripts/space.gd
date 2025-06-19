extends Node2D

@export var asteroid_scene: PackedScene = preload("res://assets/space_asteroid.tscn")
@export var drone_scene: PackedScene = preload("res://assets/space_drone.tscn")
@export var processed_iron_scene: PackedScene = preload("res://assets/processed_iron.tscn")

func _ready() -> void:
    var positions := Globals.space_asteroid_positions
    for pos in positions:
        var asteroid: Node2D = asteroid_scene.instantiate()
        add_child(asteroid)
        asteroid.position = pos * 10
        asteroid.scale *= 10
        asteroid.add_to_group("asteroid")
        if asteroid.has_signal("mined"):
            asteroid.connect("mined", Callable(self, "_on_asteroid_mined"))
    Globals.space_asteroid_positions = []

    var drone_positions := Globals.space_drone_positions
    for pos in drone_positions:
        var d: Node2D = drone_scene.instantiate()
        add_child(d)
        d.position = pos * 10
        d.scale *= 10
        d.add_to_group("drone")
    Globals.space_drone_positions = []

func _unhandled_input(event: InputEvent) -> void:
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

func _on_asteroid_mined(global_pos: Vector2) -> void:
    if processed_iron_scene == null:
        return
    var iron: Node2D = processed_iron_scene.instantiate()
    add_child(iron)
    iron.global_position = global_pos
    iron.scale *= 10

func _save_system_drone_positions() -> void:
    var positions: Array = []
    for d in get_tree().get_nodes_in_group("drone"):
        positions.append(Globals.space_origin + d.position / 10)
    Globals.system_drone_positions = positions
