extends Node2D

@export var seed: int = 0

var _glow_sprite: Sprite2D

func _ready() -> void:
    _generate_visuals(seed)

func _generate_visuals(seed_value: int) -> void:
    seed = seed_value
    var color := StarVisuals.color_from_seed(seed)
    $Sprite2D.modulate = color
    _create_glow(color)

func _create_glow(color: Color) -> void:
    _glow_sprite = Sprite2D.new()
    _glow_sprite.texture = $Sprite2D.texture
    _glow_sprite.scale = $Sprite2D.scale * 3.0
    var mat := CanvasItemMaterial.new()
    mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
    _glow_sprite.material = mat
    _glow_sprite.modulate = color
    _glow_sprite.z_index = -1
    add_child(_glow_sprite)
