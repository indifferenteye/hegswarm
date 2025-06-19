extends Object
class_name StarVisuals

static func color_from_seed(seed: int) -> Color:
    var rng := RandomNumberGenerator.new()
    rng.seed = seed
    var hue := rng.randf()
    var sat := 0.6 + rng.randf() * 0.4
    var val := 0.8 + rng.randf() * 0.2
    return Color.from_hsv(hue, sat, val)
