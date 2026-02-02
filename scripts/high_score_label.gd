extends Label

func _process(delta: float) -> void:
	text = "High Score: " + str(GameManager.highScore)
