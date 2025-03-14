extends StaticBody2D

# implement sticking to this 
# also it will turn green when you stick to it
# when all orbs turn green , then the portal will open 

var is_grabbed : bool = false 

func orb_grabbed():
	if(!is_grabbed):
		is_grabbed = true
		$Sprite2D.modulate = Color(0,0,0,1)
		LevelManager.grabbed_orbs += 1
