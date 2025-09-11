# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a simple 2D platformer game built with Godot 4.4. The player controls a pixel art character with natural animations that can jump between platforms in a rectangular play area to earn points.

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
- **Animation System**: Uses custom `PixelCharacterSprite` with state-based animations
  - States: IDLE, WALK, JUMP_START, JUMP_AIR, JUMP_LAND
  - Pixel art character with proper proportions and natural movement
  - Enhanced color palette with skin, hair, shirt, pants, and shoe colors
  - Directional sprite flipping for left/right movement
  - **Jump Animation**: Arms rotate upward from shoulders during jump_air state
  - Fixed arm positioning ensures arms stay connected to body during all animations

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
- `Player.tscn`: Character with collision and pixel art sprite
- `Platform.tscn`: Platform with collision body and detection area
- UI implemented as CanvasLayer with score display in bottom-left

## Key Implementation Notes

- GameManager is registered as autoload singleton in project.godot
- Boundaries are created programmatically in Main.gd setup_boundaries()
- Platform heights adjusted to be reachable with current jump physics
- Ground detection uses both Y-position check and GroundPlatform contact
- **Character Rendering**: `PixelCharacterSprite.gd` uses Godot's `_draw()` for pixel art
- Character with proper proportions and natural animations
- Enhanced color palette: skin, hair, shirt, pants, and shoe colors
- Animation states: idle, walk (4-frame cycle), jump_start, jump_air, jump_land
- **Fixed Jump Arms**: Arms rotate upward from shoulders using pixel-by-pixel positioning
- Arms remain connected to body during all animation states

## Multiplayer Implementation (COMPLETED)

### Architecture Implemented
**Server-Relayed Multiplayer** using Nakama for real-time networking:
- ✅ Clients control their own player movement for responsiveness
- ✅ Server relays position/animation data between players
- ✅ Basic server-side validation for scoring and platform detection
- ✅ Synchronized scoring across all connected players

### Implemented Components

**NetworkManager (Autoload)**
- Handles Nakama client connection and authentication
- Manages socket communication with match creation/joining
- Sends player state updates (position, animation, direction)
- Relays platform reached and ground touched events
- Manages player join/leave events

**MultiplayerPlayer**
- Extends regular Player with network capabilities
- Sends state updates only when significant changes occur (20fps)
- Handles both local player (full physics) and remote player (visual only)
- Smooth position interpolation for remote players
- Network event broadcasting for platform interactions

**MultiplayerGameManager**
- Server-side scoring validation and synchronization
- Tracks per-player scores and visited platforms
- Validates platform reaches with position checking
- Broadcasts score updates to all connected clients
- Provides leaderboard functionality

**MultiplayerMain Scene**
- Complete multiplayer-enabled main scene
- Real-time connection status and player count display
- Dynamic remote player spawning/cleanup
- Live leaderboard showing top 3 players
- Debug controls (Enter to reconnect, Escape to quit)

### How to Use Multiplayer

**Prerequisites:**
1. Install Nakama Godot 4 client plugin from Asset Library
2. Run a local Nakama server on localhost:7350 (or update NetworkManager.gd with your server details)

**To Test Multiplayer:**
1. Open MultiplayerMain.tscn as the main scene
2. Run the game - it will automatically attempt to connect
3. Run multiple instances to test with multiple players
4. Players share the same game world and see each other's movements
5. Scoring is synchronized - all players see the same scores

**Network Events:**
- Op Code 1: Player state updates (position/animation)
- Op Code 2: Platform reached events
- Op Code 3: Ground touched events

### File Structure (Implemented)
```
scenes/
├── MultiplayerMain.tscn      # ✅ Multiplayer main scene
├── RemotePlayer.tscn         # ✅ Remote player visualization
scripts/
├── NetworkManager.gd         # ✅ Nakama networking controller
├── MultiplayerGameManager.gd # ✅ Server-synchronized game state
├── MultiplayerPlayer.gd      # ✅ Network-enabled player controller
├── MultiplayerMain.gd        # ✅ Multiplayer scene controller
```

### Future Enhancements (Phase 4)
- Player names/avatars and visual identification
- Real-time chat system using Nakama
- Lobby/matchmaking system
- Enhanced server-side validation and anti-cheat