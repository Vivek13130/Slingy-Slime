extends StaticBody2D

@export var damage : int = 10

func _on_damage_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(damage)
