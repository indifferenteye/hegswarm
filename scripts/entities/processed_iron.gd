extends Node2D

@export var size: float = 4.0
@export var color: Color = Color.BURLYWOOD
@export var material_type: String = "iron"

func _ready() -> void:
    add_to_group("processed_material")

func _draw() -> void:
    draw_rect(Rect2(Vector2(-size / 2, -size / 2), Vector2(size, size)), color)
