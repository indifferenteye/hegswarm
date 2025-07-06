extends Node2D

const DroneMovement = preload("res://scripts/entities/components/movement.gd")
const DroneCargo = preload("res://scripts/entities/components/cargo.gd")
const DroneMining = preload("res://scripts/entities/components/mining.gd")
const DroneStorage = preload("res://scripts/entities/components/storage.gd")

@export var move_speed: float = 50.0
@export var detection_range: float = 4000.0
@export var mining_range: float = 20.0
@export var mining_rate: float = 1.0
## Minimum distance this drone tries to keep from other drones.
@export var separation_distance: float = 30.0
@export var cluster_scene: PackedScene
## Maximum number of other drones this drone can store.
@export var storeable_amount: int = 0
## Total storage capacity of this drone. Defaults to storeable_amount for
## backwards compatibility.
@export var storage_capacity: float = 0.0
## Amount of storage space this drone occupies when carried by a carrier.
@export var cargo_space: float = 1.0

var path_line: Node2D
var movement: DroneMovement
var cargo: DroneCargo
var mining: DroneMining
var storage: DroneStorage

func _ready() -> void:
    path_line = preload("res://scripts/utils/path_line.gd").new()
    path_line.set_as_top_level(true)
    path_line.visible = false
    if get_parent():
        get_parent().add_child(path_line)
    if storage_capacity <= 0.0 and storeable_amount > 0:
        storage_capacity = float(storeable_amount)

    movement = DroneMovement.new(self, path_line, move_speed, separation_distance)
    cargo = DroneCargo.new(self, path_line, move_speed, detection_range, mining_range)
    mining = DroneMining.new(self, path_line, move_speed, mining_range, mining_rate, detection_range)
    storage = DroneStorage.new(self, storage_capacity, cargo_space)

func move_to(pos) -> void:
    movement.move_to(pos)

func _process(delta: float) -> void:
    movement.apply_separation_force(delta)
    if path_line and path_line.visible:
        path_line.start_pos = global_position
    if movement.handle_manual_move(delta):
        return
    if cargo.carried_material != null:
        if cargo.deliver_to_cluster:
            if cargo.deliver_to_cluster_action(delta):
                return
        else:
            if cargo.deliver_material(delta):
                return
    if cargo.take_from_cluster(delta):
        return
    if cargo.collect_material(delta):
        return
    mining.mine_or_move_asteroid(delta)

func store_drone(drone: Node2D) -> bool:
    return storage.store_drone(drone)

func unload_drones() -> void:
    storage.unload_drones()
