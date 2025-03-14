extends Node2D

@export var dart_scene: PackedScene  # Assign the dart scene in the Inspector
@export var fire_interval: float = 0.5  # Time between shots
@export var dart_speed: float = 3000  # Speed of the dart
@export var detection_range: float = 10000  # Max range to check for the player

@onready var raycast: RayCast2D = $RayCast2D
@onready var shoot_timer: Timer = $Timer
@onready var spawn_marker: Marker2D = $Marker2D

var can_shoot : bool = true 

func _ready():
	shoot_timer.wait_time = fire_interval

func _process(delta):
	look_at(get_global_mouse_position())
	check_for_player()

func check_for_player():
	# Cast a ray in the shooter's facing direction
	raycast.target_position = Vector2(detection_range, 0)  # Shoots horizontally
	raycast.force_raycast_update()  # Update the raycast check
	
	if raycast.is_colliding():
		#print("ray is colliding ")
		var target = raycast.get_collider()
		
		if target and target.is_in_group("player"):  # Ensure it only triggers on the player
			if can_shoot : 
				shoot_dart()
				shoot_timer.start()
				can_shoot = false

func shoot_dart():
	# Make sure the raycast is updated
	raycast.force_raycast_update()
	
	if not raycast.is_colliding():
		return  # No target in line of sight
	
	var target = raycast.get_collider()
	var dart = dart_scene.instantiate()
	get_parent().add_child(dart)
	dart.global_position = spawn_marker.global_position

		# Corrected direction: Get unit vector from shooter to player
	var direction =  (target.global_position - global_position).normalized()

		# Apply velocity in that direction
	dart.linear_velocity = direction * dart_speed

func _on_timer_timeout() -> void:
	can_shoot = true
