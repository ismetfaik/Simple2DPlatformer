extends Node

signal score_changed(new_score)

var score = 0
var visited_platforms = []

func add_points(platform_name):
	if platform_name not in visited_platforms:
		visited_platforms.append(platform_name)
		score += 100
		score_changed.emit(score)

func reset_score():
	score = 0
	visited_platforms.clear()
	score_changed.emit(score)

func get_score():
	return score