# script: bird

extends RigidBody2D

onready var state = FlyingState.new(self)
var prev_state

var speed = 50

const STATE_FLYING = 0
const STATE_FLAPPING = 1
const STATE_HIT = 2
const STATE_GROUNDED = 3

signal state_changed

func _ready():
	add_to_group(game.GROUP_BIRDS)
	connect("body_entered", self, "_on_body_entered")
	pass

func _physics_process(delta):
	state.update(delta)

func _unhandled_input(event):
	if state.has_method("unhandled_input"):	
		state.unhandled_input(event)
	
func _on_body_entered(other_body):
	if state.has_method("on_body_enter"):
		state.on_body_enter(other_body)
	pass
	
func set_state(new_state):
	state.exit()
	prev_state = get_state()
	
	match new_state:
		STATE_FLYING:
			state = FlyingState.new(self)
		STATE_FLAPPING:
			state = FlappingState.new(self)
		STATE_HIT:
			state = HitState.new(self)
		STATE_GROUNDED:
			state = GroundedState.new(self)
			
	emit_signal("state_changed", self)

func get_state():
	if state is FlyingState:
		return STATE_FLYING
	elif state is FlappingState:
		return STATE_FLAPPING
	elif state is HitState:
		return STATE_HIT
	elif state is GroundedState:
		return STATE_GROUNDED


# class FlyingState ------------------------------------

class FlyingState:
	var bird
	var prev_gravity_scale
	
	func _init(bird):
		self.bird = bird
		bird.get_node("anim").play("flying")
		bird.linear_velocity = Vector2(bird.speed, bird.linear_velocity.y)
		prev_gravity_scale = bird.gravity_scale
		bird.gravity_scale = 0
		
	func update(delta):
		pass
		
	func exit():
		bird.gravity_scale = prev_gravity_scale
		bird.get_node("anim").stop()
		bird.get_node("anim_sprite").position = Vector2(0, 0)

# class FlappingState ------------------------------------

class FlappingState:
	var bird
	
	func _init(bird):
		self.bird = bird
		bird.linear_velocity = Vector2(bird.speed, bird.linear_velocity.y)
		flap()
		
	func update(delta):
		if rad2deg(bird.rotation) < -30:
			bird.rotation = deg2rad(-30)
			bird.angular_velocity = 0

		if bird.linear_velocity.y > 0:
			bird.angular_velocity = 1.5
		
	func unhandled_input(event):
		if event is InputEventKey:
			if event.pressed and event.scancode == KEY_SPACE:
				flap()
				return
		if event is InputEventMouseButton:
			if event.pressed and !event.is_echo() and event.button_index == BUTTON_LEFT:
				flap()
			
	
	func on_body_enter(other_body):
		if other_body.is_in_group(game.GROUP_PIPES):
			bird.set_state(bird.STATE_HIT)
		elif other_body.is_in_group(game.GROUP_GROUNDS):
			bird.set_state(bird.STATE_GROUNDED)
		pass
		
	func flap():
		bird.angular_velocity = -3
		bird.linear_velocity = Vector2(bird.linear_velocity.x, -150)
		bird.get_node("anim").play("flap")
		
		audio_player.stream = load("res://sounds/sfx_wing.wav")
		audio_player.play()
		
	func exit():
		pass

# class HitState ------------------------------------

class HitState:
	var bird
	
	func _init(bird):
		self.bird = bird
		bird.linear_velocity = Vector2(0, 0)
		bird.angular_velocity = 2
		
		var other_body = bird.get_colliding_bodies()[0]
		bird.add_collision_exception_with(other_body)
		
		audio_player.stream = load("res://sounds/sfx_hit.wav")
		audio_player.play()
		#audio_player.stream = load("res://sounds/sfx_die.wav")
		#audio_player.play()
		
	func update(delta):
		pass
		
	func on_body_enter(other_body):
		if other_body.is_in_group(game.GROUP_GROUNDS):
			bird.set_state(bird.STATE_GROUNDED)
		
	func exit():
		pass
		
# class GroundedState ------------------------------------

class GroundedState:
	var bird
	
	func _init(bird):
		self.bird = bird
		bird.linear_velocity = Vector2(0, 0)
		bird.angular_velocity = 0
		
		if bird.prev_state != bird.STATE_HIT:
			audio_player.stream = load("res://sounds/sfx_hit.wav")
			audio_player.play()
		
	func update(delta):
		pass

	func exit():
		pass