extends Node2D

## Materials required to finish this blueprint. Each key is a material type
## and the value is the amount needed.
@export var required_materials: Dictionary = {"iron": 5}
@export var drone_scene: PackedScene = preload("res://assets/drones/space_drone.tscn")

var current_materials: Dictionary = {}

func _ready() -> void:
    add_to_group("drone_blueprint")
    queue_redraw()

func needs_material(material_type: String) -> bool:
    return current_materials.get(material_type, 0) < required_materials.get(material_type, 0)

func add_material(material_type: String) -> void:
    var current = current_materials.get(material_type, 0)
    current += 1
    current_materials[material_type] = current
    _check_completion()
    queue_redraw()

func _check_completion() -> void:
    for mat in required_materials.keys():
        if current_materials.get(mat, 0) < required_materials[mat]:
            return
    _spawn_drone()

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
    var required_total := 0.0
    var current_total := 0.0
    for mat in required_materials.keys():
        required_total += float(required_materials[mat])
        current_total += float(current_materials.get(mat, 0))
    if required_total <= 0.0:
        return
    var angle := TAU * (current_total / required_total)
    draw_arc(Vector2.ZERO, 12.0, -PI / 2.0, angle, 16, Color.AQUA)
