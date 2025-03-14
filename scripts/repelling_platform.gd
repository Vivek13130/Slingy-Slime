extends StaticBody2D


#func _on_body_entered(body):
	#if body is RigidBody2D:
		#var velocity = body.linear_velocity  # Get player's velocity
		#var normal = (body.global_position - global_position).normalized()  # Normal direction from platform
		#var reflected_velocity = velocity.bounce(normal)  # Reflect the velocity
#
		#body.linear_velocity = (-1) * reflected_velocity.normalized() * repel_force  # Apply new velocity
