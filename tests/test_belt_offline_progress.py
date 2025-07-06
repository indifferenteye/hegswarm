import math
import time


def apply_offline_progress_py(
    key,
    counts,
    belt_last_loaded,
    belt_mining_percent,
    belt_asteroid_count,
    belt_total_integrity,
    now=None,
    offline_progress_factor=0.05,
):
    if now is None:
        now = int(time.time())
    last_time = belt_last_loaded.get(key, 0)
    if last_time == 0:
        belt_last_loaded[key] = now
        return 0
    dt = float(now - last_time)
    total_asteroids = belt_asteroid_count.get(key, 1)
    total_integrity = belt_total_integrity.get(key, float(total_asteroids))
    percent = belt_mining_percent.get(key, 0.0)
    if not counts:
        belt_last_loaded[key] = now
        return 0
    rate_accum = 0.0
    for info in counts.values():
        count = info['count']
        rate = info['mining_rate']
        speed = info['move_speed']
        rate_accum += count * rate * offline_progress_factor / (total_integrity / speed)
    new_percent = 1.0 - (1.0 - percent) * math.exp(-rate_accum * dt * 0.00001)
    new_percent = max(0.0, min(1.0, new_percent))
    belt_mining_percent[key] = new_percent
    belt_last_loaded[key] = now
    return new_percent - percent


def test_belt_offline_progress_increases_percent():
    key = 'belt1'
    now = 2000
    belt_last_loaded = {key: 1900}
    belt_mining_percent = {key: 0.0}
    belt_asteroid_count = {key: 10}
    belt_total_integrity = {key: 10.0}
    counts = {
        'drone.scn': {'count': 1, 'mining_rate': 10.0, 'move_speed': 2.0}
    }
    delta = apply_offline_progress_py(
        key,
        counts,
        belt_last_loaded,
        belt_mining_percent,
        belt_asteroid_count,
        belt_total_integrity,
        now=now,
    )
    assert belt_mining_percent[key] > 0.0
    assert delta > 0.0
