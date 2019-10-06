extends CanvasLayer

const STAGE_GAME = "res://stages/game_stage.tscn"
const STAGE_MENU = "res://stages/menu_stage.tscn"

var is_changing = false

signal state_changed

func _ready():
	pass

func change_stage(stage_path):
	if is_changing: return
	
	is_changing = true
	
	# fade to black
	$tex_black.show()
	$anim.play("fade_in")
	audio_player.stream = load("res://sounds/sfx_swooshing.wav")
	audio_player.play()
	yield($anim, "animation_finished")
	
	# change state
	get_tree().change_scene(stage_path)
	emit_signal("state_changed")

	# fade from black
	$anim.play("fade_out")
	yield($anim, "animation_finished")
	$tex_black.hide()
	is_changing = false