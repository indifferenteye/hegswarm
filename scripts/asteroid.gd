extends Node2D

signal clicked(global_position: Vector2)
signal mined(global_position: Vector2)

@export var radius: float = 5.0
@export var click_radius: float = 32.0
@export var color: Color = Color.WHITE
@export var integrity: float = 1.0
@export var seed: int = 0
@export var voxel_size: float = 2.0

var _max_integrity: float = 1.0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var noise: FastNoiseLite = FastNoiseLite.new()
var _voxels: Array = []

func _ready() -> void:
    rng.seed = seed
    noise.seed = seed
    radius = rng.randf() * 2 * radius
    _generate_voxels()
    _max_integrity = float(_voxels.size())
    integrity = _max_integrity

func _draw() -> void:
    var scale := integrity / _max_integrity
    var size := voxel_size * scale
    for voxel in _voxels:
        var pos: Vector2 = voxel * voxel_size * scale
        draw_rect(Rect2(pos, Vector2(size, size)), color)

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

func _generate_voxels() -> void:
    _voxels.clear()
    noise.noise_type = FastNoiseLite.TYPE_CELLULAR
    noise.frequency = .05
    var grid_radius := int(radius / voxel_size) + 1
    for x in range(-grid_radius, grid_radius + 1):
        for y in range(-grid_radius, grid_radius + 1):
            var dist := Vector2(x, y).length() / grid_radius
            var n :float = (noise.get_noise_2d(x, y) + 1)
            if n > dist:
                _voxels.append(Vector2(x, y))
