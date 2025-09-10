extends Node2D

enum AnimationState { 
	IDLE, IDLE_BLINK, WALK, RUN, CROUCH, CROUCH_WALK, 
	JUMP_START, JUMP_AIR, JUMP_FALL, JUMP_LAND, WALL_SLIDE 
}

var current_state = AnimationState.IDLE
var walk_frame = 0
var run_frame = 0
var idle_frame = 0
var animation_timer = 0.0
var walk_speed = 0.12   # 8 frames
var run_speed = 0.08    # Faster animation for running
var idle_speed = 2.0    # Slow idle animation
var blink_timer = 0.0
var blink_chance = 0.02  # 2% chance per frame to blink

# Enhanced cute color palette
var skin_color = Color(1.0, 0.92, 0.8)       # Softer, pinker skin
var skin_shadow = Color(0.92, 0.82, 0.68)    # Gentle skin shadow
var hair_color = Color(0.4, 0.2, 0.1)        # Rich brown hair
var hair_highlight = Color(0.65, 0.45, 0.3)  # Golden brown highlights
var hair_accent = Color(0.8, 0.6, 0.4)       # Light hair strands
var hair_shadow = Color(0.3, 0.15, 0.08)     # Dark hair shadow
var shirt_color = Color(0.95, 0.7, 0.85)     # Cute pink shirt
var shirt_shadow = Color(0.85, 0.6, 0.75)    # Pink shirt shadow  
var shirt_highlight = Color(0.98, 0.8, 0.9)  # Pink shirt highlight
var pants_color = Color(0.3, 0.2, 0.6)       # Pretty purple pants
var pants_highlight = Color(0.4, 0.3, 0.7)   # Purple pants highlight
var shoe_color = Color(0.8, 0.3, 0.4)        # Cute red shoes
var shoe_highlight = Color(0.9, 0.5, 0.6)    # Red shoe highlight
var eye_color = Color(0.2, 0.4, 0.8)         # Bright blue eyes
var eye_highlight = Color(0.8, 0.9, 1.0)     # Eye sparkle
var mouth_color = Color(0.95, 0.6, 0.7)      # Sweet pink lips
var blush_color = Color(1.0, 0.8, 0.85)      # Cute cheek blush

func _ready():
	pass

func _draw():
	var pixel_size = 2  # Scale factor for pixels
	
	# Draw based on current animation state
	match current_state:
		AnimationState.IDLE:
			draw_idle(pixel_size)
		AnimationState.IDLE_BLINK:
			draw_idle_blink(pixel_size)
		AnimationState.WALK:
			draw_walk(pixel_size)
		AnimationState.RUN:
			draw_run(pixel_size)
		AnimationState.CROUCH:
			draw_crouch(pixel_size)
		AnimationState.CROUCH_WALK:
			draw_crouch_walk(pixel_size)
		AnimationState.JUMP_START:
			draw_jump_start(pixel_size)
		AnimationState.JUMP_AIR:
			draw_jump_air(pixel_size)
		AnimationState.JUMP_FALL:
			draw_jump_fall(pixel_size)
		AnimationState.JUMP_LAND:
			draw_jump_land(pixel_size)
		AnimationState.WALL_SLIDE:
			draw_wall_slide(pixel_size)

func draw_pixel(pos: Vector2, color: Color, size: int):
	draw_rect(Rect2(pos.x * size, pos.y * size, size, size), color)

