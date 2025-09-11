extends Node

signal connected_to_server
signal disconnected_from_server
signal player_joined(player_data)
signal player_left(player_id)
signal player_state_updated(player_id, state_data)
signal score_updated(scores)

var client: NakamaClient
var session: NakamaSession
var socket: NakamaSocket
var match_id: String = ""
var local_player_id: String = ""
var connected_players: Dictionary = {}

const SERVER_KEY = "defaultkey"
const HOST = "127.0.0.1"
const PORT = 7350
const SCHEME = "http"

func _ready():
	client = Nakama.create_client(SERVER_KEY, HOST, PORT, SCHEME)

func authenticate_device(device_id: String = ""):
	if device_id == "":
		device_id = OS.get_unique_id()
	
	var auth_result = await client.authenticate_device_async(device_id, true)
	if auth_result.is_exception():
		print("Authentication failed: ", auth_result.get_exception().message)
		return false
	
	session = auth_result
	local_player_id = session.user_id
	print("Authenticated as: ", session.username)
	return true

func connect_to_server():
	if not session:
		var auth_success = await authenticate_device()
		if not auth_success:
			return false
	
	socket = Nakama.create_socket_from(client)
	
	socket.connected.connect(_on_socket_connected)
	socket.closed.connect(_on_socket_closed)
	socket.received_error.connect(_on_socket_error)
	socket.received_match_state.connect(_on_match_state_received)
	socket.received_match_presence.connect(_on_match_presence_received)
	
	var connect_result = await socket.connect_async(session)
	if connect_result.is_exception():
		print("Socket connection failed: ", connect_result.get_exception().message)
		return false
	
	return true

func create_match():
	if not socket:
		return false
	
	var create_result = await socket.create_match_async()
	if create_result.is_exception():
		print("Match creation failed: ", create_result.get_exception().message)
		return false
	
	match_id = create_result.match_id
	print("Created match: ", match_id)
	return true

func join_match(match_id_to_join: String):
	if not socket:
		return false
	
	var join_result = await socket.join_match_async(match_id_to_join)
	if join_result.is_exception():
		print("Match join failed: ", join_result.get_exception().message)
		return false
	
	match_id = match_id_to_join
	print("Joined match: ", match_id)
	return true

func send_player_state(position: Vector2, animation_state: String, facing_direction: int):
	if not socket or match_id == "":
		return
	
	var state_data = {
		"player_id": local_player_id,
		"position": {"x": position.x, "y": position.y},
		"animation_state": animation_state,
		"facing_direction": facing_direction,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	var json_data = JSON.stringify(state_data)
	socket.send_match_state_async(match_id, 1, json_data)

func send_platform_reached(platform_name: String):
	if not socket or match_id == "":
		return
	
	var platform_data = {
		"player_id": local_player_id,
		"platform_name": platform_name,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	var json_data = JSON.stringify(platform_data)
	socket.send_match_state_async(match_id, 2, json_data)

func send_ground_touched():
	if not socket or match_id == "":
		return
	
	var ground_data = {
		"player_id": local_player_id,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	var json_data = JSON.stringify(ground_data)
	socket.send_match_state_async(match_id, 3, json_data)

func _on_socket_connected():
	print("Connected to Nakama server")
	connected_to_server.emit()

func _on_socket_closed():
	print("Disconnected from Nakama server")
	connected_players.clear()
	disconnected_from_server.emit()

func _on_socket_error(error):
	print("Socket error: ", error.message)

func _on_match_state_received(match_state):
	var json = JSON.new()
	var parse_result = json.parse(match_state.data)
	
	if parse_result != OK:
		print("Failed to parse match state data")
		return
	
	var data = json.data
	var sender_id = match_state.user_presence.user_id
	
	if sender_id == local_player_id:
		return
	
	match match_state.op_code:
		1:
			player_state_updated.emit(sender_id, data)
		2:
			_handle_platform_reached(data)
		3:
			_handle_ground_touched(data)

func _on_match_presence_received(match_presence):
	for join in match_presence.joins:
		var player_data = {
			"user_id": join.user_id,
			"username": join.username,
			"session_id": join.session_id
		}
		connected_players[join.user_id] = player_data
		
		if join.user_id != local_player_id:
			print("Player joined: ", join.username)
			player_joined.emit(player_data)
	
	for leave in match_presence.leaves:
		if connected_players.has(leave.user_id):
			connected_players.erase(leave.user_id)
			
			if leave.user_id != local_player_id:
				print("Player left: ", leave.username)
				player_left.emit(leave.user_id)

func _handle_platform_reached(data):
	# This would be handled by server-side validation in a real implementation
	# For now, we'll trust the client but you should validate server-side
	var player_id = data.player_id
	var platform_name = data.platform_name
	
	# In a real server implementation, you'd validate the player position
	# For now, we'll emit the event for other systems to handle
	# MultiplayerGameManager will handle the validation
	pass

func _handle_ground_touched(data):
	# This would be handled by server-side validation in a real implementation
	var player_id = data.player_id
	
	# In a real server implementation, you'd validate the ground touch
	# For now, we'll emit the event for other systems to handle
	# MultiplayerGameManager will handle the validation
	pass

func disconnect_from_server():
	if socket:
		socket.close()

func _exit_tree():
	disconnect_from_server()