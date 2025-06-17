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
## Path to the space scene file.
const SPACE_SCENE_PATH := "res://scenes/space.tscn"
