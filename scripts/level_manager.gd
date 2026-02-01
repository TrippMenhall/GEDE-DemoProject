extends Node2D

@export var chunk_scenes: Array[PackedScene]
@export var player: Node2D

var active_chunks: Array = []
var spawn_threshold: float = 1000.0
var delete_threshold: float = 2000.0

func _ready():
	spawn_chunk(Vector2(0, 0))

func _process(_delta):
	if not player:
		return
		
	var last_chunk = active_chunks.back()
	var last_chunk_end_global = last_chunk.get_node("EndPoint").global_position
	
	if last_chunk_end_global.distance_to(player.global_position) < spawn_threshold:
		spawn_chunk(last_chunk_end_global)
		
	var first_chunk = active_chunks.front()
	var first_chunk_end_global = first_chunk.get_node("EndPoint").global_position
	
	if player.global_position.distance_to(first_chunk_end_global) > delete_threshold:
		if player.global_position.x > first_chunk_end_global.x:
			delete_oldest_chunk()

func spawn_chunk(connection_position: Vector2):
	var random_scene = chunk_scenes.pick_random()
	var new_chunk = random_scene.instantiate()
	
	add_child(new_chunk)
	
	var start_node_pos = new_chunk.get_node("StartPoint").position
	
	new_chunk.global_position = connection_position - start_node_pos
	
	active_chunks.append(new_chunk)

func delete_oldest_chunk():
	var old_chunk = active_chunks.pop_front()
	old_chunk.queue_free()
