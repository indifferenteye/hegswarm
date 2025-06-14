extends Object

class_name GalaxyGenerator

func generate_star_data(
	star_count: int,
	radius: float,
	arm_count: int,
	twist: float,
	arm_spread: float,
	random_offset: float,
	rng: RandomNumberGenerator
) -> Array:
	var stars: Array = []
	for i in range(star_count):
		var t: float = float(i) / star_count
		var arm := rng.randi() % arm_count
		var r := t * radius + rng.randf_range(-random_offset, random_offset)
		var angle := t * twist + TAU * arm / arm_count
		angle += rng.randf_range(-arm_spread, arm_spread)
		var star_data := {
			"position": Vector2(cos(angle), sin(angle)) * r,
			"seed": rng.randi()
		}
		stars.append(star_data)
	return stars
