extends Object

class_name StarSystemGenerator

func generate_planet_offsets(min_planets: int, max_planets: int, orbit_step: float, rng: RandomNumberGenerator, min_step: float) -> Array:
    var offsets: Array = []
    var count := rng.randi_range(min_planets, max_planets)
    for i in range(count):
        var radius := orbit_step * (i + 1 + min_step) + rng.randf_range(-orbit_step * 0.25, orbit_step * 0.25)
        var angle := rng.randf_range(0.0, TAU)
        offsets.append(Vector2(cos(angle), sin(angle)) * radius)
    return offsets
