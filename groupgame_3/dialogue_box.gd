extends Control

var sentence = ""
var s_index = 0

func _ready():
	$Panel.visible = false  # Hide by default

func show_dialogue(new_sentence: String ,player_position: Vector2):
	sentence = new_sentence
	s_index = 0
	$Panel/RichTextLabel.clear()
	$Panel.visible = true
	
	global_position = player_position + Vector2(50, -100)
	
	$Timer.start()

func _on_timer_timeout() -> void:
	if s_index < sentence.length():
		$Panel/RichTextLabel.append_text(sentence[s_index])
		s_index += 1
	else:
		$Timer.stop()
		
