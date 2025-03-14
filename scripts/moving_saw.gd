extends Path2D

@export var loop : bool = false 
@export var open_path_speed : float = 1
@export var loop_speed : float = 10 

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var path_follow_2d: PathFollow2D = $PathFollow2D
@onready var saw: AnimatableBody2D = $saw
 
func _ready() -> void:
	if(!loop):
		animation_player.play("move_saw")
		print("playing move saw")
		animation_player.speed_scale = open_path_speed

func _process(_delta: float) -> void:
	if(loop):
		path_follow_2d.progress += loop_speed
	
