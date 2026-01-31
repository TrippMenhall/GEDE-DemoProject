extends CharacterBody2D

const JUMP_VELOCITY = -130.0 # Increased slightly for better feel
const JUMP_FORWARD_BOOST = 20.0 # The "force" only applied when jumping

# CONTROL HOW FAST SLOPES ARE
# Increase this to make sliding down ramps much faster
const SLOPE_SPEED_BOOST = 50.0 

# CONTROL FLAT GROUND FRICTION
# A small amount of friction prevents sliding forever on flat ground
const FLAT_FRICTION = 500.0

var is_dead: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# Allow steep slopes (80 degrees)
	floor_max_angle = deg_to_rad(80.0)
	
	# Allow physics to slide us down naturally
	floor_stop_on_slope = false
	
	# Snap to floor so we don't fly off bumps
	floor_snap_length = 32.0 

func die() -> void:
	is_dead = true
	animated_sprite.play("roll")
	$CollisionShape2D.queue_free()

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity.y = 50.0  
		velocity.x = 0
		move_and_slide()
		return

	# 1. APPLY GRAVITY
	velocity += get_gravity() * delta

	# 2. HANDLE SLOPE PHYSICS
	if is_on_floor():
		var floor_normal = get_floor_normal()
		
		# If we are on a slope (normal.x is not 0), push the player down it.
		# This makes sliding much faster than gravity alone.
		if abs(floor_normal.x) > 0.1: # 0.1 ignores tiny bumps
			velocity.x += floor_normal.x * SLOPE_SPEED_BOOST * delta
		else:
			# If we are on flat ground, apply friction to slowly stop
			velocity.x = move_toward(velocity.x, 0, FLAT_FRICTION * delta)

		# Handle Jump
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
			
			# Add forward momentum to the jump
			if velocity.x >= 0:
				velocity.x += JUMP_FORWARD_BOOST
			else:
				velocity.x -= JUMP_FORWARD_BOOST
				
			# Turn off snapping so we can detach
			floor_snap_length = 0.0
	else:
		# Reset snapping when in air
		floor_snap_length = 32.0

	# 3. ANIMATION & FLIPPING
	if is_on_floor():
		if abs(velocity.x) > 10:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("idle")
	else:
		animated_sprite.play("jump")

	# FORCE FLIP BASED ON MOVEMENT DIRECTION
	# If sliding left (negative speed), face left.
	# If sliding right (positive speed), face right.
	if velocity.x > 1.0: # Using 1.0 prevents flickering at 0 speed
		animated_sprite.flip_h = false
	elif velocity.x < -1.0:
		animated_sprite.flip_h = true

	move_and_slide()
	
