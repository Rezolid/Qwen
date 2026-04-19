# FPS Survival Game - Godot 4.3+

A 3D first-person shooter with light survival and crafting mechanics.

## Project Structure
```
res://
├── scripts/          # All GDScript files
│   ├── globals/      # Singleton GameManager
│   ├── player/       # Player controller, inventory, building
│   ├── interaction/  # Trees, interactables
│   ├── enemies/      # Zombie AI
│   └── ui/           # HUD scripts
├── scenes/           # All .tscn scene files
├── resources/        # Resources, recipes, items
└── assets/           # Models, materials, audio
```

## Setup Instructions

### 1. Input Map (Already configured in project.godot)
- **WASD**: Move
- **Mouse**: Look around
- **Space**: Jump
- **LMB**: Fire weapon / Confirm build
- **E**: Interact
- **Tab**: Switch weapon (Axe ↔ Rifle)
- **B**: Toggle build mode
- **R**: Rotate building piece

### 2. Autoload Setup
The GameManager is already set as an autoload in project.godot.

### 3. Physics Layers
- Layer 1: World (ground, static objects)
- Layer 2: Player
- Layer 3: Enemies
- Layer 4: Buildings

### 4. Next Steps to Complete the Game

#### A. Add Ground Plane
1. Open `scenes/main/Main.tscn`
2. Add a MeshInstance3D child to "Ground" node
3. Add a PlaneMesh or BoxMesh for the terrain
4. Add CollisionShape3D with appropriate shape

#### B. Create Navigation for Zombies
1. Add a NavigationRegion3D node to your Main scene
2. Create a NavigationMesh resource
3. Bake the navigation mesh (Navigation → Bake)

#### C. Add Placeholder Assets
Replace the empty MeshInstance3D nodes with:
- Tree models in `scenes/interaction/Tree.tscn`
- Wall/Floor models in `scenes/buildings/`
- Zombie models in `scenes/enemies/Zombie.tscn`

#### D. Testing
1. Run the scene `scenes/main/Main.tscn`
2. Press WASD to move, mouse to look
3. Press Tab to switch weapons
4. Press B to enter build mode
5. Shoot trees to earn money
6. Build structures with earned money

## Features Implemented
✅ Player movement (CharacterBody3D)
✅ Mouse look with camera clamping
✅ Weapon system (Axe/Rifle)
✅ Money economy (GameManager singleton)
✅ Building placement with preview
✅ Zombie AI with navigation
✅ Tree cutting mechanic
✅ UI HUD with money display

## Extending the Game
- Add more buildable types in BuildingSystem.gd
- Create different zombie variants
- Implement crafting recipes
- Add multiple zones/environments
- Implement save/load system
