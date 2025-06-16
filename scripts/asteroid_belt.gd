extends Node2D

@export var radius: float = 100.0
@export var dot_count: int = 40
@export var dot_radius: float = 2.0
@export var color: Color = Color.LIGHT_GRAY


func _draw() -> void:
    for i in range(dot_count):
        var angle := TAU * float(i) / dot_count
        var pos := Vector2(cos(angle), sin(angle)) * radius
        draw_circle(pos, dot_radius, color)
