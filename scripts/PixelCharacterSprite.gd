extends Node2D

enum AnimationState { IDLE, WALK, JUMP_START, JUMP_AIR, JUMP_LAND }

var current_state = AnimationState.IDLE
var walk_frame = 0
var animation_timer = 0.0
var walk_speed = 0.15  # seconds per frame

# Colors
var skin_color = Color(1.0, 0.86, 0.69)  # Light skin
var hair_color = Color(0.55, 0.27, 0.07)  # Brown hair
var shirt_color = Color(0.0, 0.39, 0.78)  # Blue shirt
var pants_color = Color(0.2, 0.2, 0.2)   # Dark pants
var shoe_color = Color(0.55, 0.27, 0.07)  # Brown shoes

func _ready():
	pass

func _draw():
	var pixel_size = 2  # Scale factor for pixels
	
	# Draw based on current animation state
	match current_state:
		AnimationState.IDLE:
			draw_idle(pixel_size)
		AnimationState.WALK:
			draw_walk(pixel_size)
		AnimationState.JUMP_START:
			draw_jump_start(pixel_size)
		AnimationState.JUMP_AIR:
			draw_jump_air(pixel_size)
		AnimationState.JUMP_LAND:
			draw_jump_land(pixel_size)

func draw_pixel(pos: Vector2, color: Color, size: int):
	draw_rect(Rect2(pos.x * size, pos.y * size, size, size), color)

func draw_idle(pixel_size: int):
	# Head
	for x in range(-3, 4):
		for y in range(-12, -6):
			if abs(x) <= 2 and abs(y + 9) <= 2:
				draw_pixel(Vector2(x, y), skin_color, pixel_size)
	
	# Hair
	for x in range(-2, 3):
		for y in range(-12, -9):
			draw_pixel(Vector2(x, y), hair_color, pixel_size)
	
	# Eyes
	draw_pixel(Vector2(-1, -9), Color.BLACK, pixel_size)
	draw_pixel(Vector2(1, -9), Color.BLACK, pixel_size)
	
	# Body (shirt)
	for x in range(-2, 3):
		for y in range(-6, 6):
			draw_pixel(Vector2(x, y), shirt_color, pixel_size)
	
	# Arms
	draw_pixel(Vector2(-3, -4), skin_color, pixel_size)
	draw_pixel(Vector2(-3, -3), skin_color, pixel_size)
	draw_pixel(Vector2(-3, -2), skin_color, pixel_size)
	draw_pixel(Vector2(-3, -1), skin_color, pixel_size)
	draw_pixel(Vector2(3, -4), skin_color, pixel_size)
	draw_pixel(Vector2(3, -3), skin_color, pixel_size)
	draw_pixel(Vector2(3, -2), skin_color, pixel_size)
	draw_pixel(Vector2(3, -1), skin_color, pixel_size)
	
	# Legs (pants)
	draw_pixel(Vector2(-1, 6), pants_color, pixel_size)
	draw_pixel(Vector2(0, 6), pants_color, pixel_size)
	draw_pixel(Vector2(1, 6), pants_color, pixel_size)
	for y in range(7, 13):
		draw_pixel(Vector2(-1, y), pants_color, pixel_size)
		draw_pixel(Vector2(1, y), pants_color, pixel_size)
	
	# Feet
	for x in range(-2, 3):
		draw_pixel(Vector2(x, 13), shoe_color, pixel_size)

func draw_walk(pixel_size: int):
	var offset_x = int(sin(walk_frame * PI / 2) * 2)
	var arm_offset = int(cos(walk_frame * PI / 2) * 2)
	
	# Head (same as idle)
	for x in range(-3, 4):
		for y in range(-12, -6):
			if abs(x) <= 2 and abs(y + 9) <= 2:
				draw_pixel(Vector2(x, y), skin_color, pixel_size)
	
	# Hair
	for x in range(-2, 3):
		for y in range(-12, -9):
			draw_pixel(Vector2(x, y), hair_color, pixel_size)
	
	# Eyes
	draw_pixel(Vector2(-1, -9), Color.BLACK, pixel_size)
	draw_pixel(Vector2(1, -9), Color.BLACK, pixel_size)
	
	# Body
	for x in range(-2, 3):
		for y in range(-6, 6):
			draw_pixel(Vector2(x, y), shirt_color, pixel_size)
	
	# Arms (swinging)
	var left_arm_x = -3 + arm_offset
	var right_arm_x = 3 - arm_offset
	for y in range(-4, 0):
		draw_pixel(Vector2(left_arm_x, y), skin_color, pixel_size)
		draw_pixel(Vector2(right_arm_x, y), skin_color, pixel_size)
	
	# Legs (walking motion)
	var left_leg_x = -1 + offset_x
	var right_leg_x = 1 - offset_x
	
	draw_pixel(Vector2(-1, 6), pants_color, pixel_size)
	draw_pixel(Vector2(0, 6), pants_color, pixel_size)
	draw_pixel(Vector2(1, 6), pants_color, pixel_size)
	
	for y in range(7, 13):
		draw_pixel(Vector2(left_leg_x, y), pants_color, pixel_size)
		draw_pixel(Vector2(right_leg_x, y), pants_color, pixel_size)
	
	# Feet
	draw_pixel(Vector2(left_leg_x - 1, 13), shoe_color, pixel_size)
	draw_pixel(Vector2(left_leg_x, 13), shoe_color, pixel_size)
	draw_pixel(Vector2(left_leg_x + 1, 13), shoe_color, pixel_size)
	draw_pixel(Vector2(right_leg_x - 1, 13), shoe_color, pixel_size)
	draw_pixel(Vector2(right_leg_x, 13), shoe_color, pixel_size)
	draw_pixel(Vector2(right_leg_x + 1, 13), shoe_color, pixel_size)

