extends "res://scripts/Player.gd"

var last_sent_position: Vector2 = Vector2.ZERO
var last_sent_state: String = ""
var last_sent_direction: int = 0
var network_send_timer: float = 0.0
const NETWORK_SEND_RATE: float = 1.0 / 20.0 # 20 times per second

var player_id: String = ""
var is_local_player: bool = false

func _ready():
	super._ready()
	
	# Connect to network events
	NetworkManager.connected_to_server.connect(_on_connected_to_server)
	
	# Connect to platform reached and ground touched signals for multiplayer
	platform_reached.connect(_on_platform_reached_mp)
	ground_touched.connect(_on_ground_touched_mp)

func _physics_process(delta):
	if is_local_player:
		super._physics_process(delta)
		handle_network_updates(delta)
	else:
		# Remote players don't process input, only update animations
		update_animation(delta)

func setup_as_local_player(id: String):
	player_id = id
	is_local_player = true
	
	# Enable collision and physics for local player
	set_collision_layer(1)
	set_collision_mask(2)

func setup_as_remote_player(id: String):
	player_id = id
	is_local_player = false
	
	# Disable collision for remote players to prevent interference
	set_collision_layer(0)
	set_collision_mask(0)
	
	# Remote players don't process physics
	set_physics_process(false)

func handle_network_updates(delta):
	network_send_timer += delta
	
	if network_send_timer >= NETWORK_SEND_RATE:
		network_send_timer = 0.0
		send_player_state_if_changed()

func send_player_state_if_changed():
	var current_position = global_position
	var current_state = get_animation_state_string()
	var current_direction = get_facing_direction()
	
	# Only send if something significant has changed
	var position_changed = last_sent_position.distance_to(current_position) > 2.0
	var state_changed = last_sent_state != current_state
	var direction_changed = last_sent_direction != current_direction
	
	if position_changed or state_changed or direction_changed:
		NetworkManager.send_player_state(current_position, current_state, current_direction)
		
		last_sent_position = current_position
		last_sent_state = current_state
		last_sent_direction = current_direction

func get_animation_state_string() -> String:
	if not pixel_character_sprite:
		return "idle"
	
	match pixel_character_sprite.current_state:
		pixel_character_sprite.AnimationState.IDLE:
			return "idle"
		pixel_character_sprite.AnimationState.WALK:
			return "walk"
		pixel_character_sprite.AnimationState.JUMP_START:
			return "jump_start"
		pixel_character_sprite.AnimationState.JUMP_AIR:
			return "jump_air"
		pixel_character_sprite.AnimationState.JUMP_LAND:
			return "jump_land"
		_:
			return "idle"

func get_facing_direction() -> int:
	if pixel_character_sprite:
		return 1 if pixel_character_sprite.scale.x > 0 else -1
	return 1

func update_from_network_state(state_data: Dictionary):
	if is_local_player:
		return  # Don't update local player from network
	
	# Update position with smoothing
	var target_position = Vector2(state_data.position.x, state_data.position.y)
	global_position = global_position.lerp(target_position, 0.5)
	
	# Update animation state
	set_animation_state_from_string(state_data.animation_state)
	
	# Update facing direction
	if pixel_character_sprite and state_data.has("facing_direction"):
		pixel_character_sprite.scale.x = state_data.facing_direction

func set_animation_state_from_string(state_string: String):
	if not pixel_character_sprite:
		return
	
	var PixelCharacterSprite = preload("res://scripts/PixelCharacterSprite.gd")
	
	match state_string:
		"idle":
			pixel_character_sprite.set_animation_state(PixelCharacterSprite.AnimationState.IDLE)
		"walk":
			pixel_character_sprite.set_animation_state(PixelCharacterSprite.AnimationState.WALK)
		"jump_start":
			pixel_character_sprite.set_animation_state(PixelCharacterSprite.AnimationState.JUMP_START)
		"jump_air":
			pixel_character_sprite.set_animation_state(PixelCharacterSprite.AnimationState.JUMP_AIR)
		"jump_land":
			pixel_character_sprite.set_animation_state(PixelCharacterSprite.AnimationState.JUMP_LAND)

func _on_connected_to_server():
	if is_local_player:
		player_id = NetworkManager.local_player_id

func _on_platform_reached_mp(platform_name: String):
	if is_local_player:
		NetworkManager.send_platform_reached(platform_name)

func _on_ground_touched_mp():
	if is_local_player:
		NetworkManager.send_ground_touched()