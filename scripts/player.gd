extends CharacterBody2D

const JUMP_VELOCITY = -400.0
const JUMP_FORWARD_BOOST = 0.0
const SLOPE_SPEED_BOOST = 50.0
const FLAT_FRICTION = 500.0

var is_dead: bool = false

@export var laser_scene: PackedScene
@onready var eye_position: Marker2D = $EyePosition
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d_normal: CollisionShape2D = $"CollisionShape2D-normal"
@onready var collision_shape_2d_jump: CollisionShape2D = $"CollisionShape2D-jump"
@onready var collision_shape_2d_sliding: CollisionShape2D = $"CollisionShape2D-sliding"

func _ready() -> void:
	floor_max_angle = deg_to_rad(80.0)
	floor_stop_on_slope = false
	floor_snap_length = 32.0 

func die() -> void:
	if is_dead:
		return
		
	is_dead = true
	
	animated_sprite.play("roll")
	velocity = Vector2(0, 0)
	
	$"CollisionShape2D-jump".queue_free()
	$"CollisionShape2D-sliding".queue_free()
	$"CollisionShape2D-normal".queue_free()

	Engine.time_scale = 0.5 
	
	await get_tree().create_timer(1.0).timeout
	
	Engine.time_scale = 1.0
	
	GameManager.score = 0
	get_tree().reload_current_scene()

func shoot_laser():
	if not laser_scene || is_dead || not is_on_floor(): 
		return
		
	var laser = laser_scene.instantiate()
	var start_point = eye_position.global_position
	var end_point = get_global_mouse_position()
	
	laser.global_position = start_point
	laser.set_target(start_point, end_point)
	
	get_tree().root.add_child(laser)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("mouse_click"):
		shoot_laser()
	
	if is_dead:
		velocity.y = 50.0  
		velocity.x = 0
		move_and_slide()
		return

	velocity += get_gravity() * delta

	if is_on_floor():
		var floor_normal = get_floor_normal()
		
		if abs(floor_normal.x) > 0.1: 
			velocity.x += floor_normal.x * SLOPE_SPEED_BOOST * delta
		else:
			velocity.x = move_toward(velocity.x, 0, FLAT_FRICTION * delta)

		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
			
			if velocity.x >= 0:
				velocity.x += JUMP_FORWARD_BOOST
			else:
				velocity.x -= JUMP_FORWARD_BOOST
				
			floor_snap_length = 0.0

	else:
		floor_snap_length = 32.0
		
		if Input.is_action_just_released("jump") and velocity.y < 0:
			
			velocity.y *= 0.1

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
