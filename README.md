# Simple 2D Platformer

A simple 2D platformer game built with Godot 4.4 where players jump between platforms to earn points.

## Game Features

- **Physics-based movement** with smooth controls and responsive jumping
- **Scoring system** - earn 100 points for each platform reached
- **Score reset** when player falls to the ground
- **Enhanced jump mechanics** with coyote time and jump buffering for better feel

## Controls

- **Move**: A/D keys or Left/Right arrow keys
- **Jump**: Space or Up arrow key

## How to Play

1. Use the movement keys to navigate the blue player character
2. Jump between the brown platforms to earn points
3. Each platform gives 100 points when reached for the first time
4. If you fall to the ground, your score resets to zero
5. Try to reach all platforms without falling!

## Requirements

- Godot 4.4 or later

## Running the Game

1. Clone this repository
2. Open the project in Godot Engine
3. Press F5 or click the "Play" button
4. Select `Main.tscn` as the main scene when prompted

## Project Structure

- `Main.tscn` - Main game scene with level layout
- `scenes/Player.tscn` - Player character prefab
- `scenes/Platform.tscn` - Platform prefab with scoring detection
- `scripts/` - All game scripts including player movement, platform detection, and game management
- `CLAUDE.md` - Technical documentation for developers

## Game Architecture

The game uses a signal-based architecture with a global GameManager singleton for score tracking. Player movement includes advanced features like coyote time and jump buffering for responsive platforming gameplay.