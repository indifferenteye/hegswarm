extends Node2D

@export var asteroid_scene: PackedScene = preload("res://assets/space_asteroid.tscn")
@export var drone_scene: PackedScene = preload("res://assets/space_drone.tscn")

func _ready() -> void:
    var positions := Globals.space_asteroid_positions
    for pos in positions:
        var asteroid: Node2D = asteroid_scene.instantiate()
        add_child(asteroid)
        asteroid.position = pos * 10
        asteroid.scale *= 10
    Globals.space_asteroid_positions = []

    var drone_positions := Globals.space_drone_positions
    for pos in drone_positions:
        var d: Node2D = drone_scene.instantiate()
        add_child(d)
        d.position = pos * 10
        d.scale *= 10
    Globals.space_drone_positions = []

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed('toggle_star_system'):
        get_tree().change_scene_to_file(Globals.STAR_SYSTEM_SCENE_PATH)

func _on_back_button_pressed() -> void:
    get_tree().change_scene_to_file(Globals.STAR_SYSTEM_SCENE_PATH)
