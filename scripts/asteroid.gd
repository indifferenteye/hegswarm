extends Node2D

signal clicked(global_position: Vector2)
signal mined(global_position: Vector2)

@export var radius: float = 1.0
@export var click_radius: float = 32.0
@export var color: Color = Color.WHITE
@export var integrity: float = 1.0

var _max_integrity: float = 1.0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
    rng.randomize()
    radius = rng.randf() * 2 * radius
    _max_integrity = radius
    integrity = _max_integrity

func _draw() -> void:
    var scale := integrity / _max_integrity
    draw_circle(Vector2.ZERO, radius * scale, color)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        if global_position.distance_to(get_global_mouse_position()) <= click_radius:
            emit_signal("clicked", global_position)

func mine(amount: float) -> void:
    integrity -= amount
    if integrity <= 0:
        emit_signal("mined", global_position)
        queue_free()
    else:
        queue_redraw()
