extends Node2D

var _radius: float = 100.0
@export var radius: float = 100.0:
    set = set_radius,
    get = get_radius
@export var thickness: float = 20.0
@export var dot_count: int = 40
@export var dot_radius: float = 2.0
@export var color: Color = Color.LIGHT_GRAY

var _points: PackedVector2Array = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
    _generate_points()

func set_radius(value: float) -> void:
    _radius = value
    _generate_points()

func get_radius() -> float:
    return _radius

func _generate_points() -> void:
    _points.clear()
    _rng.randomize()
    for i in range(dot_count):
        var angle := TAU * float(i) / dot_count
        var dist := radius + _rng.randf_range(-thickness / 2.0, thickness / 2.0)
        var pos := Vector2(cos(angle), sin(angle)) * dist
        _points.append(pos)


func _draw() -> void:
    for pos in _points:
        draw_circle(pos, dot_radius, color)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        var local_pos := to_local(get_global_mouse_position())
        var dist := local_pos.length()
        if dist >= radius - thickness / 2.0 and dist <= radius + thickness / 2.0:
            print("belt clicked")
