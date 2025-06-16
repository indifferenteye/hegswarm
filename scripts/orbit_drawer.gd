class_name OrbitDrawer
extends Node2D

@export var radius: float = 100.0
@export var color: Color = Color(1, 1, 1, 0.5)

func _ready():
update()

func _draw():
draw_arc(Vector2.ZERO, radius, 0, TAU, 64, color, 1.0)
