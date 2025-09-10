extends Node2D

enum AnimationState { IDLE, WALK, JUMP_START, JUMP_AIR, JUMP_LAND }

var current_state = AnimationState.IDLE
var walk_frame = 0
var animation_timer = 0.0
var walk_speed = 0.15  # seconds per frame

func _ready():
	pass

func _draw():
	var head_pos = Vector2(0, -15)
	var body_start = Vector2(0, -5)
	var body_end = Vector2(0, 15)
	
	# Head (circle)
	draw_circle(head_pos, 5, Color.BLACK)
	draw_circle(head_pos, 4, Color(1, 0.9, 0.8))  # Skin color
	
	# Eyes
	draw_circle(head_pos + Vector2(-2, -1), 1, Color.BLACK)
	draw_circle(head_pos + Vector2(2, -1), 1, Color.BLACK)
	
	# Body (line)
	draw_line(body_start, body_end, Color.BLACK, 2)
	
	# Arms and legs based on current animation state
	match current_state:
		AnimationState.IDLE:
			draw_idle()
		AnimationState.WALK:
			draw_walk()
		AnimationState.JUMP_START:
			draw_jump_start()
		AnimationState.JUMP_AIR:
			draw_jump_air()
		AnimationState.JUMP_LAND:
			draw_jump_land()

func draw_idle():
	# Arms down
	draw_line(Vector2(0, 0), Vector2(-8, 8), Color.BLACK, 2)
	draw_line(Vector2(0, 0), Vector2(8, 8), Color.BLACK, 2)
	# Legs straight
	draw_line(Vector2(0, 15), Vector2(-6, 25), Color.BLACK, 2)
	draw_line(Vector2(0, 15), Vector2(6, 25), Color.BLACK, 2)

func draw_walk():
	var arm_swing = sin(walk_frame * PI / 2) * 4
	var leg_swing = cos(walk_frame * PI / 2) * 3
	
	# Arms swinging
	draw_line(Vector2(0, 0), Vector2(-8 + arm_swing, 8), Color.BLACK, 2)
	draw_line(Vector2(0, 0), Vector2(8 - arm_swing, 8), Color.BLACK, 2)
	# Legs with walking motion
	draw_line(Vector2(0, 15), Vector2(-6 + leg_swing, 25), Color.BLACK, 2)
	draw_line(Vector2(0, 15), Vector2(6 - leg_swing, 25), Color.BLACK, 2)

func draw_jump_start():
	# Arms back, preparing to jump
	draw_line(Vector2(0, 0), Vector2(-6, 10), Color.BLACK, 2)
	draw_line(Vector2(0, 0), Vector2(6, 10), Color.BLACK, 2)
	# Legs bent, crouching
	draw_line(Vector2(0, 15), Vector2(-4, 20), Color.BLACK, 2)
	draw_line(Vector2(0, 15), Vector2(4, 20), Color.BLACK, 2)
	draw_line(Vector2(-4, 20), Vector2(-6, 22), Color.BLACK, 2)
	draw_line(Vector2(4, 20), Vector2(6, 22), Color.BLACK, 2)

func draw_jump_air():
	# Arms up
	draw_line(Vector2(0, 0), Vector2(-6, -8), Color.BLACK, 2)
	draw_line(Vector2(0, 0), Vector2(6, -8), Color.BLACK, 2)
	# Legs bent up
	draw_line(Vector2(0, 15), Vector2(-4, 8), Color.BLACK, 2)
	draw_line(Vector2(0, 15), Vector2(4, 8), Color.BLACK, 2)
	draw_line(Vector2(-4, 8), Vector2(-6, 12), Color.BLACK, 2)
	draw_line(Vector2(4, 8), Vector2(6, 12), Color.BLACK, 2)

func draw_jump_land():
	# Arms forward for balance
	draw_line(Vector2(0, 0), Vector2(-10, 5), Color.BLACK, 2)
	draw_line(Vector2(0, 0), Vector2(10, 5), Color.BLACK, 2)
	# Legs slightly bent
	draw_line(Vector2(0, 15), Vector2(-5, 23), Color.BLACK, 2)
	draw_line(Vector2(0, 15), Vector2(5, 23), Color.BLACK, 2)

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