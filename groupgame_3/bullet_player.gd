extends RigidBody2D

@export var speed: float = 250 
var direction: Vector2 = Vector2.RIGHT  

func _ready():
	gravity_scale = 0 
	linear_velocity = direction * speed  

func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()
	linear_velocity = direction * speed  # Apply velocity immediately


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and body.is_in_group("Enemies"):
		body.take_damage(10) 
		queue_free()
		
	if not body.is_in_group("Player"):
		queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
