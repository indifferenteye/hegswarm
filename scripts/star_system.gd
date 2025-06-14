extends Node2D

## Scene used for the system's star.
@export var sun_scene: PackedScene = preload("res://assets/sun.tscn")

func _ready() -> void:
	var sun: Node2D = sun_scene.instantiate()
	add_child(sun)
	sun.position = Vector2.ZERO
