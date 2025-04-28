extends TileMap


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	$AudioStreamPlayer2D.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://bossRoom/boss_room.tscn")


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_kill_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		get_tree().change_scene_to_file("res://map/cave/caveMap.tscn")
