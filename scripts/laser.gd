extends Area2D

enum State { EXPANDING, RETRACTING }
var current_state = State.EXPANDING

var speed: float = 5000.0

var start_point: Vector2
var end_point: Vector2
var direction: Vector2
var total_distance: float

var head_dist: float = 0.0
var tail_dist: float = 0.0

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

func set_target(origin: Vector2, target: Vector2):
	start_point = origin
	end_point = target
	
	direction = (end_point - start_point).normalized()
	total_distance = start_point.distance_to(end_point)
	
	rotation = direction.angle()

func _physics_process(delta: float):
	match current_state:
		State.EXPANDING:
			head_dist += speed * delta
			
			if head_dist >= total_distance:
				head_dist = total_distance
				current_state = State.RETRACTING
				
		State.RETRACTING:
			tail_dist += speed * delta
			
			if tail_dist >= total_distance:
				queue_free()

	update_beam_visuals()

func update_beam_visuals():
	var current_length = max(0.0, head_dist - tail_dist)
	
	global_position = start_point + (direction * tail_dist)
	
	if sprite.texture:
		sprite.scale.x = current_length / sprite.texture.get_width()
	
	if collision_shape.shape is RectangleShape2D:
		collision_shape.shape.size.x = current_length
		collision_shape.position.x = current_length / 2.0

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player": return
	if body.has_method("die"):
		body.die()
