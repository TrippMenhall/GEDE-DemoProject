extends Control

const SAVE_PATH = "user://savegame.save"

@onready var confirmation_dialog: ConfirmationDialog = $ConfirmationDialog

func _ready():
	confirmation_dialog.confirmed.connect(_on_reset_confirmed)

func _on_reset_score_button_pressed():
	confirmation_dialog.popup_centered()

func _on_reset_confirmed():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data = {
		"highScore": 0 
	}
	file.store_line(JSON.stringify(data))
	
	GameManager.highScore = 0

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
