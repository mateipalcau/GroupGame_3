extends Node2D

@onready var path_follow = $Path2D/PathFollow2D
@onready var sprite = $Path2D/PathFollow2D/CharacterBody2D/AnimatedSprite2D
@export var speed: int = 2
@export var health: int = 40
@export var atk_cd_time: int
var atk_cd: bool = false


func _ready() -> void:
	$AtkCD.wait_time = atk_cd_time
	sprite.play("walk")
	sprite.flip_v = false
	
func _process(delta: float) -> void:
	if health <= 0:
		queue_free()
	if path_follow.progress_ratio > 0.5:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
	path_follow.progress += speed
	if atk_cd:
		$Path2D/PathFollow2D/CharacterBody2D/CollisionShape2D.disabled = true



func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not atk_cd:
		if body.has_method("take_damage"):
			body.take_damage(10)
		atk_cd = true
		$AtkCD.start()
	


func _on_atk_cd_timeout() -> void:
	atk_cd = false
