extends Node2D

enum AnimationState { IDLE, WALK, JUMP_START, JUMP_AIR, JUMP_LAND }

var current_state = AnimationState.IDLE
var walk_frame = 0
var animation_timer = 0.0
var walk_speed = 0.15  # seconds per frame

# Gradient colors for modern look
var primary_color = Color(0.15, 0.2, 0.35, 1.0)    # Dark blue-gray
var secondary_color = Color(0.25, 0.3, 0.45, 1.0)  # Slightly lighter
var accent_color = Color(0.4, 0.5, 0.7, 1.0)       # Accent highlights

func _ready():
	pass

func _draw():
	# Draw based on current animation state
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

func draw_smooth_polygon(points: PackedVector2Array, color: Color):
	# Draw main shape
	draw_colored_polygon(points, color)
	# Add subtle outline for definition
	for i in range(points.size()):
		var start = points[i]
		var end = points[(i + 1) % points.size()]
		draw_line(start, end, color.darkened(0.2), 1.0)

func draw_idle():
	# Main body silhouette - standing upright
	var body_points = PackedVector2Array([
		Vector2(0, -16),    # Head top
		Vector2(4, -14),    # Head right
		Vector2(4, -8),     # Neck right
		Vector2(6, -6),     # Shoulder right
		Vector2(6, 2),      # Torso right
		Vector2(4, 4),      # Waist right
		Vector2(4, 14),     # Hip right
		Vector2(6, 16),     # Leg outer right
		Vector2(6, 22),     # Foot right
		Vector2(2, 24),     # Foot bottom right
		Vector2(-2, 24),    # Foot bottom left
		Vector2(-6, 22),    # Foot left
		Vector2(-6, 16),    # Leg outer left
		Vector2(-4, 14),    # Hip left
		Vector2(-4, 4),     # Waist left
		Vector2(-6, 2),     # Torso left
		Vector2(-6, -6),    # Shoulder left
		Vector2(-4, -8),    # Neck left
		Vector2(-4, -14),   # Head left
	])
	
	draw_smooth_polygon(body_points, primary_color)
	
	# Add gradient effect for depth
	var gradient_points = PackedVector2Array([
		Vector2(-2, -12),   # Inner head
		Vector2(2, -12),
		Vector2(3, -6),     # Inner shoulder
		Vector2(3, 8),      # Inner torso
		Vector2(1, 10),
		Vector2(-1, 10),
		Vector2(-3, 8),
		Vector2(-3, -6),
	])
	draw_smooth_polygon(gradient_points, secondary_color)

func draw_walk():
	var sway = sin(walk_frame * PI / 2) * 2
	var lean = cos(walk_frame * PI / 2) * 1
	
	# Walking body with slight lean and sway
	var body_points = PackedVector2Array([
		Vector2(lean, -16),           # Head top
		Vector2(4 + lean, -14),       # Head right
		Vector2(4 + lean, -8),        # Neck right
		Vector2(6 + lean, -6),        # Shoulder right
		Vector2(6 + lean/2, 2),       # Torso right
		Vector2(4 + lean/2, 4),       # Waist right
		Vector2(4 + sway, 14),        # Hip right
		Vector2(8 + sway, 16),        # Leg outer right (extended)
		Vector2(8 + sway, 22),        # Foot right
		Vector2(4 + sway, 24),        # Foot bottom right
		Vector2(-4 - sway, 24),       # Foot bottom left
		Vector2(-6 - sway, 22),       # Foot left
		Vector2(-6 - sway, 16),       # Leg outer left
		Vector2(-4 - sway, 14),       # Hip left
		Vector2(-4 - lean/2, 4),      # Waist left
		Vector2(-6 - lean/2, 2),      # Torso left
		Vector2(-6 - lean, -6),       # Shoulder left
		Vector2(-4 - lean, -8),       # Neck left
		Vector2(-4 - lean, -14),      # Head left
	])
	
	draw_smooth_polygon(body_points, primary_color)
	
	# Dynamic inner gradient based on movement
	var inner_points = PackedVector2Array([
		Vector2(-1 + lean/2, -12),
		Vector2(1 + lean/2, -12),
		Vector2(2 + lean/2, -6),
		Vector2(2, 6),
		Vector2(0, 8),
		Vector2(-2, 6),
		Vector2(-2 - lean/2, -6),
	])
	draw_smooth_polygon(inner_points, secondary_color)