func draw_jump_start(pixel_size: int):
	# Head
	for x in range(-3, 4):
		for y in range(-10, -4):
			if abs(x) <= 2 and abs(y + 7) <= 2:
				draw_pixel(Vector2(x, y), skin_color, pixel_size)
	
	# Hair
	for x in range(-2, 3):
		for y in range(-10, -7):
			draw_pixel(Vector2(x, y), hair_color, pixel_size)
	
	# Eyes
	draw_pixel(Vector2(-1, -7), Color.BLACK, pixel_size)
	draw_pixel(Vector2(1, -7), Color.BLACK, pixel_size)
	
	# Body (crouched)
	for x in range(-2, 3):
		for y in range(-4, 4):
			draw_pixel(Vector2(x, y), shirt_color, pixel_size)
	
	# Arms (back for jump)
	for y in range(-2, 2):
		draw_pixel(Vector2(-4, y), skin_color, pixel_size)
		draw_pixel(Vector2(4, y), skin_color, pixel_size)
	
	# Legs (bent, crouching)
	draw_pixel(Vector2(-1, 4), pants_color, pixel_size)
	draw_pixel(Vector2(0, 4), pants_color, pixel_size)
	draw_pixel(Vector2(1, 4), pants_color, pixel_size)
	
	for y in range(5, 9):
		draw_pixel(Vector2(-2, y), pants_color, pixel_size)
		draw_pixel(Vector2(2, y), pants_color, pixel_size)
	
	# Feet
	for x in range(-3, -1):
		draw_pixel(Vector2(x, 9), shoe_color, pixel_size)
	for x in range(1, 4):
		draw_pixel(Vector2(x, 9), shoe_color, pixel_size)

func draw_jump_air(pixel_size: int):
	# Head
	for x in range(-3, 4):
		for y in range(-12, -6):
			if abs(x) <= 2 and abs(y + 9) <= 2:
				draw_pixel(Vector2(x, y), skin_color, pixel_size)
	
	# Hair
	for x in range(-2, 3):
		for y in range(-12, -9):
			draw_pixel(Vector2(x, y), hair_color, pixel_size)
	
	# Eyes
	draw_pixel(Vector2(-1, -9), Color.BLACK, pixel_size)
	draw_pixel(Vector2(1, -9), Color.BLACK, pixel_size)
	
	# Body
	for x in range(-2, 3):
		for y in range(-6, 4):
			draw_pixel(Vector2(x, y), shirt_color, pixel_size)
	
	# Arms (up)
	for y in range(-8, -4):
		draw_pixel(Vector2(-3, y), skin_color, pixel_size)
		draw_pixel(Vector2(3, y), skin_color, pixel_size)
	
	# Legs (bent up)
	draw_pixel(Vector2(-1, 4), pants_color, pixel_size)
	draw_pixel(Vector2(0, 4), pants_color, pixel_size)
	draw_pixel(Vector2(1, 4), pants_color, pixel_size)
	
	for y in range(1, 5):
		draw_pixel(Vector2(-2, y), pants_color, pixel_size)
		draw_pixel(Vector2(2, y), pants_color, pixel_size)
	
	# Feet (tucked)
	draw_pixel(Vector2(-3, 5), shoe_color, pixel_size)
	draw_pixel(Vector2(-2, 6), shoe_color, pixel_size)
	draw_pixel(Vector2(2, 6), shoe_color, pixel_size)
	draw_pixel(Vector2(3, 5), shoe_color, pixel_size)

func draw_jump_land(pixel_size: int):
	# Head
	for x in range(-3, 4):
		for y in range(-11, -5):
			if abs(x) <= 2 and abs(y + 8) <= 2:
				draw_pixel(Vector2(x, y), skin_color, pixel_size)
	
	# Hair
	for x in range(-2, 3):
		for y in range(-11, -8):
			draw_pixel(Vector2(x, y), hair_color, pixel_size)
	
	# Eyes
	draw_pixel(Vector2(-1, -8), Color.BLACK, pixel_size)
	draw_pixel(Vector2(1, -8), Color.BLACK, pixel_size)
	
	# Body
	for x in range(-2, 3):
		for y in range(-5, 5):
			draw_pixel(Vector2(x, y), shirt_color, pixel_size)
	
	# Arms (forward for balance)
	for y in range(-3, 1):
		draw_pixel(Vector2(-4, y), skin_color, pixel_size)
		draw_pixel(Vector2(-5, y), skin_color, pixel_size)
		draw_pixel(Vector2(4, y), skin_color, pixel_size)
		draw_pixel(Vector2(5, y), skin_color, pixel_size)
	
	# Legs (slightly bent)
	draw_pixel(Vector2(-1, 5), pants_color, pixel_size)
	draw_pixel(Vector2(0, 5), pants_color, pixel_size)
	draw_pixel(Vector2(1, 5), pants_color, pixel_size)
	
	for y in range(6, 12):
		draw_pixel(Vector2(-1, y), pants_color, pixel_size)
		draw_pixel(Vector2(1, y), pants_color, pixel_size)
	
	# Feet
	for x in range(-2, 3):
		draw_pixel(Vector2(x, 12), shoe_color, pixel_size)

func _process(delta):
	if current_state == AnimationState.WALK:
		animation_timer += delta
		if animation_timer >= walk_speed:
			walk_frame = (walk_frame + 1) % 4
			animation_timer = 0.0
			queue_redraw()

func set_animation_state(new_state: AnimationState):
	if current_state != new_state:
		current_state = new_state
		if current_state == AnimationState.WALK:
			animation_timer = 0.0
			walk_frame = 0
		queue_redraw()