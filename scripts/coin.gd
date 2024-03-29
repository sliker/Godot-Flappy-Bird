#script: coin

extends Area2D

func _ready():
	connect("body_entered", self, "_on_body_enter")
	$coin_player.stream = load("res://sounds/sfx_point.wav")
	pass

func _on_body_enter(other_body):
	if other_body.is_in_group(game.GROUP_BIRDS):
		game.score_current += 1
		$coin_player.play()
