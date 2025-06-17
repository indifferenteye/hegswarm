extends Node2D

signal clicked(global_position: Vector2)


@export var radius: float = 1.0
@export var click_radius: float = 32.0
@export var color: Color = Color.WHITE

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
  radius = rng.randf() * 2 * radius

func _draw() -> void:
    draw_circle(Vector2.ZERO, radius, color)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        if global_position.distance_to(get_global_mouse_position()) <= click_radius:
            emit_signal("clicked", global_position)
