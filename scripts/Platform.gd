extends StaticBody2D

func _ready():
	$DetectionArea.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.has_method("on_platform_reached"):
		body.on_platform_reached(name)