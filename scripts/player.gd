extends RigidBody2D

# -- Exported variables --
@export var sling_force_multiplier: float = 1250.0
@export var max_drag_distance: float = 100.0
@export var aiming_line_width: float = 5.0
@export var max_sling_length: float = 200.0
@export var min_unstick_distance: float = 50.0

# -- State Tracking --
var is_stuck: bool = false      # Is the slime sticking to a node?
var can_sling: bool = true
var is_aiming: bool = false
var stuck_to: PhysicsBody2D = null   # The node to which slime is stuck
var sling_count: int = 0
var starting_position: Vector2
var drag_start: Vector2
var drag_current: Vector2

# -- Node References --
@onready var sprite: Sprite2D = $Sprite2D
@onready var camera: Camera2D = $Camera
@onready var sling_line: Line2D = $sling_line
@onready var collision_shape: CollisionShape2D = $ElementDetector/CollisionShape2D

func _ready():
	set_physics_process(true)
	starting_position = global_position
	sling_line.visible = false

func _process(delta: float) -> void:
	# Update slime visuals (squash & stretch)
	#update_slime_visuals()
	# Update aiming line while dragging
	if is_aiming:
		update_sling_line()

func _physics_process(delta):
	# If stuck, reposition the player to "stick" to the surface.
	if is_stuck and stuck_to:
		# Assumes collision_shape uses a circular shape.
		global_position = stuck_to.global_position + (global_position - stuck_to.global_position).normalized() * collision_shape.shape.radius

func _input(event):
	# Handle restart and pause input first.
	if event.is_action_pressed("restart"):
		reset_player()
		return
	if event.is_action_pressed("pause"):
		Global.toggle_pause()
		return

	# Handle mouse events for aiming and releasing the sling.
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_aiming(event.position)
			elif not event.pressed and is_aiming:
				release_sling()
	elif event is InputEventMouseMotion and is_aiming:
		drag_current = get_global_mouse_position()

func start_aiming(position):
	is_aiming = true
	drag_start = get_global_mouse_position()
	drag_current = drag_start
	sling_line.visible = true

func release_sling():
	if not is_aiming:
		return
	
	is_aiming = false
	sling_line.visible = false
	
	# --- Unstick Logic ---
	if is_stuck:
		var drag_distance = (drag_start - drag_current).length()
		# If drag is strong enough, break the stuck state.
		if drag_distance > min_unstick_distance:
			is_stuck = false
			stuck_to = null
			freeze = false  # Unfreeze physics so the body can move
		else:
			# Not enough force to unstick; remain stuck.
			return
	
	# Set some angular randomness.
	angular_velocity = randi_range(0, 20)
	
	# Determine launch direction and strength.
	var direction = (drag_start - drag_current).normalized()
	var strength = min((drag_start - drag_current).length(), max_sling_length) / max_sling_length
	
	# Only launch if shot is strong enough.
	if strength > 0.1:
		var force = direction * strength * sling_force_multiplier
		freeze = false  # Ensure physics is active.
		apply_central_impulse(force)
		sling_count += 1
		Global.total_slings += 1

func reset_player():
	# Reset position and physics state.
	global_position = starting_position
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	
	# Reset state variables.
	is_stuck = false
	can_sling = true
	is_aiming = false
	sling_count = 0
	freeze = false
	
	# Reset visuals.
	sling_line.visible = false
	sprite.scale = Vector2.ONE
	
	# Reset camera smoothing.
	camera.reset_smoothing()

func update_sling_line():
	# Calculate aiming line end based on drag direction and maximum allowed length.
	var direction = (drag_start - drag_current).normalized()
	var length = min((drag_start - drag_current).length(), max_sling_length)
	var end_pos = global_position + direction * length
	
	# Draw the line (using local coordinates).
	sling_line.clear_points()
	sling_line.add_point(Vector2.ZERO)
	sling_line.add_point(to_local(end_pos))
	
	# Adjust the line color based on the sling power.
	var power_ratio = length / max_sling_length
	sling_line.default_color = Color(1.0, 1.0 - power_ratio, 0.0, 1.0)
	sling_line.width = aiming_line_width

func update_slime_visuals() -> void:
	# Apply squash and stretch effect based on velocity.
	if not is_stuck and not freeze:
		var speed = linear_velocity.length()
		var max_deform = 0.5
		var deform_ratio = min(speed / 1000.0, max_deform)
		var direction = linear_velocity.normalized()
		# Calculate stretch along movement direction.
		var scale_x = 1.0 - deform_ratio * abs(direction.x)
		var scale_y = 1.0 - deform_ratio * abs(direction.y)
		scale_x = max(scale_x, 0.5)
		scale_y = max(scale_y, 0.5)
		# Apply squash in perpendicular direction.
		var squash_x = 1.0 + deform_ratio * abs(direction.y)
		var squash_y = 1.0 + deform_ratio * abs(direction.x)
		sprite.scale = Vector2(scale_x * squash_x, scale_y * squash_y)
	else:
		sprite.scale = Vector2.ONE

# -- Collision Handling from the Element Detector --
func _on_element_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("sticky") and not is_stuck:
		stick_to(body)
	elif body.is_in_group("non_sticky"):
		# Bounce off non-sticky surfaces if needed.
		pass
	elif body.is_in_group("hazard"):
		die()
	elif body.is_in_group("collectible"):
		collect(body)
	elif body.is_in_group("goal"):
		complete_level()

func take_damage(damage : int) -> void : 
	#print("damage taken : ", damage)
	pass

func stick_to(body):
	is_stuck = true
	stuck_to = body
	#freeze = true
	# Optionally, play stick sound/animation.

func die():
	can_sling = false
	freeze = true
	lock_rotation = true
	# Optionally, play death animation/sound.
	await get_tree().create_timer(1.0).timeout
	reset_player()

func collect(collectible):
	print("Element collected, signal not connected.")
	# Add collectible logic here.

func complete_level():
	can_sling = false
	# Optionally, play celebratory animation.
