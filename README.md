# Simple 2D Platformer

A simple 2D platformer game built with Godot 4.4 where players jump between platforms to earn points. Features both single-player and multiplayer modes with real-time networking.

## Game Features

### Single Player
- **Physics-based movement** with smooth controls and responsive jumping
- **Scoring system** - earn 100 points for each platform reached
- **Score reset** when player falls to the ground
- **Enhanced jump mechanics** with coyote time and jump buffering for better feel
- **Pixel art character** with natural animations and smooth movement

### Multiplayer (NEW!)
- **Real-time multiplayer** using Nakama server networking
- **Synchronized scoring** across all connected players
- **Live leaderboard** showing top 3 players
- **Server-side validation** to prevent cheating
- **Dynamic player join/leave** with seamless gameplay
- **Connection status** and player count display
- **Smooth interpolation** for remote player movement

## Controls

- **Move**: A/D keys or Left/Right arrow keys
- **Jump**: Space or Up arrow key

## How to Play

### Single Player Mode
1. Use the movement keys to navigate the pixel art character
2. Jump between the brown platforms to earn points
3. Each platform gives 100 points when reached for the first time
4. If you fall to the ground, your score resets to zero
5. Try to reach all platforms without falling!

### Multiplayer Mode
1. Follow the setup instructions below to connect to a Nakama server
2. Run the game with `MultiplayerMain.tscn` as the main scene
3. Multiple players can join the same match and compete for points
4. Watch the live leaderboard to see who's winning!
5. Connection status is shown in the top-left corner

## Requirements

### Single Player
- Godot 4.4 or later

### Multiplayer
- Godot 4.4 or later
- Nakama Godot 4 client plugin (from Asset Library)
- Nakama server (local or cloud deployment)

## Running the Game

### Single Player
1. Clone this repository
2. Open the project in Godot Engine
3. Press F5 or click the "Play" button
4. Select `Main.tscn` as the main scene when prompted

### Multiplayer Setup
1. Install the **Nakama Godot 4** client plugin from the Asset Library
2. Set up a Nakama server:
   - **Local**: Download and run Nakama server locally on port 7350
   - **Cloud**: Use Nakama Cloud or deploy to your preferred cloud provider
3. Update `scripts/NetworkManager.gd` with your server details if needed
4. Run the game with `MultiplayerMain.tscn` as the main scene
5. Launch multiple instances to test multiplayer functionality

## Project Structure

### Single Player Files
- `Main.tscn` - Single player main scene with level layout
- `scenes/Player.tscn` - Player character prefab
- `scenes/Platform.tscn` - Platform prefab with scoring detection
- `scripts/Player.gd` - Player movement and physics
- `scripts/GameManager.gd` - Single player scoring system

### Multiplayer Files
- `scenes/MultiplayerMain.tscn` - Multiplayer main scene
- `scenes/RemotePlayer.tscn` - Remote player visualization
- `scripts/NetworkManager.gd` - Nakama networking controller
- `scripts/MultiplayerPlayer.gd` - Network-enabled player controller  
- `scripts/MultiplayerGameManager.gd` - Server-side scoring validation
- `scripts/MultiplayerMain.gd` - Multiplayer scene management

### Documentation
- `CLAUDE.md` - Comprehensive technical documentation for developers
- `README.md` - This file with setup and usage instructions

## Game Architecture

### Single Player
The game uses a signal-based architecture with a global GameManager singleton for score tracking. Player movement includes advanced features like coyote time and jump buffering for responsive platforming gameplay.

### Multiplayer
Built on Nakama for real-time networking with client-server architecture:
- **NetworkManager**: Handles all Nakama client operations and socket communication
- **MultiplayerPlayer**: Extends Player with network state synchronization (20fps updates)
- **MultiplayerGameManager**: Server-side validation for scoring and leaderboards
- **Real-time synchronization**: Position, animation, and game state across all players
- **Anti-cheat protection**: Server validates platform reaches and prevents position manipulation

## Debug Controls (Multiplayer)
- **Enter**: Toggle connection to server
- **Escape**: Quit game