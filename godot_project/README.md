# Forest Survival FPS - Godot Version

A first-person survival game ported from Three.js/HTML5 to Godot 4.2.

## Features

- **First-person movement** with WASD controls and mouse look
- **Three locations**: Forest, Field, and Swamp with different environments
- **Resource gathering**: Cut trees to collect wood
- **Combat**: Shoot zombies with a rifle to earn money
- **Building system**: Construct walls, floors, flooring, and ladders
- **Portal system**: Travel between different locations
- **Health system**: Zombies damage you when close
- **UI**: Money counter, wood counter, health bar, inventory, and build menu

## Controls

| Key | Action |
|-----|--------|
| W/A/S/D | Move |
| Mouse | Look around |
| Left Click | Use item / Shoot / Cut tree / Place building |
| 1-3 | Select inventory item (Hands, Axe, Rifle) |
| B | Toggle build menu |
| E | Interact with buildings (demolish for 50% refund) |
| Space | Jump |

## Project Structure

```
godot_project/
├── project.godot          # Project configuration
├── scenes/
│   └── main.tscn          # Main game scene
└── scripts/
    ├── main.gd            # Main game controller
    ├── game_manager.gd    # Game state management
    ├── player.gd          # Player controller
    ├── zombie.gd          # Zombie AI
    ├── tree.gd            # Tree interaction
    ├── projectile.gd      # Projectile logic
    ├── environment_manager.gd  # Environment spawning
    ├── location_portal.gd      # Portal teleportation
    └── game_ui.gd         # UI management
```

## How to Run

1. Open Godot 4.2 or later
2. Import the `godot_project` folder
3. Open the `scenes/main.tscn` scene
4. Press F5 to run

## Gameplay

### Getting Started
1. Click "CLICK TO START" to begin
2. Your mouse will be captured for looking around
3. Press ESC to release the mouse cursor

### Gathering Resources
1. Press `2` to select the Wooden Axe
2. Approach a tree (within 5 units)
3. Left-click to cut the tree
4. Collect wood (3-5 per tree)

### Combat
1. Press `3` to select the Rifle
2. Aim at a zombie
3. Left-click to shoot
4. Earn $10-25 per zombie killed

### Building
1. Press `B` to open the build menu
2. Click on a building type or press the corresponding button
3. Aim at the ground where you want to place it
4. Left-click to place (requires sufficient money)

### Demolishing
1. Approach a building you placed
2. Press `E` while looking at it
3. Receive 50% of the cost back

### Traveling
1. Find colored portal rings in the environment
2. Walk into a portal to travel to that location
3. Each location has different resources and zombie counts

## Building Costs

| Building | Cost |
|----------|------|
| Wooden Wall | $50 |
| Wooden Floor | $40 |
| Wooden Flooring | $30 |
| Ladder | $25 |

## Location Details

| Location | Trees | Zombies | Color Theme |
|----------|-------|---------|-------------|
| Forest | 30 | 3 | Green |
| Field | 5 | 2 | Light green |
| Swamp | 15 | 5 | Dark green/brown |

## Notes

- Trees respawn after 10 seconds in random locations
- Zombies respawn after 5 seconds if less than 5 are alive
- Health regenerates only by not taking damage (no healing items yet)
- Game over occurs when health reaches 0

## Future Improvements

- Add saving/loading system
- Add more building types
- Add crafting system
- Add more enemy types
- Add day/night cycle
- Add sound effects and music
- Add particle effects for combat and interactions
