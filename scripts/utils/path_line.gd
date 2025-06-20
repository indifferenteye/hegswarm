extends Node2D

var start_pos: Vector2 = Vector2.ZERO
var end_pos: Vector2 = Vector2.ZERO
var line_color: Color = Color.WHITE
var line_width: float = 1.0
var dash_size: float = 4.0

func _process(_delta: float) -> void:
    queue_redraw()

func _draw() -> void:
    if start_pos.distance_to(end_pos) <= 1.0:
        return
    draw_dashed_line(start_pos, end_pos, line_color, line_width, dash_size)
