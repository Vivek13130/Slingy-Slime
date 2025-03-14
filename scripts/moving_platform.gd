extends Path2D

@export var loop : bool = false 
@export var lock_platform_rotation : bool = true
@export var is_sticky: bool = false
@export var open_path_speed : float = 1
@export var loop_speed : float = 10 

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var path_follow_2d: PathFollow2D = $PathFollow2D
 
func _ready() -> void:
	if is_sticky:
		add_to_group("sticky")
	else:
		add_to_group("non_sticky")
	
	if(!loop):
		animation_player.play("move_platform")
		animation_player.speed_scale = open_path_speed

func _process(_delta: float) -> void:
	if(loop):
		path_follow_2d.progress += loop_speed
		
