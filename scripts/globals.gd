extends Node

var star_seed: int = 0
## Seed of the first star system visited. Used to determine where the
## player's drone should appear.
var start_star_seed: int = 0
## Indicates whether the galaxy scene has been opened for the first time.
var first_load: bool = true
## Path to the star system scene file.
const STAR_SYSTEM_SCENE_PATH := "res://scenes/star_system.tscn"
## Number of drones that should spawn in the next opened star system.
var entering_drone_count: int = 0
## Positions of asteroids passed to the space scene.
var space_asteroid_positions: Array = []
## Seeds of asteroids passed to the space scene.
var space_asteroid_seeds: Array = []
## Relative positions of drones passed to the space scene.
var space_drone_positions: Array = []
## Position where the galaxy drone should reappear when returning from a star system.
var galaxy_drone_position: Vector2 = Vector2.ZERO
## Star-system coordinates of the asteroid clicked to open the space scene.
var space_origin: Vector2 = Vector2.ZERO
## Absolute positions of drones to restore when returning from the space scene.
var system_drone_positions: Array = []
## Path to the space scene file.
const SPACE_SCENE_PATH := "res://scenes/space.tscn"
