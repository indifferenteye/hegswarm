extends Node2D

## Unique seed for this star, useful for deterministic system generation.
@export var seed: int = 0

## Color used when the mouse is hovering over the star.
@export var hover_color: Color = Color.YELLOW
## Color used to indicate the star was the last system visited.
@export var visited_color: Color = Color.AQUA
@export var _default_color: Color = Color.WHITE

var _is_last_visited: bool = false

## Handles mouse input on the star. When the player left-clicks the star, the
## scene changes to the star system view.
func _update_star_counts() -> void:
    var counts: Dictionary = {}
    for d in get_tree().get_nodes_in_group("galaxy_drone"):
        if "belongs_to_star_seed" in d:
            var s = d.belongs_to_star_seed
            if not counts.has(s):
                counts[s] = {}
            var t_counts: Dictionary = counts[s]
            var t := Globals.GALAXY_DRONE_SCENE_PATH
            t_counts[t] = t_counts.get(t, 0) + 1
            counts[s] = t_counts
    Globals.star_drone_counts = counts

func _on_star_clicked(event: InputEvent) -> void:
    _update_star_counts()
    var drones := get_tree().get_nodes_in_group("galaxy_drone")
    var counts  = Globals.star_drone_counts.get(seed, {})
    var near_count : int = counts.get(Globals.GALAXY_DRONE_SCENE_PATH, 0)
    var first_near_drone: Node2D = null
    for d in drones:
        if "belongs_to_star_seed" in d and d.belongs_to_star_seed == seed:
            first_near_drone = d
            break
    if event.button_index == MOUSE_BUTTON_LEFT and near_count > 0:
        if first_near_drone != null:
            Globals.galaxy_drone_position = first_near_drone.global_position
        Globals.entering_drone_count = near_count
        Globals.star_seed = seed
        Globals.start_star_seed = seed
        get_tree().change_scene_to_file(Globals.STAR_SYSTEM_SCENE_PATH)
    elif event.button_index == MOUSE_BUTTON_RIGHT and drones.size() > 0:
        var d := drones[0]
        if d.has_method("move_to"):
            d.call("move_to", global_position)
            if "belongs_to_star_seed" in d:
                d.belongs_to_star_seed = seed

func _handle_click_event(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed:
        _on_star_clicked(event)

func _on_sprite_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
    _handle_click_event(event)

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
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
