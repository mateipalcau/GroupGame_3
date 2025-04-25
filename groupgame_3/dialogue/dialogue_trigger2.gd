extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var dialogue_scene := preload("res://dialogue/dialogue_box.tscn")
@export var dialogue_text: String = "Hello from the area!"

func _on_body_entered(body):
	if body.is_in_group("Player"):
		var dialogue = get_parent().get_node("DialogueBox")
		dialogue.show_dialogue("AH.. you're finally here.. and with the artifact...hmmm..", body.global_position)
	
