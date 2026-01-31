extends Node2D

# Assign your chunk scenes in the Inspector
@export var chunk_scenes: Array[PackedScene]
@export var player: Node2D

# Configuration
var active_chunks: Array = []
var spawn_threshold: float = 1000.0 # How far ahead to look?
var delete_threshold: float = 2000.0 # How far behind before deleting?

func _ready():
	# Spawn the very first chunk manually to start the chain
	spawn_chunk(Vector2(0, 0))

func _process(_delta):
	if not player:
		return
		
	# 1. Check if we need to spawn a new chunk
	# We look at the LAST chunk in the list to see where it ends
	var last_chunk = active_chunks.back()
	var last_chunk_end_global = last_chunk.get_node("EndPoint").global_position
	
	# If the end of the slide is getting close to the player, add more
	if last_chunk_end_global.distance_to(player.global_position) < spawn_threshold:
		spawn_chunk(last_chunk_end_global)
		
	# 2. Check if we need to delete old chunks
	# We look at the FIRST chunk in the list (the oldest one)
	var first_chunk = active_chunks.front()
	var first_chunk_end_global = first_chunk.get_node("EndPoint").global_position
	
	# If the player has passed the chunk by a large margin
	if player.global_position.distance_to(first_chunk_end_global) > delete_threshold:
		# Important: Only delete if it's behind the player (checking X axis mostly)
		if player.global_position.x > first_chunk_end_global.x:
			delete_oldest_chunk()

func spawn_chunk(connection_position: Vector2):
	# Pick a random scene
	var random_scene = chunk_scenes.pick_random()
	var new_chunk = random_scene.instantiate()
	
	add_child(new_chunk)
	
	# --- ALIGNMENT LOGIC ---
	# We need to offset the new chunk so its StartPoint matches the connection_position.
	# 1. Get the local position of the StartPoint inside the new chunk
	var start_node_pos = new_chunk.get_node("StartPoint").position
	
	# 2. Subtract that local position from the desired global position
	new_chunk.global_position = connection_position - start_node_pos
	
	active_chunks.append(new_chunk)

func delete_oldest_chunk():
	var old_chunk = active_chunks.pop_front()
	old_chunk.queue_free()
