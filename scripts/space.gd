extends Node2D

@export var asteroid_scene: PackedScene = preload("res://assets/space_asteroid.tscn")

func _ready() -> void:
    var positions := Globals.space_asteroid_positions
    for pos in positions:
        var asteroid: Node2D = asteroid_scene.instantiate()
        add_child(asteroid)
        asteroid.position = pos * 10
        asteroid.scale *= 10
    Globals.space_asteroid_positions = []

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed('toggle_star_system'):
        get_tree().change_scene_to_file(Globals.STAR_SYSTEM_SCENE_PATH)

func _on_back_button_pressed() -> void:
    get_tree().change_scene_to_file(Globals.STAR_SYSTEM_SCENE_PATH)
