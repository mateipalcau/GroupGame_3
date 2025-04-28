extends Node2D
#var level2Portal = preload("res://level2.tscn")



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#func _spawn_level2() -> void:
	#	var level2 = level2Portal.instantiate()
	#	level2.position.y = $Hero.position.y
	#	level2.position.x = $Hero.position.x + 400
	#	PlayerVariables.is_level2 = true
	#	get_tree().current_scene.add_child(level2)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		get_tree().change_scene_to_file("res://bossRoom/boss_room.tscn")


func _on_next_level_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		get_tree().change_scene_to_file("res://bossRoom/boss_room.tscn")
