extends Control

# check all this code : 

# Signals
signal resume_game
signal restart_level
signal go_to_menu

# References
@onready var resume_button = $PausePanel/VBoxContainer/ResumeButton
@onready var restart_button = $PausePanel/VBoxContainer/RestartButton
@onready var menu_button = $PausePanel/VBoxContainer/MenuButton
@onready var pause_label = $PausePanel/PauseLabel


func _ready():
	# Connect button signals
	resume_button.connect("pressed", Callable(self, "_on_resume_button_pressed"))
	restart_button.connect("pressed", Callable(self, "_on_restart_button_pressed"))
	menu_button.connect("pressed", Callable(self, "_on_menu_button_pressed"))
	
	# Set initial visibility
	visible = false
	
	# Pause the game when this menu is shown
	visibility_changed.connect(Callable(self, "_on_visibility_changed"))

func _on_resume_button_pressed():
	emit_signal("resume_game")

func _on_restart_button_pressed():
	emit_signal("restart_level")

func _on_menu_button_pressed():
	# Show confirmation dialog
	var dialog = ConfirmationDialog.new()
	dialog.title = "Return to Menu"
	dialog.dialog_text = "Are you sure you want to return to the main menu?\nYour progress in this level will be lost."
	dialog.get_ok_button().text = "Yes"
	dialog.get_cancel_button().text = "No"
	dialog.connect("confirmed", Callable(self, "_confirm_go_to_menu"))
	add_child(dialog)
	dialog.popup_centered()

func _confirm_go_to_menu():
	emit_signal("go_to_menu")

func _on_visibility_changed():
	if visible:
		# Center the pause panel
		var panel = $PausePanel
		panel.position = (get_viewport_rect().size - panel.size) / 2
		
		# Set focus to resume button
		resume_button.grab_focus()
