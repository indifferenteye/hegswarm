extends Node2D

@export var size: float = 4.0
@export var color: Color = Color.BURLYWOOD

func _draw() -> void:
    draw_rect(Rect2(Vector2(-size / 2, -size / 2), Vector2(size, size)), color)
