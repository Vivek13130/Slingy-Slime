extends Node

# Game progression tracking
var current_level: int = 1
var max_unlocked_level: int = 1
var total_levels: int = 3  # Increase this as more levels are added
var collected_orbs: Array = []  # Store IDs of collected orbs
var total_slings: int = 0  # Track total slings used

# Game state
var is_paused: bool = false

# Settings
var sfx_volume: float = 1.0
var music_volume: float = 0.8

# groups : sticky, non-sticky, hazard, collectible, goal, player


# Save and load game progress
func save_game() -> void:
	var save_data = {
		"max_unlocked_level": max_unlocked_level,
		"collected_orbs": collected_orbs,
		"total_slings": total_slings,
		"sfx_volume": sfx_volume,
		"music_volume": music_volume
	}
	
	var save_file = FileAccess.open("user://slimysave.dat", FileAccess.WRITE)
	if save_file:
		save_file.store_var(save_data)
		save_file.close()


func load_game() -> bool:
	if not FileAccess.file_exists("user://slimysave.dat"):
		return false
		
	var saved_file = FileAccess.open("user://slimysave.dat", FileAccess.READ)
	if saved_file:
		var saved_data = saved_file.get_var()
		saved_file.close()
		
		if saved_data != null:
			max_unlocked_level = saved_data.get("max_unlocked_level", 1)
			collected_orbs = saved_data.get("collected_orbs", [])
			total_slings = saved_data.get("total_slings", 0)
			
			var color_data = saved_data.get("slime_color", null)
				
			sfx_volume = saved_data.get("sfx_volume", 1.0)
			music_volume = saved_data.get("music_volume", 0.8)
			
			return true
	
	return false


# Helper function to get the path for a specific level
func get_level_path(level_number: int) -> String:
	return "res://scenes/levels/Level" + str(level_number) + ".tscn"


# Called when a level is completed
func level_completed(level_number: int) -> void:
	if level_number >= max_unlocked_level and level_number < total_levels:
		max_unlocked_level = level_number + 1
		save_game()

# Called when a goo orb is collected
func collect_orb(orb_id: String) -> void:
	if not collected_orbs.has(orb_id):
		collected_orbs.append(orb_id)
		save_game()

# Handle pause state
func toggle_pause() -> void:
	is_paused = !is_paused
	get_tree().paused = is_paused

# Reset level progress (for debugging or player choice)
func reset_progress() -> void:
	# add a warning for this -----------------
	max_unlocked_level = 1
	collected_orbs = []
	total_slings = 0
	save_game()
