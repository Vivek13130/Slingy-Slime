extends AnimatableBody2D

@export var saw_damage : int = 20
@onready var saw: Node2D = $saw_shape

func _on_damage_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(saw_damage)


func _process(delta: float) -> void:
	saw.rotation += 0.25 
	if(saw.rotation > 360):
		saw.rotation = 0
