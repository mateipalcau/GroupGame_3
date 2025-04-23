extends Area2D

@export var speed: float = 300.0
var direction = Vector2.ZERO

func set_direction(dir: Vector2):
	direction = dir.normalized()

func _physics_process(delta):
	position += direction * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("Player"): 
		if body.has_method("take_damage"):
			body.take_damage(10)
		queue_free()
		print("hit")
