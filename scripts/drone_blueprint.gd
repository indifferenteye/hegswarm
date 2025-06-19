extends Node2D

@export var required_iron: int = 5
@export var drone_scene: PackedScene = preload("res://assets/space_drone.tscn")

var current_iron: int = 0

func _ready() -> void:
    add_to_group("drone_blueprint")
    queue_redraw()

func add_iron() -> void:
    current_iron += 1
    if current_iron >= required_iron:
        _spawn_drone()
    queue_redraw()

func _spawn_drone() -> void:
    if drone_scene == null:
        return
    var d: Node2D = drone_scene.instantiate()
    get_parent().add_child(d)
    d.global_position = global_position
    d.scale *= 10
    d.add_to_group("drone")
    queue_free()

func _draw() -> void:
    draw_circle(Vector2.ZERO, 10.0, Color(0.2, 0.6, 1.0, 0.5))
    var angle := TAU * float(current_iron) / float(required_iron)
    draw_arc(Vector2.ZERO, 12.0, -PI / 2.0, angle, 16, Color.AQUA)