func draw_jump_start():
	# Crouched, compressed silhouette
	var body_points = PackedVector2Array([
		Vector2(0, -12),     # Head top (lower)
		Vector2(3, -10),     # Head right
		Vector2(3, -6),      # Neck right
		Vector2(8, -4),      # Arm extended back right
		Vector2(8, 0),       # Arm end right
		Vector2(5, 2),       # Shoulder back right
		Vector2(5, 6),       # Torso right
		Vector2(7, 8),       # Hip right
		Vector2(9, 12),      # Knee right (bent)
		Vector2(7, 16),      # Shin right
		Vector2(9, 18),      # Foot right
		Vector2(5, 20),      # Foot bottom right
		Vector2(-5, 20),     # Foot bottom left
		Vector2(-9, 18),     # Foot left
		Vector2(-7, 16),     # Shin left
		Vector2(-9, 12),     # Knee left (bent)
		Vector2(-7, 8),      # Hip left
		Vector2(-5, 6),      # Torso left
		Vector2(-5, 2),      # Shoulder back left
		Vector2(-8, 0),      # Arm end left
		Vector2(-8, -4),     # Arm extended back left
		Vector2(-3, -6),     # Neck left
		Vector2(-3, -10),    # Head left
	])
	
	draw_smooth_polygon(body_points, primary_color)
	
	# Inner gradient for compressed pose
	var inner_points = PackedVector2Array([
		Vector2(0, -8),
		Vector2(2, -4),
		Vector2(3, 4),
		Vector2(1, 6),
		Vector2(-1, 6),
		Vector2(-3, 4),
		Vector2(-2, -4),
	])
	draw_smooth_polygon(inner_points, secondary_color)

func draw_jump_air():
	# Extended, airborne silhouette with dramatic pose
	var body_points = PackedVector2Array([
		Vector2(0, -16),     # Head top
		Vector2(3, -14),     # Head right
		Vector2(3, -8),      # Neck right
		Vector2(8, -12),     # Arm up right
		Vector2(10, -14),    # Hand right
		Vector2(8, -6),      # Shoulder right
		Vector2(4, -4),      # Chest right
		Vector2(4, 4),       # Waist right
		Vector2(6, 6),       # Hip right
		Vector2(10, 2),      # Knee up right
		Vector2(8, 8),       # Shin right
		Vector2(10, 10),     # Foot right
		Vector2(6, 12),      # Foot bottom right
		Vector2(-6, 12),     # Foot bottom left
		Vector2(-10, 10),    # Foot left
		Vector2(-8, 8),      # Shin left
		Vector2(-10, 2),     # Knee up left
		Vector2(-6, 6),      # Hip left
		Vector2(-4, 4),      # Waist left
		Vector2(-4, -4),     # Chest left
		Vector2(-8, -6),     # Shoulder left
		Vector2(-10, -14),   # Hand left
		Vector2(-8, -12),    # Arm up left
		Vector2(-3, -8),     # Neck left
		Vector2(-3, -14),    # Head left
	])
	
	draw_smooth_polygon(body_points, primary_color)
	
	# Highlight for dynamic air pose
	var highlight_points = PackedVector2Array([
		Vector2(0, -12),
		Vector2(2, -10),
		Vector2(2, -2),
		Vector2(1, 2),
		Vector2(-1, 2),
		Vector2(-2, -2),
		Vector2(-2, -10),
	])
	draw_smooth_polygon(highlight_points, accent_color)

func draw_jump_land():
	# Landing pose with arms extended for balance
	var body_points = PackedVector2Array([
		Vector2(0, -14),     # Head top
		Vector2(3, -12),     # Head right
		Vector2(3, -7),      # Neck right
		Vector2(12, -5),     # Arm extended right
		Vector2(14, -3),     # Hand right
		Vector2(12, 0),      # Arm mid right
		Vector2(6, 2),       # Shoulder right
		Vector2(4, 4),       # Chest right
		Vector2(4, 8),       # Waist right
		Vector2(5, 10),      # Hip right
		Vector2(5, 16),      # Thigh right
		Vector2(7, 18),      # Knee right
		Vector2(5, 22),      # Shin right
		Vector2(7, 24),      # Foot right
		Vector2(3, 26),      # Foot bottom right
		Vector2(-3, 26),     # Foot bottom left
		Vector2(-7, 24),     # Foot left
		Vector2(-5, 22),     # Shin left
		Vector2(-7, 18),     # Knee left
		Vector2(-5, 16),     # Thigh left
		Vector2(-5, 10),     # Hip left
		Vector2(-4, 8),      # Waist left
		Vector2(-4, 4),      # Chest left
		Vector2(-6, 2),      # Shoulder left
		Vector2(-12, 0),     # Arm mid left
		Vector2(-14, -3),    # Hand left
		Vector2(-12, -5),    # Arm extended left
		Vector2(-3, -7),     # Neck left
		Vector2(-3, -12),    # Head left
	])
	
	draw_smooth_polygon(body_points, primary_color)
	
	# Balance emphasis
	var balance_points = PackedVector2Array([
		Vector2(0, -10),
		Vector2(2, -8),
		Vector2(2, 2),
		Vector2(1, 6),
		Vector2(-1, 6),
		Vector2(-2, 2),
		Vector2(-2, -8),
	])
	draw_smooth_polygon(balance_points, secondary_color)

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