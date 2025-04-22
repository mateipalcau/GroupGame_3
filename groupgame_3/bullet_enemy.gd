extends CharacterBody2D

@export var speed: float = 300
var direction = Vector2.RIGHT  
@export var damage: int = 10

func _physics_process(delta):
	velocity = direction * speed
	move_and_slide()


func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): 
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
