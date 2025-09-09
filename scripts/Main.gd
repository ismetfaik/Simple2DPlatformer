extends Node2D

func _ready():
	setup_boundaries()
	setup_ui()
	connect_signals()

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

func setup_ui():
	GameManager.score_changed.connect(_on_score_changed)

func connect_signals():
	$Player.platform_reached.connect(_on_platform_reached)
	$Player.ground_touched.connect(_on_ground_touched)

func _on_score_changed(new_score):
	$UI/ScoreLabel.text = "Score: " + str(new_score)

func _on_platform_reached(platform_name):
	GameManager.add_points(platform_name)

func _on_ground_touched():
	GameManager.reset_score()
