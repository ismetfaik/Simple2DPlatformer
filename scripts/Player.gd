extends CharacterBody2D

signal platform_reached(platform_name)
signal ground_touched

const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 980.0

var coyote_time = 0.1
var coyote_timer = 0.0
var jump_buffer_time = 0.1
var jump_buffer_timer = 0.0
var was_on_ground = false

# Animation variables
var enhanced_pixel_sprite
var jump_start_timer = 0.0
var jump_land_timer = 0.0
var jump_fall_timer = 0.0
var was_jumping = false
var is_crouching = false

func _ready():
	enhanced_pixel_sprite = $EnhancedPixelCharacterSprite

func _physics_process(delta):
	handle_gravity(delta)
	handle_input()
	handle_movement()
	move_and_slide()
	update_animation(delta)

func handle_gravity(delta):
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		coyote_timer -= delta
	else:
		coyote_timer = coyote_time

func handle_input():
	# Handle crouching
	is_crouching = Input.is_action_pressed("crouch") if Input.get_connected_joypads().size() > 0 or Input.is_action_pressed("ui_down") else Input.is_action_pressed("ui_down")
	
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= get_physics_process_delta_time()
	
	if jump_buffer_timer > 0 and (is_on_floor() or coyote_timer > 0):
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0
		coyote_timer = 0

func handle_movement():
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 5 * get_physics_process_delta_time())
	
	check_ground_collision()

func check_ground_collision():
	var is_on_ground = position.y > 540
	if is_on_ground and not was_on_ground:
		ground_touched.emit()
	was_on_ground = is_on_ground

func on_platform_reached(platform_name):
	if platform_name == "GroundPlatform":
		ground_touched.emit()
	else:
		platform_reached.emit(platform_name)

func update_animation(delta):
	var EnhancedPixelCharacterSprite = preload("res://scripts/EnhancedPixelCharacterSprite.gd")
	
	# Handle timed animation states
	if jump_start_timer > 0:
		jump_start_timer -= delta
		if jump_start_timer <= 0:
			enhanced_pixel_sprite.set_animation_state(EnhancedPixelCharacterSprite.AnimationState.JUMP_AIR)
			jump_fall_timer = 0.3  # Time before switching to fall animation
	
	if jump_fall_timer > 0:
		jump_fall_timer -= delta
		if jump_fall_timer <= 0 and velocity.y > 0:  # Only switch to fall if actually falling
			enhanced_pixel_sprite.set_animation_state(EnhancedPixelCharacterSprite.AnimationState.JUMP_FALL)
	
	if jump_land_timer > 0:
		jump_land_timer -= delta
		if jump_land_timer <= 0:
			# Return to appropriate ground animation
			determine_ground_animation()
	
	# Skip other animation updates if in timed states
	if jump_start_timer > 0 or jump_land_timer > 0:
		return
	
	# Determine animation state based on physics and input
	var direction = Input.get_axis("move_left", "move_right")
	var is_jumping = velocity.y < -50  # Moving up significantly
	var is_falling = velocity.y > 50   # Moving down significantly
	var just_landed = is_on_floor() and was_jumping and velocity.y >= 0
	var movement_speed = abs(velocity.x)
	
	if just_landed:
		# Start landing animation
		enhanced_pixel_sprite.set_animation_state(EnhancedPixelCharacterSprite.AnimationState.JUMP_LAND)
		jump_land_timer = 0.25  # Landing recovery time
		was_jumping = false
		jump_fall_timer = 0.0
	elif is_jumping:
		if not was_jumping:
			# Start jump sequence
			enhanced_pixel_sprite.set_animation_state(EnhancedPixelCharacterSprite.AnimationState.JUMP_START)
			jump_start_timer = 0.1  # Brief crouch before jump
			was_jumping = true
	elif is_falling and was_jumping:
		# Continue with fall animation if not already set
		if jump_fall_timer <= 0:
			enhanced_pixel_sprite.set_animation_state(EnhancedPixelCharacterSprite.AnimationState.JUMP_FALL)
	elif is_on_floor():
		was_jumping = false
		jump_fall_timer = 0.0
		determine_ground_animation()
	
	# Handle sprite flipping for direction
	if abs(direction) > 0.1:
		enhanced_pixel_sprite.scale.x = 1 if direction > 0 else -1

func determine_ground_animation():
	var EnhancedPixelCharacterSprite = preload("res://scripts/EnhancedPixelCharacterSprite.gd")
	var direction = Input.get_axis("move_left", "move_right")
	var movement_speed = abs(velocity.x)
	
	if is_crouching:
		if abs(direction) > 0.1:
			enhanced_pixel_sprite.set_animation_state(EnhancedPixelCharacterSprite.AnimationState.CROUCH_WALK)
		else:
			enhanced_pixel_sprite.set_animation_state(EnhancedPixelCharacterSprite.AnimationState.CROUCH)
	elif abs(direction) > 0.1:
		# Determine walk vs run based on speed
		if movement_speed > SPEED * 0.8:  # Running at near full speed
			enhanced_pixel_sprite.set_animation_state(EnhancedPixelCharacterSprite.AnimationState.RUN)
		else:
			enhanced_pixel_sprite.set_animation_state(EnhancedPixelCharacterSprite.AnimationState.WALK)
	else:
		enhanced_pixel_sprite.set_animation_state(EnhancedPixelCharacterSprite.AnimationState.IDLE)