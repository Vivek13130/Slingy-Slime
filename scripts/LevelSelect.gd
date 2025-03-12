extends Control

# References
@onready var level_grid = $ScrollContainer/LevelGrid
@onready var back_button = $BackButton
@onready var title_label = $TitleLabel

# Audio
@onready var audio_player = $AudioStreamPlayer
var button_sound = AudioStreamWAV.new()

# Level button template
var level_button_scene = preload("res://scenes/LevelButton.tscn")

func _ready():
	# Connect back button
	back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))
	
	# Load game data
	Global.load_game()
	
	# Populate level grid
	populate_level_grid()

func populate_level_grid():
	# Clear existing children
	for child in level_grid.get_children():
		child.queue_free()
	
	# Create level buttons
	for i in range(1, Global.total_levels + 1):
		var button = level_button_scene.instantiate()
		level_grid.add_child(button)
		
		# Set button properties
		button.text = str(i)
		button.disabled = i > Global.max_unlocked_level
		
		# Connect button signal
		button.connect("pressed", Callable(self, "_on_level_button_pressed").bind(i))
		
		# Add visual indicator if level is complete (all orbs collected)
		# This would require tracking per-level orb collection in a full implementation
		if i < Global.max_unlocked_level:
			# Add a small checkmark or star to indicate completion
			var complete_icon = TextureRect.new()
			complete_icon.texture = preload("res://assets/ui/checkmark.svg")
			complete_icon.size = Vector2(16, 16)
			complete_icon.position = Vector2(button.size.x - 20, 5)
			button.add_child(complete_icon)

func _on_level_button_pressed(level_number):
	play_button_sound()
	Global.current_level = level_number
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_back_button_pressed():
	play_button_sound()
	get_tree().change_scene_to_file("res://scenes/UI/MainMenu.tscn")

func play_button_sound():
	audio_player.stream = button_sound
	audio_player.volume_db = linear_to_db(Global.sfx_volume)
	audio_player.play()
