extends RigidBody2D

@export var sling_force_multiplier: float = 1250.0
@export var max_drag_distance: float = 100.0
@export var aiming_line_width: float = 5.0

# State tracking
var is_stuck: bool = false # If slime is sticking to a node 
var can_sling: bool = true
var is_aiming: bool = false
var stuck_to: PhysicsBody2D = null # the node to which slime is sticked
var sling_count: int = 0
var starting_position: Vector2
var drag_start: Vector2
var drag_current: Vector2
var dragging : bool = false 

var max_sling_length : float = 200

# Reference to scenes
@onready var sprite: Sprite2D = $Sprite2D
@onready var camera: Camera2D = $Camera
@onready var sling_line: Line2D = $sling_line
@onready var collision_shape: CollisionShape2D = $ElementDetector/CollisionShape2D


func _ready():
	set_physics_process(true)
	starting_position = global_position
	# Make sure sling line is not visible initially
	sling_line.visible = false

func _process(delta: float) -> void:
	#update_slime_visuals() # Setting various scale at x and y axis 

	# Show sling line when aiming
	if is_aiming:
		update_sling_line()


func _physics_process(delta):
	# Update the stuck state
	if is_stuck and stuck_to:
		# Make sure we stay attached to the surface we're stuck to
		global_position = stuck_to.global_position + (global_position - stuck_to.global_position).normalized() * collision_shape.shape.radius



func _input(event):
	#if not can_sling or Global.is_paused:
		#return
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed :
				# Start aiming
				start_aiming(event.position)
			elif not event.pressed and is_aiming:
				# Release the sling
				release_sling()

	elif event is InputEventMouseMotion and is_aiming:
		# Update drag position for aiming
		drag_current = get_global_mouse_position()
		
	# Handle restart input
	if event.is_action_pressed("restart"):
		reset_player()
		
	# Handle pause input
	if event.is_action_pressed("pause"):
		Global.toggle_pause()



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
	
	angular_velocity = randi_range(0, 20)
	
	var direction = (drag_start - drag_current).normalized()
	var strength = min((drag_start - drag_current).length(), max_sling_length) / max_sling_length

	if strength > 0.1:  # Prevent weak shots
		var force = direction * strength * sling_force_multiplier
		
		freeze = false  # Enable physics before applying force
		apply_central_impulse(force)

		sling_count += 1
		Global.total_slings += 1
		#emit_signal("sling_used")

func reset_player():
	# Reset position and physics state
	global_position = starting_position
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	
	# Reset state variables
	is_stuck = false  # Start stuck to initial platform
	can_sling = true
	is_aiming = false
	sling_count = 0
	freeze = false
	
	# Reset visuals
	sling_line.visible = false
	
	# Reset camera
	camera.reset_smoothing()

func update_sling_line(): # draw the line and adjust the color based on stretch 
	var start_pos = global_position
	var direction = (drag_start - drag_current).normalized()
	var length = min((drag_start - drag_current).length(), max_sling_length)
	var end_pos = global_position + direction * length
	
	# Update the line
	sling_line.clear_points()
	sling_line.add_point(Vector2.ZERO)  # local coordinates - damn this bug is insane
	sling_line.add_point(to_local(end_pos))
	
	# Adjust line color based on sling power
	var power_ratio = length / max_sling_length
	sling_line.default_color = Color(1.0, 1.0 - power_ratio, 0.0, 1.0)
	sling_line.width = aiming_line_width


func update_slime_visuals() -> void : 
	# Apply squash and stretch based on velocity
	if not is_stuck and not freeze:
		var speed = linear_velocity.length()
		var max_deform = 0.5
		var deform_ratio = min(speed / 1000.0, max_deform)
		
		# Get velocity direction
		var direction = linear_velocity.normalized()
		
		# Apply stretch along velocity direction
		var scale_x = 1.0 - deform_ratio * abs(direction.x)
		var scale_y = 1.0 - deform_ratio * abs(direction.y)
		
		# Prevent zero scale
		scale_x = max(scale_x, 0.5)
		scale_y = max(scale_y, 0.5)
		
		# Apply squash in perpendicular direction
		var squash_x = 1.0 + deform_ratio * abs(direction.y)
		var squash_y = 1.0 + deform_ratio * abs(direction.x)
		
		# Set the sprite scale
		sprite.scale = Vector2(scale_x * squash_x, scale_y * squash_y)
	else:
		# Reset scale when stuck
		sprite.scale = Vector2(1, 1)


#func complete_level():
	## This function will be called  by the level manager
	#can_sling = false
	#
	## Celebratory animation
	#animation_player.play("celebrate")


func _on_element_detector_body_entered(body: Node2D) -> void:
	# this will handle detecting various bodies interaction with player
	
	print(" a body entered now")
	
	if body.is_in_group("sticky") and not is_stuck:
		stick_to(body)
	elif body.is_in_group("non_sticky"):
		# Bounce off non-sticky surfaces
		#play_sound(bounce_sound)
		pass
	elif body.is_in_group("hazard"):
		die()
	elif body.is_in_group("collectible"):
		collect(body)
	elif body.is_in_group("goal"):
		complete_level()


func stick_to(body):
	is_stuck = true
	stuck_to = body
	freeze = true
	#play_sound(stick_sound)
	
	# Play stick animation
	#animation_player.play("stick")

func die():
	# Disable physics and controls
	can_sling = false
	freeze = true
	lock_rotation = true
	
	# Play death animation and sound
	#animation_player.play("death")
	#play_sound(death_sound)
	
	# Signal that player died
	#emit_signal("player_died")
	
	# Reset after a short delay
	await get_tree().create_timer(1.0).timeout
	reset_player()


func collect(collectible):
	print("element collected , signal not connected")
	# check commented code -----------------------
	#if collectible.has_method("collect"):
		#var orb_id = collectible.collect()
		#emit_signal("orb_collected", orb_id)
		#play_sound(collect_sound)

func complete_level():
	# This will be handled by the level manager
	can_sling = false
	
	# Celebratory animation
	#animation_player.play("celebrate")
