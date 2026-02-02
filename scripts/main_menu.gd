extends Control

@onready var highScore_label: Label = $MarginContainer/VBoxContainer/Scores/HighScoreLabel

func _ready():
	update_display()

func update_display():
	if visible:
		highScore_label.text = "High Score: " + str(GameManager.highScore)

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_options_button_pressed():
	# TODO: Replace with options menu
	print("Options pressed")
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