func draw_detailed_head(pixel_size: int, offset_y: int = 0):
	# Rounder, cuter head shape
	for x in range(-4, 5):
		for y in range(-16 + offset_y, -8 + offset_y):
			var dist_from_center = sqrt((x * x) + ((y + 12 - offset_y) * (y + 12 - offset_y)))
			if dist_from_center <= 3.8:  # Slightly rounder
				if dist_from_center <= 3.0:
					draw_pixel(Vector2(x, y), skin_color, pixel_size)
				else:
					draw_pixel(Vector2(x, y), skin_shadow, pixel_size)
	
	# Cute hairstyle with more detail
	for x in range(-4, 5):
		for y in range(-17 + offset_y, -11 + offset_y):
			if y == -17 + offset_y and abs(x) <= 3:  # Top hair line
				draw_pixel(Vector2(x, y), hair_color, pixel_size)
			elif y == -16 + offset_y and abs(x) <= 3:
				if x == -2 or x == 2:  # Side highlights
					draw_pixel(Vector2(x, y), hair_highlight, pixel_size)
				elif x == -1 or x == 1:  # Center highlights
					draw_pixel(Vector2(x, y), hair_accent, pixel_size)
				else:
					draw_pixel(Vector2(x, y), hair_color, pixel_size)
			elif y >= -15 + offset_y and abs(x) <= 3:
				if x == 0 and y == -15 + offset_y:  # Hair part
					draw_pixel(Vector2(x, y), hair_accent, pixel_size)
				elif abs(x) == 3:  # Side hair
					draw_pixel(Vector2(x, y), hair_shadow if x < 0 else hair_highlight, pixel_size)
				else:
					draw_pixel(Vector2(x, y), hair_color, pixel_size)
	
	# Bigger, cuter eyes with sparkles
	# Left eye
	draw_pixel(Vector2(-2, -12 + offset_y), Color.WHITE, pixel_size)
	draw_pixel(Vector2(-1, -12 + offset_y), Color.WHITE, pixel_size)
	draw_pixel(Vector2(-2, -11 + offset_y), Color.WHITE, pixel_size)
	draw_pixel(Vector2(-2, -12 + offset_y), eye_color, pixel_size)
	draw_pixel(Vector2(-1, -12 + offset_y), eye_color, pixel_size)
	draw_pixel(Vector2(-1, -11 + offset_y), eye_highlight, pixel_size)  # Sparkle
	
	# Right eye  
	draw_pixel(Vector2(2, -12 + offset_y), Color.WHITE, pixel_size)
	draw_pixel(Vector2(1, -12 + offset_y), Color.WHITE, pixel_size)
	draw_pixel(Vector2(2, -11 + offset_y), Color.WHITE, pixel_size)
	draw_pixel(Vector2(2, -12 + offset_y), eye_color, pixel_size)
	draw_pixel(Vector2(1, -12 + offset_y), eye_color, pixel_size)
	draw_pixel(Vector2(1, -11 + offset_y), eye_highlight, pixel_size)  # Sparkle
	
	# Cute blush on cheeks
	draw_pixel(Vector2(-3, -10 + offset_y), blush_color, pixel_size)
	draw_pixel(Vector2(3, -10 + offset_y), blush_color, pixel_size)
	
	# Small cute nose
	draw_pixel(Vector2(0, -10 + offset_y), skin_shadow, pixel_size)
	
	# Sweet smile
	draw_pixel(Vector2(-1, -9 + offset_y), mouth_color, pixel_size)
	draw_pixel(Vector2(0, -9 + offset_y), mouth_color, pixel_size)
	draw_pixel(Vector2(1, -9 + offset_y), mouth_color, pixel_size)

func draw_detailed_torso(pixel_size: int, arm_left_offset: Vector2 = Vector2.ZERO, arm_right_offset: Vector2 = Vector2.ZERO):
	# Shorter, better proportioned torso with cute pink shirt
	for x in range(-3, 4):
		for y in range(-7, 3):  # Reduced from -8,8 to -7,3 (10 pixels vs 16)
			if abs(x) <= 2:
				if x == -2 or y == -7:  # Highlight areas (left side and top)
					draw_pixel(Vector2(x, y), shirt_highlight, pixel_size)
				elif x == 2 or y == 2:  # Shadow areas (right side and bottom)
					draw_pixel(Vector2(x, y), shirt_shadow, pixel_size)
				else:
					draw_pixel(Vector2(x, y), shirt_color, pixel_size)
	
	# More natural arm positioning with shoulder attachment
	var left_shoulder = Vector2(-3, -6)
	var right_shoulder = Vector2(3, -6)
	
	# Left arm with natural curve
	var left_arm_positions = [
		left_shoulder + arm_left_offset,                    # Shoulder
		Vector2(-3, -5) + arm_left_offset,                 # Upper arm
		Vector2(-4, -4) + arm_left_offset,                 # Upper arm
		Vector2(-4, -3) + arm_left_offset,                 # Elbow
		Vector2(-4, -2) + arm_left_offset,                 # Forearm
		Vector2(-5, -1) + arm_left_offset,                 # Forearm
		Vector2(-5, 0) + arm_left_offset                   # Hand
	]
	
	# Right arm with natural curve
	var right_arm_positions = [
		right_shoulder + arm_right_offset,                  # Shoulder
		Vector2(3, -5) + arm_right_offset,                 # Upper arm
		Vector2(4, -4) + arm_right_offset,                 # Upper arm
		Vector2(4, -3) + arm_right_offset,                 # Elbow
		Vector2(4, -2) + arm_right_offset,                 # Forearm
		Vector2(5, -1) + arm_right_offset,                 # Forearm
		Vector2(5, 0) + arm_right_offset                   # Hand
	]
	
	# Draw arms with better joint definition
	for i in range(left_arm_positions.size()):
		var pos = left_arm_positions[i]
		if i >= 5:  # Hand area
			draw_pixel(pos, skin_shadow, pixel_size)
		elif i == 3:  # Elbow - slight shadow
			draw_pixel(pos, skin_shadow, pixel_size)
		else:
			draw_pixel(pos, skin_color, pixel_size)
	
	for i in range(right_arm_positions.size()):
		var pos = right_arm_positions[i]
		if i >= 5:  # Hand area
			draw_pixel(pos, skin_shadow, pixel_size)
		elif i == 3:  # Elbow - slight shadow
			draw_pixel(pos, skin_shadow, pixel_size)
		else:
			draw_pixel(pos, skin_color, pixel_size)

