extends Control

func _on_startbutton_pressed() -> void:
	get_tree().change_scene_to_file("res://map/cave/caveMap.tscn")

func _on_options_pressed() -> void:
	pass # Add options logic here

func _on_exit_pressed() -> void:
	get_tree().quit()
