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
var is_attacking := false
var is_time_slowed := false
var slow_time_scale := 0.2
var normal_time_scale := 1.0


@onready var sprite = $SpriteOffset/AnimatedSprite2D
@onready var sprite_offset = $SpriteOffset
@onready var hitbox = $Area2D

func _ready():
	sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))
	sprite.play("Idle")

func _physics_process(delta: float) -> void:
	handle_time_slow()

	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	if is_dashing:
		handle_dash(delta)
	else:
		handle_movement(input_vector, delta)

	move_and_slide()
	update_animation(input_vector)

	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

func handle_time_slow():
	if Input.is_action_just_pressed("time_slow"):
		is_time_slowed = !is_time_slowed
		Engine.time_scale = slow_time_scale if is_time_slowed else normal_time_scale

func handle_movement(input_vector: Vector2, delta: float):
	velocity.x = input_vector.x * speed

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		jumps_left = max_jumps
		can_air_dash = true

	if Input.is_action_just_pressed("ui_up") and jumps_left > 0:
		velocity.y = jump_velocity
		jumps_left -= 1

	if Input.is_action_just_pressed("attack") and not is_attacking:
		start_attack()

	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0:
		var grounded = is_on_floor()
		if grounded or can_air_dash:
			if not grounded:
				can_air_dash = false

			dash_direction = Vector2(
				Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
				Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
			).normalized()

			if dash_direction == Vector2.ZERO:
				dash_direction = Vector2(sign(velocity.x), 0)

			is_dashing = true
			dash_time_left = dash_duration
			dash_cooldown_timer = dash_cooldown

func handle_dash(delta: float):
	velocity = dash_direction * dash_speed
	dash_time_left -= delta
	

	if dash_time_left <= 0:
		is_dashing = false




func update_animation(input_vector: Vector2):
	if is_attacking:
		return

	if abs(input_vector.x) > 0.1 and is_on_floor() and not is_dashing:
		play_animation("Walk")
	elif is_on_floor() and not is_dashing:
		play_animation("Idle")

	if input_vector.x != 0:
		sprite.flip_h = input_vector.x < 0

func play_animation(anim_name: String):
	sprite.play(anim_name)
	match anim_name:
		"Idle":
			sprite_offset.position = Vector2(0, 0)
		"Walk":
			sprite_offset.position = Vector2(-2, 11)
		"Attack":
			sprite_offset.position = Vector2(2, -2)
		"Die":
			sprite_offset.position = Vector2(0, -3)

func start_attack():
	if is_attacking:
		return

	is_attacking = true
	sprite.play("Attack")
	sprite_offset.position = Vector2(2, -2)
	hitbox.monitoring = true

	await get_tree().create_timer(0.2).timeout
	hitbox.monitoring = false

func _on_animation_finished():
	if sprite.animation == "Attack":
		is_attacking = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		body.take_damage(1)
