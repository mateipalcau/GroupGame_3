extends CharacterBody2D

@export var speed := 500.0

@export var jump_velocity := -600.0
@export var gravity := 1200.0
@export var max_jumps := 2
@export var dash_speed := 1000.0
@export var dash_duration := 0.2
@export var dash_cooldown := 0.5
var flySpeed = 800.0
var is_flying = false 


var can_air_dash := true
var jumps_left := max_jumps
var is_dashing := false
var dash_time_left := 0.0
var dash_cooldown_timer := 0.0
var dash_direction := Vector2.ZERO

@onready var sprite = $SpriteOffset/AnimatedSprite2D
@onready var sprite_offset = $SpriteOffset

var controls_reversed := false
var flickering := false
@onready var reverse_timer: Timer = $ReverseTimer


@onready var freeze_timer: Timer = $FreezeTimer
var is_freezing = false


@onready var health_bar: ProgressBar = $HealthBar
var bullet_path = preload("res://bullet_player.tscn")
var is_attacking = false
@onready var stop_timer: Timer = $StopTimer
var ok = 1
var can_shoot = true


func reverse_controls(duration: float) -> void:
	if controls_reversed:
		return  

	controls_reversed = true
	flickering = true
	start_flicker()
	reverse_timer.start(duration)
	print("Controls reversed for", duration, "seconds")
	
func _on_reverse_timer_timeout():
	controls_reversed = false
	flickering = false
	sprite.modulate = Color.WHITE
	print("Controls back to normal.")
	
func start_flicker():
	flicker_loop()

func flicker_loop():
	await get_tree().process_frame

	while flickering:
		sprite.modulate = Color.PURPLE
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color.WHITE
		await get_tree().create_timer(0.1).timeout
		
		
func freeze_all_enemies():
	var enemies = get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		enemy.freeze()
	stop_timer.start()
	ok=0
		
func unfreeze_all_enemies():
	var enemies = get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		enemy.unfreeze()		

func _process(delta):
	
	if Input.is_action_just_pressed("stop") and not is_freezing and ok==1:  
		freeze_all_enemies()
		freeze_timer.start()
		is_freezing = true
		
	if Input.is_action_just_pressed("full"):
		health = max_health
		health_bar.value = health
	
	
	
	if Input.is_action_just_pressed("fly"):
		
		is_flying = !is_flying
		velocity = Vector2.ZERO 
		
		 
@export var max_health: int = 100
var health: int = max_health

func _ready() -> void:
	health_bar.value = health


func take_damage(amount: int) -> void:
	flicker_on_hit()
	health -= amount
	health_bar.value = health
	

	if health <= 0:
		die()

		
func die():
	print("Player died!")
	play_die()
	await get_tree().create_timer(1.0).timeout  
	get_tree().reload_current_scene() 
	
	
func flicker_on_hit():
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE
	
func fire():
	if is_attacking:
		return

	can_shoot = false  

	is_attacking = true
	sprite.play("Attack")
	$AudioStreamPlayer2D.play()
	var bullet = bullet_path.instantiate()
	bullet.position = $Node2D.global_position
	bullet.rotation = 0

	if not $SpriteOffset/AnimatedSprite2D.flip_h:
		bullet.position = $Node2D.global_position
		bullet.set_direction(Vector2.RIGHT)
	else:
		bullet.position = $Node2D2.global_position
		bullet.set_direction(Vector2.LEFT)

	get_parent().add_child(bullet)

	await get_tree().create_timer(0.3).timeout
	sprite.play("Idle")
	is_attacking = false

	await get_tree().create_timer(0.3).timeout  
	can_shoot = true


func _physics_process(delta: float) -> void:
	
	
	if Input.is_action_just_pressed("shoot") and can_shoot:
		fire()
	
	
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if controls_reversed:
		input_vector.x *= -1  
	
	if is_flying: 
		print("fly cheat code activated!!")
		fly_movement()
	else:
	
		if not is_dashing:
			
			velocity.x = input_vector.x * speed

			
			if not is_on_floor():
				velocity.y += gravity * delta
			else:
				
				jumps_left = max_jumps
				can_air_dash = true

			
			if Input.is_action_just_pressed("ui_up") and jumps_left > 0:
				velocity.y = jump_velocity
				jumps_left -= 1

			
			if Input.is_action_just_pressed("ui_accept"):
				play_attack()
				
				

		
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

		else:
			
			velocity = dash_direction * dash_speed
			dash_time_left -= delta
			if dash_time_left <= 0:
				is_dashing = false

		
		if dash_cooldown_timer > 0:
			dash_cooldown_timer -= delta

		move_and_slide()
		update_animation(input_vector)
		

func play_idle():
	sprite.play("Idle")
	sprite_offset.position = Vector2(0, 0) 

func play_walk():
	sprite.play("Walk")
	sprite_offset.position = Vector2(-2, 11) 

func play_die():
	sprite.play("Die")
	sprite_offset.position = Vector2(0, -3) 

func play_attack():
	if is_attacking:
		return  

	is_attacking = true
	$AttackArea.monitoring = true  
	sprite.play("Attack")
	$AudioStreamPlayer2D2.play()

	await get_tree().create_timer(0.3).timeout  
	$AttackArea.monitoring = false  
	sprite.play("Idle")
	is_attacking = false


func update_animation(input_vector: Vector2):
	if is_attacking:
		return 

	if abs(input_vector.x) > 0.1 and is_on_floor() and not is_dashing:
		play_walk()
	elif is_on_floor() and not is_dashing:
		play_idle()

	if input_vector.x != 0:
		sprite.flip_h = input_vector.x < 0

func fly_movement():
	var input_vector = Vector2(
	Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
	Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")).normalized()
	velocity = input_vector * flySpeed
	move_and_slide()

	
func _on_freeze_timer_timeout() -> void:
	unfreeze_all_enemies()
	is_freezing = false


func _on_stop_timer_timeout() -> void:
	ok=1


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemies"):
		if body.has_method("take_damage"):
			body.take_damage(20)
