extends AnimatableBody2D

# Movement properties
@export var move_speed: float = 100.0
@export var move_distance: float = 200.0
@export var wait_time: float = 1.0
@export var is_vertical: bool = true
@export var is_sticky: bool = false

# State tracking
var start_position: Vector2
var target_position: Vector2
var is_moving_to_target: bool = true
var is_waiting: bool = false

func _ready():
	# Add to appropriate group based on stickiness
	if is_sticky:
		add_to_group("sticky")
	else:
		add_to_group("non_sticky")
	
	# Save start position
	start_position = global_position
	
	# Set initial target
	if is_vertical:
		target_position = start_position + Vector2(0, move_distance)
	else:
		target_position = start_position + Vector2(move_distance, 0)

func _physics_process(delta):
	if is_waiting:
		return
		
	# Calculate movement
	var direction = (target_position - global_position).normalized()
	var velocity = direction * move_speed * delta
	
	# Check if we've reached the target
	if global_position.distance_to(target_position) < velocity.length():
		global_position = target_position
		is_waiting = true
		
		# Wait before moving to the next point
		await get_tree().create_timer(wait_time).timeout
		is_waiting = false
		
		# Swap target
		if is_moving_to_target:
			target_position = start_position
		else:
			target_position = start_position + (Vector2(0, move_distance) if is_vertical else Vector2(move_distance, 0))
			
		is_moving_to_target = !is_moving_to_target
	else:
		# Move platform
		global_position += velocity
