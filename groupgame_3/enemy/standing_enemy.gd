extends CharacterBody2D

@onready var timer: Timer = $Timer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_timer: Timer = $JumpTimer
@onready var label: Label = $Label
@onready var shooting_point = $ShootingPoint
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

@export var damage: int = 20

var projectile = preload("res://enemy/bullet_enemy.tscn")
var gravity = ProjectSettings.get("physics/2d/default_gravity")

var health: int = 50  
var player: Node2D = null
var directions = [Vector2.LEFT] 

# === NEW: Freezing variables ===
var is_frozen: bool = false
var freeze_shooting: bool = false

func _ready():
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]
	
	shoot_randomly()
	animated_sprite_2d.play("idle")

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		die()

func die():
	queue_free()

func shoot_randomly() -> void:
	while health > 0:
		var wait_time = randf_range(0.75, 1.5) 
		await get_tree().create_timer(wait_time).timeout
		
		if is_frozen:
			continue  # Don't shoot if frozen

		if not visible_on_screen_notifier_2d.is_on_screen():
			continue  

		update_direction()

		animated_sprite_2d.play("shoot")
		shoot()
		await get_tree().create_timer(0.3).timeout
		animated_sprite_2d.play("idle")

func update_direction():
	if not player:
		return

	var to_player = player.global_position - global_position
	if abs(to_player.x) > abs(to_player.y): 
		if to_player.x > 0:
			directions = [Vector2.RIGHT]
			animated_sprite_2d.flip_h = false
		else:
			directions = [Vector2.LEFT]
			animated_sprite_2d.flip_h = true

func shoot():
	if is_frozen:
		return  # Don't shoot if frozen

	for direction in directions:
		var instance = projectile.instantiate()
		instance.global_position = shooting_point.global_position
		get_parent().add_child(instance)

		if instance.has_method("set_direction"):
			instance.set_direction(direction)

func _physics_process(delta: float) -> void:
	if is_frozen:
		return  # Stop physics movement when frozen

	if animated_sprite_2d.animation != "shoot":
		animated_sprite_2d.play("idle")

	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()

func _on_jump_timer_timeout() -> void:
	if not is_frozen:
		velocity.y = -500

# === NEW: Freeze and Unfreeze functions ===
func freeze():
	is_frozen = true
	animated_sprite_2d.pause()

func unfreeze():
	is_frozen = false
	animated_sprite_2d.play("idle")
