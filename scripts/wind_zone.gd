extends Area2D

# Wind properties
@export var force_strength: float = 1000.0
@export var direction: Vector2 = Vector2(0, -1)  # Default vertical wind

# Visual properties
@export var particle_amount: int = 50
@export var particle_speed: float = 100.0

# References
@onready var particles = $CPUParticles2D
@onready var collision_shape = $CollisionShape2D

func _ready():
	
	# Normalize direction
	direction = direction.normalized()
	
	# Setup particles
	setup_particles()

func setup_particles():
	# Configure particle system to match wind direction
	particles.direction = Vector2(direction.x, direction.y)
	particles.amount = particle_amount
	particles.lifetime = collision_shape.shape.size.x / particle_speed
	particles.speed_scale = particle_speed / 100.0
	particles.local_coords = false
	#particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_BOX
	particles.emission_rect_extents = Vector2(collision_shape.shape.size.x / 2, collision_shape.shape.size.y / 2)
	
	# Start particles
	particles.emitting = true

func _on_body_entered(body):
	# Apply wind force to player when they enter
	if body.is_in_group("player") and body is RigidBody2D:
		# Start applying continuous force
		_apply_wind_force(body)

func _on_body_exited(body):
	# Stop applying wind force
	if body.is_in_group("player"):
		pass  # Force will stop being applied naturally

func _physics_process(delta):
	# Apply force to all bodies in the wind zone
	for body in get_overlapping_bodies():
		if body.is_in_group("player") and body is RigidBody2D:
			_apply_wind_force(body)

func _apply_wind_force(body):
	if not body.freeze:
		body.apply_central_force(direction * force_strength )
