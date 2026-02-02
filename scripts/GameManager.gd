extends Node

var score: int = 0
var highScore: int = 0

# The path where we will store the file on the player's computer
const SAVE_PATH = "user://savegame.save"

func _ready():
	# When the game starts, try to load the old high score
	load_game()

func add_score():
	score += 1
	
	# Check if we beat the high score
	if score > highScore:
		highScore = score
		save_game() # Save immediately when we get a new record!

func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	# We store the data in a simple dictionary
	var data = {
		"highScore": highScore
	}
	# Convert the dictionary to JSON text and write it
	file.store_line(JSON.stringify(data))

func load_game():
	# 1. Check if a save file even exists
	if not FileAccess.file_exists(SAVE_PATH):
		return # No save file found, just keep highScore at 0

	# 2. Open the file
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	
	# 3. Read the text
	while file.get_position() < file.get_length():
		var json_string = file.get_line()
		var json = JSON.new()
		
		# 4. Parse the text back into data
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var data = json.get_data()
			# 5. Load the high score
			highScore = data["highScore"]