func draw_detailed_legs(pixel_size: int, left_leg_offset: Vector2 = Vector2.ZERO, right_leg_offset: Vector2 = Vector2.ZERO):
	# Hip area - connects to shorter torso
	for x in range(-2, 3):
		draw_pixel(Vector2(x, 3), pants_color, pixel_size)  # Moved up from y=8 to y=3
		if x == 2:
			draw_pixel(Vector2(x, 3), pants_highlight, pixel_size)
	
	# Longer, more proportional legs (thigh + shin)
	var left_leg_positions = []
	var right_leg_positions = []
	
	# Thigh section (4-5 pixels)
	for y in range(4, 9):
		left_leg_positions.append(Vector2(-1, y) + left_leg_offset)
		right_leg_positions.append(Vector2(1, y) + right_leg_offset)
		
		# Add width for more natural thigh shape
		if y >= 5 and y <= 7:
			left_leg_positions.append(Vector2(-2, y) + left_leg_offset)
			right_leg_positions.append(Vector2(2, y) + right_leg_offset)
	
	# Knee area (transition)
	left_leg_positions.append(Vector2(-1, 9) + left_leg_offset)
	right_leg_positions.append(Vector2(1, 9) + right_leg_offset)
	
	# Shin section (longer - 6 pixels)
	for y in range(10, 16):
		left_leg_positions.append(Vector2(-1, y) + left_leg_offset)
		right_leg_positions.append(Vector2(1, y) + right_leg_offset)
		
		# Shin has some width too
		if y >= 12:
			left_leg_positions.append(Vector2(-2, y) + left_leg_offset)
			right_leg_positions.append(Vector2(2, y) + right_leg_offset)
	
	# Draw legs with better shading
	for pos in left_leg_positions:
		if pos.x == -2:  # Outer edge - highlight
			draw_pixel(pos, pants_highlight, pixel_size)
		else:
			draw_pixel(pos, pants_color, pixel_size)
	
	for pos in right_leg_positions:
		if pos.x == 2:  # Outer edge - highlight
			draw_pixel(pos, pants_highlight, pixel_size)
		else:
			draw_pixel(pos, pants_color, pixel_size)
	
	# Better proportioned feet
	var left_foot_base = Vector2(-1, 16) + left_leg_offset  # Moved down from y=17 to y=16
	var right_foot_base = Vector2(1, 16) + right_leg_offset
	
	# Left foot with better shape
	var left_foot_pixels = [
		left_foot_base + Vector2(-2, 0),  # Heel
		left_foot_base + Vector2(-1, 0),  # Arch
		left_foot_base + Vector2(0, 0),   # Mid foot
		left_foot_base + Vector2(1, 0),   # Toe area
		left_foot_base + Vector2(-1, 1),  # Sole
		left_foot_base + Vector2(0, 1)    # Sole
	]
	
	# Right foot with better shape  
	var right_foot_pixels = [
		right_foot_base + Vector2(-1, 0),  # Toe area
		right_foot_base + Vector2(0, 0),   # Mid foot
		right_foot_base + Vector2(1, 0),   # Arch
		right_foot_base + Vector2(2, 0),   # Heel
		right_foot_base + Vector2(0, 1),   # Sole
		right_foot_base + Vector2(1, 1)    # Sole
	]
	
	# Draw feet
	for pos in left_foot_pixels:
		if pos.x <= left_foot_base.x - 2:  # Heel highlight
			draw_pixel(pos, shoe_highlight, pixel_size)
		else:
			draw_pixel(pos, shoe_color, pixel_size)
	
	for pos in right_foot_pixels:
		if pos.x >= right_foot_base.x + 2:  # Heel highlight
			draw_pixel(pos, shoe_highlight, pixel_size)
		else:
			draw_pixel(pos, shoe_color, pixel_size)

