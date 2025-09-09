# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a simple 2D platformer game built with Godot 4.4. The player controls a humanoid character (blue rectangle) that can jump between platforms in a rectangular play area to earn points.

## Running the Game

- **Run Game**: Open project in Godot Editor and press F5, or use "Play" button
- **Main Scene**: `Main.tscn` is set as the main scene in project settings
- **Controls**: A/D or Left/Right arrows to move, Space or Up arrow to jump

## Architecture

### Core Components

**GameManager (Autoload Singleton)**
- Global scoring system accessible via `GameManager`
- Tracks visited platforms to prevent duplicate scoring
- Emits `score_changed(new_score)` signal when score updates
- Methods: `add_points(platform_name)`, `reset_score()`, `get_score()`

**Player System**
- `Player.gd` extends CharacterBody2D with physics-based movement
- Implements coyote time and jump buffering for responsive controls
- Emits `platform_reached(platform_name)` and `ground_touched` signals
- Key constants: SPEED=200, JUMP_VELOCITY=-400, GRAVITY=980

**Platform Detection**
- Each platform has both StaticBody2D for collision and Area2D for detection
- Detection area positioned above platform triggers scoring
- Platform script calls `player.on_platform_reached(name)` on contact

**Signal Flow**
```
Platform Detection → Player.on_platform_reached() → platform_reached signal → Main._on_platform_reached() → GameManager.add_points()
Ground Contact → Player.ground_touched signal → Main._on_ground_touched() → GameManager.reset_score()
```

### Game Rules

- **Scoring**: 100 points per platform on first visit
- **Score Reset**: When player touches ground (Y > 540) or GroundPlatform
- **Physics Layers**: Layer 1 = Player, Layer 2 = Platform

### Scene Structure

- `Main.tscn`: Main game scene with boundaries, platforms, player, and UI
- `Player.tscn`: Character with collision and visual representation
- `Platform.tscn`: Platform with collision body and detection area
- UI implemented as CanvasLayer with score display in bottom-left

## Key Implementation Notes

- GameManager is registered as autoload singleton in project.godot
- Boundaries are created programmatically in Main.gd setup_boundaries()
- Platform heights adjusted to be reachable with current jump physics
- Ground detection uses both Y-position check and GroundPlatform contact