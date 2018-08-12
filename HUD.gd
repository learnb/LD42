extends Node

func _ready():
	$Message.hide()

func update_score(score):
	$Score.text = str(score)

func update_zone(text):
	$Zone.text = text

func show_message(text):
	$Message.show()
	$Message.text = text
	$MessageTimer.start()
	yield($MessageTimer, "timeout")
	$Message.hide()
	$Message.text = ""

func resize_space(height):
	$AnimationPlayer/Space.margin_bottom = height
	#$Space.margin_bottom = height