func draw_idle(pixel_size: int):
	# Subtle breathing animation
	var breath_offset = sin(idle_frame * 0.1) * 0.5
	
	draw_detailed_head(pixel_size, int(breath_offset))
	draw_detailed_torso(pixel_size)
	draw_detailed_legs(pixel_size)

func draw_idle_blink(pixel_size: int):
	# Draw base character
	draw_detailed_head(pixel_size)
	draw_detailed_torso(pixel_size)
	draw_detailed_legs(pixel_size)
	
	# Draw cute closed eyes (override the open ones)
	# Left eye closed
	draw_pixel(Vector2(-2, -12), skin_color, pixel_size)
	draw_pixel(Vector2(-1, -12), skin_color, pixel_size)
	draw_pixel(Vector2(-2, -11), skin_color, pixel_size)
	draw_pixel(Vector2(-2, -13), hair_shadow, pixel_size)  # Eyelash effect
	draw_pixel(Vector2(-1, -13), hair_shadow, pixel_size)
	
	# Right eye closed
	draw_pixel(Vector2(2, -12), skin_color, pixel_size)
	draw_pixel(Vector2(1, -12), skin_color, pixel_size)
	draw_pixel(Vector2(2, -11), skin_color, pixel_size)
	draw_pixel(Vector2(2, -13), hair_shadow, pixel_size)  # Eyelash effect
	draw_pixel(Vector2(1, -13), hair_shadow, pixel_size)
	
	# Keep the cute blush and smile
	draw_pixel(Vector2(-3, -10), blush_color, pixel_size)
	draw_pixel(Vector2(3, -10), blush_color, pixel_size)

func draw_walk(pixel_size: int):
	# 8-frame walking cycle
	var cycle_progress = walk_frame / 8.0
	var arm_swing = sin(cycle_progress * PI * 2) * 2
	var leg_step = sin(cycle_progress * PI * 2) * 3
	var body_bob = abs(sin(cycle_progress * PI * 2)) * 0.5
	
	draw_detailed_head(pixel_size, -int(body_bob))
	draw_detailed_torso(pixel_size, 
		Vector2(-arm_swing, 1), 
		Vector2(arm_swing, 1))
	draw_detailed_legs(pixel_size, 
		Vector2(leg_step, 0), 
		Vector2(-leg_step, 0))

func draw_run(pixel_size: int):
	# More dramatic running animation
	var cycle_progress = run_frame / 6.0
	var arm_swing = sin(cycle_progress * PI * 2) * 3
	var leg_step = sin(cycle_progress * PI * 2) * 4
	var body_lean = sin(cycle_progress * PI * 2) * 1
	var body_bob = abs(sin(cycle_progress * PI * 2)) * 1
	
	draw_detailed_head(pixel_size, int(body_lean - body_bob))
	draw_detailed_torso(pixel_size, 
		Vector2(-arm_swing + body_lean, 2), 
		Vector2(arm_swing + body_lean, -1))
	draw_detailed_legs(pixel_size, 
		Vector2(leg_step, 0), 
		Vector2(-leg_step, 0))

func draw_crouch(pixel_size: int):
	# Crouched position - head lower
	draw_detailed_head(pixel_size, 5)
	
	# Compressed torso but using our new proportions
	draw_detailed_torso(pixel_size, Vector2(-2, 4), Vector2(2, 4))
	
	# Bent legs - much more compressed due to crouching
	draw_detailed_legs(pixel_size, Vector2(-3, -8), Vector2(3, -8))

