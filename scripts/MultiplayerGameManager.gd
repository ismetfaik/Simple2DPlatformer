extends Node

signal score_changed(player_scores)
signal player_platform_reached(player_id, platform_name, score)

var player_scores: Dictionary = {}
var player_visited_platforms: Dictionary = {}

func _ready():
	# Connect to NetworkManager events
	NetworkManager.player_joined.connect(_on_player_joined)
	NetworkManager.player_left.connect(_on_player_left)

func _on_player_joined(player_data):
	var player_id = player_data.user_id
	player_scores[player_id] = 0
	player_visited_platforms[player_id] = []
	
	# Emit updated scores to all players
	score_changed.emit(player_scores)

func _on_player_left(player_id):
	if player_scores.has(player_id):
		player_scores.erase(player_id)
	if player_visited_platforms.has(player_id):
		player_visited_platforms.erase(player_id)
	
	# Emit updated scores to all players
	score_changed.emit(player_scores)

func handle_platform_reached(player_id: String, platform_name: String, player_position: Vector2) -> bool:
	# Validate platform reach (basic distance check)
	if not is_valid_platform_reach(platform_name, player_position):
		print("Invalid platform reach for player ", player_id, " at platform ", platform_name)
		return false
	
	# Check if player already visited this platform
	if not player_visited_platforms.has(player_id):
		player_visited_platforms[player_id] = []
	
	if platform_name not in player_visited_platforms[player_id]:
		player_visited_platforms[player_id].append(platform_name)
		
		# Add points
		if not player_scores.has(player_id):
			player_scores[player_id] = 0
		
		player_scores[player_id] += 100
		
		# Emit signals
		player_platform_reached.emit(player_id, platform_name, player_scores[player_id])
		score_changed.emit(player_scores)
		
		print("Player ", player_id, " reached platform ", platform_name, ". Score: ", player_scores[player_id])
		return true
	
	return false

func handle_ground_touched(player_id: String):
	if player_scores.has(player_id):
		player_scores[player_id] = 0
	if player_visited_platforms.has(player_id):
		player_visited_platforms[player_id].clear()
	
	# Emit updated scores
	score_changed.emit(player_scores)
	print("Player ", player_id, " touched ground. Score reset.")

func is_valid_platform_reach(platform_name: String, player_position: Vector2) -> bool:
	# Get platform positions (you might want to store these or get them from the scene)
	var platform_positions = get_platform_positions()
	
	if not platform_positions.has(platform_name):
		return false
	
	var platform_pos = platform_positions[platform_name]
	var distance = player_position.distance_to(platform_pos)
	
	# Allow reasonable distance for platform detection (accounting for network lag)
	return distance < 100.0

func get_platform_positions() -> Dictionary:
	# In a real implementation, you'd get these from the scene or store them
	# For now, return approximate positions based on your current setup
	return {
		"Platform1": Vector2(200, 450),
		"Platform2": Vector2(400, 350),
		"Platform3": Vector2(600, 250),
		"Platform4": Vector2(800, 450),
		"GroundPlatform": Vector2(512, 550)
	}

func get_player_score(player_id: String) -> int:
	if player_scores.has(player_id):
		return player_scores[player_id]
	return 0

func get_all_scores() -> Dictionary:
	return player_scores.duplicate()

func reset_all_scores():
	for player_id in player_scores.keys():
		player_scores[player_id] = 0
	for player_id in player_visited_platforms.keys():
		player_visited_platforms[player_id].clear()
	
	score_changed.emit(player_scores)

func get_leaderboard() -> Array:
	var leaderboard = []
	for player_id in player_scores.keys():
		leaderboard.append({
			"player_id": player_id,
			"score": player_scores[player_id]
		})
	
	# Sort by score descending
	leaderboard.sort_custom(func(a, b): return a.score > b.score)
	return leaderboard