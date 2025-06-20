extends Node

var star_seed: int = 0
## Seed of the first star system visited. Used to determine where the
## player's drone should appear.
var start_star_seed: int = 0
## Indicates whether the galaxy scene has been opened for the first time.
var first_load: bool = true
## Path to the star system scene file.
const STAR_SYSTEM_SCENE_PATH := "res://scenes/star_system.tscn"
## Path to the galaxy scene file.
const GALAXY_SCENE_PATH := "res://scenes/galaxy.tscn"
## Path to the drone scene used in the galaxy view.
const GALAXY_DRONE_SCENE_PATH := "res://assets/galaxy_drone.tscn"
## Number of drones that should spawn in the next opened star system.
var entering_drone_count: int = 0
## Mapping from star seeds to dictionaries storing drone type counts.
var star_drone_counts: Dictionary = {}
## Positions of asteroids passed to the space scene.
var space_asteroid_positions: Array = []
## Seeds of asteroids passed to the space scene.
var space_asteroid_seeds: Array = []
## Relative positions of drones passed to the space scene.
var space_drone_positions: Array = []
## Position where the galaxy drone should reappear when returning from a star system.
var galaxy_drone_position: Vector2 = Vector2.ZERO
## Number of drones that should reappear in the galaxy scene.
var returning_drone_count: int = 0
## Star-system coordinates of the asteroid clicked to open the space scene.
var space_origin: Vector2 = Vector2.ZERO
## Absolute positions of drones to restore when returning from the space scene.
var system_drone_positions: Array = []
## Path to the space scene file.
const SPACE_SCENE_PATH := "res://scenes/space.tscn"

## Mapping from belt identifiers to the percent of asteroids mined.
var belt_mining_percent: Dictionary = {}
## Total asteroid count for each belt.
var belt_asteroid_count: Dictionary = {}
## Belt seed of the asteroids currently loaded in the space scene.
var space_belt_seed: int = 0

## Counts how many drones belonging to a particular star are near the given
## position.
func count_drones_near_star(star_position: Vector2, seed_to_check: int) -> int:
    var count := 0
    for d in get_tree().get_nodes_in_group("galaxy_drone"):
        if d.has_method("is_near") and d.call("is_near", star_position):
            if "belongs_to_star_seed" in d and d.belongs_to_star_seed == seed_to_check:
                count += 1
    return count
