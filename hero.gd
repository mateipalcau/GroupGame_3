extends CharacterBody2D

@export var speed := 500.0
@export var jump_velocity := -600.0
@export var gravity := 1200.0
@export var max_jumps := 2
@export var dash_speed := 1000.0
@export var dash_duration := 0.2
@export var dash_cooldown := 0.5

var can_air_dash := true
var jumps_left := max_jumps
var is_dashing := false
var dash_time_left := 0.0
var dash_cooldown_timer := 0.0
var dash_direction := Vector2.ZERO

@onready var sprite = $SpriteOffset/AnimatedSprite2D
@onready var sprite_offset = $SpriteOffset

func _physics_process(delta: float) -> void:
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	if not is_dashing:
		# Normal movement
		velocity.x = input_vector.x * speed

		# Apply gravity
		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			# Reset jumps when grounded
			jumps_left = max_jumps
			can_air_dash = true

		# Jumping
		if Input.is_action_just_pressed("ui_up") and jumps_left > 0:
			velocity.y = jump_velocity
			jumps_left -= 1

		# Attack
		if Input.is_action_just_pressed("ui_accept"):
			play_attack()

		# Dashing
		if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0:
			var grounded = is_on_floor()
			if grounded or can_air_dash:
				if not grounded:
					can_air_dash = false # consume air dash

				dash_direction = Vector2(
					Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
					Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
				).normalized()

				if dash_direction == Vector2.ZERO:
					dash_direction = Vector2(sign(velocity.x), 0)

				is_dashing = true
				dash_time_left = dash_duration
				dash_cooldown_timer = dash_cooldown

	else:
		# Apply dash movement
		velocity = dash_direction * dash_speed
		dash_time_left -= delta
		if dash_time_left <= 0:
			is_dashing = false

	# Update cooldown timer
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	move_and_slide()
	update_animation(input_vector)

func play_idle():
	sprite.play("Idle")
	sprite_offset.position = Vector2(0, 0) # offset for idle

func play_walk():
	sprite.play("Walk")
	sprite_offset.position = Vector2(-2, 11) # offset for walk

func play_die():
	sprite.play("Die")
	sprite_offset.position = Vector2(0, -3) # offset for die

func play_attack():
	sprite.play("Attack")
	sprite_offset.position = Vector2(2, -2) # offset for attack

func update_animation(input_vector: Vector2):
	if abs(input_vector.x) > 0.1 and is_on_floor() and not is_dashing:
		play_walk()
	elif is_on_floor() and not is_dashing:
		play_idle()

	if input_vector.x != 0:
		sprite.flip_h = input_vector.x < 0
