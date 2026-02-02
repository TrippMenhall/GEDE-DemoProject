extends Control

@onready var score_label: Label = $MarginContainer/VBoxContainer/Scores/ScoreLabel
@onready var highScore_label: Label = $MarginContainer/VBoxContainer/Scores/HighScoreLabel
@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel

func _ready():
	visibility_changed.connect(update_display)

func update_display():
	if visible:
		score_label.text = "Score: " + str(GameManager.score)
		highScore_label.text = "High Score: " + str(GameManager.highScore)

func _on_restart_button_pressed():
	GameManager.score = 0
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed():
	GameManager.score = 0
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
