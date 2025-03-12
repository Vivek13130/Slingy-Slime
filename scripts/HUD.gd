extends CanvasLayer

# References
@onready var level_label = $MarginContainer/HBoxContainer/LevelLabel
@onready var slings_label = $MarginContainer/HBoxContainer/SlingsLabel
@onready var orbs_label = $MarginContainer/HBoxContainer/OrbsLabel
@onready var message_label = $CenterContainer/MessageLabel
@onready var message_timer = $MessageTimer

# Level info
var level_number: int = 1
var slings_used: int = 0
var orbs_collected: int = 0
var total_orbs_in_level: int = 0  # This would be set by the level

func _ready():
	# Initialize labels
	level_label.text = "Level: 1"
	slings_label.text = "Slings: 0"
	orbs_label.text = "Orbs: 0/0"
	
	# Hide message initially
	message_label.visible = false
	
	# Connect message timer
	message_timer.connect("timeout", Callable(self, "_on_message_timer_timeout"))

func set_level_number(number: int):
	level_number = number
	level_label.text = "Level: " + str(number)
	
	# Reset counters
	slings_used = 0
	orbs_collected = 0
	slings_label.text = "Slings: 0"
	
	# Count orbs in level to update the counter
	# This would need to be implemented based on the level's structure
	# For now, we'll just use a placeholder
	total_orbs_in_level = 3  # Placeholder
	orbs_label.text = "Orbs: 0/" + str(total_orbs_in_level)

func update_slings(count: int):
	slings_used = count
	slings_label.text = "Slings: " + str(count)

func update_orbs_collected(count: int):
	orbs_collected += count
	orbs_label.text = "Orbs: " + str(orbs_collected) + "/" + str(total_orbs_in_level)
	
	# Show message
	show_message("Orb Collected!", 1.0)

func show_message(text: String, duration: float = 2.0):
	message_label.text = text
	message_label.visible = true
	
	# Setup and start fade animation
	var tween = create_tween()
	message_label.modulate = Color(1, 1, 1, 0)
	tween.tween_property(message_label, "modulate", Color(1, 1, 1, 1), 0.3)
	
	# Set timer for message duration
	message_timer.wait_time = duration
	message_timer.start()

func _on_message_timer_timeout():
	# Fade out message
	var tween = create_tween()
	tween.tween_property(message_label, "modulate", Color(1, 1, 1, 0), 0.3)
	tween.tween_callback(Callable(self, "_hide_message"))

func _hide_message():
	message_label.visible = false

func show_death_message():
	show_message("Oops! Try again!", 1.5)

func show_level_complete(slings_used: int):
	# Calculate stars based on slings used
	# This would need proper thresholds per level in a full implementation
	var star_count = 3
	if slings_used > 5:
		star_count = 2
	if slings_used > 10:
		star_count = 1
	
	var stars = "d"
	for i in range(star_count):
		stars += "★"
	for i in range(3 - star_count):
		stars += "☆"
	
	show_message("Level Complete!\nSlings: " + str(slings_used) + "\n" + stars, 2.0)
