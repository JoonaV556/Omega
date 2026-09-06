# Omega Agent Guide

## Project Shape

- This is a Godot 4 2D roguelite shooter. Open the project in the Godot Editor; the configured main scene is `Levels/Main.tscn`.
- Gameplay scripts live under `Code/`. Scenes, resources, dialogue, and tile sets are kept in their corresponding top-level directories.
- `Assets_LICENSED/` is a private asset dependency. Missing licensed assets can prevent scenes from loading; do not replace or redistribute them.
- Read [README.md](README.md) for project scope and asset licensing. Treat [design-docs/design-doc.txt](design-docs/design-doc.txt), [design-docs/level-generation.txt](design-docs/level-generation.txt), and [design-docs/notes.txt](design-docs/notes.txt) as plans and notes, not authoritative runtime behavior.

## Runtime Boundaries

- [Code/game_manager.gd](Code/game_manager.gd) starts the runtime, creates the level root, loads the initial level, and coordinates player and camera setup.
- [Code/Other/level.gd](Code/Other/level.gd) is the level contract for player start position, navigation tilemap, transitions, and unique names.
- Autoloads and input actions are configured in [project.godot](project.godot). Preserve those contracts when changing global systems or controls.
- Shared character movement belongs in [Code/Character/character.gd](Code/Character/character.gd); player-specific input and owned systems belong in [Code/Character/player.gd](Code/Character/player.gd).
- Inventory, dialogue, combat events, and global game data are integrated through configured autoloads. Check their scene/resource references before changing initialization order.

## Level Generation

- [Code/LevelGeneration/level_generator.gd](Code/LevelGeneration/level_generator.gd) is the newer noise-and-random-walk generator that renders directly to an exported `TileMapLayer` and performs deferred initialization.
- [Code/LevelGeneration/old_level_generator.gd](Code/LevelGeneration/old_level_generator.gd) and [Code/LevelGeneration/procedural_level_data.gd](Code/LevelGeneration/procedural_level_data.gd) implement the older BSP/data path. [Code/Other/scouting_mission.gd](Code/Other/scouting_mission.gd) still uses it, so do not assume the old path is dead.
- Generation depends on exported tilemap patterns, tile coordinates, seeded randomness, and initialization order. Preserve the existing coordinate conventions and inspect the owning scene when changing generator parameters.
- Road connection bitmasks use `1`, `2`, `4`, and `8` for north, south, east, and west.

## Coding Conventions

- Follow nearby GDScript style. Existing code uses `class_name` with PascalCase, snake_case variables/functions, typed fields where practical, exported inspector properties, and `on_*` signal names.
- Preserve local indentation and formatting because the repository is not fully consistent. Keep public scene paths, exported property names, autoload names, and resource UIDs stable unless the change requires migration.
- Prefer the smallest change at the owning script or scene. For editor-configured behavior, update the relevant `.tscn`, resource, or Inspector property rather than recreating wiring in code.
- Keep design-document updates separate from runtime changes unless the request explicitly requires both.

## Validation

- There is no formal test framework or documented command. Use the Godot Editor to inspect affected scenes, run the main scene or a focused test scene, and observe the relevant behavior.
- Do not suggest bash or shell scripts as a way to verify code integrity. Report any validation that could not be performed because the Godot Editor or licensed assets are unavailable.
- Small ad hoc tests live under `Code/test/`; [Code/Other/test.gd](Code/Other/test.gd) is the base pattern for test nodes that call `run()` from `_ready()`.
