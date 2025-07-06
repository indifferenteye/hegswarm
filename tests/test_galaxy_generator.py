import math
import random


def generate_star_data_py(star_count, radius, arm_count, twist, arm_spread, random_offset, rng):
    stars = []
    for i in range(star_count):
        t = i / star_count
        arm = rng.randrange(arm_count)
        r = t * radius + rng.uniform(-random_offset, random_offset)
        angle = t * twist + math.tau * arm / arm_count
        angle += rng.uniform(-arm_spread, arm_spread)
        x = math.cos(angle) * r
        y = math.sin(angle) * r
        stars.append({"position": (x, y), "seed": rng.getrandbits(32)})
    return stars


def test_generate_star_data_radius_and_count():
    rng = random.Random(123)
    radius = 10.0
    star_count = 50
    data = generate_star_data_py(
        star_count=star_count,
        radius=radius,
        arm_count=3,
        twist=1.0,
        arm_spread=0.2,
        random_offset=0.0,
        rng=rng,
    )
    assert len(data) == star_count
    # Ensure no star lies beyond the radius
    max_dist = max(math.hypot(x, y) for x, y in [d["position"] for d in data])
    assert max_dist <= radius + 1e-6
