extends CharacterBody2D

@onready var timer: Timer = $Timer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_timer: Timer = $JumpTimer
@onready var death_timer: Timer = $DeathTimer
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer

@export var damage: int = 20
@onready var label: Label = $Label

var projectile = preload("res://bullet_boss.tscn")
var gravity = ProjectSettings.get("physics/2d/default_gravity")

@export var speed: float = 125.0  
@export var jump_force: float = -650.0  
var direction: int = 1  


@onready var ray_cast_2d_down_right: RayCast2D = $"RayCast2DDown-Right"
@onready var ray_cast_2d_down_left: RayCast2D = $"RayCast2DDown-Left"

@export var attack_range = 50  
@export var attack_damage = 10  
@export var attack_cooldown = 1.5  


@onready var teleport_timer: Timer = $TeleportTimer
@onready var area_2d: Area2D = $Area2D

@onready var reverse_timer_effect: Timer = $ReverseTimerEffect

var shockwave_scene = preload("res://shock_wave.tscn")
var was_in_air := false

var player = null
var can_attack = true

var is_frozen: bool = false
var freeze_shooting: bool = false

var directions = [Vector2.LEFT]
@export var health: int = 50  

var teleport_points = [
	Vector2(2250, -450),
	Vector2(2250, -200),
	Vector2(1500, -250),
	Vector2(1500, -625),
	
]

func freeze():
	is_frozen = true
	animated_sprite_2d.pause()

func unfreeze():
	is_frozen = false
	animated_sprite_2d.play("idle")

func enemy():
	pass

func take_damage(damage):
	if health>0:
		teleport_randomly()
		teleport_timer.start()
	animated_sprite_2d.play("hurt")
	health -= damage
	print("enemy hit")
	if health <= 0:
		die()


func die(): 
	animated_sprite_2d.play("death")
	death_timer.start()
	get_tree().change_scene_to_file("res://victory screen.tscn")
	

func _ready():
	timer.start()  
	animated_sprite_2d.play("idle")  
	
	jump_timer.start()  
	direction = randi() % 2 * 2 - 1  
	
	teleport_timer.start()

func _on_timer_timeout(): 
	if is_frozen:
		return  
	animated_sprite_2d.play("shoot")  
	shoot()  
	
	await get_tree().create_timer(0.3).timeout  
	animated_sprite_2d.play("idle")

func shoot():
	if direction > 0: 
		spawn_projectile($ShootingPointRight.global_position, Vector2(1, -1))   
		#spawn_projectile($ShootingPointRight2.global_position, Vector2(1, -1))     
		spawn_projectile($ShootingPointRight3.global_position, Vector2(1, -1)) 
		#spawn_projectile($ShootingPointRight4.global_position, Vector2(1, -1))      
		spawn_projectile($ShootingPointRight5.global_position, Vector2(1, -1))     
		#spawn_projectile($ShootingPointRight6.global_position, Vector2(1, -1))   
	elif direction < 0:  
		spawn_projectile($ShootingPointLeft.global_position, Vector2(-1, -1))
		#spawn_projectile($ShootingPointLeft2.global_position, Vector2(-1, -1))    
		spawn_projectile($ShootingPointLeft3.global_position, Vector2(-1, -1)) 
		#spawn_projectile($ShootingPointLeft4.global_position, Vector2(-1, -1))    
		#spawn_projectile($ShootingPointLeft5.global_position, Vector2(-1, -1))    
		spawn_projectile($ShootingPointLeft6.global_position, Vector2(-1, -1))  
		#more projectile can be added here
		#the direction and speed of projectiles can be changed in bullet_boss scene 
		
func spawn_projectile(position: Vector2, direction: Vector2):
	var instance = projectile.instantiate()
	instance.position = position
	get_parent().add_child(instance)  

	if instance.has_method("set_direction"):  
		instance.set_direction(direction) 

func _physics_process(delta: float) -> void:
	if is_frozen:
		return  
	
	if animated_sprite_2d.animation != "attack" and animated_sprite_2d.animation != "death" and animated_sprite_2d.animation != "hurt":  
		animated_sprite_2d.play("move")
		
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if (direction > 0 and (not ray_cast_2d_down_right.is_colliding())) or (direction < 0 and (not ray_cast_2d_down_left.is_colliding())):
		direction *= -1 

	velocity.x = direction * speed  

	animated_sprite_2d.flip_h = direction < 0

	if animated_sprite_2d.animation != "attack" and animated_sprite_2d.animation != "death" and animated_sprite_2d.animation != "hurt": 
		if not is_on_floor():
			animated_sprite_2d.play("jump")
		elif velocity.x != 0:
			animated_sprite_2d.play("move")
		else:
			animated_sprite_2d.play("idle")
		
	if player:
		var distance = global_position.distance_to(player.global_position)
		if distance <= attack_range:
			attack_player()

	move_and_slide()
	
	var on_ground = is_on_floor()
	
	
	if not was_in_air and not on_ground:
		was_in_air = true  
		

		
func spawn_shockwave():
	var shockwave = shockwave_scene.instantiate()
	shockwave.global_position = global_position
	get_parent().add_child(shockwave)
	
func attack_player():
	if can_attack:
		can_attack = false
		print("Enemy attacks the player!")
		player.hit(damage)
		animated_sprite_2d.play("attack")
		await get_tree().create_timer(1.5).timeout
		attack_cooldown_timer.start()
		
func _on_attack_cooldown_timer_timeout() -> void:
	can_attack = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		
func _on_jump_timer_timeout() -> void:
		velocity.y = jump_force  
		jump_timer.start(randf_range(4.0, 7.0)) 
		direction = randi() % 2 * 2 - 1     

func _on_teleport_timer_timeout() -> void:
	if is_frozen:
		return
	teleport_randomly()
	
func teleport_randomly():
	var random_index = randi() % teleport_points.size()  
	position = teleport_points[random_index]  
	await get_tree().create_timer(0.2).timeout
	spawn_shockwave()

func _on_death_timer_timeout() -> void:
	queue_free()
	#this needs to be changed to move to the ending scene after the boss dies


func _on_reverse_timer_effect_timeout() -> void:
	if player and player.is_inside_tree() and player.has_method("reverse_controls"):
		player.reverse_controls(7.0)
