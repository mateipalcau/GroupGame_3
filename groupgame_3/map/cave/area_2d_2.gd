extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var dialogue_scene := preload("res://dialogue/dialogue_box.tscn")

func _on_body_entered(body):
	if body.is_in_group("Player"):
		var dialogue = get_parent().get_node("DialogueBox")
		dialogue.show_dialogue(" Agh!! Where am I.. I can't seem to leave. What should I do? Should I run? Fight, maybe? I don`t know... I`m so scared!" , body.global_position)
	
