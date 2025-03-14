extends StaticBody2D

@export var is_sticky : bool = false

func _ready() -> void:
	if is_sticky:
		add_to_group("sticky")
		$Sprite2D.modulate = Color(0,0,1)
	else:
		add_to_group("non_sticky")
