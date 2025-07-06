# AGENTS Guidance

## Overview
This repository contains a Godot 4 project written in GDScript 2.0. Gameplay revolves around self-replicating drones mining a procedurally generated galaxy. Scenes are kept under `scenes/` and reusable assets live in `assets/`. Global state is tracked through the `Globals` autoload (`scripts/world/globals.gd`).

## Style Guide
- **Language**: Use GDScript 2.0 compatible with Godot 4.
- **Indentation**: Four spaces. Tabs should not appear.
- **Naming**
  - `PascalCase` for classes.
  - `snake_case` for functions and variables.
- **Comments**: Prefer `##` for block comments and `#` for inline notes.
- **Line length**: Try to keep lines under 120 characters.
- **Resource loading**: Use `preload()` for fixed paths at the top of the script.
- **Groups**: Add nodes to existing groups (e.g. `drone`, `asteroid`) when applicable.
- **Deterministic Randomness**: Any use of randomness must be seeded. Each script that relies on randomness should own a `RandomNumberGenerator` instance seeded in `_ready()` or initialization. This applies to world generation, mining logic, or any other random behavior, not just `belt_offline_progress`.

## Repository Layout
- `assets/` – scenes for celestials, drones, materials, and UI.
- `scenes/` – top-level scenes like `galaxy.tscn` and `space.tscn`.
- `scripts/entities/` – logic for in-game entities and components.
- `scripts/utils/` – helper scripts such as the belt manager.
- `scripts/world/` – high-level world management and autoloads.
- `scripts/generators/` – procedural generation helpers.
- `tests/` – pytest unit tests.

## Development Practices
- Open the project via `project.godot` in Godot 4.
- Do not edit `.import` or `.uid` files directly; they are generated.
- Keep new functionality modular by placing scripts in an appropriate subdirectory and using `class_name` to expose them for reuse.
- All seeded random generators should use explicit seeds so generated content is reproducible between runs.
- When adding features, write unit tests under `tests/` when possible and run `pytest` before committing.

## Commit Guidelines
- Write short, imperative commit messages (e.g., "Add carrier drone scene").
- Respect existing `.gitignore` and `.gitattributes` rules.

## Structuring New Features
- Mirror the existing folder layout when introducing new assets or scripts. For example, new drones belong in `assets/drones/`, and world logic goes in `scripts/world/`.
- Keep scenes small and focused; use child scenes or components to avoid giant monolithic scenes.
- Share common code through reusable helpers in `scripts/utils/` or components under `scripts/entities/components/`.
- Document new scripts with a short comment block explaining their purpose.

Following these guidelines helps keep the code base deterministic, organized, and approachable for future contributors.
