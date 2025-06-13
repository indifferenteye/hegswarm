extends Camera2D

## Camera movement speed in pixels per second.
@export var move_speed: float = 200.0
## How quickly the zoom level changes when zooming in or out.
@export var zoom_speed: float = 1.0
## Minimum allowed zoom level.
@export var max_zoom_in: float = 0.5
## Maximum allowed zoom level.
@export var max_zoom_out: float = 4.0

func _process(delta: float) -> void:
    var direction := Vector2.ZERO
    if Input.is_action_pressed("camera_move_up"):
        direction.y -= 1
    if Input.is_action_pressed("camera_move_down"):
        direction.y += 1
    if Input.is_action_pressed("camera_move_left"):
        direction.x -= 1
    if Input.is_action_pressed("camera_move_right"):
        direction.x += 1
    if direction != Vector2.ZERO:
        position += direction.normalized() * move_speed * delta

    var zoom_change := 0.0
    if Input.is_action_pressed("camera_zoom_in"):
        zoom_change -= zoom_speed * delta
    if Input.is_action_pressed("camera_zoom_out"):
        zoom_change += zoom_speed * delta
    if zoom_change != 0.0:
        _update_zoom(zoom_change)

func _update_zoom(delta_z: float) -> void:
    var new_zoom := clamp(zoom.x + delta_z, max_zoom_in, max_zoom_out)
    zoom = Vector2(new_zoom, new_zoom)
