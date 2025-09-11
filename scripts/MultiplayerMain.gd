extends Node2D

var remote_players: Dictionary = {}
var multiplayer_game_manager: MultiplayerGameManager
var local_player: CharacterBody2D
var connection_status_label: Label
var players_list_label: Label

func _ready():
	setup_boundaries()
	setup_multiplayer_components()
	setup_ui()
	connect_signals()
	
	# Attempt to connect to server
	connect_to_server()

func setup_boundaries():
	var boundaries = $Boundaries
	
	# Create collision shapes for walls and floor/ceiling
	var left_wall = RectangleShape2D.new()
	left_wall.size = Vector2(20, 620)
	$Boundaries/LeftWall.shape = left_wall
	
	var right_wall = RectangleShape2D.new()
	right_wall.size = Vector2(20, 620)
	$Boundaries/RightWall.shape = right_wall
	
	var floor = RectangleShape2D.new()
	floor.size = Vector2(1044, 20)
	$Boundaries/Floor.shape = floor
	
	var ceiling = RectangleShape2D.new()
	ceiling.size = Vector2(1044, 20)
	$Boundaries/Ceiling.shape = ceiling

func setup_multiplayer_components():
	# Create and setup multiplayer game manager
	multiplayer_game_manager = MultiplayerGameManager.new()
	add_child(multiplayer_game_manager)
	
	# Replace regular player with multiplayer player
	var old_player = $Player
	old_player.queue_free()
	
	var multiplayer_player_scene = preload("res://scenes/Player.tscn")
	local_player = multiplayer_player_scene.instantiate()
	local_player.set_script(preload("res://scripts/MultiplayerPlayer.gd"))
	local_player.position = Vector2(100, 500)
	local_player.name = "LocalPlayer"
	add_child(local_player)
	
	# Setup as local player (will be set properly after connection)
	local_player.setup_as_local_player("local_temp")

func setup_ui():
	# Setup existing score label
	multiplayer_game_manager.score_changed.connect(_on_multiplayer_score_changed)
	
	# Add connection status label
	connection_status_label = Label.new()
	connection_status_label.text = "Connecting..."
	connection_status_label.position = Vector2(20, 20)
	connection_status_label.add_theme_color_override("font_color", Color.WHITE)
	connection_status_label.add_theme_font_size_override("font_size", 18)
	$UI.add_child(connection_status_label)
	
	# Add players list label
	players_list_label = Label.new()
	players_list_label.text = "Players: 0"
	players_list_label.position = Vector2(200, 20)
	players_list_label.add_theme_color_override("font_color", Color.WHITE)
	players_list_label.add_theme_font_size_override("font_size", 18)
	$UI.add_child(players_list_label)

func connect_signals():
	local_player.platform_reached.connect(_on_local_platform_reached)
	local_player.ground_touched.connect(_on_local_ground_touched)
	
	# NetworkManager signals
	NetworkManager.connected_to_server.connect(_on_connected_to_server)
	NetworkManager.disconnected_from_server.connect(_on_disconnected_from_server)
	NetworkManager.player_joined.connect(_on_player_joined)
	NetworkManager.player_left.connect(_on_player_left)
	NetworkManager.player_state_updated.connect(_on_player_state_updated)

func connect_to_server():
	connection_status_label.text = "Connecting to server..."
	
	var connected = await NetworkManager.connect_to_server()
	if connected:
		# Try to create a match first, if it fails try to join one
		var match_created = await NetworkManager.create_match()
		if not match_created:
			# In a real game, you'd have a list of available matches to join
			print("Could not create match, you might want to implement match finding")
	else:
		connection_status_label.text = "Failed to connect to server"
		connection_status_label.add_theme_color_override("font_color", Color.RED)

func _on_connected_to_server():
	connection_status_label.text = "Connected - In Match"
	connection_status_label.add_theme_color_override("font_color", Color.GREEN)
	
	# Setup local player with proper ID
	local_player.setup_as_local_player(NetworkManager.local_player_id)

func _on_disconnected_from_server():
	connection_status_label.text = "Disconnected"
	connection_status_label.add_theme_color_override("font_color", Color.RED)
	
	# Clean up remote players
	for player_id in remote_players.keys():
		if remote_players[player_id]:
			remote_players[player_id].queue_free()
	remote_players.clear()
	update_players_count()

func _on_player_joined(player_data):
	print("Player joined: ", player_data.username, " (", player_data.user_id, ")")
	
	# Create remote player
	var remote_player_scene = preload("res://scenes/RemotePlayer.tscn")
	var remote_player = remote_player_scene.instantiate()
	remote_player.setup_as_remote_player(player_data.user_id)
	remote_player.position = Vector2(200, 500)  # Spawn position for remote players
	remote_player.name = "RemotePlayer_" + player_data.user_id
	add_child(remote_player)
	
	remote_players[player_data.user_id] = remote_player
	update_players_count()

func _on_player_left(player_id):
	print("Player left: ", player_id)
	
	if remote_players.has(player_id) and remote_players[player_id]:
		remote_players[player_id].queue_free()
		remote_players.erase(player_id)
	
	update_players_count()

func _on_player_state_updated(player_id, state_data):
	if remote_players.has(player_id) and remote_players[player_id]:
		remote_players[player_id].update_from_network_state(state_data)

func _on_local_platform_reached(platform_name):
	# Let MultiplayerGameManager handle the validation
	var player_position = local_player.global_position
	multiplayer_game_manager.handle_platform_reached(NetworkManager.local_player_id, platform_name, player_position)

func _on_local_ground_touched():
	multiplayer_game_manager.handle_ground_touched(NetworkManager.local_player_id)

func _on_multiplayer_score_changed(player_scores):
	# Update UI to show scores
	var local_score = 0
	if player_scores.has(NetworkManager.local_player_id):
		local_score = player_scores[NetworkManager.local_player_id]
	
	$UI/ScoreLabel.text = "Your Score: " + str(local_score)
	
	# You could also show other players' scores here
	var total_players = player_scores.size()
	var leaderboard = multiplayer_game_manager.get_leaderboard()
	var leaderboard_text = "Leaderboard:\n"
	for i in range(min(3, leaderboard.size())):  # Show top 3
		var entry = leaderboard[i]
		var player_name = entry.player_id.substr(0, 8) + "..."  # Show first 8 chars of ID
		leaderboard_text += str(i + 1) + ". " + player_name + ": " + str(entry.score) + "\n"
	
	# Update UI with leaderboard (create a new label if needed)
	if not has_node("UI/LeaderboardLabel"):
		var leaderboard_label = Label.new()
		leaderboard_label.name = "LeaderboardLabel"
		leaderboard_label.position = Vector2(400, 20)
		leaderboard_label.add_theme_color_override("font_color", Color.WHITE)
		leaderboard_label.add_theme_font_size_override("font_size", 16)
		$UI.add_child(leaderboard_label)
	
	$UI/LeaderboardLabel.text = leaderboard_text

func update_players_count():
	var total_players = remote_players.size() + 1  # +1 for local player
	players_list_label.text = "Players: " + str(total_players)

func _input(event):
	# Add some debug controls
	if event.is_action_pressed("ui_accept"):  # Enter key
		# Toggle connection (for debugging)
		if NetworkManager.socket and NetworkManager.socket.is_connected():
			NetworkManager.disconnect_from_server()
		else:
			connect_to_server()
	
	if event.is_action_pressed("ui_cancel"):  # Escape key
		# Quit game
		get_tree().quit()