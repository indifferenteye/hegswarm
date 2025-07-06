extends RefCounted

class_name BeltOfflineProgress

var offline_progress_factor: float = 0.05
var transport_time_per_material: float = 1.0

## Calculates and applies offline progress for the belt identified by `key`.
## Returns the amount of mined material available for delivery after
## processing blueprints and updates various Globals dictionaries.
func apply(key: String) -> int:
    var last_time = Globals.belt_last_loaded.get(key, 0)
    var now := Time.get_unix_time_from_system()
    if last_time == 0:
        Globals.belt_last_loaded[key] = now
        return 0

    var counts: Dictionary = Globals.belt_drones.get(key, {})
    var mined_total := _calculate_mined_total(counts, last_time, now, key)
    var available := _apply_blueprints(counts, mined_total, last_time, now, key)

    Globals.belt_last_loaded[key] = now
    return available

## Computes how many asteroids were mined while the belt was unloaded.
## Updates `Globals.belt_mining_percent` based on the elapsed time and the
## drones specified in `counts`.
func _calculate_mined_total(counts: Dictionary, last_time: int, now: int, key: String) -> float:
    if counts.is_empty():
        return 0.0

    var dt: float = float(now - last_time)
    var total_asteroids = Globals.belt_asteroid_count.get(key, 1)
    var total_integrity = Globals.belt_total_integrity.get(key, float(total_asteroids))
    var percent = Globals.belt_mining_percent.get(key, 0.0)

    # Calculate an aggregated mining rate scaled by the offline_progress_factor.
    # This value is used as the exponential growth rate so that mining slows as
    # the belt approaches depletion.
    var rate_accum := 0.0
    for scene_path in counts.keys():
        var scene := load(scene_path)
        if scene == null:
            continue
        var inst = scene.instantiate()
        var rate := 0.0
        if "mining_rate" in inst:
            rate = inst.mining_rate
        var speed := 0.0
        if "move_speed" in inst:
            speed = inst.move_speed
        inst.free()
        rate_accum += float(counts[scene_path]) * rate * offline_progress_factor / (total_integrity / speed)

    # Apply exponential progress so that mining gradually slows the closer the
    # belt gets to 100% mined.
    var new_percent = 1.0 - (1.0 - percent) * exp(-rate_accum * dt * 0.00001)
    new_percent = clamp(new_percent, 0.0, 1.0)
    Globals.belt_mining_percent[key] = new_percent

    return (new_percent - percent) * float(total_integrity)

## Converts mined resources into drones by completing queued blueprints.
## Returns the remaining materials that can be delivered to the player.
func _apply_blueprints(counts: Dictionary, mined_total: float, last_time: int, now: int, key: String) -> int:
    var mined_materials := int(mined_total)
    var cluster_materials = Globals.belt_cluster_iron.get(key, 0)
    var blueprint_count = Globals.belt_blueprint_counts.get(key, 0)
    var blueprint_needed = Globals.belt_blueprint_iron_needed.get(key, blueprint_count * 5)
    var available = mined_materials + cluster_materials
    var deliverable = min(available, int(float(now - last_time) / transport_time_per_material))
    var built = min(blueprint_count, deliverable)
    built = min(built, blueprint_needed)
    if built > 0:
        var drone_path := preload("res://assets/drones/space_drone.tscn").resource_path
        counts[drone_path] = counts.get(drone_path, 0) + built
        available -= built * 5
        blueprint_count -= built
        blueprint_needed -= built * 5
    Globals.belt_drones[key] = counts
    Globals.belt_blueprint_counts[key] = blueprint_count
    Globals.belt_blueprint_iron_needed[key] = blueprint_needed
    return available
