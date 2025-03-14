extends RigidBody2D

@export var damage: int = 10  # Damage to player

var stuck: bool = false  # Track if the dart is stuck
var direction: Vector2


func _on_body_entered(body):
	if stuck:
		return  # Don't process further if already stuck

	if body.is_in_group("player"):
		body.take_damage(damage)  # Call the player's damage function
		# Dart continues moving through the player

	elif body.is_in_group("platform"):
		stick_to_surface(body)

func stick_to_surface(body):
	if stuck:
		return

	print("stuck")
	stuck = true

	# Stop movement
	linear_velocity = Vector2.ZERO
	angular_velocity = 0

	# Disable physics
	freeze = true
	#mode = RigidBody2D.MODE_STATIC  # Make it completely static

	# Attach dart to the platform
	reparent(body, true)  # Move under the platform while keeping global position
