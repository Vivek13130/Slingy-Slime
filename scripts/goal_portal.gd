extends Area2D

# Signal to indicate level completion
signal level_completed

# References
@onready var particles = $CPUParticles2D

func _process(delta: float) -> void:
	rotation += 0.5 
	if(rotation > 360) : 
		rotation = 0

func _on_body_entered(body):
	if body.is_in_group("player"):
		complete_level(body)

func complete_level(player):
	# Emit completion signal
	emit_signal("level_completed")
	print("level completed")
