extends Node2D

@export var capacity: int = 20
@export var material_type: String = "iron"
var stored_amount: int = 0

func _ready() -> void:
    add_to_group("material_cluster")
    queue_redraw()

func add_material(mat_type: String) -> bool:
    if mat_type != material_type:
        return false
    if stored_amount >= capacity:
        return false
    stored_amount += 1
    queue_redraw()
    return true

func take_material() -> bool:
    if stored_amount <= 0:
        return false
    stored_amount -= 1
    queue_redraw()
    return true

func _draw() -> void:
    draw_circle(Vector2.ZERO, 10.0, Color(0.8, 0.5, 0.1, 0.3))
    if capacity > 0:
        var angle := TAU * float(stored_amount) / float(capacity)
        draw_arc(Vector2.ZERO, 12.0, -PI / 2.0, angle, 16, Color.YELLOW)
