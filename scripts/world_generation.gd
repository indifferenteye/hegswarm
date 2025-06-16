extends Node2D

@export var scene_to_instance: PackedScene
@export var count: int = 8
@export var radius: float = 200.0

func _ready():
	for i in range(count):
		var instance = scene_to_instance.instantiate()
		var angle = TAU * i / count
		instance.position = Vector2(cos(angle), sin(angle)) * radius
		add_child(instance)
		var orbit = OrbitDrawer.new()
		orbit.radius = radius
		add_child(orbit)
