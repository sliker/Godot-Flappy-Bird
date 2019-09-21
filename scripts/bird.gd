# script: bird

extends RigidBody2D

func _ready():
	linear_velocity = Vector2(50, linear_velocity.y)
	
func _physics_process(delta):
	if rad2deg(rotation) < -30:
		rotation = deg2rad(-30)
		angular_velocity = 0

	if linear_velocity.y > 0:
		angular_velocity = 1.5

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_SPACE:
			flap()
			
func flap():
	angular_velocity = -3
	linear_velocity = Vector2(linear_velocity.x, -150)