extends CharacterBody2D

const JUMP_VELOCITY = -400.0 # Initial upward burst
const JUMP_FORWARD_BOOST = 0.0 # Force added when jumping
const SLOPE_SPEED_BOOST = 50.0 # Physics acceleration on slopes
const FLAT_FRICTION = 500.0 # Friction on flat ground

var is_dead: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d_normal: CollisionShape2D = $"CollisionShape2D-normal"
@onready var collision_shape_2d_jump: CollisionShape2D = $"CollisionShape2D-jump"
@onready var collision_shape_2d_sliding: CollisionShape2D = $"CollisionShape2D-sliding"

func _ready() -> void:
	floor_max_angle = deg_to_rad(80.0)
	floor_stop_on_slope = false
	floor_snap_length = 32.0 

func die() -> void:
	is_dead = true
	animated_sprite.play("roll")
	$"CollisionShape2D-jump".queue_free()
	$"CollisionShape2D-sliding".queue_free()
	$"CollisionShape2D-normal".queue_free()

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity.y = 50.0  
		velocity.x = 0
		move_and_slide()
		return

	# 1. APPLY GRAVITY
	velocity += get_gravity() * delta

	# 2. HANDLE INPUT & PHYSICS
	if is_on_floor():
		var floor_normal = get_floor_normal()
		
		# Slope Physics
		if abs(floor_normal.x) > 0.1: 
			velocity.x += floor_normal.x * SLOPE_SPEED_BOOST * delta
		else:
			velocity.x = move_toward(velocity.x, 0, FLAT_FRICTION * delta)

		# START JUMP
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
			
			if velocity.x >= 0:
				velocity.x += JUMP_FORWARD_BOOST
			else:
				velocity.x -= JUMP_FORWARD_BOOST
				
			floor_snap_length = 0.0 # Detach from floor
			
	else:
		# Reset snapping when in air
		floor_snap_length = 32.0
		
		# --- HEAVY JUMP CUTOFF ---
		# Check if player let go AND is currently moving UP
		if Input.is_action_just_released("jump") and velocity.y < 0:
			
			# Smoother but still heavy:
			velocity.y *= 0.1 # Kill 90% of momentum
			
	# 3. ANIMATION & FLIPPING
	if is_on_floor():
		if abs(velocity.x) > 0:
			animated_sprite.play("slide")
			collision_shape_2d_sliding.disabled = false
			collision_shape_2d_jump.disabled = true
			collision_shape_2d_normal.disabled = true
		else:
			animated_sprite.play("idle")
			collision_shape_2d_sliding.disabled = true
			collision_shape_2d_jump.disabled = true
			collision_shape_2d_normal.disabled = false
	else:
		animated_sprite.play("jump")
		collision_shape_2d_sliding.disabled = true
		collision_shape_2d_jump.disabled = false
		collision_shape_2d_normal.disabled = true
		

	if velocity.x > 1.0: 
		animated_sprite.flip_h = false
	elif velocity.x < -1.0:
		animated_sprite.flip_h = true

	move_and_slide()
