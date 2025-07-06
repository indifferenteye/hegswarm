import math
import random


def generate_planet_offsets_py(min_planets, max_planets, orbit_step, rng, min_step):
    offsets = []
    count = rng.randint(min_planets, max_planets)
    for i in range(count):
        radius = orbit_step * (i + 1 + min_step) + rng.uniform(-orbit_step * 0.25, orbit_step * 0.25)
        angle = rng.uniform(0.0, math.tau)
        offsets.append((math.cos(angle) * radius, math.sin(angle) * radius))
    return offsets


def test_generate_planet_offsets_count_and_radius():
    rng = random.Random(42)
    min_planets = 2
    max_planets = 5
    orbit_step = 80.0
    min_step = 1.5
    offsets = generate_planet_offsets_py(min_planets, max_planets, orbit_step, rng, min_step)
    assert min_planets <= len(offsets) <= max_planets
    count = len(offsets)
    max_radius = orbit_step * (count + min_step + 0.25)
    for x, y in offsets:
        assert math.hypot(x, y) <= max_radius + 1e-6
