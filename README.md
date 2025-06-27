# Hegswarm

Hegswarm is a small project written in **Godot version 4**. The core idea is to play as a self-replicating van Neumann drone moving through a procedurally generated galaxy. You mine asteroids and planets for resources which can then be used to build new drones and factories.

## Ideas to Explore

- **Procedural Galaxy**: Each playthrough generates unique star systems filled with mineable planets and asteroids.
- **Automation**: Build factories and additional drones to automate resource gathering and production.
- **Exploration and Expansion**: Use new drones to scout distant systems, expanding your reach and discovering more materials.
- **Resource Management**: Balance mined materials between expanding your swarm and powering existing structures.
- **Carrier Drones**: Specialized drones that can store and unload other drones for rapid transportation.

The project is in its early stages, so feel free to experiment with the world generation script in `scripts/world/world_generation.gd`.

## Development Notes

This repository targets **Godot version 4**. Contributors should use GDScript 2.0 syntax and ensure that any scenes or scripts remain compatible with Godot 4's features.

## Repository Layout

- `assets/celestials` - Scene files for planets, stars, and other space objects.
- `assets/drones` - Drone-related scenes and prefabs.
- `assets/materials` - Scenes for resource items.
- `assets/ui` - Camera and UI scenes.
- `scripts/entities` - GDScript files attached to game entities.
- `scripts/world` - World management and generation scripts.
- `scripts/utils` - Reusable helper scripts.
- `scripts/generators` - Procedural generation helpers.
