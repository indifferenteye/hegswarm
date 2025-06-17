extends Node2D

@export var asteroid_scene: PackedScene = preload("res://assets/space_asteroid.tscn")

func _ready() -> void:
    var positions := Globals.space_asteroid_positions
    for pos in positions:
        var asteroid: Node2D = asteroid_scene.instantiate()
        add_child(asteroid)
        asteroid.position = pos
    Globals.space_asteroid_positions = []
