extends CharacterBody2D

const SPEED = 100.0
const ACCELERATION = 1000.0
const AIR_ACCELERATION = 400.0
const FRICTION = 1000.0
const AIR_FRICTION = 200.0
const JUMP_VELOCITY = -250.0
const GRAVITY_SCALE = 0.8
@onready var start_pos = position
var gravity = ProjectSettings.get_setting ("physics/2d/default_gravity")
var jumpsMidAir = 1

func _physics_process(delta):
	apply_gravity(delta)
	var input = Input.get_axis("left", "right")
	handle_jump(input) 
	handle_acceleration(input, delta)
	apply_friction(input, delta)
	update_animations(input)
	move_and_slide()
	check_collisions()

func apply_gravity(delta):
	if not is_on_floor() and not is_on_wall() and velocity.y < 1000:
		velocity.y += gravity * GRAVITY_SCALE * delta
	elif not is_on_floor() and is_on_wall() and velocity.y < 1000:
		if velocity.y < 400:
			velocity.y += gravity * GRAVITY_SCALE * 0.8 * delta
		else:
			velocity.y = 400

func handle_jump(input):
	var wall_normal = get_wall_normal()
	if is_on_floor():
		jumpsMidAir = 1
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
	elif is_on_wall():
		jumpsMidAir = 1
		if Input.is_action_just_pressed("left") and wall_normal == Vector2.LEFT:
			velocity.x = wall_normal.x * SPEED
			velocity.y = JUMP_VELOCITY
		if Input.is_action_just_pressed("right") and wall_normal == Vector2.RIGHT:
			velocity.x = wall_normal.x * SPEED
			velocity.y = JUMP_VELOCITY 
	else:
		if Input.is_action_just_pressed("jump") and jumpsMidAir > 0:
			velocity.y = JUMP_VELOCITY
			jumpsMidAir -= 1

func handle_acceleration(input, delta):
	if input:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, SPEED * input, ACCELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, SPEED * input, AIR_ACCELERATION * delta)

func apply_friction(input, delta):
	if not input:
		if is_on_floor():
			velocity.x = move_toward(SPEED * input, 0, FRICTION * delta)
		else:
			velocity.x = move_toward(SPEED * input, 0, AIR_FRICTION * delta)

func update_animations(input):
	if input < 0:
		$AnimatedSprite2D.flip_h = true
	elif input > 0:
		$AnimatedSprite2D.flip_h = false
	if not is_on_floor():
		$AnimatedSprite2D.play("new_animation")
	elif input:
		$AnimatedSprite2D.play("default")
	
	else:
		$AnimatedSprite2D.play("new_animation_1")

signal gameOver
func check_collisions():
	for i in get_slide_collision_count():
		if get_slide_collision(i).get_collider().name == "spikes":
			position = start_pos
			emit_signal("gameOver")
