extends Node2D

## Unique seed for this star, useful for deterministic system generation.
@export var seed: int = 0

## Color used when the mouse is hovering over the star.
@export var hover_color: Color = Color.YELLOW
## Color used to indicate the star was the last system visited.
@export var visited_color: Color = Color.AQUA

var _default_color: Color
var _is_last_visited: bool = false

func _ready() -> void:
    _default_color = $Sprite2D.modulate

## Handles mouse input on the star. When the player left-clicks the star, the
## scene changes to the star system view.
func _on_star_clicked() -> void:
    var drones := get_tree().get_nodes_in_group("galaxy_drone")
    var near_count := 0
    for d in drones:
        if d.has_method("is_near") and d.call("is_near", global_position):
            if "belongs_to_star_seed" in d and d.belongs_to_star_seed == seed:
                near_count += 1
    if near_count > 0:
        Globals.entering_drone_count = near_count
        Globals.star_seed = seed
        get_tree().change_scene_to_file(Globals.STAR_SYSTEM_SCENE_PATH)
    elif drones.size() > 0:
        var d := drones[0]
        if d.has_method("move_to"):
            d.call("move_to", global_position)
            if "belongs_to_star_seed" in d:
                d.belongs_to_star_seed = seed

func _handle_click_event(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        _on_star_clicked()

func _on_sprite_input_event(viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
    _handle_click_event(event)

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
       _handle_click_event(event)


func _on_area_2d_mouse_entered() -> void:
    $Sprite2D.modulate = hover_color

func _on_area_2d_mouse_exited() -> void:
    if _is_last_visited:
        $Sprite2D.modulate = visited_color
    else:
        $Sprite2D.modulate = _default_color

## Marks this star as the last visited and updates its visual highlight.
func mark_as_last_visited() -> void:
    _is_last_visited = true
    $Sprite2D.modulate = visited_color