func draw_crouch_walk(pixel_size: int):
	# Sneaky crouch walking
	var cycle_progress = walk_frame / 6.0
	var arm_sway = sin(cycle_progress * PI * 2) * 1
	var leg_step = sin(cycle_progress * PI * 2) * 2
	
	draw_detailed_head(pixel_size, 5)
	draw_detailed_torso(pixel_size, 
		Vector2(-1 - arm_sway, 4), 
		Vector2(1 + arm_sway, 4))
	draw_detailed_legs(pixel_size, 
		Vector2(-2 + leg_step, -8), 
		Vector2(2 - leg_step, -8))

func draw_jump_start(pixel_size: int):
	# Pre-jump crouch - arms back for momentum, staying connected to shoulders
	draw_detailed_head(pixel_size, 6)
	draw_detailed_torso(pixel_size, Vector2(1, 3), Vector2(-1, 3))  # Arms back but connected
	draw_detailed_legs(pixel_size, Vector2(-4, -10), Vector2(4, -10))

func draw_jump_air(pixel_size: int):
	# Airborne pose - arms up high for balance and momentum
	draw_detailed_head(pixel_size)
	draw_detailed_torso(pixel_size, Vector2(0, -6), Vector2(0, -6))  # Both arms straight up
	draw_detailed_legs(pixel_size, Vector2(-2, -5), Vector2(2, -5))  # Legs tucked up

func draw_jump_fall(pixel_size: int):
	# Falling pose - arms still up but preparing for landing
	draw_detailed_head(pixel_size, 1)
	draw_detailed_torso(pixel_size, Vector2(-1, -4), Vector2(1, -4))  # Arms up but slightly out
	draw_detailed_legs(pixel_size, Vector2(-1, -1), Vector2(1, -1))  # Legs extending for landing

func draw_jump_land(pixel_size: int):
	# Landing recovery - arms out for balance, staying connected
	draw_detailed_head(pixel_size, 3)
	draw_detailed_torso(pixel_size, Vector2(-3, 0), Vector2(3, 0))  # Arms out horizontally
	draw_detailed_legs(pixel_size, Vector2(-2, -4), Vector2(2, -4))  # Knees bent for impact

func draw_wall_slide(pixel_size: int):
	# Wall sliding pose - one arm against wall, legs slightly bent
	draw_detailed_head(pixel_size, 1)
	draw_detailed_torso(pixel_size, Vector2(-4, 0), Vector2(1, 2))
	draw_detailed_legs(pixel_size, Vector2(-1, 1), Vector2(1, -2))

func _process(delta):
	# Handle different animation timers
	match current_state:
		AnimationState.WALK, AnimationState.CROUCH_WALK:
			animation_timer += delta
			if animation_timer >= walk_speed:
				walk_frame = (walk_frame + 1) % 8
				animation_timer = 0.0
				queue_redraw()
		
		AnimationState.RUN:
			animation_timer += delta
			if animation_timer >= run_speed:
				run_frame = (run_frame + 1) % 6
				animation_timer = 0.0
				queue_redraw()
		
		AnimationState.IDLE:
			animation_timer += delta
			if animation_timer >= idle_speed / 60.0:  # 60fps idle animation
				idle_frame = (idle_frame + 1) % 360  # Full circle
				animation_timer = 0.0
				queue_redraw()
			
			# Handle blinking
			blink_timer += delta
			if blink_timer >= 0.1:  # Check for blink every 0.1 seconds
				if randf() < blink_chance:
					set_animation_state(AnimationState.IDLE_BLINK)
				blink_timer = 0.0
		
		AnimationState.IDLE_BLINK:
			animation_timer += delta
			if animation_timer >= 0.15:  # Blink duration
				set_animation_state(AnimationState.IDLE)

func set_animation_state(new_state: AnimationState):
	if current_state != new_state:
		current_state = new_state
		animation_timer = 0.0
		
		# Reset appropriate frame counters
		match current_state:
			AnimationState.WALK, AnimationState.CROUCH_WALK:
				walk_frame = 0
			AnimationState.RUN:
				run_frame = 0
			AnimationState.IDLE:
				idle_frame = 0
				blink_timer = 0.0
		
		queue_redraw()