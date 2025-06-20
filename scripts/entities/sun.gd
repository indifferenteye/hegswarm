extends Node2D

## Unique seed controlling the sun's procedural look.
@export var seed: int = 0

func _ready() -> void:
    if $Sprite2D.material != null:
        $Sprite2D.material.set_shader_parameter("seed", float(seed))
