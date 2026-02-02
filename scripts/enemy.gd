extends CharacterBody2D

const GRAVITY = 980.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	move_and_slide()

func die():
	GameManager.add_score()
	queue_free()
