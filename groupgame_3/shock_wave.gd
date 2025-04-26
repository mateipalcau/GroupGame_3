extends Node2D

@export var damage: int = 15
@export var expand_speed: float = 2.5
@export var max_scale: float = 3.0
@onready var area = $Area2D
@onready var collision_shape = $Area2D/CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	scale = Vector2.ONE
	animated_sprite.play("default")
	$Timer.start()

func _process(delta):
	if scale.x < max_scale:
		scale += Vector2.ONE * expand_speed * delta




func _on_timer_timeout() -> void:
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("take_damage"):
		body.take_damage(damage)
