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
var stick_figure_sprite
var jump_start_timer = 0.0
var jump_land_timer = 0.0
var was_jumping = false

func _ready():
	stick_figure_sprite = $StickFigureSprite

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
	var StickFigureSprite = preload("res://scripts/StickFigureSprite.gd")
	
	# Handle jump start timing
	if jump_start_timer > 0:
		jump_start_timer -= delta
		if jump_start_timer <= 0:
			stick_figure_sprite.set_animation_state(StickFigureSprite.AnimationState.JUMP_AIR)
	
	# Handle jump land timing
	if jump_land_timer > 0:
		jump_land_timer -= delta
		if jump_land_timer <= 0:
			# Return to appropriate animation based on movement
			var direction = Input.get_axis("move_left", "move_right")
			if abs(direction) > 0.1:
				stick_figure_sprite.set_animation_state(StickFigureSprite.AnimationState.WALK)
			else:
				stick_figure_sprite.set_animation_state(StickFigureSprite.AnimationState.IDLE)
	
	# Skip animation updates if in timed states
	if jump_start_timer > 0 or jump_land_timer > 0:
		return
	
	# Determine animation state based on physics
	var direction = Input.get_axis("move_left", "move_right")
	var is_jumping = velocity.y < -50  # Moving up significantly
	var is_falling = velocity.y > 50   # Moving down significantly
	var just_landed = is_on_floor() and was_jumping and velocity.y >= 0
	
	if just_landed:
		# Start landing animation
		stick_figure_sprite.set_animation_state(StickFigureSprite.AnimationState.JUMP_LAND)
		jump_land_timer = 0.2  # Show landing for 0.2 seconds
		was_jumping = false
	elif is_jumping or is_falling:
		if not was_jumping:
			# Start jump with brief jump_start animation
			stick_figure_sprite.set_animation_state(StickFigureSprite.AnimationState.JUMP_START)
			jump_start_timer = 0.1  # Show jump start for 0.1 seconds
			was_jumping = true
	elif is_on_floor():
		was_jumping = false
		if abs(direction) > 0.1:
			stick_figure_sprite.set_animation_state(StickFigureSprite.AnimationState.WALK)
		else:
			stick_figure_sprite.set_animation_state(StickFigureSprite.AnimationState.IDLE)
	
	# Handle sprite flipping for direction
	if abs(direction) > 0.1:
		stick_figure_sprite.scale.x = 1 if direction > 0 else -1