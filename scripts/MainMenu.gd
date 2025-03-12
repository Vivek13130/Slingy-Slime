extends Control

# Signals
signal start_game
signal level_select
signal settings
signal quit_game

# References to UI elements
@onready var start_button = $VBoxContainer/StartButton
@onready var level_select_button = $VBoxContainer/LevelSelectButton
@onready var settings_button = $VBoxContainer/SettingsButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var title_label = $TitleLabel
@onready var version_label = $VersionLabel

# Audio
@onready var audio_player = $AudioStreamPlayer
var button_sound = AudioStreamWAV.new()

func _ready():
	# Connect button signals
	start_button.connect("pressed", Callable(self, "_on_start_button_pressed"))
	level_select_button.connect("pressed", Callable(self, "_on_level_select_button_pressed"))
	settings_button.connect("pressed", Callable(self, "_on_settings_button_pressed"))
	quit_button.connect("pressed", Callable(self, "_on_quit_button_pressed"))
	
	# Load save data to determine if level select should be enabled
	Global.load_game()
	level_select_button.disabled = Global.max_unlocked_level <= 1
	
	# Set version info
	version_label.text = "v1.0.0"
	
	# Set title animation
	var tween = create_tween()
	tween.tween_property(title_label, "scale", Vector2(1.05, 1.05), 1.0)
	tween.tween_property(title_label, "scale", Vector2(1.0, 1.0), 1.0)
	tween.set_loops()

func _on_start_button_pressed():
	play_button_sound()
	
	# If player has progress, ask if they want to continue or start new game
	if Global.max_unlocked_level > 1:
		show_continue_dialog()
	else:
		start_new_game()

func _on_level_select_button_pressed():
	play_button_sound()
	get_tree().change_scene_to_file("res://scenes/UI/LevelSelect.tscn")

func _on_settings_button_pressed():
	play_button_sound()
	# For now, just show a simple settings dialog
	var dialog = ConfirmationDialog.new()
	dialog.title = "Settings"
	dialog.dialog_text = "Settings would go here in a full implementation."
	dialog.add_button("Close", true, "close")
	add_child(dialog)
	dialog.popup_centered()

func _on_quit_button_pressed():
	play_button_sound()
	# Save game before quitting
	Global.save_game()
	get_tree().quit()

func show_continue_dialog():
	var dialog = ConfirmationDialog.new()
	dialog.title = "Continue?"
	dialog.dialog_text = "Do you want to continue from level " + str(Global.max_unlocked_level) + " or start a new game?"
	dialog.add_button("New Game", true, "new_game")
	dialog.add_button("Continue", false, "continue")
	dialog.connect("confirmed", Callable(self, "start_new_game"))
	dialog.connect("custom_action", Callable(self, "_on_continue_dialog_action"))
	add_child(dialog)
	dialog.popup_centered()

func _on_continue_dialog_action(action):
	if action == "continue":
		continue_game()
	elif action == "new_game":
		start_new_game()

func start_new_game():
	# Reset progress and start from level 1
	Global.current_level = 1
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func continue_game():
	# Continue from the last unlocked level
	Global.current_level = Global.max_unlocked_level
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func play_button_sound():
	audio_player.stream = button_sound
	audio_player.volume_db = linear_to_db(Global.sfx_volume)
	audio_player.play()
