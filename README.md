# Hegswarm

Hegswarm is a small project written in **Godot version 4**. The core idea is to play as a self-replicating van Neumann drone moving through a procedurally generated galaxy. You mine asteroids and planets for resources which can then be used to build new drones and factories.

## Current State

The project is still in an experimental phase but already provides a few
gameplay building blocks:

- **Spiral Galaxy Generation** with hundreds of seeded stars.
- **Galaxy Drone Navigation** that lets you move a drone between systems and
  enter stars when nearby.
- **Procedural Star Systems** containing planets or asteroid belts derived from
  the star seed.
- **System Drones** that spawn near planets and can be commanded with mouse
  clicks.
- **Asteroid Interaction** to open a separate space view populated with larger
  asteroids.
- **Scene Transitions** back to the galaxy or system via the spacebar or UI
  buttons while preserving your drone's position.

## Ideas to Explore

- **Procedural Galaxy**: Each playthrough generates unique star systems filled with mineable planets and asteroids.
- **Automation**: Build factories and additional drones to automate resource gathering and production.
- **Exploration and Expansion**: Use new drones to scout distant systems, expanding your reach and discovering more materials.
- **Resource Management**: Balance mined materials between expanding your swarm and powering existing structures.

The project is in its early stages, so feel free to experiment with the world generation script in `scripts/world_generation.gd`.

## Development Notes

This repository targets **Godot version 4**. Contributors should use GDScript 2.0 syntax and ensure that any scenes or scripts remain compatible with Godot 4's features.
