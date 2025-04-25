extends CharacterBody2D

@export var speed: float = 100.0
@export var move_distance: float = 200.0
@export var shoot_cooldown: float = 4.0
var bullet_scene = preload("res://enemy/bullet_flying_enemy.tscn")

var direction: int = 1
var start_position: Vector2
var can_shoot: bool = true
var player: Node2D = null

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shoot_timer: Timer = $Timer
@onready var shooting_point: Node2D = $ShootingPoint
@onready var detection_area: Area2D = $Area2D  

func _ready():
	start_position = global_position
	sprite.play("fly")
	shoot_timer.wait_time = shoot_cooldown
	shoot_timer.one_shot = true
	detection_area.body_entered.connect(_on_area_2d_body_entered)
	detection_area.body_exited.connect(_on_area_2d_body_exited)

func _physics_process(delta):
	patrol(delta)
	if player and can_shoot:
		shoot_at_player()

func patrol(delta):
	var target_x = start_position.x + (move_distance * direction)
	var move_vector = Vector2.RIGHT * direction * speed * delta
	position += move_vector

	if direction == 1 and global_position.x >= target_x:
		direction = -1
		sprite.flip_h = true
	elif direction == -1 and global_position.x <= start_position.x - move_distance:
		direction = 1
		sprite.flip_h = false

func shoot_at_player():
	can_shoot = false
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = shooting_point.global_position

	if bullet.has_method("set_direction"):
		var dir = (player.global_position - global_position).normalized()
		bullet.set_direction(dir)

	shoot_timer.start()

func _on_timer_timeout():
	can_shoot = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): 
		player = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
