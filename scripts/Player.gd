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

func _ready():
	pass

func _physics_process(delta):
	handle_gravity(delta)
	handle_input()
	handle_movement()
	move_and_slide()

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