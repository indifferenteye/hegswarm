extends Node

class_name SelectionUtils

static func set_selected(d: Node2D, selected: bool) -> void:
    var sprite: Sprite2D = d.get_node_or_null("Sprite2D")
    if sprite:
        sprite.modulate = (Color.YELLOW if selected else Color.WHITE)

static func clear_selection(selected_drones: Array) -> void:
    for d in selected_drones:
        set_selected(d, false)
    selected_drones.clear()

static func apply_selection(owner: Node, rect: Rect2, selected_drones: Array) -> void:
    clear_selection(selected_drones)
    rect = rect.abs()
    for d in owner.get_tree().get_nodes_in_group("drone"):
        if rect.has_point(d.global_position):
            selected_drones.append(d)
            set_selected(d, true)
